# JSON Programming Guide

Welcome to the Hub Framework JSON programming guide! This guide aims to act as a reference to the default JSON schema provided by the framework, and also contain information on how to enable a custom JSON schema to be used with the framework.

Before reading this guide, it's recommended to read the [Content programming guide](content-programming-guide), which goes into more detail on how content is built with the Hub Framework.

**Table of contents**

- [Introduction](#introduction)
- [JSON schema hierarchy](#json-schema-hierarchy)
- [Default JSON schema](#default-json-schema)
- [Using custom JSON schemas](#using-custom-json-schemas)

## Introduction

The Hub Framework enables content for views to be defined through JSON. This can make it a lot faster to ship content changes, since content can be defined completely in a server-side system, without requiring a client release.

Any JSON schema can be used with the Hub Framework, and each feature using the framework has the ability to define its own. This enables you to start using the Hub Framework without modifying any server-side system that produces the JSON that you're consuming, and also enables multiple teams working on the same application to potentially use different JSON schemas.

For convenience; the Hub Framework ships with a default JSON schema, that is guaranteed to be synced across both iOS & Android.

## JSON schema hierarchy

To match the content models that JSON data feeds into; each JSON schema that is used with the Hub Framework contains 3 **sub-schemas**.

- `HUBViewModelJSONSchema` - for `HUBViewModel`.
- `HUBComponentModelJSONSchema` - for `HUBComponentModel`.
- `HUBComponentImageDataJSONSchema` - for `HUBComponentImageData`.

JSON data can either be supplied with a root dictionary (in the form of a serialized view model), or with a root array (where each element contains a serialized component model).

## Default JSON schema

To use the default JSON schema, no additional action is required. Every feature that **don't** declare a custom JSON schema automatically use the default one.

Here is a reference for the default JSON schema:

### View model schema

`id` : `String`

The identifier of the view model. Can be used for logging, or to identify the view in various delegate methods & handlers. Maps to `identifier`.

`feature` : `String`

The identifier of the feature that the view belongs to (if other than what has been defined client side). Can be used for logging, or to identifier the view's feature in various delegate methods & handlers. Maps to `featureIdentifier`.

`title` : `String`

The title to use for the view's navigation bar. Maps to `navigationBarTitle`.

`header` : `Dictionary -> ComponentModel`

Dictionary for a component model that should be used as the view's header component. Will be parsed using the schema for component models. Maps to `headerComponentModel`.

`body` : `[Dictionary] -> [ComponentModel]`

An array of dictionaries for the component models that should be used for the view's body components. Will be parsed using the schema for component models. Maps to `bodyComponentModels`.

`overlays` : `[Dictionary] -> [ComponentModel]`

An array of dictionaries for the component models that should be used for the view's overlay components. Will be parsed using the schema for component models. Maps to `overlayComponentModels`.

`extension` : `String -> URL`

Any URI to use to extend this view model. This can be used to easily implement content pagination. Maps to `extensionURL`.

`custom` : `Dictionary`

Any custom (free-form) data to associate with the view model. Maps to `customData`.

### Component model schema

*When a dot (`.`) is being used in the key, it means that the key is nested within another dictionary. For example `text.title` means that the structure looks like this:*

```
{
    "text": {
        "title": "The title"
    }
}
```

`id` : `String`

The identifier of the component model. Can be used for logging, or to identify the model in other content operations, various delegate methods, handlers, etc. Maps to `identifier`.

`component.id` : `String`

The identifier (`namespace:name`) of the component to use to render the model. Maps to `componentNamespace` and `componentName`.

`component.category` : `String`

`text.title` : `String`

The title that the component should display. Maps to `title`.

`text.subtitle` : `String`

The subtitle that the component should display. Maps to `subtitle`.

`text.accessory` : `String`

Any accessory title for the component. Usually used to render some form of metadata or accessory information with less prominence. Maps to `accessoryTitle`.

`text.description` : `String`

Any longer body of text that should be displayed in the component. Maps to `descriptionText`.

`images.icon` : `String`

Any icon that should be displayed in the component. Will be resolved using the application's `HUBIconImageResolver`. Maps to `icon`.

`images.main` : `Dictionary -> ComponentImageData`

The data for the component's main image, that will be displayed in the foreground of the component. Will be parsed using the schema for component image data. Maps to `mainImageData`.

`images.background` : `Dictionary -> ComponentImageData`

The data for the component's background image. Will be parsed using the schema for component image data. Maps to `backgroundImageData`.

`images.custom` : `{String : Dictionary -> ComponentImageData}`

A dictionary containing dictionaries for custom image data that the component may use. Each nested dictionary will be parsed using the schema for component image data. Maps to `customImageData`.

`target.uri` : `String -> URL`

Any URI that should be opened when the user interacts with the component. Maps to `targetURL`.

`target.view` : `Dictionary -> ViewModel`

Any pre-loaded view model that should be used for a Hub Framework-powered view that is the destination for `targetURL`. Will be parsed using the schema for view models. Maps to `targetInitialViewModel`.

`metadata` : `Dictionary`

Any application-specific metadata to associate with the component. Typically this data is not consumed by the component itself, but by application-wide systems such as playback for a media app, or photo metadata for a photo app, etc. Maps to `metadata`.

`logging` : `Dictionary`

Logging information that can be used to log events that occur for the component. Each application should define what keys that are used in this dictionary. Maps to `loggingData`.

`custom` : `Dictionary`

Dictionary used to provide an extension point for component authors. Each component can define which keys that it wants to use from this dictionary, enabling customization of properties that are not included as first-class properties in the component model schema. Maps to `customData`.

`children` : `[Dictionary] -> [ComponentModel]`

An array of dictionaries for the component models that should be used for the component's children. Will be parsed using the schema for component models. Maps to `childComponentModels`.

### Component image data schema

`style` : `String`

The style of the image. Possible values are `rectangular` (default), `circular` and `none`. Maps to `style`.

`uri` : `String`

The URI of the image. Used to download a remote image using the application's `HUBImageLoader(Factory)`. Maps to `URL`.

`placeholder` : `String`

Any icon to use as a placeholder until a remote image has been downloaded. Will be resolved using the application's `HUBIconImageResolver`. Maps to `placeholderIcon`.

## Using custom JSON schemas

Custom JSON schemas can be used to easily use existing server side data with the Hub Framework. All you need to do is let the framework know how to parse your expected JSON format, and it takes care of the rest.

### Defining JSON paths

In order to support the level of flexibility required to be able to parse virtually any JSON schema, the Hub Framework uses a path-based approach to JSON parsing. Each piece of data that should be retrieved is associated with a path, that is then followed into a JSON structure to retrieve that data.

For example; let's say we want to retrieve the `title` string that is nested within the `text` dictionary, as below:

```
{
    "text": {
        "title": "The title"
    }
}
```

To do that, we use the following path:

```objective-c
[[[path goTo:@"text"] goTo:@"title"] stringPath];
```

This tells the Hub Framework's JSON parsing system that it should navigate through the `text` and `title` keys, and then retrieve the string value for that key.

Paths are defined using `HUBMutableJSONPath`, which can be created from a `HUBJSONSchema`, which in turn can be created from `HUBJSONSchemaRegistry`. Each path is then attached to a schema, which is then registered using `HUBJSONSchemaRegistry`.

Paths can also perform a lot more complex operations, such as running a block. For more information, see the code documentation for `HUBMutableJSONPath`.

### Extending an existing schema

Sometimes you just want to slightly tweak the default schema (or any existing custom schema), instead of building one from scratch.

All schemas that are created by the Hub Framework come setup according to the default schema, so all you need to do is tweak the properties that you want to tweak.

In order to extend an existing custom schema, use the `copySchemaWithIdentifier:` method on `HUBJSONSchemaRegistry`.