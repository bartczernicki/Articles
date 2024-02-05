<p align="center" width="100%">
    <img src="https://github.com/bartczernicki/Articles/blob/main/20240128-OptimizeGenerativeAIStrategyEssentialInsightsFromOpenAIAnnouncements/Images/Header-GenAIStrategy.png?raw=true" width="100%"/>
</p>

## Intro

On January 25th, 2024 OpenAI made several key announcements that highlight several emerging patterns that should be considered in a Generative AI (or AI) strategy. What key innovations did OpenAI announce?  

- Two new embedding models, with fluid dimension sizes & pricing options  
- An updated GPT-4 Turbo preview model  
- An updated GPT-3.5 Turbo model, with reduced pricing  
- An updated text moderation model  

A full summary of announcements from OpenAI can be found here: [https://openai.com/blog/new-embedding-models-and-api-updates](https://openai.com/blog/new-embedding-models-and-api-updates)

In this article, I will uncover how these seemingly simple technology announcements uncover several important patterns in the Generative AI space that every person crafting an Generative AI strategy should be aware of.


## 1) Competitive Descent in Generative AI Pricing

The competition for Generative AI & Artificial Intelligence overall is hitting a frenzy phase! Seemingly every company is looking to Generative AI as a potential growth scalar for years to come. Some companies are well ahead in executing their AI strategy; others like Google, Meta (Facebook), Apple are going through massive Gen AI transformation: re-orgs, re-locations (Apple), unlocking financial capital for future AI investments. All one has todo is follow the stock price of public companies on the stock market and one can see a dramatic rise reflected in AI investments. For example, at the time of this writing IBM's stock was up over 13% in a single day, because of blowout earnings forecasts driven by generative AI. History has repeatedly shown that Generative AI is not going to be unique as the competitive market forms.

I would like to focus on what I call the "Competitive Descent in Generative AI Pricing". In my opinion, price history will repeat itself like any past set of technology innovations some like to call "the race to the bottom". Let's highlight a key OpenAI (01.25.2024) announcement around the reduction of the price of the GPT-3.5 Turbo model from $0.001 to $0.0005 per (1K tokens). From a historical perspective this amounts to:  
- Mar '23: $0.002 (initial general availability)  
- Jul '23: $0.0015 (-25%)  
- Nov '23: $0.001 (-33%)  
- Jan '24: $0.0005 (-50%)

**Basically, the latest GPT-3.5 Turbo model(s) are 4x cheaper than they were just 9 months ago!!** In my personal opinion, we are in the early throes of the Generative AI price decline that typically will follow a steep decline follow by a "floor" (logarithmic decreasing function).  Let's take a look at the path a "similar" innovation of "cloud blob storage" and the price decline that had occured. The figure below ([full article from Wasabi](https://wasabi.com/industry/cloud-storage-fee-inflation/)) showcases the steep price declines across several cloud hyperscalars over roughly four (4) years until prices stabilized very cleanly over the last dozen years. I claim that blob storage is a similar innovation to Generative AI, because many hyperscalers craved customer data on their storage platforms. This was because once the data was in the vendor's cloud, it unlocked innovations ("doing things on top of the data"). In a very similar manner, vendors will want generative AI functionality on their platforms to surround that functionality from services from their platform.  
<p align="center" width="100%">
    Price Decline in Azure Blog Storage<br>
    <img src="https://github.com/bartczernicki/Articles/blob/main/20240128-OptimizeGenerativeAIStrategyEssentialInsightsFromOpenAIAnnouncements/Images/ReductionsInCloudStoragePricing.png?raw=true" width="600"/>
</p>
So, what is the impact on your Generative AI strategy? Should you wait 4-5 years until Generative AI competition potentially drastically lowers prices? Of course not, as you could be losing valuable industry opportunity or risking your competition unlocking generative AI to get ahead in the market. Applying this information, the approach should be to carefully select AI vendors & partners that can provide fluid pricing options that allow your business to thrive with Generative AI potential. Even if your business's technology strategy is to leverage open-source AI models, those could end up costing much more to maintain/host than commercial alternatives. Price forecasting of Gen AI should be a forefront component in making AI strategic decisions.  


## 2) AI Model Versions & Innovation Matters  

At the time of writing this article, we just passed the first "rolling 12 months" since ChatGPT launched and grew to one of the fastest services to reach 100 million users. This was largely done on the GPT-3 model version, which is not used anymore! Think about that, the model that showed the world the innovation power just over a year ago has been superseded by dozens of commercial and open-source models.

On 01.25.2024, OpenAI continued that innovation trend updating the functionality, performance, accuracy and context size of their models. For example, there are over 7 different GPT-3.5 model versions with 3 of these model versions being labeled as "legacy" in the API documentation. This applied to GPT-4 with 8 different model versions offered by OpenAI.

The clear AI strategy implication is that there will be a constant stream of upcoming generative AI model innovations and model versions. It may seem like common sense to software development veterans to version technology assets, but this concept has not been fully adopted by the data science community (even in 2024)! Your strategy should ensure an architecture that can fluidly test new AI innovations (i.e. A/B testing) and implement new Gen AI model innovations easily from portfolio of AI functionality. Having this fluidity will optimize the business impact of Generative AI investments.


## 3) Embedding Sizes are a Key Performance & Architecture Decision  

OpenAI has provided embeddings functionality from their Ada-v1 and Ada-v2 embeddings models that output vectors with 1536 dimensions. Basically, if you sent in a sentence/paragraph/document it will translate it to a vector with 1536 dimensions (or 1536 floating point numbers).  
![Vector Translation](https://raw.githubusercontent.com/bartczernicki/Articles/ff9437889bb586828e22cdcf910da7cb623fde10/20240128-OptimizeGenerativeAIStrategyEssentialInsightsFromOpenAIAnnouncements/Images/vectors-1.svg)  

With the new embedding models, OpenAI has made several innovations:
- New embedding model version(s) promoted to v3  
- Improved performance (similarity search & match) with the v3 models over v2. Note the [embedding leaderboard rankings](https://huggingface.co/spaces/mteb/leaderboard)  
- New v3 embedding models offered in varying dimension sizes from 256 to 3072 vector dimensions, offering a huge performance improvement for smaller dimension sizes  

After the vectors are "translated" from a sentence/phrase/document into a vector, in order to compare it to another sentence/phrase/document math needs to be performed between the vectors to gauge their semantic similarity. This is usually done by distance formulas like cosine or dot product calculations. As you can imagine, if there are less vectors (smaller dimension size) there is less math to perform (less floating points to add, multiply, square etc.) This optimization can dramatically lead to massive performance gains! Below are results of a simple test, comparing varying OpenAI v3 dimension sizes. For example, performing cosine similarity on a 256 dimension size is 76% faster than the 1536 dimension size. There is a tradeoff with smaller dimension sized models in accuracy performance and smaller token context size.

```
| Method                                | NumberOfVectorsToCreate | Mean      | Error     | StdDev    | Ratio    | RatioSD | 
|-------------------------------------- |------------------------ |----------:|----------:|----------:|---------:|--------:|-
| CosineSimilarityVectors3072Dimensions | 1000                    | 0.2291 ms | 0.0002 ms | 0.0002 ms |     +85% |    0.1% | 
| CosineSimilarityVectors1536Dimensions | 1000                    | 0.1239 ms | 0.0001 ms | 0.0001 ms | baseline |         | 
| CosineSimilarityVectors768Dimensions  | 1000                    | 0.0646 ms | 0.0001 ms | 0.0001 ms |     -48% |    0.1% | 
| CosineSimilarityVectors256Dimensions  | 1000                    | 0.0299 ms | 0.0000 ms | 0.0000 ms |     -76% |    0.2% | 
```

What is the implication on your AI strategy? This OpenAI innovation will lead to more vendors (commercial or open-source) offering a common model with varying dimension size capabilities; not just tied to the model size. Similarly to the constant updates of model versions, your AI technical strategy needs to consider embedding size to balance performance and accuracy. This is especially important for hetereogenous embedding model deployments using various model sizes across varying model types.

## 4) "Coming Soon" to Azure OpenAI  

<p align="center" width="100%">
    Microsoft & OpenAI are exclusive partners<br>
    <img src="https://github.com/bartczernicki/Articles/blob/main/20240128-OptimizeGenerativeAIStrategyEssentialInsightsFromOpenAIAnnouncements/Images/OpenAI-ChatGPT-Microsoft.jpg?raw=true" width="600"/>
</p>
Microsoft has a special commercial relationship with OpenAI. Most of the innovations that OpenAI announces "fast follow" to Microsoft Azure OpenAI or other Microsoft products (M365). Basically, this means that the various model versions & capabilities in their state (preview or general availability) make it to the Microsoft platforms quite quickly. There are some key things to look out for: pricing & licensing options offered on Microsoft's platforms, additional adjacent Machine Learning and AI Services that compliment OpenAI offers, hyperscalar global Azure OpenAI region availability and many more hundreds of Azure/M365 services that help unlock the full potential of OpenAI.  For strategy purposes, this is an important consideration when planning technical AI decisions, vendor agreements, AI Cloud strategy and licensing.  

## 5) Not all Gen AI Innovations initiate from OpenAI  

While the previous items focused on OpenAI innovations, it is important to note that not all of the Generative AI nor AI innovations initiate from OpenAI. This might be common sense for some as OpenAI is relatively "young" company and AI has been around for quite some time with OpenAI re-leveraging a great deal of best practices to build their GPT-X models on top. For example, from the OpenAI updates announced recently: variable text embedding sizes as well as a new moderation model to identify potential harmful text. For example, the varying lengths of embedding models has been already offered from the open-source community, but OpenAI extended how fluidly it works across multiple models. In regard to harm moderation, Microsoft's Azure platform has a very sophisticated Responsible AI framework that powers underlies all of the AI Services on the Microsoft platforms. Therefore, strategically it is important to keep an eye on OpenAI's innovations coupled with AI market leaders and the open-source community holistically to get a better innovation picture.
