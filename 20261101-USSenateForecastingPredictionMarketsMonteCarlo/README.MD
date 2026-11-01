# Forecasting the U.S. Senate with Prediction Markets and Monte Carlo Simulations  

Predicting which party will control the U.S. Senate is challenging because each race comes with its own uncertainties and complexities. Prediction markets like Polymarket and Kalshi provide real-time estimates of each candidate's chances of winning. By combining these estimates with Monte Carlo simulations, we can quckly run tens of thousands of possible election scenarios to better understand which party is most likely to win a Senate majority. We can also explore how changes in the national political environment might affect multiple races at once (Democratic or Republican wave). In this article, we'll walk through how to build a forecasting model for the 2026 U.S. Senate elections using prediction market data, statistical research methods and Monte Carlo simulations.

## Background on the 2026 Senate Races

**Key Information:** 
- **Current balance of power:** Republicans hold **53 seats**, compared with **45 Democrats and two independents who caucus with them**, giving the Democratic bloc 47 seats. ([Ballotpedia](https://ballotpedia.org/United_States_Senate_elections,_2026))
- **Senate Election map:** On 11.03.2026, voters will decide **35 of the Senate's 100 seats**: 33 regular elections plus special senate elections in Florida and Ohio. Republicans defend 22 seats and Democrats defend 13. ([Ballotpedia](https://ballotpedia.org/United_States_Senate_elections,_2026))
- **What Democrats need:** A **net gain of four seats** brings their bloc to 51 and gives them control. Holding all their current seats means flipping four Republican seats; each Democratic loss requires another pickup. ([Inside Elections](https://insideelections.com/ratings/senate/))
- **What Republicans need:** **50 seats are enough to retain control**, because Republican Vice President J.D. Vance can break ties. Republicans can therefore lose three seats net and still control the chamber at 50-50. ([U.S. Senate](https://www.senate.gov/legislative/TieVotes.htm))

In this article, we will demonstrate a forecast of the 35 US Senate race outcomes & combine the forecasts with the **65 existing US Senate seats not on the ballot**. This will determine the final 100 US Senate totals and each party's probability of controlling the Senate.

## Background on Prediction Markets

Prediction markets such as Polymarket and Kalshi let people buy and sell contracts on questions like, "Will this candidate win?" Trading turns those competing views into a probability that changes as new information arrives. A market resolves when it confirms the outcome under its rules and settles the contracts.

![How Kalshi Contract Market Works](https://www.tradetheoutcome.com/wp-content/uploads/2026/07/How-Kalshi-YES-NO-Contract-Payoffs-Work-768x512.jpg)

*Workflow of Kalshi Market Contracts. Image credit: [Trade the Outcome](https://www.tradetheoutcome.com/wp-content/uploads/2026/07/How-Kalshi-YES-NO-Contract-Payoffs-Work-768x512.jpg).*

**Key Concepts:**

- **Prices represent probabilities:** A "YES" contract priced at **\$0.65 implies about a 65% chance** of the event happening. In a standard binary market, that contract pays \$1 if the event happens and \$0 if it does not. The percentage describes the chance of winning, rather than the candidate's expected share of the vote. ([Polymarket overview](https://help.polymarket.com/en/articles/13364060-what-is-polymarket))
- **You can sell before the result:** Like stocks, contract prices rise and fall. Buying at \$0.65 and selling at \$0.80 earns \$0.15 per contract before fees; selling at \$0.45 instead loses \$0.20 (\$0.65 - \$0.45 = \$0.20). Traders can take a profit or limit a loss before resolution, provided another trader will buy. ([Polymarket trading guide](https://legacy-docs.polymarket.com/faq/trading))
- **Collective intelligence:** Traders bring different polls, news, expertise and local knowledge. Their buying and selling combines that information into one price: the **wisdom of markets**. Someone who thinks the price is wrong has an incentive to trade against it, helping the market update. ([Polymarket overview](https://help.polymarket.com/en/articles/13364060-what-is-polymarket))

  ![James Surowiecki on the wisdom of crowds](https://raw.githubusercontent.com/bartczernicki/decision-intelligence-with-ai/refs/heads/main/Images/DecisionIntelligence-Quote-JamesSurowiecki-WisdomOfCrowds.png)

- **People put money behind their beliefs:** Financial stakes give a forecast more accountability than a casual opinion. This connects with the core them in Annie Duke's book *Thinking in Bets*. That makes prediction market prices useful evidence, as traders are materialy invested in their forecast beliefs. ([Annie Duke on thinking in bets](https://www.annieduke.com/thinking-in-bets/))

  <p align="center">
    <a href="https://www.penguinrandomhouseretail.com/book/?isbn=9780735216358"><img src="https://images.penguinrandomhouse.com/cover/9780735216358" alt="Thinking in Bets by Annie Duke — book cover" width="150"></a>
  </p>

- **Calibration means the percentages match reality:** Across many comparable events assigned a **70% chance**, roughly **70 out of 100 should happen** (within statistical boundary) in a well-calibrated market. If the forecast is way over in its forecast versus the reality, it is considered overconfident. Conversely, a forecast that is way under its forecast is considered underconfident. ([Research on market calibration](https://pubmed.ncbi.nlm.nih.gov/42896054/))

  ![Decision assurance and probability calibration](https://raw.githubusercontent.com/bartczernicki/decision-intelligence-with-ai/refs/heads/main/Images/DecisionIntelligence-DecisionAssurance-Calibration.png)

- **Forecasts often improve closer to resolution:** As the event approaches, market traders have more information and less uncertainty to price. Research has found markets better calibrated near expiration than farther out. For example, making a prediction for a U.S. Senate election 6 months before the election (before any debates, official candidate positions or major voter considerations) has considerably much more uncertainty than a forecast 6 days before the election. ([Page and Clemen, 2013](https://scholars.duke.edu/publication/765630))

For our U.S. Senate forecast, these market probabilities provide the starting estimates for each race. The data that has been used was over the last week prior to the 11.03.2026 U.S. Senate election. Therefore, the Polymarket and Kalshi markets can be considered to be calibrated fairly well. 

## Monte Carlo Simulations & Forecast Methodology

A **Monte Carlo simulation** runs a model thousands (or more) of times, using random draws to represent uncertainty. Each run produces one possible future. For our Senate forecast, one run represents an entire election: who wins each race, how many seats each party holds, and who controls the chamber.

![Simulation as a way to explore outcomes before acting, illustrated by a person checking a ladder](https://raw.githubusercontent.com/bartczernicki/decision-intelligence-with-ai/refs/heads/main/Images/DecisionIntelligenceFramework/DecisionExecution-QuantMethods-LadderSimulation.png)

*A Monte Carlo simulation lets us explore what could happen before the real event, much like checking a ladder's stability before climbing.*

**Monte Carlo Basics:**

- **Probabilities guide the random draws:** In a simple independent simulation, a candidate with a 70% chance wins when a random number between 0 and 1 falls below 0.70. Across many runs, that candidate wins roughly seven times out of ten, while still losing in some simulated elections.
- **Many runs produce a range of outcomes:** Some simulated elections produce a narrow majority; others produce a larger victory for either party. The result is a **distribution of possible seat totals**, showing both common and less likely outcomes.
- **Count how often an outcome happens:** As an illustration, if Democrats control the Senate in 65,000 of 100,000 simulations, the model estimates a 65% chance of Democratic control. More runs reduce random variation in this estimate; the quality of the forecast still depends on its inputs and assumptions.

![Monte Carlo sales forecast showing a distribution of outcomes from 10,000 simulations](https://raw.githubusercontent.com/bartczernicki/decision-intelligence-with-ai/refs/heads/main/Images/DecisionIntelligence-MonteCarlo-SalesProbabilities.png)

*This sales example illustrates the same principle: repeated simulations produce a range of possible results.*

**Forecast Methodology:**

1. **Start with market probabilities:** Use the time-stamped Polymarket and Kalshi estimates for the 35 races as inputs. Exclude the 65 senate seats not on the ballot.
2. **Simulate a complete election:** Generate winners for all 35 races. An independent baseline treats each race separately; a correlated version also includes shared influences that can move several races together.
3. **Count seats and determine control:** Add the simulated winners to the existing seats, counting independents according to their caucus alignment. Democrats need a bloc of 51; Republicans can retain control with 50 because they hold the vice presidency.
4. **Repeat and compare:** Summarize the seat distribution and control probabilities across many simulated elections. Compare the independent baseline with correlated simulations and explicitly defined wave scenarios to see how the assumptions affect the forecast.

**Correlated Outcomes: FLIPR and a Democratic Wave**

Senate races share influences such as national turnout and shifts in voter sentiment. If a forecast misses one of those influences, several races can surprise us together. Nate Silver's **FLIPR** model combines polls, other indicators such as incumbency and fundraising, and, in its default version, expert ratings. It runs **many simulations per update**, accounting for uncertainty shared nationally, across similar regions or demographic groups, within a state, and within individual races. ([Silver's FLIPR methodology](https://www.natesilver.net/p/flipr-midterms-model-methodology))

A simpler approach using market probabilities can borrow that principle: draw **one shared national environment for each simulated election**, alongside randomness specific to each race. In a Democratic wave simulation, stronger Democratic turnout or support can help Democratic candidates in several states at once. Local factors still matter, so a wave does not mean every close race goes the same way. Shared surprises can also favor Republicans; Silver explicitly treats that uncertainty as party-neutral. ([Silver on correlated forecast errors](https://www.natesilver.net/p/what-if-the-polls-are-wrong-again))

For the ordinary baseline, the correlated simulation should preserve each race's starting market probability across all runs; correlation changes which wins occur together. A deliberately stronger **Democratic wave scenario** asks a separate question: **How would Senate control change if the national environment were better for Democrats than markets currently expect?** Its results are conditional on that assumption. Correlation alone does not automatically increase either party's chance of control.
