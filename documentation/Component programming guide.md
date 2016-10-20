# Component Programming Guide

Welcome to the Hub Framework component programming guide! This guide aims to help you gain a deeper understanding of how components work, how to build them and how to deal with things like data binding, image loading and layout.

**Table of contents**

- [Introduction](#introduction)
- [The basics](#the-basics)
- [Image handling](#image-handling)
- [Managing child components](#managing-child-components)
- [Saving and restoring UI state](#saving-and-restoring-ui-state)
- [Responding to user interactions](#responding-to-user-interactions)
- [Integrating a component with the framework](#integrating-a-component-with-the-framework)
- [Best practices](#best-practices)

## Introduction

Components are the visual building blocks used to construct a View using the Hub Framework. Each component instance manages a `UIView`, and can be described as a simplified `UIViewController`. They each define a piece of UI that can easily be reused in any View using the Hub Framework.

Each component instance has a 1:1 relationship with its view, and is responsible for rendering a visual representation of a `HUBComponentModel`. A component can also (optionally) have child components nested within it.

There are very few constraints on how a component may be implemented. You can, for example, choose to use Auto Layout or not, and use any `UIView` type as your view. Think of a component as your own rectangle to draw in, and whatever you draw in that rectangle is up to you.

## The basics

To start creating a component, create a new class and make it conform to `HUBComponent`. There are a [few different templates](https://github.com/spotify/HubFramework/tree/master/templates/xcode/Hub%20Framework) that you can use as a starting point, if you want to.

Initially, the implementation will look something like this:

```objective-c
@implementation SPTMyHubComponent

@synthesize view = _view;

- (NSSet<HUBComponentLayoutTrait *> *)layoutTraits
{
    // Return a set of layout traits that describe your component's UI style
    return [NSSet new];
}

- (void)loadView
{
    // Create your view. You can give it a zero rectangle for its frame.
    self.view = [[UIView alloc] initWithFrame:CGRectZero];
}

- (CGSize)preferredViewSizeForDisplayingModel:(id<HUBComponentModel>)model containerViewSize:(CGSize)containerViewSize
{
    // Return the size you'd prefer that the layout system resizes your view to
    return CGSizeZero;
}

- (void)prepareViewForReuse
{
    // Prepare your view for reuse, reset state, remove highlights, etc.
}

- (void)configureViewWithModel:(id<HUBComponentModel>)model
{
    // Do your model->view data binding here
}

@end
```

Now, let's dive a bit deeper and take a look at how to implement the methods above, and further customize a component implementation.

### Defining layout for a component

To be able to lay out components in a way that looks nice & consistent, the Hub Framework uses a single source of truth for calculating margins and layout; an implementation of `HUBComponentLayoutManager`. However, each component is still in control of how it should be laid out, even if it doesn't compute the absolute metrics.

This is achieved with layout traits. Each component can define a set of layout traits that best describes it in terms of layout.

For more information; see the [Layout programming guide](https://spotify.github.io/HubFramework/layout-programming-guide.html).

### Creating a component's view

Just like a view controller, a component is responsible for creating its own view - using the `loadView` method. When called, the component should instantiate an appropriate `UIView` and store it in its `view` property.

A component is free to use any subclass of `UIView`, and the property even allows of implicit casting to any `UIView` type.

Since the Hub Framework will take care of layouting the component's view, there's no need to perform manual frame calculations in a component implementation, instead, just give your view a `CGRectZero` frame to begin with.

### Defining a component's view size

Each component has the ability to tell the Hub Framework what size it would **prefer** that its view will be resized to; using the `preferredViewSizeForDisplayingModel:containerViewSize:` method. The component is already here getting access to the model that it's about to be used with, as well as the size of the container view that its view will be displayed in. The component is free to use any of this information to compute what size that it would prefer.

The framework will then do its best to let the component's view get this size, however, it also needs to take the layout (computed according to the component's layout traits) into account - and may therefore slightly adjust the final size of the view.

So an important thing to keep in mind is to never hard-code internal layout rules for a component's view based on its preferred view size. The internal layout of a component should always be dynamically calculated, either using frames or Auto Layout.

### Reacting to view changes

To be able to resize subviews, perform internal layout changes or start animations, you can observe your component's view using `HUBComponentViewObserver`. This enables you to get notified when your component's view was either resized, or when it appeared on the screen.

### Preparing a component for reuse

To reduce the memory footprint of a Hub Framework-powered View, all components are reused when possible. This means that even though a component always maintains its 1:1 relationship with its view, it will potentially be used with many different models.

Just like a collection- or table view cell, a `HUBComponent` will be sent a message when it should prepare itself for reuse; `prepareViewForReuse`. When this is called, each component should make sure to reset any state and cleanup so that it can be reused for a new model.

### Rendering a component model

When its time for a component or render a visual representation of a model, it will be sent the `configureViewWithModel:` message. The component itself decides what parts of the supplied `HUBComponentModel` that it wants to use, and how to bind the data contained within the model to any visual building blocks that it uses.

So again a component implementation is very free-form, but it's definitely recommended to properly document how each component implementation uses a model.

A component is free to hold a reference to its current model, in case it needs it for any other task - but it should always make sure to reset any such reference to `nil` in `prepareViewForReuse`.

## Image handling

The Hub Framework provides built-in support for both local and remote images for components. However the actual images are rendered is up to each component, but the framework takes care of facilitating all loading of images.

There are 3 categories of images supported; `Main`, `Background` and `Custom`. The last category - `Custom` - enables you to define a dictionary of custom images for certain identifiers - practically allowing you to define any number of images for a component.

For each image, the Hub Framework creates a set of data - `HUBComponentImageData` that contains hints about how an image should be rendered - and also any remote image URL and/or local image.

### Using local images

In order to use a local image that was defined during the content loading phase, simply access `localImage` on a `HUBComponentImageData` object.

### Using remote images

If a component supports rendering remote images that are downloaded over the network, it should conform to `HUBComponentWithImageHandling`. This will tell the framework to load images for that specific component.

First, the component will be asked what size it would prefer that a downloaded image would be (potentially) resized to, secondly - it gets a callback once the image was downloaded.

## Managing child components

Optionally, a component can chose to support child components - either through just the use of `HUBComponentModel` data, or with full `HUBComponent` implementations as its subviews.

### Declaring support for child components

If a component has support for child components, it should conform to the `HUBComponentWithChildren` protocol, and use its `childDelegate` to notify the Hub Framework whenever a child component appeared, disappeared, or was selected.

This enables the author of the component to take advantage of the built in selection handling of the Hub Framework (and potentially any universal hooks that have been added - such as logging or default actions).

### Using HUBComponentModel data only

One way of using child components is to only use the data that the Hub Framework provides for them - through the `childComponentModels` property on a `HUBComponentModel`. Doing this, a component is free to create visual representations of its children in whatever way it sees fit - such as using "normal" `UIView` instances and doing the managing of those views itself.

This can sometimes be the preferred approach for providing lightweight support for child components - without the level of dynamism that using `HUBComponent` implementations provides.

### Using nested HUBComponents

To make a component that can render any child component; use nested `HUBComponent` implementations. You can easily create such child components using the `component:createChildComponentAtIndex:` method on your component's `childDelegate`.

The component returned from this method will have a loaded view and be resized to its default size - but it's up to each component implementation to manage its child components.

## Saving and restoring UI state

Some components have specific UI states that ideally should be preserved between reuses when the same model is rendered. For example, if a component is scrollable horizontally you might want to retain the scroll position per model, so that state isn't lost when the component is reused.

To do that, make your component conform to `HUBComponentWithRestorableUIState`. This will make the Hub Framework call `currentUIState` on your component before each reuse takes place - giving you a chance to return a UI state that should be saved.

You can use any type to model your UI state. For example, in the case of a scroll position an `NSValue` containing a `CGPoint` is probably a good choice.

Once your component has started to render a model for which a UI state was previously saved, the framework will call `restoreUIState:` on your component with the saved state, allowing the component to restore it.

Thanks to this API, you can hide the fact that components are reused for your users, as from their perspective it will look like the component was there all along.

## Responding to user interactions

If you want your component to adapt its appearance when the user interacts with it (mimicking the behavior as when highlighting or selecting a `UITableViewCell`), you can make it conform to `HUBComponentWithSelectionState`.

The Hub Framework supports two selection states; `Highlighted` and `Selected`. Your component will automatically be called and asked to update its view for a new selection state when the user either touches it (highlight), or taps it (selection).

Here we are implementing a component and modifying its view's `alpha` in response to user interactions:

```objective-c
- (void)updateViewForSelectionState:(HUBComponentSelectionState)selectionState
{
    switch (selectionState) {
        case HUBComponentSelectionStateNone:
            self.view.alpha = 1;
            break;
        case HUBComponentSelectionStateHighlighted:
            self.view.alpha = 0.7;
            break;
        case HUBComponentSelectionStateSelected:
            self.view.alpha = 0.5;
            break;
    }
}
```

## Integrating a component with the framework

Components are integrated with the Hub Framework through a `HUBComponentFactory` implementation. Usually each feature that supplies components into the framework will have its own factory implementation.

You register a factory with `HUBComponentRegistry`, available on the application's `HUBManager`. Each factory is registered for a certain `namespace`, which will make the Hub Framework dispatch to that factory if a `HUBComponentModel` has that component `namespace`.

A factory is responsible for creating new component instances for a given `name`, or returning `nil` if the supplied `name` is not supported by the factory.

*(For more information about component `namespaces` and `names`, see the [Content programming guide](https://spotify.github.io/HubFramework/content-programming-guide.html)).*

To create a factory implementation, add a new `class` and make it conform to `HUBComponentFactory`:

```objective-c
@implementation SPTHubComponentFactory

- (nullable id<HUBComponent>)createComponentForName:(NSString *)name
{
    if ([name isEqualToString:@"myComponentName"]) {
        return [SPTMyHubComponent new];
    }
    
    return nil;
}

@end
```

## Best practices

Components and their corresponding models (`HUBComponentModel`) are very free-form by design. We didn't want to strictly enforce how data is bound to views, or which `UIView` types that are usable for components, since that won't scale for new UI ideas and large teams. We want component authors to be able to move really fast, without a lot of restrictions.

However, there are some best practices that are recommended to follow when building new components, so that they become intuitive and easy to use for other developers. Here are some things to keep in mind:

#### Use the properties on `HUBComponentModel` as documented

All the properties that are available as first-class citizens on `HUBComponentModel` have documentation detailing their recommended usage. For example, use `title` for the most prominent piece of text in your component, then `subtitle` etc. That way your component will have a predictable behavior when used with various models.

#### Use `customData` only when customization is needed

Both `HUBComponentModel` and `HUBViewModel` have a `customData` property that enables you to set custom keys & values that can be used by your feature & components. This is an essential part of the API as it provides an easy way to extend the models for new ideas & concepts that we didn't consider when designing the models.

With that being said, if there is a way to use the properties already available on `HUBComponentModel`, that is definitely preferred. Using the properties, you'll get things like automatic type checking and compatibility with other components.

If you encounter a piece of data that is common across multiple components & applications, and should be included in `HUBComponentModel` as a first-class property, feel free to open an issue or send a PR!

#### Document how your component behaves

Components have built-in reusability, so it's recommended that you prepare them for reuse - not only for different models - but for different developers as well. It's recommended to thoroughly document what `HUBComponentModel` data your component uses, and how it behaves in terms of interactions, animations, etc.

#### Use the framework for as many events as you can

The Hub Framework provides a lot of built-in functionality to handle events (like selection, appearance, etc) - and rather than building your own functionality for those kind of events - it's recommended to leverage the framework. That way you'll get a consistent behavior with other components, and reduce code duplication.

If there's some functionality that you need but doesn't exist yet - considering opening an issue for it - or implement it and send a PR!