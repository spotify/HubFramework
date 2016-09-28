# Action Programming Guide

Welcome to the Hub Framework action programming guide! This guide aims to help you gain a deeper understanding of how actions work, how to create them and how you can use them to easily extend the framework with additional functionality.

If you haven't already - we really recommend that you read the [component programming guide](https://ghe.spotify.net/pages/iOS/HubFramework/component-programming-guide.html) and [content programming guide](https://ghe.spotify.net/pages/iOS/HubFramework/content-programming-guide.html) before proceeding with this one.

**Table of contents**

- [Introduction](#introduction)

## Introduction

The Hub Framework comes with built-in selection handling for components. Whenever a component is selected, the `URI` associated with that component's `target` will be opened, using the standard `[UIApplication openURL:]` API. However, if you want to customize the selection behavior, or execute other type of actions based on other user interactions - that's when the Action API comes in handy.

The Action API also makes it easy to send events back to your content operations from your components.

## Creating an action

Just like components, content operations and the other aspects of the Hub Framework, actions are defined using a protocol - `HUBAction`. Actions are very simple to implement, all you require is one method:

```objective-c
@interface SPTMyHubAction : NSObject <HUBAction>

@end
```

```objective-c
@implementation SPTMyHubAction

- (BOOL)performWithContext:(id<HUBActionContext>)context
{
    // Return a boolean indicating whether the action was performed or not
    return YES;
}

@end
```

The contextual object passed to the action contains useful information like what view controller (and for which view URI) the action is being performed, as well as the component & view model that the action should be performed for.

## Integrating an action with the framework

Before an action can be used, it must be integrated into the Hub Framework. This is done through the `HUBActionRegistry` API, which works similar to how the `HUBComponentRegistry` works for components.

In order to avoid accidentally sharing state between actions, all actions are uniquely created before they are performed, using a factory - an implementation of `HUBActionFactory`.

So, to integrate your action into the framework, first create a factory class:

```objective-c
@interface SPTMyActionFactory : NSObject <HUBActionFactory>

@end
```

```objective-c
@implementation SPTMyActionFactory

- (nullable id<HUBAction>)createActionForName:(NSString *)name
{
    if ([name isEqualToString:@"myAction"]) {
        return [SPTMyAction new];
    }
    
    return nil;
}

@end
```

Then, register your factory with the action registry (available on `HUBManager`):

```objective-c
id<HUBActionFactory> factory = [SPTMyActionFactory new];
[actionRegistry registerActionFactory:factory forNamespace:@"myNamespace"];
```

The `namespace` used when registering the factory are used to match actions when performed - just like the way components are matched.

## Triggering an action

### Triggering an action from a component model

Actions that are associated with a `HUBComponentModel` will automatically be triggered when a component rendering that model was selected by the user.

To add actions to a component model, you add a `HUBIdentifier` matching your action's `name` and `namespace` (that your factory was registered for) either using code in a content operation:

```
id<HUBComponentModelBuilder> componentModelBuilder = [viewModelBuilder builderForBodyComponentModelWithIdentifier:@"myComponent"];
[componentModelBuilder.targetBuilder addActionWithNamespace:@"myNamespace"
                                                       name:@"myAction"];
```

Or using JSON:

```json
// A component model dictionary
{
   "target": {
       "actions": ["myNamespace:myAction"]
   }
}
```

### Triggering an action from a component

You can also have a component implementation manually trigger an action. This can be done at any point in time, for example in response to a custom user interaction (such as a swipe), or some other event.

To make a component able to perform actions, make it conform to the `HUBComponentActionPerformer` protocol. This gives you an `actionDelegate` that you can call to perform an action for a given identifier (which will be resolved exactly the same way as when action identifiers are attached to a `HUBComponentModel`). You also have the option of passing any `customData` that you can then pick up in the action or in a content operation.

Here's an example where we perform an action in response to a `UIGestureRecognizer` being triggered:

```objective-c
- (void)handleGestureRecognizer:(UIGestureRecognizer *)recognizer
{
    HUBIdentifier *actionIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"myFeature" name:@"myAction"];
    [self.actionDelegate component:self performActionWithIdentifier:actionIdentifier customData:nil];
}
```

## Responding to an action in a content operation

As mentioned in the introduction, one thing you can use actions for, is to be able to easily communicate with a content operation from a component. For example, you might want to reschedule an operation based on user interaction, or modify your underlying data.

To observe actions performed in the view that a content operation is serving, conform to the `HUBContentOperationActionObserver` protocol in your content operation.

In the example below, we are rendering a list of songs based on a `SPTSongContentOperation`. We then implement a delete button in one of our components, which will trigger an action to delete the song associated with that component from our data source, and then reschedule our content operation to re-render our view (with the component deleted).

First, the component which performs the action when the delete button is tapped:

```objective-c
@implementation SPTDeletableComponent

- (void)handleDeleteButtonTapped
{
    HUBIdentifier *actionIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"delete" name:@"song"];
    [self.actionDelegate component:self performActionWithIdentifier:actionIdentifier];
}

@end
```

Then, the action, which deletes the song from our data source:

```objective-c
@implementation SPTDeleteSongAction

- (BOOL)performWithContext:(id<HUBActionContext>)context
{
    NSString *songID = context.componentModel.identifier;
    [self.dataSource removeSongWithIdentifier:songID];
    return YES;
}

@end
```

Finally, we observe actions being performed in our content operation, and re-schedule it once a delete action was performed:

```objective-c
@implementation SPTSongContentOperation

- (void)actionPerformedWithContext:(id<HUBActionContext>)context
                           viewURI:(NSURL *)viewURI
                       featureInfo:(id<HUBFeatureInfo>)featureInfo
                 connectivityState:(HUBConnectivityState)connectivityState
{
    HUBIdentifier *deleteSongActionID = [[HUBIdentifier alloc] initWithNamespace:@"delete" name:@"song"];

    if ([context.customActionIdentifier isEqual:deleteSongActionID]) {
        [self.delegate contentOperationRequiresRescheduling:self];
    }
}

@end
```

The result of the above is that every time a delete button is pressed, the component for that song is deleted from the view.

## Handling actions

You can also opt to handle certain actions on a feature level. When you set up your feature with the Hub Framework, you can pass an `actionHandler` (an implementation of the `HUBActionHandler` protocol), that gets called each time an action is about to be performed. The action handler can then choose to handle the action itself, rather than letting the action being performed.

Let's take the "delete a song" example from just before, and add some "protected songs" that are not deletable. That is, when the `SPTDeleteSongAction` is about to be performed, we check if the song is protected, and if it is - we veto the action, preventing it from being performed. Let's implement `HUBActionHandler`:

```objective-c
@implementation SPTMyActionHandler

- (BOOL)handleActionWithContext:(id<HUBActionContext>)context
{
    NSString *songID = context.componentModel.identifier;

    if ([self isSongWithIdentifierProtected:songID]) {
        return YES;
    }
    
    return NO;
}

@end
```

By returning `YES` above, we tell the Hub Framework that we've handled the action in our action handler, which means that the action won't be performed.

A global action handler can also be added when setting up `HUBManager`, that will be used for all features that do not implement their own. For more information about setting up Hub Manager, see the [setup guide](https://ghe.spotify.net/pages/iOS/HubFramework/setup-guide.html).
