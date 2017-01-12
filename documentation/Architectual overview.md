# Hub Framework architectual overview

Welcome to the Hub Framework architectual overview. This document is aimed at developers who are looking to contribute to the framework, as well as people who want to get a more thorough understanding of how the internals of the framework work. It’s also meant to document what patterns that are used and why.

For information on how to use the framework see the other [available guides](https://spotify.github.io/HubFramework/index.html). Each guide introduces you to the various aspects of the framework, its APIs and [concepts](https://spotify.github.io/HubFramework/concept-guide.html).

|  ℹ️  | _In progress_ |  ℹ️  |
| ----- | :-----------: | ----- |
| ℹ️ | **This docment is currently “work-in-progress” and does not yet offer a complete picture of the Hub Framework architecture.** | ℹ️ |

## `HUBManager`

`HUBManager` represents an insance of the Hub Framework. It’s not a singleton, but rather a core object that an application using the framework creates and holds a reference to. The manager then provides access to all of the framework’s features in a modular fashion.

## Registries and factories

The top-level APIs that the Hub Framework offers are exposed as **Registries** and **Factories**. Instead of having `HUBManager` directly contain all APIs, we opted for this pattern for the following reasons:

- To enable a high degree of modularity, each part of the API can be consumed in isolation.
- Avoids `HUBManager` becoming a "god object" that knows too much about everything.
- Registries enables a "plugin-like" architecture, where other pieces of code can easily register functionality into the framework, making the framework as thin as possible.
- Factories enable us to avoid shared state, by making sure that we create unique object instances for each use - instead of sharing them between various parts of the code.
- Makes dependency injection and testing a lot easier.

So what registries and factories do `HUBManager` currently contain?

### Registries

- `HUBFeatureRegistry` for registering [features](concept-guide#feature).
- `HUBComponentRegistry` for registering [components](concept-guide#component).
- `HUBActionRegistry` for registering [actions](concept-guide#action).
- `HUBJSONSchemaRegistry` for registering [custom JSON schemas](concept-guide#json-schema).

### Factories

- `HUBViewModelLoaderFactory` for creating [view model loaders](https://spotify.github.io/HubFramework/Protocols/HUBViewModelLoader.html).
- `HUBViewControllerFactory` for creating [view controllers](https://spotify.github.io/HubFramework/Classes/HUBViewController.html).

## Protocols as public APIs

A core design principle used in the Hub Framework is the use of protocols to define public APIs, and then having matching classes for the actual implementation. This technique is used to get a clear separation between the public API and the internals. 

We considered using private header files as well (in fact, some classes that need to be exposed as public do), but using protocols instead have some advantages that we really liked:

- Mocking becomes a lot simpler, as a mock can just conform to the public protocol, instead of having to rely on partial mocking.
- Implementations can be swapped under the hood without having to affect the public API and/or introduce subclassing.
- Fully hides implementation details with compile time safe mechanics.

So for example, given the public API `HUBJSONSchema`, there is an implementation class called `HUBJSONSchemaImplementation`.

