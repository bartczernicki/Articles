[CmdletBinding()]
param(
    [string]$DataPath,
    [string]$OutputDirectory,
    [switch]$ValidateOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
if ([string]::IsNullOrEmpty($DataPath)) { $DataPath = Join-Path $PSScriptRoot 'Data\ForecastResults.json' }
if ([string]::IsNullOrEmpty($OutputDirectory)) { $OutputDirectory = Join-Path $PSScriptRoot 'Images' }

$script:CanvasWidth = 1506
$script:CanvasHeight = 1162
$script:Ink = [System.Drawing.ColorTranslator]::FromHtml('#333333')
$script:Grid = [System.Drawing.ColorTranslator]::FromHtml('#D3D3D3')
$script:Green = [System.Drawing.ColorTranslator]::FromHtml('#119C38')
$script:Gray = [System.Drawing.ColorTranslator]::FromHtml('#858585')

function New-ChartFont {
    param([single]$Size, [System.Drawing.FontStyle]$Style = [System.Drawing.FontStyle]::Regular)
    return [System.Drawing.Font]::new('Arial', $Size, $Style, [System.Drawing.GraphicsUnit]::Pixel)
}

function New-TextFormat {
    param(
        [System.Drawing.StringAlignment]$Align = [System.Drawing.StringAlignment]::Near,
        [System.Drawing.StringAlignment]$VerticalAlign = [System.Drawing.StringAlignment]::Near
    )
    $format = [System.Drawing.StringFormat]::GenericTypographic.Clone()
    $format.Alignment = $Align
    $format.LineAlignment = $VerticalAlign
    $format.Trimming = [System.Drawing.StringTrimming]::None
    $format.FormatFlags = $format.FormatFlags -bor [System.Drawing.StringFormatFlags]::NoWrap -bor [System.Drawing.StringFormatFlags]::MeasureTrailingSpaces
    return $format
}

function Measure-ChartText {
    param([System.Drawing.Graphics]$Graphics, [string]$Text, [System.Drawing.Font]$Font)
    $format = New-TextFormat
    try {
        return $Graphics.MeasureString($Text, $Font, [System.Drawing.SizeF]::new(10000, 10000), $format)
    }
    finally { $format.Dispose() }
}

function Draw-ChartText {
    param(
        [System.Drawing.Graphics]$Graphics,
        [string]$Text,
        [System.Drawing.Font]$Font,
        [System.Drawing.RectangleF]$Bounds,
        [System.Drawing.Color]$Color = $script:Ink,
        [System.Drawing.StringAlignment]$Align = [System.Drawing.StringAlignment]::Near,
        [System.Drawing.StringAlignment]$VerticalAlign = [System.Drawing.StringAlignment]::Near,
        [string]$Context = 'text'
    )
    if ([string]::IsNullOrEmpty($Text)) { return }
    if ($Text.Contains("`n") -or $Text.Contains("`r")) { throw "$Context must be a single line." }
    if ($Bounds.Left -lt 0 -or $Bounds.Top -lt 0 -or $Bounds.Right -gt $script:CanvasWidth -or $Bounds.Bottom -gt $script:CanvasHeight) {
        throw "$Context extends beyond the canvas."
    }
    $measured = Measure-ChartText $Graphics $Text $Font
    if ($measured.Width -gt $Bounds.Width -or $measured.Height -gt $Bounds.Height) {
        throw ("{0} does not fit: measured {1:N1}x{2:N1}px in {3:N1}x{4:N1}px. Text: {5}" -f $Context, $measured.Width, $measured.Height, $Bounds.Width, $Bounds.Height, $Text)
    }
    $format = New-TextFormat $Align $VerticalAlign
    $brush = [System.Drawing.SolidBrush]::new($Color)
    try { $Graphics.DrawString($Text, $Font, $brush, $Bounds, $format) }
    finally { $brush.Dispose(); $format.Dispose() }
}

function New-ChartCanvas {
    $bitmap = [System.Drawing.Bitmap]::new($script:CanvasWidth, $script:CanvasHeight, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $bitmap.SetResolution(144, 144)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
    $graphics.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $graphics.Clear([System.Drawing.Color]::White)
    return [pscustomobject]@{ Bitmap = $bitmap; Graphics = $graphics }
}

function Draw-WinnerBadge {
    param([System.Drawing.Graphics]$Graphics, [single]$X, [single]$Y)
    $path = [System.Drawing.Drawing2D.GraphicsPath]::new()
    $brush = [System.Drawing.SolidBrush]::new($script:Green)
    $pen = [System.Drawing.Pen]::new([System.Drawing.Color]::White, 3.2)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    try {
        $path.AddArc($X, $Y, 8, 8, 180, 90)
        $path.AddArc($X + 19, $Y, 8, 8, 270, 90)
        $path.AddArc($X + 19, $Y + 19, 8, 8, 0, 90)
        $path.AddArc($X, $Y + 19, 8, 8, 90, 90)
        $path.CloseFigure()
        $Graphics.FillPath($brush, $path)
        $Graphics.DrawLines($pen, [System.Drawing.PointF[]]@(
            [System.Drawing.PointF]::new($X + 6, $Y + 14),
            [System.Drawing.PointF]::new($X + 11, $Y + 20),
            [System.Drawing.PointF]::new($X + 21, $Y + 6)
        ))
    }
    finally { $pen.Dispose(); $brush.Dispose(); $path.Dispose() }
}

function Draw-CareerValue {
    param(
        [System.Drawing.Graphics]$Graphics, [string]$Text, [System.Drawing.Font]$Font,
        [System.Drawing.RectangleF]$Bounds, [bool]$Winner, [string]$Context
    )
    if (-not $Winner) {
        Draw-ChartText $Graphics $Text $Font $Bounds -Context $Context
        return
    }
    $before = $Text
    $after = ''
    if ($Text.EndsWith(' (projected)')) {
        $before = $Text.Substring(0, $Text.Length - ' (projected)'.Length)
        $after = ' (projected)'
    }
    $beforeSize = Measure-ChartText $Graphics $before $Font
    $afterWidth = 0
    if ($after) { $afterWidth = (Measure-ChartText $Graphics $after $Font).Width }
    $totalWidth = $beforeSize.Width + 36 + $afterWidth
    if ($totalWidth -gt $Bounds.Width) { throw "$Context and its winner badge do not fit the table cell." }
    Draw-ChartText $Graphics $before $Font $Bounds -Context $Context
    Draw-WinnerBadge $Graphics ($Bounds.X + $beforeSize.Width + 6) ($Bounds.Y + 2)
    if ($after) {
        $suffixX = $Bounds.X + $beforeSize.Width + 36
        $suffixBounds = [System.Drawing.RectangleF]::new($suffixX, $Bounds.Y, $Bounds.Right - $suffixX, $Bounds.Height)
        Draw-ChartText $Graphics $after $Font $suffixBounds -Context "$Context suffix"
    }
}

function Render-CareerTable {
    param($Data)
    $canvas = New-ChartCanvas
    $graphics = $canvas.Graphics
    $headerFont = New-ChartFont 26 ([System.Drawing.FontStyle]::Bold)
    $metricFont = New-ChartFont 26 ([System.Drawing.FontStyle]::Bold)
    $bodyFont = New-ChartFont 27
    $noteFont = New-ChartFont 27 ([System.Drawing.FontStyle]::Italic)
    $gridPen = [System.Drawing.Pen]::new($script:Grid, 1)
    $successful = $false
    try {
        $xs = @(10, 370, 727, 1491)
        $ys = @(11, 74, 182, 289, 396, 504, 611, 719, 826, 933, 1041, 1148)
        foreach ($x in $xs) { $graphics.DrawLine($gridPen, $x, $ys[0], $x, $ys[-1]) }
        foreach ($y in $ys) { $graphics.DrawLine($gridPen, $xs[0], $y, $xs[-1], $y) }
        for ($column = 0; $column -lt 3; $column++) {
            $bounds = [System.Drawing.RectangleF]::new($xs[$column] + 12, $ys[0], $xs[$column + 1] - $xs[$column] - 24, $ys[1] - $ys[0])
            Draw-ChartText $graphics $Data.headers[$column] $headerFont $bounds -Color ([System.Drawing.Color]::Black) -Align Center -VerticalAlign Center -Context "career header $column"
        }
        for ($index = 0; $index -lt 10; $index++) {
            $row = $Data.rows[$index]
            $top = $ys[$index + 1]
            $height = $ys[$index + 2] - $top
            $metricBounds = [System.Drawing.RectangleF]::new(32, $top, 316, $height)
            Draw-ChartText $graphics $row.metric $metricFont $metricBounds -Color ([System.Drawing.Color]::Black) -VerticalAlign Center -Context "career row $index metric"
            foreach ($player in @('brady', 'mahomes')) {
                $left = 391
                $width = 315
                if ($player -eq 'mahomes') { $left = 748; $width = 722 }
                $display = [string]$row.($player + '_display')
                $note = [string]$row.($player + '_note')
                $valueTop = $top + 17
                if ([string]::IsNullOrEmpty($note)) { $valueTop = $top + ($height - 36) / 2 }
                $valueBounds = [System.Drawing.RectangleF]::new($left, $valueTop, $width, 36)
                Draw-CareerValue $graphics $display $bodyFont $valueBounds ($row.leader -eq $player) "career row $index $player value"
                if ($note) {
                    $noteBounds = [System.Drawing.RectangleF]::new($left, $top + 60, $width, 36)
                    $selectedFont = $noteFont
                    if ($player -eq 'brady') { $selectedFont = $bodyFont }
                    Draw-ChartText $graphics $note $selectedFont $noteBounds -Context "career row $index $player note"
                }
            }
        }
        $successful = $true
        return $canvas.Bitmap
    }
    finally {
        $gridPen.Dispose(); $noteFont.Dispose(); $bodyFont.Dispose(); $metricFont.Dispose(); $headerFont.Dispose(); $graphics.Dispose()
        if (-not $successful) { $canvas.Bitmap.Dispose() }
    }
}

function Render-ProbabilityChart {
    param($Data)
    $canvas = New-ChartCanvas
    $graphics = $canvas.Graphics
    $titleFont = New-ChartFont 48 ([System.Drawing.FontStyle]::Bold)
    $subtitleFont = New-ChartFont 29
    $yearFont = New-ChartFont 36 ([System.Drawing.FontStyle]::Bold)
    $valueFont = New-ChartFont 42 ([System.Drawing.FontStyle]::Bold)
    $noteFont = New-ChartFont 27 ([System.Drawing.FontStyle]::Italic)
    $tickFont = New-ChartFont 24
    $axisFont = New-ChartFont 26
    $changeFont = New-ChartFont 32 ([System.Drawing.FontStyle]::Bold)
    $footerFont = New-ChartFont 23
    $gridPen = [System.Drawing.Pen]::new([System.Drawing.ColorTranslator]::FromHtml('#E5E5E5'), 1)
    $axisPen = [System.Drawing.Pen]::new($script:Gray, 1.5)
    $rangePen = [System.Drawing.Pen]::new($script:Green, 3)
    $greenBrush = [System.Drawing.SolidBrush]::new($script:Green)
    $grayBrush = [System.Drawing.SolidBrush]::new($script:Gray)
    $successful = $false
    try {
        Draw-ChartText $graphics $Data.title $titleFont ([System.Drawing.RectangleF]::new(74, 62, 1360, 66)) -Color ([System.Drawing.Color]::Black) -Context 'probability title'
        Draw-ChartText $graphics $Data.subtitle $subtitleFont ([System.Drawing.RectangleF]::new(76, 142, 1358, 44)) -Context 'probability subtitle'
        $plotLeft = 270
        $plotWidth = 1050
        $axisY = 825
        for ($tick = 0; $tick -le 100; $tick += 20) {
            $x = $plotLeft + $plotWidth * $tick / 100
            $graphics.DrawLine($gridPen, $x, 275, $x, $axisY)
            $graphics.DrawLine($axisPen, $x, $axisY, $x, $axisY + 8)
            Draw-ChartText $graphics ($tick.ToString() + '%') $tickFont ([System.Drawing.RectangleF]::new($x - 55, 844, 110, 35)) -Align Center -Context "axis tick $tick"
        }
        $graphics.DrawLine($axisPen, $plotLeft, $axisY, $plotLeft + $plotWidth, $axisY)
        $series = @($Data.historical, $Data.current)
        $barTops = @(320, 540)
        for ($index = 0; $index -lt 2; $index++) {
            $item = $series[$index]
            $top = $barTops[$index]
            $barWidth = $plotWidth * [double]$item.value / 100
            $brush = $grayBrush
            $color = $script:Gray
            if ($index -eq 1) { $brush = $greenBrush; $color = $script:Green }
            $graphics.FillRectangle($brush, [single]$plotLeft, [single]$top, [single]$barWidth, [single]82)
            Draw-ChartText $graphics $item.year $yearFont ([System.Drawing.RectangleF]::new(76, $top + 18, 160, 48)) -Color ([System.Drawing.Color]::Black) -Context "probability year $index"
            $labelX = $plotLeft + $barWidth + 17
            Draw-ChartText $graphics $item.label $valueFont ([System.Drawing.RectangleF]::new($labelX, $top + 14, 1490 - $labelX, 58)) -Color $color -Context "probability label $index"
            Draw-ChartText $graphics $item.note $noteFont ([System.Drawing.RectangleF]::new($plotLeft, $top + 101, 1150, 39)) -Context "probability note $index"
        }
        $rangeLowX = $plotLeft + $plotWidth * [double]$Data.sensitivity.low / 100
        $rangeHighX = $plotLeft + $plotWidth * [double]$Data.sensitivity.high / 100
        $rangeCenterX = $plotLeft + $plotWidth * [double]$Data.current.value / 100
        $rangeY = 710
        $graphics.DrawLine($rangePen, [single]$rangeLowX, [single]$rangeY, [single]$rangeHighX, [single]$rangeY)
        $graphics.DrawLine($rangePen, [single]$rangeLowX, [single]($rangeY - 11), [single]$rangeLowX, [single]($rangeY + 11))
        $graphics.DrawLine($rangePen, [single]$rangeHighX, [single]($rangeY - 11), [single]$rangeHighX, [single]($rangeY + 11))
        $graphics.FillEllipse($greenBrush, [single]($rangeCenterX - 6), [single]($rangeY - 6), [single]12, [single]12)
        Draw-ChartText $graphics $Data.sensitivity.label $noteFont ([System.Drawing.RectangleF]::new($plotLeft, 745, 1150, 39)) -Color $script:Green -Context 'sensitivity label'
        Draw-ChartText $graphics $Data.axis_label $axisFont ([System.Drawing.RectangleF]::new($plotLeft, 895, $plotWidth, 40)) -Align Center -Context 'probability axis label'
        Draw-ChartText $graphics $Data.change_label $changeFont ([System.Drawing.RectangleF]::new(76, 961, 1360, 48)) -Color $script:Green -Context 'probability change label'
        for ($index = 0; $index -lt $Data.footer_lines.Count; $index++) {
            Draw-ChartText $graphics $Data.footer_lines[$index] $footerFont ([System.Drawing.RectangleF]::new(76, 1034 + $index * 39, 1360, 34)) -Context "probability footer $index"
        }
        $successful = $true
        return $canvas.Bitmap
    }
    finally {
        $grayBrush.Dispose(); $greenBrush.Dispose(); $rangePen.Dispose(); $axisPen.Dispose(); $gridPen.Dispose()
        $footerFont.Dispose(); $changeFont.Dispose(); $axisFont.Dispose(); $tickFont.Dispose(); $noteFont.Dispose()
        $valueFont.Dispose(); $yearFont.Dispose(); $subtitleFont.Dispose(); $titleFont.Dispose(); $graphics.Dispose()
        if (-not $successful) { $canvas.Bitmap.Dispose() }
    }
}

function Assert-ChartSchema {
    param($Data)
    foreach ($chart in @($Data.career, $Data.probability)) {
        if ($chart.width -ne $script:CanvasWidth -or $chart.height -ne $script:CanvasHeight) {
            throw 'Both chart dimensions must be 1506 by 1162 pixels.'
        }
    }
    if ($Data.career.headers.Count -ne 3 -or $Data.career.rows.Count -ne 10) {
        throw 'The career table must contain three headers and ten metric rows.'
    }
    foreach ($row in $Data.career.rows) {
        if ($null -ne $row.leader -and $row.leader -notin @('brady', 'mahomes')) { throw 'A career leader must be brady, mahomes, or null.' }
        foreach ($field in @('metric', 'brady_display', 'brady_note', 'mahomes_display', 'mahomes_note')) {
            if ($row.$field -isnot [string]) { throw "Career field $field must be a string." }
        }
    }
    foreach ($value in @($Data.probability.historical.value, $Data.probability.current.value, $Data.probability.sensitivity.low, $Data.probability.sensitivity.high)) {
        $number = [double]$value
        if ([double]::IsNaN($number) -or [double]::IsInfinity($number) -or $number -lt 0 -or $number -gt 100) { throw 'Probability chart values must be finite numbers from 0 to 100.' }
    }
    if ($Data.probability.sensitivity.low -gt $Data.probability.sensitivity.high) { throw 'The sensitivity lower bound must not exceed its upper bound.' }
    if ($Data.probability.footer_lines.Count -gt 2) { throw 'The probability chart supports at most two footer lines.' }
}

$source = Get-Content -LiteralPath $DataPath -Raw -Encoding UTF8 | ConvertFrom-Json
Assert-ChartSchema $source.chart_data
$careerBitmap = $null
$probabilityBitmap = $null
try {
    # Rendering into memory validates all measured text before either file is written.
    $careerBitmap = Render-CareerTable $source.chart_data.career
    $probabilityBitmap = Render-ProbabilityChart $source.chart_data.probability
    if ($ValidateOnly) {
        Write-Output 'Validated both 1506x1162 chart layouts; no files written.'
    }
    else {
        if (-not (Test-Path -LiteralPath $OutputDirectory -PathType Container)) {
            $null = New-Item -ItemType Directory -Path $OutputDirectory
        }
        $careerPath = Join-Path $OutputDirectory 'CareerProjections.png'
        $probabilityPath = Join-Path $OutputDirectory 'GOATProbabilityUpdate.png'
        $careerBitmap.Save($careerPath, [System.Drawing.Imaging.ImageFormat]::Png)
        $probabilityBitmap.Save($probabilityPath, [System.Drawing.Imaging.ImageFormat]::Png)
        Write-Output "Created $careerPath"
        Write-Output "Created $probabilityPath"
    }
}
finally {
    if ($null -ne $careerBitmap) { $careerBitmap.Dispose() }
    if ($null -ne $probabilityBitmap) { $probabilityBitmap.Dispose() }
}
