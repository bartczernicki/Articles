## An Innovative OpenAI Approach to Crafting a Vector Database in SQL Server and using Semantic Kernel

## Background

Large language models (LLMs) has signaled a transformative shift in artificial intelligence (AI), providing a doorway to tasks rooted in natural language processing. While they are a crucial component of traditional AI, it's important to acknowledge that these models also come with their share of limitations. Their versatility and wide-ranging utility have positioned them as fundamental building blocks for numerous applications, leading some to re-christen them as "foundation models". Despite their value, current LLMs (including GPT-4)
have inherent limitations:
* Lack of access to current information. For example, many OpenAI models have been trained on data up to September 2021  
* Lack of access to private document stores. For example, OpenAI models were not trained on private corporate contracts  
* Lack of cognitive reasoning. LLMs (including OpenAI) can provide non-sense answers sometimes called "hallucinations"  
* Limited amount of context. Most LLMs have small contexts (memory) that help it remember what topic the chat was about or details of the previous chat exchange   

Good news is that there are approaches to overcome these limitations and improving the utility of large language models (including OpenAI). One of these approaches is "adding more memory" using a vector database for storing and retrieving embeddings, which are mathematical representations of features or attributes of data. Vector databases allow for fast and accurate similarity search and retrieval of data based on their vector distance or similarity, making it possible to find the most similar or relevant data based on their semantic or contextual meaning. This kind of "grounding" the LLM with context-specific data can provide more accurate and relevant outputs to answer specific questions.

However, there are challenges associated with this approach. Maintaining, storing, and searching embeddings through vector databases can be challenging in production settings. Embeddings are heavy objects and the storage requirements can grow quickly, especially with larger datasets. There are many new open-source and startups trying to solve for this issue. In this article, it will be illustrated how SQL Server or Azure SQL can be used to solve these issues by building an end-to-end vector database, efficiently store vectors in columnstore indexes, perform search and be able to answer queries with Semantic Kernel!

## Case for SQL as a Vector Database

Vector databases are not an new concept. In fact, there has been years of research on this subject and vector database have been used in specific scenarios (i.e. Information Retrieval, Bing Search). There has been a lot more interest in vector database correlated with the explosion of OpenAI and new powerful embeddings models. As any technology space going through disruption, many startups and open-source offerings have appeared: Qdrant, Pinecone, Chroma, Faiss and integrations into other enterprise products: Azure Cognitive Search, Redis, ElasticSearch etc. One product to consider for vector search is Microsoft's SQL engine.

### Why SQL?
* Proven enterprise product with pedigree since late 1990s  
* It runs almost anywhere you would need a vector database: on-premises (local), IoT, Docker container, cross-cloud, Linux/Windows, x64 and ARM architectures etc.
* No-cost (free) development environment! SQL Server offers a development SKU ideal for development of AI and vector-based solutions  
* The power of SQL language. SQL has been around in existance for quite some time and it is very easy to perform complex analytical, mathematical, filtering etc. using it. Compare this with some vector database startups, that are just adding basic filtering (where clause) or lack ability to perform a simple join!  
* ColumnStore indexes allow SQL to scale to millions of documents per table (Vector Index)  
* Enterprise features like security, business continuity, integrations with hundreds of systems built-in  
* You probably already have used SQL Server/Azure SQL or are using it in your enterprise

## Introducting the "Vector Database SQL Search" Demo Console Application  

Main GitHub location and instructions to get started:  
https://github.com/bartczernicki/MachineIntelligence-TextAnalytics-TPLDataFlows  

![TPL Pipeline](https://raw.githubusercontent.com/bartczernicki/Articles/main/20230507-AnInnovativeOpenAIApproachtoCraftingaVectorDatabaseinSQLServerandusingSemanticKernel/Images/TPLDataFlows-Pipeline.png)  

## Features:
* The console app uses 30 selected books from the Project Gutenberg site from various authors: Oscar Wilde, Bram Stoker, Edgar Allen Poe and performs enrichment using multiple AI enrichment steps
* Downloads book text, processes text analytics & embeddings, creates a vector database in SQL, demonstrates vector search and answers a sample question using semantic meaning from OpenAI embeddings
* Stores all enrichment output for each book in a seperate JSON file
* Rather than processing text analytics enrichment in single synchronous steps, it uses an data flow model to create efficient pipelines that can saturate multiple logical CPU cores  
* Illustrates that SQL Server or Azure SQL can be used as a valid Vector Store, can perform vector search and provide Q&A over the database
* Demonstrates how to create a Machine Intelligence & Text Analytics Pipeline can be combbined using TPL DataFlows
* The console application is cross-platform .NET 8.x. It will run on macOS, Linux, Windows 10/11 x64, Windows 11 ARM

## Two Pipeline Execution Options showing the power of Vector Embeddings Search using SQL
* Option 1 processes the entire Data Enrichment Pipeline (build the embeddings Vector Database in SQL)
* Option 2 processes the Q&A pipeline using Semantic Kernel over the Vector Database (Note: Option #1 must have been run beforehand at some point)  

![TPL Pipeline](https://raw.githubusercontent.com/bartczernicki/Articles/main/20230507-AnInnovativeOpenAIApproachtoCraftingaVectorDatabaseinSQLServerandusingSemanticKernel/Images/TPLDataFlows-ConsoleApp.png)  

## Data Enrichment Pipeline in action  
* Essentially performs all of the text analytics, AI (OpenAI) work to materialize the SQL Server Vector Database

![TPL Pipeline](https://raw.githubusercontent.com/bartczernicki/Articles/main/20230507-AnInnovativeOpenAIApproachtoCraftingaVectorDatabaseinSQLServerandusingSemanticKernel/Images/TPLVectorEmbeddingsProcessingConsole.gif)  


