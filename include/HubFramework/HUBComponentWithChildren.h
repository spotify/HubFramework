#import "HUBComponent.h"

@protocol HUBComponentWithChildren;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Delegate protocol used to communicate back to the Hub Framework from a component implementation
 *
 *  You don't implement this protocol yourself. Instead, you @synthesize your component's `childEventHandler`
 *  property, and may choose to send any of these methods to it to notify it of events.
 */
@protocol HUBComponentChildEventHandler <NSObject>

/**
 *  Notify the Hub Framework that a component is about to display a child component at a given index
 *
 *  @param component The parent component
 *  @param childIndex The index of the child component that is about to be displayed
 *
 *  If your component has nested child components, you should call this method every time a child is about to
 *  appear on the screen, to enable the Hub Framework to load images and perform other setup work for it.
 */
- (void)component:(id<HUBComponentWithChildren>)component willDisplayChildAtIndex:(NSUInteger)childIndex;

/**
 *  Notify the Hub Framework that a component's child component has been selected
 *
 *  @param component The parent component
 *  @param childIndex The index of the child component that was selected
 *
 *  If your component has nested child components, you should call this method every time a child component was
 *  selected by the user, to enable the Hub Framework to handle the selection.
 */
- (void)component:(id<HUBComponentWithChildren>)component childSelectedAtIndex:(NSUInteger)childIndex;

@end

/**
 *  Extended Hub component protocol that adds the ability to handle child components
 *
 *  Use this protocol if your component supports nesting other components within it. Use the assigned
 *  `childEventHandler` to let the Hub Framework perform tasks for nested components for you. See `HUBComponent`
 *  for more info.
 */
@protocol HUBComponentWithChildren <HUBComponent>

/**
 *  The object that handles events for the component's children
 *
 *  Don't assign any custom objects to this property. Instead, just @sythensize it, so that the Hub Framework can
 *  assign an internal object to this property, to enable you to send events for the component's children back from
 *  the component to the framework.
 */
@property (nonatomic, weak, nullable) id<HUBComponentChildEventHandler> childEventHandler;

@end

NS_ASSUME_NONNULL_END
