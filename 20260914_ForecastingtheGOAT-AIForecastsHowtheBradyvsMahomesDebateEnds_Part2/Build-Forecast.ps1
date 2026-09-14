[CmdletBinding()]
param([switch]$ValidateOnly)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest
$inputPath = Join-Path $PSScriptRoot 'Data/ForecastData.json'
$outputPath = Join-Path $PSScriptRoot 'Data/ForecastResults.json'
$data = Get-Content -LiteralPath $inputPath -Raw -Encoding UTF8 | ConvertFrom-Json
$culture = [Globalization.CultureInfo]::InvariantCulture

function Assert-True([bool]$Condition, [string]$Message) {
    if (-not $Condition) { throw $Message }
}
function Round-To([double]$Value, [double]$Unit = 1) {
    return [Math]::Round($Value / $Unit, 0, [MidpointRounding]::AwayFromZero) * $Unit
}
function Show-Number([double]$Value, [double]$Unit = 1) {
    if ($Unit -lt 1) { return $Value.ToString('0.0', $culture) }
    return $Value.ToString('#,0', $culture)
}
function Dot-Probability($Weights, $Conditional) {
    Assert-True ($Weights.Count -eq 4 -and $Conditional.Count -eq 4) 'Expected four scenario probabilities.'
    $sum = 0.0
    $probability = 0.0
    for ($i = 0; $i -lt 4; $i++) {
        Assert-True ($Weights[$i] -ge 0 -and $Weights[$i] -le 1) 'Weight outside [0,1].'
        Assert-True ($Conditional[$i] -ge 0 -and $Conditional[$i] -le 1) 'Conditional probability outside [0,1].'
        $sum += $Weights[$i]
        $probability += $Weights[$i] * $Conditional[$i]
    }
    Assert-True ([Math]::Abs($sum - 1) -lt 0.0000001) 'Scenario weights must sum to 1.'
    return $probability
}
$sourceIds = @($data.sources | ForEach-Object { $_.id })
foreach ($source in $data.sources) {
    Assert-True ($source.url -match '^https://') "Missing source URL: $($source.id)"
    if ($source.published) {
        Assert-True ([datetime]$source.published -le [datetime]$data.cutoff.date) "Source after cutoff: $($source.id)"
    }
    if ($source.PSObject.Properties.Name -contains 'updated') {
        Assert-True ([datetime]$source.updated -le [datetime]$data.cutoff.date) "Source update after cutoff: $($source.id)"
    }
}
Assert-True ($data.metrics.Count -eq 10 -and $data.scenarios.Count -eq 4) 'Unexpected metric/scenario count.'
foreach ($metric in $data.metrics) {
    foreach ($id in $metric.source_ids) { Assert-True ($sourceIds -contains $id) "Unknown source: $id" }
}
$latestSeason = $data.baseline.seasons[-1]
$yardMetric = $data.metrics | Where-Object id -eq 'passing_yards'
$tdMetric = $data.metrics | Where-Object id -eq 'passing_tds'
Assert-True ($data.baseline.mahomes.regular_2024_yards + $latestSeason.passing_yards -eq $yardMetric.current) 'Career yards do not reconcile.'
Assert-True ($data.baseline.mahomes.regular_2024_tds + $latestSeason.passing_tds -eq $tdMetric.current) 'Career TDs do not reconcile.'
$winMetric = $data.metrics | Where-Object id -eq 'playoff_wins'
Assert-True ($winMetric.current + $data.baseline.mahomes.playoff_losses -eq $data.baseline.mahomes.playoff_games) 'Mahomes playoff record does not reconcile.'
Assert-True ($winMetric.brady + $data.baseline.brady.playoff_losses -eq $data.baseline.brady.playoff_games) 'Brady playoff record does not reconcile.'

$team = $data.baseline.chiefs_2025
Assert-True ($team.games.Count -eq 17) 'Expected 17 regular-season games.'
$wins = 0; $losses = 0; $pointsFor = 0; $pointsAgainst = 0; $closeWins = 0; $closeLosses = 0
foreach ($game in $team.games) {
    $margin = $game.chiefs_points - $game.opponent_points
    $pointsFor += $game.chiefs_points
    $pointsAgainst += $game.opponent_points
    if ($margin -gt 0) { $wins++ } elseif ($margin -lt 0) { $losses++ }
    if ([Math]::Abs($margin) -le 8) {
        if ($margin -gt 0) { $closeWins++ } elseif ($margin -lt 0) { $closeLosses++ }
    }
}
Assert-True ($wins -eq $team.wins -and $losses -eq $team.losses) 'Team record does not reconcile.'
Assert-True ($pointsFor -eq $team.points_for -and $pointsAgainst -eq $team.points_against) 'Team points do not reconcile.'
Assert-True ($closeWins -eq $team.one_possession_wins -and $closeLosses -eq $team.one_possession_losses) 'Close-game record does not reconcile.'

