## An Innovative OpenAI Approach to Crafting a Vector Database in SQL Server using Semantic Kernel

## Background

Large language models (LLMs) have signaled a transformative shift in artificial intelligence (AI), providing a doorway to tasks rooted in natural language processing. While they are a crucial component of traditional AI, it's important to acknowledge that these models also come with their share of limitations. Their versatility and wide-ranging utility have positioned them as fundamental building blocks for numerous applications, leading some to re-christen them as "foundation models". Despite their value, current LLMs (including GPT-4)
have inherent limitations:
* **Lack of access to current information.** For example, several current OpenAI models have been trained on data up to September 2021  
* **Lack of access to private document stores.** For example, most OpenAI models were not trained on private corporate contracts  
* **Lack of cognitive reasoning.** LLMs (either OpenAI or open-source) can provide nonsense answers sometimes called "hallucinations"  
* **Limited amount of context.** Most LLMs have small token contexts (memory) that help it remember what topic the chat was about or details of the previous chat exchange  

Good news is that there are approaches to overcome these limitations and improving the utility of large language models (including OpenAI). One of these approaches is "adding more memory" using a vector database for storing and retrieving embeddings, which are mathematical representations of features or attributes of data. Vector databases allow for fast and accurate similarity search and retrieval of data based on their vector distance or similarity, making it possible to find the most similar or relevant data based on their semantic or contextual meaning. This kind of "grounding" the LLM with context-specific data can provide more accurate and relevant outputs to answer specific questions.

However, there are challenges associated with this approach. Maintaining, storing, and searching embeddings through vector databases can be challenging in production settings. Embeddings are heavy objects and the storage requirements can grow quickly, especially with larger datasets. There are many new open-source and startups trying to solve for this issue. In this article, it will be illustrated how SQL Server or Azure SQL can be used to solve these issues by building an end-to-end vector database, efficiently store vectors in columnstore indexes, perform search and be able to answer queries with Semantic Kernel!

## Case for SQL as a Vector Database

Vector databases are not an new concept. In fact, there has been years of research on this subject and vector database have been used in specific scenarios (i.e. Information Retrieval, Bing Search).  If you launch a search engine and look up old articles for vector databases, you will find articles from over a decade ago! However, there has been a lot more interest in vector database correlated with the explosion of OpenAI and new powerful embeddings models. As any technology space going through disruption, many startups and open-source offerings have appeared: Qdrant, Pinecone, Chroma, Faiss and integrations into other enterprise products: Azure Cognitive Search, Redis, ElasticSearch etc. One product to consider for vector search is Microsoft's SQL database engine.

### Features of Microsoft SQL for Vector (Indexes) Databases
* Proven enterprise-grade product line with pedigree since late 1990s. It has been around for quite some time, and likely continue to be around for years
* SQL Server engine runs almost anywhere you would need a vector database: on-premises (local), IoT, Docker container, cross-cloud, Linux/Windows, x64 and ARM architectures etc.  
* No-cost (free) development environment!! SQL Server offers a development SKU ideal for development of AI and vector-based solutions offered for free to test out the engine.  
* The power of SQL language. SQL has been around in existance for quite some time and it is very easy to perform complex analytical, mathematical, filtering etc. using it. Compare this with some vector database startups, that are just adding basic filtering (where clause) or lack ability to perform a simple join!  
* Columnstore indexes, partitioning, distributing indexes in tables allow Microsoft SQL to scale to tens of millions of documents in a Vector Index. For example, Columnstore indexes provide massive performance gains by reducing I/O through data compression and batch processing, which allows more data to be stored in memory and entire "areas" of data to be eliminated during query processing  
* Enterprise features like security, business continuity, query intelligence optimizations, integrations with hundreds of other systems & software are first-class citizens. Many open-source vector database alternatives can't match this functionality posture.  
* You probably already have used SQL Server/Azure SQL or are using it in your enterprise. You are probably NOT using one of the open-source or new startup vector stores. In the former example, it is clearly easier to "integrate" a vector store into an existing database system.  

## Introducting the "Vector Database SQL Search" Demo Console Application  

Main GitHub location and developer instructions to get started:  
https://github.com/bartczernicki/MachineIntelligence-TextAnalytics-TPLDataFlows  

