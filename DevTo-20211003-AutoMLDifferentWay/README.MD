## Intro

Microsoft's AI strategy is to *"Innovate and accelerate with powerful tools and services that bring artificial intelligence to every developer"*. One of those core foundational patterns is AutoML (Automated Machine Learning), which allows end-to-end automation and application of common data science best practices to deliver production-ready ML pipelines and operationalized models with ease.

The Microsoft AI platform is vast made up of many services, infrastructure, software and solutions; including AutoML implementations. In this article, I will uncover various techniques to perform AutoML (Automated Machine Learning) on the Microsoft AI Platform. Some of these techniques re-use similar backend technology, however they deviate enough in their integrations, purpose and user interfaces to call them "different". Did you know that you can perform AutoML 9+ different ways using Microsoft AI?! In each AutoML "way"; I will describe the nuances, their superpowers and when to use one "way vs other".

## Why

Why have many different ways to execute a data science design pattern; such as AutoML? The idea is that an organization may have made multiple investments across different technologies, architectures, programming languages or platforms and Microsoft AI activates AutoML across a wide breadth of these services!


## 1) Azure Machine Learning - Studio & Web Portal

Azure Machine Learning is a portfolio of enterprise cloud services that aim to build and deploy Machine Learning models faster. AML studio is a web portal that provides a web UI to interface with Azure Machine Learning. You can get started with AutoML using the web portal easily

**When to use:** Use the Studio portal to get started easily without writing any code by leveraging the web UI in the Azure cloud. It is a great way to learn about the AutoML capabilities before diving in deeper. The studio portal is ideal for crafting models for a POC, hackfest or in a time crunch when you do not need to automate the process. Do note that there is some functionality not completely exposed inside the portal, where the SDK might be a better fit. This is a cloud service, so to perform anything sophisticated you will need an Azure subscription (at least FREE trial).


