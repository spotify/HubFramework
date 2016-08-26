# Content Programming Guide

Welcome to the Hub Framework content programming guide! This guide aims to help you gain a deeper understanding of how to build the content that will be rendered in a Hub Framework-powered view.

**Table of contents**

- [Introduction](#introduction)
- [Content hierarchy](#content-hierarchy)
- [Using JSON](#using-json)
- [Using builders](#using-builders)
- [Content operations](#content-operations)
- [Content loading chain](#content-loading-chain)
- [Rescheduling content operations](#rescheduling-content-operations)
- [Handling errors in content operations](#handling-errors-in-content-operations)

## Introduction

The Hub Framework is built around the idea of a "content-driven architecture", which just like content-driven UI design puts the content front and center - and lets the content drive the UI rather than the other way around.

The way this works is through the use of **view models** and **component models** that each encapsulates content on either the view level, or the component level. Components are the visual buildings blocks of a Hub Framework-powered view, and are used to render the content defined by a component model.

*(For more information about components, see the [Component programming guide](https://ghe.spotify.net/pages/iOS/HubFramework/component-programming-guide.html))*

## Content hierarchy

The content of a Hub Framework-powered view is described using a hierarchy of models, consisting of `HUBViewModel`, `HUBComponentModel` and `HUBComponentImageData` objects.

### View models encapsulate all content of a view

View models are top-level model objects, that contain both metadata & information about a view, but also a series of `HUBComponentModels` that make up the visual content of a view.

### Component models define how content should be rendered

Component models come in 3 variants; **header**, **body** and **overlay**. While any component can be used in any of those 3 variants, they will be treated slightly differently in terms of rendering.

A **Header component** is rendered at the top of a view. Each view can only have a single header component, although that component can have children nested within it. It will always remain on top of the view, and does not scroll with the rest of the view's content.

**Body components** make up all the standard visual content that is part of the view. They automatically support scrolling when there's an overflow of components outside of the view's bounds, and are laid out next to each other according to their *Layout traits* (for more information see the [Layout programming guide](https://ghe.spotify.net/pages/iOS/HubFramework/layout-programming-guide.html)).

**Overlay components** are rendered on top of the rest of the view's content, making them suitable for overlays such as loading indicators, popups, notifications, etc. They are always rendered at the center of the screen, stacked on top of each other.

### Component models define a generic data model for all components

Component models are exposed to components using the `HUBComponentModel` API, and contain all data that the component should need to set itself up for rendering a piece of content.

They contain textual content, like `title`, `subtitle` & `descriptionText`, as well as image data, metadata & the ability for component authors to support `customData` key/value combinations.

For each component model; a `HUBComponent` implementation will be used for rendering. Which implementation to use is determined by the model's `componentNamespace` and `componentName`. For more information about how namespaces and names are resolved; see the [Component programming guide](https://ghe.spotify.net/pages/iOS/HubFramework/component-programming-guide.html).

*For a full list of supported properties, see [`HUBComponentModel`](https://ghe.spotify.net/pages/iOS/HubFramework/Protocols/HUBComponent.html).*

## Using JSON

One way of adding content to a Hub Framework-powered view is through JSON, which can be used to define a serialized view model. Using the JSON API to define your content means that you can dynamically update a view from a server-side system - fully decoupling your application from the content that is being rendered in it. It could potentially reduce iteration times, and enabling you to release whenever you want - instead of always having to make changes in the client-side code.

The Hub Framework can be used with any JSON schema, but does provide a default one for convenience. For more information; see the [JSON programming guide](https://ghe.spotify.net/pages/iOS/HubFramework/json-programming-guide.html).

## Using builders

Builders are used to manipulate the content of a view in code. [The builder pattern](https://en.wikipedia.org/wiki/Builder_pattern) is used to reduce the need to keep state, and to avoid mutable models.

Each model that is used to define Hub Framework content has a builder that matches it; `HUBViewModelBuilder`, `HUBComponentModelBuilder` and `HUBComponentImageDataBuilder`.

Each model's parent can be used to create a builder for that model. So you use a view model builder to create component model builders, and component model builders to create component model builders for child components, and so on. For example; to create a **body component model builder**, use `[viewModelBuilder builderForBodyComponentModelWithIdentifier:]`.

Once a builder has been retrieved, it can be used to mutate the content that it represents, for example; a `HUBComponentModelBuilder` can be used to mutate the content of a specific component.

Builders are also persisted throughout the lifecycle of a view, meaning that you can retrieve an existing builder that was previously used to define content, to mutate that content further, or remove it completely.

## Content operations

Whether you're using JSON or calling builders in code, the composition of all content for a Hub Framework-powered view is done through **content operations**. They each define an atomic content task (such as downloading a JSON file, adding a series of components based on a local dataset, reading from a cache, etc).

Each application or feature using the Hub Framework defines its own content operations through the `HUBContentOperation` protocol, and enables the framework to create instances of them through the use of `HUBContentOperationFactories`. An array of content operation factories are registered when each feature sets itself up with the Hub Framework.

Content operations are called when either of the following 3 events happen:

- The view is about to appear, and the content operations are asked to add initial (pre-loaded) content to the view. *This only happens if the content operation conforms to `HUBContentOperationWithInitialContent`.*

- The view has appeared, and the content operations are asked to load the main content for the view.

- A content operation has been rescheduled, for example because of an underlying model change, or because of a UI event. See [Rescheduling content operations](#rescheduling-content-operations) for more information.

## Content loading chain

When you register an array of `HUBContentOperationFactories` with the Hub Framework, when setting up a feature using `HUBFeatureRegistry`, the order of that array is used to determine the order of what's called the **content loading chain**.

The content loading chain enables you to create advanced logical sequences using content operations, where each operation can modify the content setup by previous operations, or add new content. This can be used to create code encapsulation, implement A/B tests, and aggregate data from multiple sources.

Let's say we're building a feature that has 2 content operation factories; `1` and `2`; which each create two content operations; `A` and `B`. When we register our feature, we'll supply our content operation factories in an array like this:

```objective-c
@[contentOperationFactory1, contentOperationFactory2];
```

When a view that belongs to our feature is created, our factories will be used to create content operations for that view, using the order in which we supplied our factories. So the following content operations will be created:

```
contentOperationFactory1
    - contentOperationA1
    - contentOperationB1
contentOperationFactory2
    - contentOperationA2
    - contentOperationB2
```

And the following **content loading chain** will be formed:

```objective-c
@[contentOperationA1, contentOperationB1, contentOperationA2, contentOperationB2];
```

Each operation in a content loading chain is called in sequence, meaning that the Hub Framework will start by calling `contentOperationA1`, and when it finishes, it will call `contentOperationB1`, and so on.

This becomes very powerful, since the same `HUBViewModelBuilder` is passed through the whole chain, meaning that a subsequent operation can mutate the content that was defined by a previous operation.

Here is an example where `ContentOperationA` creates a component model, and then `ContentOperationB` changes its title. Let's start with the implementation for `ContentOperationA`:

```objective-c
@implementation ContentOperationA

- (void)performForViewURI:(NSURL *)viewURI
              featureInfo:(id<HUBFeatureInfo>)featureInfo
        connectivityState:(HUBConnectivityState)connectivityState
         viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
            previousError:(nullable NSError *)previousError
{
    id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
    componentModelBuilder.title = @"TitleA";
    componentModelBuilder.subtitle = @"Subtitle";

    [self.delegate contentOperationDidFinish:self];
}

@end
```

And then for `ContentOperationB` (which retrieves the same `HUBComponentModelBuilder` as `ContentOperationA` was using, by using the same component model identifier):

```objective-c
@implementation ContentOperationB

- (void)performForViewURI:(NSURL *)viewURI
              featureInfo:(id<HUBFeatureInfo>)featureInfo
        connectivityState:(HUBConnectivityState)connectivityState
         viewModelBuilder:(id<HUBViewModelBuilder>)viewModelBuilder
            previousError:(nullable NSError *)previousError
{
    id<HUBComponentModelBuilder> const componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"component"];
    componentModelBuilder.title = @"TitleB";

    [self.delegate contentOperationDidFinish:self];
}

@end
```

This will result in a single component displaying the title `"TitleB"`. While this was a very trivial example; it showcases how the content loading chain can be used to sequentially mutate the content of a view. This can not only be done for titles, but for headers, entire components, overlays, etc.

## Rescheduling content operations

Content operations may be rescheduled whenever some state changed that requires parts of the view to be re-rendered. To reschedule an operation, call its delegate:

```objective-c
[self.delegate contentOperationRequiresRescheduling:self];
```

This will reschedule the operation for execution as soon as possible, and will also schedule **all subsequent operations in the content loading chain**. Consider the following content loading chain:

```objective-c
@[contentOperationA, contentOperationB, contentOperationC];
```

If `contentOperationB` is rescheduled; that means that `contentOperationC` will also be rescheduled. This enables subsequent operations to always be able to rely on their preceding operations.

### View model builder snapshotting

Important to note is also that when an operation is rescheduled, the view model builder that it recieves as input will be a snapshot of the builder that it recieved **the last time that it was executed**. This enables content operations to always have the same execution conditions, and reduces the need for them to keep state.

For example, let's say we have two content operations; `contentOperationA` and `contentOperationB`. In the initial content loading chain, `contentOperationA` will add 2 body component models (`A` and `B`). `contentOperationB` will then add a third body component - `C`. So the final state of the view that will be rendered will contain 3 body component models; `A`, `B` and `C`.

Then, we retrigger `contentOperationB`. Instead of recieving a view model builder that contains `A`, `B` and `C` - it will get one that only contains `A` and `B`. This is because it will recieve a snapshot of its previous view model builder input, rather than a builder representation of the current view model.

So, if we only wanted to add component model `C` conditionally, we wouldn't have to worry about any previous states, and can simply just add it if the conditions are met. We never have to "clean up" any previous state, since we're always starting from the same state.

## Handling errors in content operations

Content operations may also be used for error handling. Whenever an operation exited with an error (by calling `contentOperation:didFailWithError:` on its delegate) any subsequent operation will have that error passed to it as `previousError`. The subsequent operation can then chose to do one of two things:

- Silence the error by doing its work as normal, and calling `contentOperationDidFinish:` once done.
- Forward the error by calling `contentOperation:didFailWithError:`, which will cause the error to continue down the chain.