![TPL Pipeline](https://raw.githubusercontent.com/bartczernicki/Articles/main/20230507-AnInnovativeOpenAIApproachtoCraftingaVectorDatabaseinSQLServerandusingSemanticKernel/Images/TPLDataFlows-Pipeline.png)  

### Features:
* The console application uses 50 selected books (with over 33 million text characters) from the Project Gutenberg site from various authors: Oscar Wilde, Bram Stoker, Edgar Allen Poe, Alexandre Dumas and performs enrichment using multiple AI enrichment steps
* Downloads book text, processes text analytics & embeddings, creates a vector database in SQL, demonstrates vector search and finally using Semantic Kernel answers sample questions using semantic meaning from OpenAI embeddings
* Stores all enrichment output for each book in a seperate JSON file, which can then be used in a Data Lake (Lakehouse, Delta Lake) for big data analytics & AI
* Rather than processing text analytics enrichment in single synchronous steps, it uses .NET 8 TPL Dataflow model to create efficient pipelines that can saturate multiple logical CPU cores  
* Illustrates that the SQL Server engine or Azure SQL can be used as a valid Vector Store at scale, can perform hybrid vector search and provide Semantic Kernel Q&A over the database
* The console application is cross-platform .NET 8.x. It can run on macOS, Linux, Windows 10/11 x64, Windows 11 ARM

### Three Pipeline Execution Options showing the power of Vector Embeddings Search using SQL
* Option 1 processes the entire Data Enrichment Pipeline (builds the OpenAI embeddings Vector Database in SQL)  
* Option 2 processes the Q&A pipeline using Semantic Kernel over the Vector Database (Note: Option #1 must have been run beforehand at some point and the application needs access to the current vector store)  
* Option 3 processes the Q&A pipeline with reasoning using Semantic Kernel over the Vector Database. It also includes a rudimentary confidence score illustrating how "sure" the LLM is in its answer. (Note: Option #1 must have been run beforehand at some point and the application needs access to the current vector store)  

![TPL Pipeline](https://raw.githubusercontent.com/bartczernicki/Articles/main/20230507-AnInnovativeOpenAIApproachtoCraftingaVectorDatabaseinSQLServerandusingSemanticKernel/Images/TPLDataFlows-ConsoleApp.png)  

### Data Enrichment Pipeline in Action  
* Essentially performs all of the text analytics, AI (OpenAI) work to materialize the SQL Server Vector Database. The start of the pipeline is a list of 50 books and their URL locations. At the completion of the pipeline a full AI & ML enriched set of JSON documents and a vector embeddings database is built.  

![Data Enrichment Pipeline](https://raw.githubusercontent.com/bartczernicki/Articles/main/20230507-AnInnovativeOpenAIApproachtoCraftingaVectorDatabaseinSQLServerandusingSemanticKernel/Images/TPLVectorEmbeddingsProcessingConsole.gif)  

### Q&A Pipeline in Action  
* Uses both the SQL Vector Search Database & Semantic Kernel to answer question(s) from the 50 processed novels. The sample questions show how the power of the SQL Vector DB and Semantic Kernel can work together on a simple vector search, more complex hybrid search to enhance the accuracy and filter out any disambiguation between context(s) of novels.

![Q&A Pipeline](https://raw.githubusercontent.com/bartczernicki/Articles/main/20230507-AnInnovativeOpenAIApproachtoCraftingaVectorDatabaseinSQLServerandusingSemanticKernel/Images/TPLDataFlows-Pipeline-Finish.png)  

### Learn More - Upcoming Articles

Main GitHub location: source code, developer instructions to get started and more details on the application:  
https://github.com/bartczernicki/MachineIntelligence-TextAnalytics-TPLDataFlows  

After introducing this solution, in the next upcoming three parts of this series I will cover the three core components that make up the solution:  
* Part 1) How the SQL Server engine can be effectively used as a vector database, facilitate hybrid search capabilities and provide massive scale to millions of documents  
* Part 2) .NET 8.x TPL Dataflows Pipelines - How .NET is uniquely positioned to run anywhere with performance and leverage advanced concepts like saturating all of the available the CPU environment to execute a data-enrichment AI pipeline  
* Part 3) Semantic Kernel configuration and how Semantic Kernel can be configured to adapt to context from almost any vector store and work with vector stores on advanced features. Finally, I will cover additional concepts that can improve recall of Q&A in sophisticated context environments.  
