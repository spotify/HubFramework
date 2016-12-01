# Hub Framework concept guide

Welcome to the Hub Framework concept guide! This guide aims to give you an easy to navigate, alphabetical reference that explains all the key concepts of the framework. It also contains links to other guides and code that will give you more in-depth knowledge about the various concepts and how they relate.

**Table of contents**

- [Action](#action)
- [Action handler](#action-handler)
- [Backend-driven UIs](#backend-driven-uis)
- [Builder](#builder)
- [Component](#component)
- [Component-driven UIs](#component-driven-uis)
- [Component identifier](#component-identifier)
- [Component model](#component-model)
- [Content loading chain](#content-loading-chain)
- [Content operation](#content-operation)
- [Factory](#factory)
- [JSON schema](#json-schema)
- [Layout trait](#layout-trait)
- [Registry](#registry)
- [View model](#view-model)

## Action

An object implementing `HUBAction` - which can be used to define custom behavior for components & content operations. Actions can be both observed and triggered by content operations & components, meaning that they can be used to bridge the gap between content operations and components.

Actions are integrated with the Hub Framework through a [factory](#factory) (`HUBActionFactory`) that is registered using `HUBActionRegistry`.

For more information see:

- The `HUBAction` protocol.
- The `HUBActionFactory` protocol.
- The [Action programming guide](https://spotify.github.io/HubFramework/action-programming-guide.html).

## Action handler

An object that handles actions, either on a global or feature level. Action handlers are defined using `HUBActionHandler` and can be supplied either when setting up `HUBManager` (as `defaultActionHandler`) or when setting up a feature (as `actionHandler`).

An action handler is called each time an action is about to be performed in a view, and can chose to handle that action itself, or simply returning `NO` to let the action take place.

For more information see:

- The `HUBAction` protocol.
- The `HUBActionHandler` protocol.
- The [Action programming guide](https://spotify.github.io/HubFramework/action-programming-guide.html).

## Backend-driven UIs

A phrase used to describe UIs that are essentially controlled by a backend service. While most apps these days have their content provided by some form of backend, UIs that are considered "backend-driven" also have their structure & layout driven from the backend.

The Hub Framework faciliates the creation of "backend-driven UIs" through its JSON API and declarative characteristics.

For more information see:

- The [Content programming guide](https://spotify.github.io/HubFramework/content-programming-guide.html).
- The [JSON programming guide](https://spotify.github.io/HubFramework/json-programming-guide.html).
- The talk ["Backend-driven UIs"](https://atscaleconference.com/videos/backend-driven-native-uis/) from Mobile@Scale London 2016.

## Builder

An object that is responsible for constructing a model. Builders are used in [content operations](#content-operation) to declare content (like components, images, targets, etc). They act like a mutable counterpart to the model that they build - with the key difference that they're not related by inheritance. Each model in the Hub Framework has a builder associated with it.

You can add content to a builder either through code, or through JSON.

For more information see:

- The `HUBViewModelBuilder` protocol.
- The `HUBComponentModelBuilder` protocol.
- The `HUBComponentImageDataBuilder` protocol.
- The `HUBComponentTargetBuilder` protocol.
- The [Content programming guide](https://spotify.github.io/HubFramework/content-programming-guide.html).

## Component

An object that manages a view that is rendered in a `HUBViewController`. Components are defined using `HUBComponent` (or related protocols) and are registered with the Hub Framework using a [factory](#factory) (`HUBComponentFactory`) through `HUBComponentRegistry`. A component is the controller between a [component model](#component-model) and a `UIView`. All views that are rendered in a `HUBViewController` are components.

For more information see:

- The `HUBComponent` protocol.
- The `HUBComponentFactory` protocol.
- The `HUBComponentModel` protocol.
- The [Component programming guide](https://spotify.github.io/HubFramework/component-programming-guide.html).

## Component-driven UIs

A phrase used to describe UIs that consists entirely of components. Instead of creating hard-wired layout relationships between subviews, components are fully decoupled, atomic pieces of a UI. In the Hub Framework, a [component](#component) in a thin wrapper around a `UIView`, that enables existing views to be easily imported into the framework.

For more information see:

- The `HUBComponent` protocol.
- The `HUBComponentModel` protocol.
- The [Component programming guide](https://spotify.github.io/HubFramework/component-programming-guide.html).
- The talk ["Building component-driven UIs"](https://vimeo.com/190713343) from MobileEra 2016.

## Component model

A model that is used to render a component. Component models are created using [builders](#builder) in [content operations](#content-operation) and are generic representations of data, for rendering purposes. Each component model has a [component identifier](#component-identifier) associated with it, which is used to resolve which component instance that will render it. It also contains properties like `title`, `subtitle`, `mainImage`, `target`, etc. that a component can be used to populate its view.

For more information see:

- The `HUBComponentModel` protocol.
- The `HUBComponent` protocol.
- The [Component programming guide](https://spotify.github.io/HubFramework/component-programming-guide.html).
- The [Content programming guide](https://spotify.github.io/HubFramework/content-programming-guide.html).

## Content loading chain

An array of [content operations](#content-operation) that are chained together to load the content for a view. A chain is automatically formed when a `HUBViewController` (or `HUBViewModelLoader`) is created with multiple content operations. In a chain, each operation is called sequentially, and its output state is transferred (by copying) to the next operation.

For more information see:

- The `HUBContentOperation` protocol.
- The [Content programming guide](https://spotify.github.io/HubFramework/content-programming-guide.html).

## Content operation

An operation that is resposible for loading the content for a view. A single content operation can be resonsible for the entire content, or multiple ones can be chained together (to form a [content loading chain](#content-loading-chain)), each performing a specific mutation of the view's content.

Content operations use a view model [builder](#builder) (`HUBViewModelBuilder`) to add, remove or change component models for a view. How they execute, and whether they load remote JSON or use local content is up to you. They are defined using the `HUBContentOperation` protocol (and optionally, sub-protocols).

For more information see:

- The `HUBContentOperation` protocol.
- The `HUBViewModelBuilder` protocol.
- The [Content programming guide](https://spotify.github.io/HubFramework/content-programming-guide.html).

## Factory

An object that is responsible for creating implementations of a certain protocol. The [factory pattern](https://en.wikipedia.org/wiki/Factory_method_pattern) is used extensively throughout the Hub Framework to avoid shared state. By always creating unique object instances for each context - no state is ever shared. While this requires a bit more code to be written (you have to write both an implementation **and a factory**, for example for [components](#component)), it makes the framework a lot more predictable and less error prone.

For more information see:

- ["Factory method pattern" on Wikipedia](https://en.wikipedia.org/wiki/Factory_method_pattern).
- The  `HUBComponentFactory` protocol.
- The `HUBActionFactory` protocol.
- The `HUBViewControllerFactory` protocol.
- The `HUBViewModelLoaderFactory` protocol.

## JSON schema

In the Hub Framework, a JSON schema is an object responsible for extracting model information from JSON data. Each schema has a set of defined paths, that each describe how to "go into" a JSON structure and retrieving the requested information.

The framework ships with a default JSON schema, that is implicitly used if not overriden, but custom schemas can also be defined through `HUBJSONSchemaRegistry`.

For more information see:

- The `HUBJSONSchema` protocol.
- The [JSON programming guide](https://spotify.github.io/HubFramework/json-programming-guide.html).

## Layout trait

Layout traits are used to define layout relationships between components. Instead of hard-coding margins and relationships between concrete component implementations - layout traits enables components to work with layout in a more abstract way. Each component simply defines which layout traits that best describe it, in terms of layout, and then an implementation of `HUBComponentLayoutManager` computes the exact margins that should be applied to it.

For more information see:

- The `HUBComponentLayoutTrait` type.
- The `HUBComponent` protocol.
- The [Layout programming guide](https://spotify.github.io/HubFramework/layout-programming-guide.html).

## Registry

In order to enable applications using the Hub Framework to easily inject implementations into it - registries are used. Each registry enables a certain type of object to be registered. There are currently four registries: for [features](#feature), [components](#component), [actions](#action) & [JSON schemas](#json-schema).

For more information see:

- The `HUBFeatureRegistry` protocol.
- The `HUBComponentRegistry` protocol.
- The `HUBActionRegistry` protocol.
- The `HUBJSONSchemaRegistry` protocol.

## View model

The Hub Framework uses a take on the [MVVM pattern](https://en.wikipedia.org/wiki/Model–view–viewmodel) to drive its view controllers. It uses a view model to encapsulate exactly what should be rendered. A view model in turn consists of [component models](#component-model) in three categories: `Header`, `Body` and `Overlay`. A view model also contains information like what `UINavigationItem` to use, etc.

View models are built in content operations, using any combination of JSON and code through the `HUBViewModelBuilder` API.

For more information see:

- The `HUBViewModel` protocol.
- The `HUBViewModelBuilder` protocol.
- The [Content programming guide](https://spotify.github.io/HubFramework/content-programming-guide.html).