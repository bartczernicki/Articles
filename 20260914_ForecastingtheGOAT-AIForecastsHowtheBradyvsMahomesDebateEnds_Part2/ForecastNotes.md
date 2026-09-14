# Forecast calculation and chart reproduction

The article is [README.MD](README.MD). The model is a subjective, evidence-informed scenario assessment for September 14, 2026, before Kansas City's opener. Its 18% headline is not an empirical frequency, medical prognosis, betting market estimate, or calibrated forecast.

## Files and commands

- [Data/ForecastData.json](Data/ForecastData.json): frozen facts, source ledger, four illustrative career profiles, scenario weights, conditional GOAT judgments, and sensitivity assumptions.
- [Data/ForecastResults.json](Data/ForecastResults.json): generated arithmetic, unrounded and rounded projections, readable career table, and drawing inputs.
- [Build-Forecast.ps1](Build-Forecast.ps1): recalculates results from inputs and checks numerical constraints.
- [Render-Charts.ps1](Render-Charts.ps1): draws the two 1506 × 1162 PNGs using Windows PowerShell 5.1, Arial, and System.Drawing. No packages or network access are needed to rebuild.

Run from this article's folder:

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Build-Forecast.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Render-Charts.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Build-Forecast.ps1 -ValidateOnly
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\Render-Charts.ps1 -ValidateOnly
```

The execution-policy flag applies to that process only; the commands do not change the machine's saved policy. Both validation commands avoid file writes. The build validator also checks the article's career table against the calculated values. Rebuilding results does not rewrite article prose: after changing assumptions, update the article's numbers and explanations before running validation and visually inspecting both charts.

## Scenario profiles

These are **assigned illustrative averages within each group**, not actual individual careers or fitted conditional means. Fractional titles and awards summarize possible careers within a group. A 3.5-title profile lies between three and four titles; a 7.3-title profile summarizes the open-ended seven-plus group. The representative profiles do not exclude early retirement, far shorter careers, or outcomes above the upper profile.

| Profile item | 3–4 titles | 5 titles | 6 titles | 7+ titles |
|---|---:|---:|---:|---:|
| Central weight | 60% | 24% | 11% | 5% |
| Conditional GOAT judgment | 2% | 25% | 60% | 90% |
| Remaining seasons, including 2026 | 7 | 10 | 12 | 14 |
| Representative final-season age | 37 | 40 | 42 | 44 |
| Final Super Bowl wins | 3.5 | 5 | 6 | 7.3 |
| Final Super Bowl MVPs | 3.35 | 4.4 | 5.1 | 6.1 |
| Final NFL MVPs | 2.5 | 3.5 | 4.3 | 5 |
| Final Pro Bowl selections | 9 | 12 | 14 | 16 |
| Final AP first-team All-Pro selections | 3 | 4.5 | 5.5 | 7 |
| Final regular-season passing yards | 59,000 | 76,000 | 85,000 | 93,000 |
| Final regular-season passing TDs | 425 | 555 | 640 | 710 |
| Final playoff wins | 24 | 31 | 36 | 43 |
| Final playoff losses | 9 | 11 | 12 | 12.7 |
| Final playoff passing TDs | 65 | 86 | 102 | 120 |
| Final playoff passer rating | 99 | 101 | 103 | 104 |

The projected remaining passing yards per representative season are approximately 3,294 / 4,006 / 4,088 / 4,076; passing TDs are approximately 22.6 / 28.8 / 31.1 / 31.6. These are averages over the entire assumed remaining career, allowing for aging and missed time. There is no fitted annual aging curve. The upper profiles require exceptional sustained production and longevity.

The lowest group is heterogeneous: injuries, early retirement, strong individual performance without titles, and ordinary team decline can all end with three or four championships. Its 2% GOAT judgment allows a small chance of an extraordinary alternative legacy despite fewer titles. Five titles carry a 25% conditional judgment; six carry 60%; seven-plus carry 90%. Those values incorporate the associated profile and debate about individual quality, eras, and longevity. They are not derived from polls.

## Calculations and rounding

For weights w and conditional GOAT judgments q:

```text
P(GOAT) = sum(w[i] * q[i])
Central = 0.60*0.02 + 0.24*0.25 + 0.11*0.60 + 0.05*0.90 = 0.183
Career metric = sum(w[i] * assigned_profile[i].metric)
```

The central weighted values are:

| Metric | Unrounded weighted value | Chart |
|---|---:|---:|
| Super Bowl wins | 4.325 | ≈4 |
| Super Bowl MVPs | 3.932 | ≈4 |
| NFL MVPs | 3.063 | ≈3 |
| Pro Bowls | 10.62 | ≈11 |
| First-team All-Pro | 3.835 | ≈4 |
| Passing yards | 67,640 | ≈68,000 |
| Passing TDs | 494.1 | ≈490 |
| Playoff wins | 27.95 | ≈28 |
| Playoff losses | 9.995 | ≈10 |
| Playoff passing TDs | 76.86 | ≈77 |
| Playoff passer rating | 100.17 | ≈100.2 |

The weighted remaining career is 8.62 seasons. These marginal averages need not describe a single realizable career. For example, rounding makes both Super Bowl wins and MVPs four, although the underlying expectations differ. The passer-rating projection averages the assumed **final career ratings** across scenarios, not yearly/game ratings or pooled passing totals.

Headline probabilities use whole percentages; career counts use integers, regular-season yards use thousands, regular-season passing TDs use tens, and passer rating uses tenths. Numerical midpoint rounding is away from zero. Checkmarks compare displayed rounded values. The playoff-record checkmark compares total wins, not losses or winning percentage.

The 2025 bar preserves the published 30%. The 2026 bar and interval use rounded 18% and 8%–33%. The 12-point comparison uses those displayed estimates; using 18.3% produces an 11.7-point difference. No 2025 sensitivity interval is invented.

| Sensitivity test | Lower assumptions | Upper assumptions |
|---|---:|---:|
| Change scenario weights and legacy judgments together | 8.02% | 33.00% |
| Change weights only; retain central legacy judgments | 11.84% | 27.10% |
| Change legacy judgments only; retain central weights | 13.15% | 23.25% |

These selected ranges are not statistical confidence intervals, all possible outcomes, or calibrated coverage guarantees. The earlier 30% is not used as a Bayesian prior. Different methodology prevents isolating a causal effect of the new season or claiming improved forecast accuracy.

## Source audit and scope

The source ledger in the input JSON records exact URLs, publisher/author where available, publication dates, access date, and the facts used. Undated player and schedule pages are frozen to their historical data through the stated cutoff. Linked article bodies were checked, rather than relying solely on search snippets.

- Mahomes' passing totals reconcile as 32,352 + 3,587 = 35,939 yards and 245 + 22 = 267 TDs.
- Postseason totals remain 17 wins, four losses, 46 passing TDs and 105.4 passer rating after no 2025 postseason appearance. Those Part 1 baseline numbers were already correct.
- Brady's NFL retirement report establishes 48 starts and 35 playoff wins, hence 13 losses. The Buccaneers retirement story contains a conflicting 32–18 line; that line is rejected. Its separate passing totals agree with NFL records.
- Mahomes' six Pro Bowls count selections, not being named an alternate. AP first-team All-Pro is distinct from second-team and other organizations' awards.
- The Chiefs release confirms ACL surgery; NFL reporting supplies the LCL detail. Clearance for the opener is not evidence of full performance recovery.
- The roster roundup is dated March 16 but its body is updated through March 20, 2026. Both dates precede the cutoff.
- The original “highest ever” playoff passer-rating description is omitted. Current ranking claims in historical biographies can be stale and are unnecessary for this analysis.
- The historical schedule independently reconciles the 6–11 record, +34 differential, and 1–9 record in games with final margins of eight points or fewer.
- Rebuilding later must not introduce the September 14 game's outcome or subsequent information into this frozen edition.

The article's main text and readable tables fall within the requested 1,500–2,000-word range. Both PNGs were inspected at full image size. Rendering validates measured text fit, canvas bounds, the 0–100% axis, and matching dimensions before saving. The original article folder remains untouched.