![Azure ML - Auto ML](https://raw.githubusercontent.com/bartczernicki/Articles/main/DevTo-20211003-AutoMLDifferentWay/AzureML-AutoML-Portal.gif)

For a complete tutorial, navigate to: https://docs.microsoft.com/en-us/azure/machine-learning/tutorial-first-experiment-automated-ml  


## 2) Azure Machine Learning - SDK & APIs

The Azure ML SDK & APIs provide a code-first approach to performing various tasks like AutoML.

**When to use:** The SDK & APIs are great to use when you need a code-first approach to AutoML, integrate with data science tools (Jupyter, VSCode) or need to automate some of the AutoML tasks. The SDK exposed is written in Python friendly to most data scientists. All of the backend APIs are REST-based. Therefore, with some additional work you can use these APIs with your favorite programming language. The SDK & APIs work across different Azure services and can also be used locally. For example, you can perform AutoML tasks and have them run on source files and local compute. Therefore, depending on how you use the APIs this can be very cost effective or even no-cost.

```
...
ensemble_settings = {
                     "ensemble_download_models_timeout_sec": 600
                     "stack_meta_learner_type": "LogisticRegressionCV",
                     "stack_meta_learner_train_percentage": 0.3,
                     "stack_meta_learner_kwargs": {
                                                    "refit": True,
                                                    "fit_intercept": False,
                                                    "class_weight": "balanced",
                                                    "multi_class": "auto",
                                                    "n_jobs": -1
                                                  }
                    }

automl_classifier = AutoMLConfig(
                                 task='classification',
                                 primary_metric='AUC_weighted',
                                 experiment_timeout_minutes=30,
                                 training_data=train_data,
                                 label_column_name=label,
                                 n_cross_validations=5,
                                 **ensemble_settings
                                )
...
```

For a complete tutorial, navigate to: https://docs.microsoft.com/en-us/azure/machine-learning/how-to-configure-auto-train  

## 3) Visual Studio 2019/2022 - Model Builder

Model Builder is a free extension to Visual Studio (proper) based on ML.NET and extensibility into the cloud that offers code-generation, integrates with full .NET and source services.

**When to use:** Model Builder targets the "developer data scientist" persona. Therefore, if your team is using Visual Studio, have .NET investments (DevOps, APIs), build C# solutions, require complete offline AutoML support; Model Builder is a great option. Model Builder has wizard-like UI that walks the user through AutoML. It is based on the ML.NET (Machine Learning .NET open-source framework, but it does extend into the Azure cloud. It does not have all of the capabilities of the Azure ML AutoML service, however it provides a solid foundation. It is provided at no-cost and works with the free (Community Edition) of Visual Studio as well. A perfect scenario is a developer who has an existing .NET solution and wants to explore if adding Machine Learning (with AutoML) is worth it. They can provide some data to Model Builder, run the experiments and have a C# set of training and inference code written in seconds!

![MLNet-Model-Builder](https://raw.githubusercontent.com/bartczernicki/Articles/main/DevTo-20211003-AutoMLDifferentWay/ml-dotnet-model-builder.gif)

For a complete tutorial, navigate to: https://dotnet.microsoft.com/learn/ml-dotnet/get-started-tutorial/intro  

Model Builder recent AutoML updates and roadmap: https://devblogs.microsoft.com/dotnet/ml-net-june-updates-model-builder/#new-and-improved-automl  

## 4) Machine Learning .NET - AutoML with C# APIs

This is a code-first approach to AutoML with ML.NET & C#. The developer now is writing C# code to interface with the Machine Learning .NET SDK & APIs.

**When to use:** Use the ML.NET AutoML APIs when you need to have explicit, automated, configurable control over the AutoML process using .NET. If your team has developers that understand the core AutoML pattern, this is a great way to integrate AutoML capabilities with your solutions. All your existing .NET architecture does not have to change, nor do you have to take a dependency on a cloud service! For example, if you have a solution that processes some sort of data sets and need to automate Machine Learning tasks, ML.NET will fit right in.

```
using Microsoft.ML;
using Microsoft.ML.AutoML;
    // ...
    MLContext mlContext = new MLContext();
    IDataView trainDataView = mlContext.Data.LoadFromTextFile<SentimentIssue>("my-data-file.csv", hasHeader: true);
```

For more information, navigate to: https://docs.microsoft.com/en-us/dotnet/machine-learning/how-to-guides/how-to-use-the-automl-api  

## 5) Machine Learning .NET - AutoML with CLI

Very similar to the previous scenario. However, this is a script-first approach to AutoML with ML.NET & CLI (Command Line Interface). The developer now is writing CLI code to automate AutoML tasks.

**When to use:** You would consider using the ML.NET - Auto ML CLI when you need to automate tasks using scripting techniques. If you have existing pipelines scripted out or are using another programming language/conventions for automation, then the CLI AutoML interface is a great option to look at.

![Azure ML - Auto ML](https://raw.githubusercontent.com/bartczernicki/Articles/main/DevTo-20211003-AutoMLDifferentWay/mlnet-classification-cli.gif)

For a complete tutorial, navigate to: https://dotnet.microsoft.com/learn/ml-dotnet/get-started-tutorial/intro  


## 6) Synapse Analytics & Studio - Spark Tables with AutoML

Synapse Analytics and Synapse Studio allow you to take existing Synapse investments & technology and enrich it with AutoML capabilities.

**When to use:** If you have Spark tables inside Synapse, want to train and operationalize ML models with Synapse or have heavy SQL code investments; consider AutoML with Synapse. Therefore, you can take your data lake or logical data warehouse and layer the AutoML pattern over it. Synapse Studio provides an AutoML wizard user interface to guide the user through the process, so it is super easy to get started. Furthermore, once your model is built with AutoML you can then use scoring wizard for dedicated SQL pools to operationalize your model directly in SQL! Note that Synapse leverages the Azure ML - AutoML platform, so you will need to have that service live. Finally, both AzureML (AutoML) and Synapse are cloud services; so you are going to be committing to the cloud. This is a commercial cloud service that will cost money to use.

![Azure ML - Synapse Automl Wizard](https://raw.githubusercontent.com/bartczernicki/Articles/main/DevTo-20211003-AutoMLDifferentWay/synapse-automl-wizard.png)

For a complete tutorial, navigate to: https://docs.microsoft.com/en-us/azure/synapse-analytics/machine-learning/tutorial-automl  

## 7) Power BI - AutoML for dataflows

Automated machine learning (AutoML) for dataflows enables business analysts to train, validate, and invoke Machine Learning (ML) models directly in Power BI. It includes a simple experience for creating a new ML model where analysts can use their dataflows to specify the input data for training the model.

**When to use:** You should consider using AutoML for dataflows, when you have or plan to have investments in the Power BI platform. This basically allows you to enrich Power BI dashboards/reports/data models across multiple sources with AutoML. The AutoML integration with Power BI provides an easy to use wizard interface. One of the nice integration pieces is that after an ML model is trained, AutoML automatically generates a Power BI report that explains the likely performance of your ML model. As the dataflows are re-run and the data is refreshed, the crafted AutoML models are also refreshed. Similar to the Synapse integration, Power BI uses automated ML from Azure Machine Learning to create your ML models. However, you don't need an Azure subscription to use AutoML in Power BI. The process of training and hosting the ML models is managed entirely by the Power BI service. This is a commercial cloud service that will cost money to use.


![automated-machine-learning-power-bi-](https://raw.githubusercontent.com/bartczernicki/Articles/main/DevTo-20211003-AutoMLDifferentWay/automated-machine-learning-power-bi-01.png)

For a complete tutorial, navigate to: https://docs.microsoft.com/en-us/power-bi/transform-model/dataflows/dataflows-machine-learning-integration  


## 8) Microsoft Research & Open-Source - FLAML

FLAML (Fast and Lightweight AutoML) is a lightweight Python library that finds accurate machine learning models automatically, efficiently and economically. It frees users from selecting learners and hyperparameters for each learner. It is fast and economical. The simple and lightweight design makes it easy to extend, such as adding customized learners or metrics. FLAML is powered by a new, cost-effective hyperparameter optimization and learner selection method invented by Microsoft Research. 

**When to use:** FLAML is open-source, free, exposed as a Python API (code-first) and you can track progress publicly on GitHub. Microsoft Research currently owns this project and it will be integrated in other Microsoft AI platform services. Consider using FLAML, when you want to use cutting edge AutoML techniques before they appear in Microsoft products at no-cost. For example, if you use Model Builder .NET, some of the capabilities of FLAML exist there. This means you can use FLAML locally & not have to take a dependency on the cloud. FLAML focuses on core (classical) Machine Learning algorithms. This means the Scikit-learn family of algorithms can be automated using FLAML. For deep learning (neural nets, PyTorch, Tensorflow) consider the Neural Network Intelligence implementation. FLAML is meant to be barebones and lightweight, so simple AutoML use cases are a great fit.

```
from flaml import AutoML
from sklearn.datasets import load_iris
# Initialize an AutoML instance
automl = AutoML()
# Specify automl goal and constraint
automl_settings = {
    "time_budget": 10,  # in seconds
    "metric": 'accuracy',
    "task": 'classification',
    "log_file_name": "test/iris.log",
}
X_train, y_train = load_iris(return_X_y=True)
# Train with labeled input data
automl.fit(X_train=X_train, y_train=y_train,
           **automl_settings)
# Predict
print(automl.predict_proba(X_train))
# Export the best model
print(automl.model)
```

For a complete tutorial, navigate to this Jupyter Notebook: https://github.com/microsoft/FLAML/blob/main/notebook/flaml_automl.ipynb

Link to FLAML GitHub repository: https://github.com/microsoft/FLAML  


## 9) Microsoft Research & Open-Source - Neural Network Intelligence**

NNI (Neural Network Intelligence) is a lightweight but powerful toolkit to help users automate Feature Engineering, Neural Architecture Search, Hyperparameter Tuning and Model Compression.

**When to use:** (Very similar to FLAML) NNI is open-source, free, exposed as a Python API, command-line, visual web UI and you can track progress publicly on GitHub. MConsider using NNI, when you want to use cutting edge AutoML techniques before they appear in Microsoft products at no-cost. The core difference between NNI and FLAML is that NNI focuses on deep learning and supports frameworks such as PyTorch, Keras, Tensorflow etc. but also supports traditional machine learning packages (Scikit-learn). NNI is much more of a complete framework than FLAML with a monthly release cadence; whereas FLAML is meant to be lightweight. The NNI framework can run locally with no cloud dependencies at no-cost!


![automl-neuralnetworkintelligence](https://raw.githubusercontent.com/bartczernicki/Articles/main/DevTo-20211003-AutoMLDifferentWay/automl-neuralnetworkintelligence.gif)

For a complete tutorial, navigate to this Jupyter Notebook: https://github.com/microsoft/nni/blob/master/examples/notebooks/tabular_data_classification_in_AML.ipynb  

Link to NNI GitHub repository: https://github.com/microsoft/nni    