$weights = @($data.scenarios | ForEach-Object { $_.base_weight })
$conditional = @($data.scenarios | ForEach-Object { $_.base_goat_given_scenario })
$base = Dot-Probability $weights $conditional
$scenarios = @()
foreach ($scenario in $data.scenarios) {
    $profile = $scenario.profile
    Assert-True ($profile.super_bowl_wins -ge $scenario.title_min) 'Title profile below its band.'
    if ($null -ne $scenario.title_max) {
        Assert-True ($profile.super_bowl_wins -le $scenario.title_max) 'Title profile above its band.'
    }
    Assert-True ($scenario.final_season_age -eq 30 + $scenario.remaining_seasons) 'Final-season age mismatch.'
    Assert-True ($profile.super_bowl_mvps -le $profile.super_bowl_wins) 'Super Bowl MVPs exceed titles.'
    $futureTitles = $profile.super_bowl_wins - 3
    Assert-True ($profile.playoff_wins - 17 -ge 3 * $futureTitles) 'Insufficient playoff wins for projected titles.'
    Assert-True ($profile.playoff_losses - 4 -le $scenario.remaining_seasons - $futureTitles) 'Too many playoff elimination seasons.'
    Assert-True ($profile.playoff_wins + $profile.playoff_losses - 21 -le 4 * $scenario.remaining_seasons) 'Too many playoff games.'
    Assert-True ($profile.playoff_passer_rating -ge 0 -and $profile.playoff_passer_rating -le 158.3) 'Invalid rating.'
    foreach ($metric in $data.metrics | Where-Object id -ne 'playoff_passer_rating') {
        Assert-True ($profile.($metric.id) -ge $metric.current) "Cumulative metric declined: $($metric.id)"
    }
    foreach ($id in @('nfl_mvps', 'pro_bowls', 'first_team_all_pro')) {
        $metric = $data.metrics | Where-Object id -eq $id
        Assert-True ($profile.$id - $metric.current -le $scenario.remaining_seasons) 'Awards exceed remaining seasons.'
    }
    $scenarios += [ordered]@{
        id = $scenario.id
        contribution_percentage_points = 100 * $scenario.base_weight * $scenario.base_goat_given_scenario
        future_yards_per_representative_season = ($profile.passing_yards - $yardMetric.current) / $scenario.remaining_seasons
        future_tds_per_representative_season = ($profile.passing_tds - $tdMetric.current) / $scenario.remaining_seasons
    }
}
$sensitivity = @()
foreach ($case in $data.sensitivity) {
    $sensitivity += [pscustomobject][ordered]@{
        id = $case.id
        probability = Dot-Probability $case.weights $case.goat_given_scenario
        trajectory_only_probability = Dot-Probability $case.weights $conditional
        legacy_only_probability = Dot-Probability $weights $case.goat_given_scenario
    }
}
$baseCase = $sensitivity | Where-Object { $_.id -eq 'base' }
Assert-True ([Math]::Abs($baseCase.probability - $base) -lt 0.0000001) 'Duplicate base assumptions differ.'
$low = ($sensitivity | Measure-Object probability -Minimum).Minimum
$high = ($sensitivity | Measure-Object probability -Maximum).Maximum
$headline = Round-To (100 * $base)
$historical = 100 * $data.historical.probability
$roundedLow = Round-To (100 * $low)
$roundedHigh = Round-To (100 * $high)
$change = $headline - $historical
$changeText = if ($change -lt 0) { "$(Show-Number ([Math]::Abs($change))) percentage points lower than 2025" } elseif ($change -gt 0) { "$(Show-Number $change) percentage points higher than 2025" } else { 'Unchanged from 2025' }
$means = [ordered]@{}
$rounded = [ordered]@{}
foreach ($metric in $data.metrics) {
    $value = 0.0
    foreach ($scenario in $data.scenarios) { $value += $scenario.base_weight * $scenario.profile.($metric.id) }
    $means[$metric.id] = $value
    $rounded[$metric.id] = Round-To $value $metric.round_to
}
$meanLosses = 0.0
$remainingYears = 0.0
foreach ($scenario in $data.scenarios) {
    $meanLosses += $scenario.base_weight * $scenario.profile.playoff_losses
    $remainingYears += $scenario.base_weight * $scenario.remaining_seasons
}
$means['playoff_losses'] = $meanLosses
$rounded['playoff_losses'] = Round-To $meanLosses
$rows = @()
$tableLines = @('| Career metric | Tom Brady (final) | Patrick Mahomes (projected) |', '|---|---:|---:|')
foreach ($metric in $data.metrics) {
    $id = $metric.id
    $bradyDisplay = Show-Number $metric.brady $metric.round_to
    $projectedDisplay = '≈' + (Show-Number $rounded[$id] $metric.round_to)
    if ($id -eq 'playoff_wins') {
        $bradyDisplay = "$bradyDisplay–$($data.baseline.brady.playoff_losses)"
        $projectedDisplay += '–' + (Show-Number $rounded['playoff_losses'])
    }
    $leader = if ($metric.brady -gt $rounded[$id]) { 'brady' } elseif ($metric.brady -lt $rounded[$id]) { 'mahomes' } else { $null }
    $note = $metric.projection_note.Replace('{mean}', $means[$id].ToString('0.00', $culture))
    $rows += [ordered]@{
        metric = $metric.label; brady_display = $bradyDisplay; brady_note = $metric.brady_note
        mahomes_display = "$projectedDisplay (projected)"; mahomes_note = $note; leader = $leader
    }
    $tableLines += "| $($metric.label) | $bradyDisplay | $projectedDisplay |"
}
$result = [ordered]@{
    schema_version = 1; cutoff = $data.cutoff; historical_probability = $data.historical.probability
    base_probability = $base; headline_percent = $headline
    exact_change_percentage_points = 100 * ($base - $data.historical.probability)
    displayed_change_percentage_points = $change
    sensitivity = $sensitivity; scenario_calculations = $scenarios
    career_weighted_means = $means; career_rounded = $rounded; weighted_remaining_seasons = $remainingYears
    career_markdown_table = ($tableLines -join "`n")
    chart_data = [ordered]@{
        career = [ordered]@{ headers = @('Career Metric', 'Tom Brady (Final Career)', 'Patrick Mahomes (Projected Career)'); rows = $rows; width = 1506; height = 1162 }
        probability = [ordered]@{
            width = 1506; height = 1162
            title = "Mahomes' chance of surpassing Brady"
            subtitle = 'Lifetime consensus GOAT forecast | Before the 2026 opener'
            axis_label = 'Probability of eventually becoming the consensus GOAT'
            historical = [ordered]@{ year = '2025'; value = $historical; label = "$(Show-Number $historical)%"; note = 'Part 1: subjective assessment' }
            current = [ordered]@{ year = '2026'; value = $headline; label = "$(Show-Number $headline)%"; note = "Scenario estimate: $((100 * $base).ToString('0.0', $culture))%, rounded" }
            sensitivity = [ordered]@{ low = $roundedLow; high = $roundedHigh; label = "2026 assumption sensitivity range: $roundedLow%–$roundedHigh%" }
            change_label = $changeText
            footer_lines = @('Sensitivity reflects alternative assumptions, not a confidence interval.', "Information cutoff: September 14, 2026, before Kansas City's opener.")
        }
    }
}
$json = $result | ConvertTo-Json -Depth 20
if ($ValidateOnly) {
    Assert-True (Test-Path -LiteralPath $outputPath) 'Results have not been generated.'
    $saved = Get-Content -LiteralPath $outputPath -Raw -Encoding UTF8 | ConvertFrom-Json | ConvertTo-Json -Depth 20
    Assert-True ($saved -ceq $json) 'Saved forecast results differ from recomputed inputs.'
    $articlePath = Join-Path $PSScriptRoot 'README.MD'
    if (Test-Path -LiteralPath $articlePath) {
        $article = Get-Content -LiteralPath $articlePath -Raw -Encoding UTF8
        Assert-True ($article.Replace("`r`n", "`n").Contains($result.career_markdown_table)) 'Article career table differs from computed values.'
    }
    Write-Output 'Forecast arithmetic, dependencies, sources, saved results and article career table verified.'
} else {
    [IO.File]::WriteAllText($outputPath, $json + [Environment]::NewLine, [Text.UTF8Encoding]::new($false))
    Write-Output "Generated $outputPath"
}
Write-Output ("GOAT: {0:N2}% -> {1}%; sensitivity {2:N2}%–{3:N2}%" -f (100 * $base), $headline, (100 * $low), (100 * $high))
