# Layout Programming Guide

Welcome to the Hub Framework layout programming guide! This guide aims to help you gain a deeper understanding of how the Hub Framework works in terms of layout.

**Table of contents**

- [Introduction](#introduction)
- [Layout traits](#layout-traits)
- [Layout manager](#layout-manager)

## Introduction

In order to both support quick iteration & development of components & content, and also be able to ensure consistent layout behavior throughout an application, The Hub Framework uses a centralized layout system - that has information fed into it by components.

There are two key parts to the Hub Framework layout system; **Layout traits** and a **Layout manager**. Those two parts are then used together with `UICollectionView`, and a custom `UICollectionViewLayout`.

## Layout traits

Each `HUBComponent` has the ability to declare a set of layout traits. These traits don't contain information about absolute margins or padding, but rather informs the framework's layout manager how to compute metrics.

The Hub Framework ships with a standard library of layout traits, but more can easily be added by applications using the framework (by declaring a new `HUBComponentLayoutTrait` constant). It's recommended to keep layout traits global in an application, to be able to create clearly defined rules around layout.

```objective-c
// extend HUBComponentLayoutTrait with a custom trait
static HUBComponentLayoutTrait const HUBComponentLayoutTraitLeftMarginOnly = @"leftMarginOnly";
```

An example of a layout trait is `HUBComponentLayoutTraitCompactWidth`, which is used for components that should have horizontal margin on each side (and not stretch the entire view). The opposite of this trait is `HUBComponentLayoutTraitFullWidth`, which tells the layout manager that no horizontal margin should be added.

So layout traits are a way do describe layout, rather than specifying hard rules or metrics. The advantage of this approach is that components can be completely unaware of each other, while still being laid out in a predictable way.

## Layout manager

The other key part of the Hub Framework layout system, is `HUBComponentLayoutManager`. Each instance of the framework has a single layout manager, that does all the computation of margins for components. To be able to make an informed decision, the layout manager is given access to the layout traits for the component(s) that it's computing margins for.

Let's make a simple implementation of `HUBComponentLayoutManager`, that uses a `15 point` vertical margin for all components (except for those with the `HUBComponentLayoutTraitStackable` trait) and a `20 point` horizontal margin (except for components with the `HUBComponentLayoutTraitFullWidth` trait):

```objective-c
@implementation LayoutManager

- (CGFloat)marginBetweenComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)layoutTraits
                                   andContentEdge:(HUBComponentLayoutContentEdge)contentEdge
{
    switch (contentEdge) {
        case HUBComponentLayoutContentEdgeTop:
        case HUBComponentLayoutContentEdgeBottom:
            return 15;
        case HUBComponentLayoutContentEdgeLeft:
        case HUBComponentLayoutContentEdgeRight: {
            if ([layoutTraits containsObject:HUBComponentLayoutTraitFullWidth]) {
                return 0;
            }
            
            return 20;
        }
            
    }
}

- (CGFloat)verticalMarginBetweenComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)layoutTraits
                       andHeaderComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)headerLayoutTraits
{
    if ([layoutTraits containsObject:HUBComponentLayoutTraitStackable]) {
        return 0;
    }
    
    return 15;
}

- (CGFloat)horizontalMarginForComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)layoutTraits
                         precedingComponentLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)precedingComponentLayoutTraits
{
    if ([layoutTraits containsObject:HUBComponentLayoutTraitFullWidth]) {
        return 0;
    }

    return 20;
}

- (CGFloat)verticalMarginForComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)layoutTraits
                       precedingComponentLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)precedingComponentLayoutTraits
{
    if ([layoutTraits containsObject:HUBComponentLayoutTraitStackable] && [precedingComponentLayoutTraits containsObject:HUBComponentLayoutTraitStackable]) {
        return 0;
    }
    
    return 15;
}

@end
```

That's it! Now we'll get proper layout for all components using the above layout traits, and we can easily add new rules (in a central place) whenever new traits are introduced.
