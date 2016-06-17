#import "HUBComponent.h"

@protocol HUBComponentWithChildren;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol used to send events related to a component's children back to the Hub Framework
 *
 *  You don't implement this protocol yourself. Instead, you @synthesize your component's `childDelegate`
 *  property, and may choose to send any of these methods to it to notify it of events, as well as creating
 *  child component instances.
 *
 *  It's definitely recommended to use this protocol as much as possible when using child components, since
 *  you can leverage the framework's built-in capabilities for selection, image loading & other events.
 */
@protocol HUBComponentChildDelegate <NSObject>

/**
 *  Create a component for a child model at a given index
 *
 *  @param component The parent component
 *  @param childIndex The index of the child component to be created
 *
 *  You may choose to use this method to create components to use to represent any child models that you
 *  wish to render in your component. Note that it is not required to use this method to create views or other
 *  visual representation for child components, but it's a convenient way - especially for components that wish
 *  to be truly dynamic with which child components they support.
 *
 *  @return A component that has its view loaded, is resized and ready to use. Nil is returned if an out-of-
 *  bounds index was supplied as `childIndex`. The Hub Framework will not manage the created component further,
 *  nor will it retain it, so it's up to you to add it to your component's view, position it, and do any other
 *  setup work required.
 */
- (nullable id<HUBComponent>)component:(id<HUBComponentWithChildren>)component
           createChildComponentAtIndex:(NSUInteger)childIndex;

/**
 *  Notify the Hub Framework that a component is about to display a child component at a given index
 *
 *  @param component The parent component
 *  @param childIndex The index of the child component that is about to be displayed
 *  @param childView The view of the child component that is about to be displayed
 *
 *  If your component has nested child components, you should call this method every time a child is about to
 *  appear on the screen, to enable the Hub Framework to load images and perform other setup work for it.
 */
- (void)component:(id<HUBComponentWithChildren>)component willDisplayChildAtIndex:(NSUInteger)childIndex view:(UIView *)childView;

/**
 *  Notify the Hub Framework that a component has stopped displaying a child component at a given index
 *
 *  @param component The parent component
 *  @param childIndex The index of the child component that is no longer being displayed
 *  @param childView The view of the child component that is no longer displayed
 */
- (void)component:(id<HUBComponentWithChildren>)component didStopDisplayingChildAtIndex:(NSUInteger)childIndex view:(UIView *)childView;

/**
 *  Notify the Hub Framework that a component's child component has been selected
 *
 *  @param component The parent component
 *  @param childIndex The index of the child component that was selected
 *  @param childView The view of the child component that was selected
 *
 *  If your component has nested child components, you should call this method every time a child component was
 *  selected by the user, to enable the Hub Framework to handle the selection.
 */
- (void)component:(id<HUBComponentWithChildren>)component childSelectedAtIndex:(NSUInteger)childIndex view:(UIView *)childView;

@end

/**
 *  Extended Hub component protocol that adds the ability to handle child components
 *
 *  Use this protocol if your component supports nesting other components within it. Use the assigned
 *  `childDelegate` to let the Hub Framework perform tasks for nested components for you. See `HUBComponent`
 *  for more info.
 */
@protocol HUBComponentWithChildren <HUBComponent>

/**
 *  The object that acts as a delegate for events related to the component's children
 *
 *  Don't assign any custom objects to this property. Instead, just @sythensize it, so that the Hub Framework can
 *  assign an internal object to this property, to enable you to send events for the component's children back from
 *  the component to the framework, as well as creating child component instances.
 */
@property (nonatomic, weak, nullable) id<HUBComponentChildDelegate> childDelegate;

@end

NS_ASSUME_NONNULL_END
