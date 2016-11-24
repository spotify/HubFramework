/*
 *  Copyright (c) 2016 Spotify AB.
 *
 *  Licensed to the Apache Software Foundation (ASF) under one
 *  or more contributor license agreements.  See the NOTICE file
 *  distributed with this work for additional information
 *  regarding copyright ownership.  The ASF licenses this file
 *  to you under the Apache License, Version 2.0 (the
 *  "License"); you may not use this file except in compliance
 *  with the License.  You may obtain a copy of the License at
 *
 *  http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 */

#import "HUBCollectionViewLayout.h"

#import "HUBViewModel.h"
#import "HUBComponentModel.h"
#import "HUBComponentRegistry.h"
#import "HUBComponent.h"
#import "HUBComponentWithChildren.h"
#import "HUBIdentifier.h"
#import "HUBComponentLayoutManager.h"
#import "HUBViewModelDiff.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBCollectionViewLayout () <HUBComponentChildDelegate>

@property (nonatomic, strong, nullable) id<HUBViewModel> viewModel;
@property (nonatomic, strong, readonly) id<HUBComponentRegistry> componentRegistry;
@property (nonatomic, strong, readonly) id<HUBComponentLayoutManager> componentLayoutManager;
@property (nonatomic, strong, readonly) NSMutableDictionary<HUBIdentifier *, id<HUBComponent>> *componentCache;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *layoutAttributesByIndexPath;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, NSMutableSet<NSIndexPath *> *> *indexPathsByVerticalGroup;
@property (nonatomic, strong, nullable) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *previousLayoutAttributesByIndexPath;
@property (nonatomic, strong, nullable) HUBViewModelDiff *lastViewModelDiff;

@property (nonatomic) CGSize contentSize;

@end

@implementation HUBCollectionViewLayout

- (instancetype)initWithComponentRegistry:(id<HUBComponentRegistry>)componentRegistry
                   componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
{
    self = [super init];
    
    if (self) {
        _componentRegistry = componentRegistry;
        _componentLayoutManager = componentLayoutManager;
        _componentCache = [NSMutableDictionary new];
        _layoutAttributesByIndexPath = [NSMutableDictionary new];
        _indexPathsByVerticalGroup = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)computeForCollectionViewSize:(CGSize)collectionViewSize
                           viewModel:(id<HUBViewModel>)viewModel
                                diff:(nullable HUBViewModelDiff *)diff
{
    self.lastViewModelDiff = diff;
    self.viewModel = viewModel;

    self.previousLayoutAttributesByIndexPath = [self.layoutAttributesByIndexPath copy];

    [self.layoutAttributesByIndexPath removeAllObjects];
    [self.indexPathsByVerticalGroup removeAllObjects];
    
    BOOL componentIsInTopRow = YES;
    NSMutableArray<id<HUBComponent>> * const componentsOnCurrentRow = [NSMutableArray new];
    CGFloat currentRowMaxY = 0;
    CGPoint currentPoint = CGPointZero;
    CGPoint firstComponentOnCurrentRowOrigin = CGPointZero;
    NSUInteger const allComponentsCount = self.viewModel.bodyComponentModels.count;
    CGFloat maxBottomRowComponentHeight = 0;
    CGFloat maxBottomRowHeightWithMargins = 0;
    
    for (NSUInteger componentIndex = 0; componentIndex < allComponentsCount; componentIndex++) {
        id<HUBComponentModel> const componentModel = self.viewModel.bodyComponentModels[componentIndex];
        id<HUBComponent> const component = [self componentForModel:componentModel];
        NSSet<HUBComponentLayoutTrait> * const componentLayoutTraits = component.layoutTraits;
        BOOL isLastComponent = (componentIndex == allComponentsCount - 1);

        CGRect componentViewFrame = [self defaultViewFrameForComponent:component
                                                                 model:componentModel
                                                          currentPoint:currentPoint
                                                    collectionViewSize:collectionViewSize];

        UIEdgeInsets margins = [self defaultMarginsForComponent:component isInTopRow:componentIsInTopRow
                                         componentsOnCurrentRow:componentsOnCurrentRow
                                             collectionViewSize:collectionViewSize];

        componentViewFrame.origin.x = currentPoint.x + margins.left;

        BOOL couldFitOnTheRow = CGRectGetMaxX(componentViewFrame) + margins.right <= collectionViewSize.width;
        
        if (couldFitOnTheRow == NO) {
            [self updateLayoutAttributesForComponentsIfNeeded:componentsOnCurrentRow
                                           lastComponentIndex:componentIndex - 1
                                              firstComponentX:firstComponentOnCurrentRowOrigin.x
                                               lastComponentX:currentPoint.x
                                                     rowWidth:collectionViewSize.width];

            if (componentsOnCurrentRow.count > 0) {
                margins.top = 0;
                
                for (id<HUBComponent> const verticallyPrecedingComponent in componentsOnCurrentRow) {
                    CGFloat const marginToComponent = [self.componentLayoutManager verticalMarginForComponentWithLayoutTraits:componentLayoutTraits
                                                                                               precedingComponentLayoutTraits:verticallyPrecedingComponent.layoutTraits];
                    
                    if (marginToComponent > margins.top) {
                        margins.top = marginToComponent;
                    }
                }
            }
            
            componentViewFrame.origin.x = [self.componentLayoutManager marginBetweenComponentWithLayoutTraits:componentLayoutTraits
                                                                                               andContentEdge:HUBComponentLayoutContentEdgeLeft];
            
            componentViewFrame.origin.y = currentRowMaxY + margins.top;
            componentIsInTopRow = NO;
            [componentsOnCurrentRow removeAllObjects];
            currentPoint.y = CGRectGetMinY(componentViewFrame);
            currentRowMaxY = CGRectGetMaxY(componentViewFrame) + margins.bottom;
        } else {
            componentViewFrame.origin.y = currentPoint.y + margins.top;
        }
        
        componentViewFrame = [self horizontallyAdjustComponentViewFrame:componentViewFrame
                                                  forCollectionViewSize:collectionViewSize
                                                                margins:margins];
        
        currentPoint.x = CGRectGetMaxX(componentViewFrame);
        currentRowMaxY = MAX(currentRowMaxY, CGRectGetMaxY(componentViewFrame));
        
        [self registerComponentViewFrame:componentViewFrame forIndex:componentIndex];
        
        [componentsOnCurrentRow addObject:component];

        if (componentsOnCurrentRow.count == 1) {
            firstComponentOnCurrentRowOrigin = componentViewFrame.origin;
        }

        if (isLastComponent) {
            // We center components if needed when we go to a new row. If it is the last row we need to center it here
            [self updateLayoutAttributesForComponentsIfNeeded:componentsOnCurrentRow
                                           lastComponentIndex:componentIndex
                                              firstComponentX:firstComponentOnCurrentRowOrigin.x
                                               lastComponentX:currentPoint.x
                                                     rowWidth:collectionViewSize.width];
        }
    }

    self.contentSize = [self contentSizeForContentHeight:currentRowMaxY
                                     bottomRowComponents:componentsOnCurrentRow
                                     minimumBottomMargin:maxBottomRowHeightWithMargins - maxBottomRowComponentHeight
                                      collectionViewSize:collectionViewSize];
}

- (CGPoint)targetContentOffsetForProposedContentOffset:(CGPoint)proposedContentOffset
{
    if (self.previousLayoutAttributesByIndexPath == nil || self.lastViewModelDiff == nil) {
        return proposedContentOffset;
    }

    CGPoint offset = self.collectionView.contentOffset;
    
    NSInteger topmostVisibleIndex = NSNotFound;
    
    for (NSIndexPath *indexPath in [self.collectionView indexPathsForVisibleItems]) {
        topmostVisibleIndex = MIN(topmostVisibleIndex, indexPath.item);
    }
    
    if (topmostVisibleIndex == NSNotFound) {
        topmostVisibleIndex = 0;
    }
    
    for (NSIndexPath *indexPath in self.lastViewModelDiff.insertedBodyComponentIndexPaths) {
        if (indexPath.item < topmostVisibleIndex) {
            UICollectionViewLayoutAttributes *attributes = self.layoutAttributesByIndexPath[indexPath];
            offset.y += CGRectGetHeight(attributes.frame);
        }
    }
    
    for (NSIndexPath *indexPath in self.lastViewModelDiff.deletedBodyComponentIndexPaths) {
        if (indexPath.item <= topmostVisibleIndex) {
            UICollectionViewLayoutAttributes *attributes = self.previousLayoutAttributesByIndexPath[indexPath];
            offset.y -= CGRectGetHeight(attributes.frame);
        }
    }
    
    // Making sure the content offset doesn't go through the roof.
    CGFloat const minContentOffset = -self.collectionView.contentInset.top;
    offset.y = MAX(minContentOffset, offset.y);
    // ...or beyond the bottom.
    CGFloat maxContentOffset = MAX(self.contentSize.height + self.collectionView.contentInset.bottom - CGRectGetHeight(self.collectionView.frame), minContentOffset);
    offset.y = MIN(maxContentOffset, offset.y);
    
    self.previousLayoutAttributesByIndexPath = nil;
    self.lastViewModelDiff = nil;
    
    return offset;
}

#pragma mark - HUBComponentChildDelegate

- (id<HUBComponent>)component:(id<HUBComponentWithChildren>)component childComponentForModel:(id<HUBComponentModel>)childComponentModel
{
    return [self componentForModel:childComponentModel];
}

- (void)component:(id<HUBComponentWithChildren>)component willDisplayChildAtIndex:(NSUInteger)childIndex view:(UIView *)childView
{
    // No-op
}

- (void)component:(id<HUBComponentWithChildren>)component didStopDisplayingChildAtIndex:(NSUInteger)childIndex view:(UIView *)childView
{
    // No-op
}

- (void)component:(id<HUBComponentWithChildren>)component childSelectedAtIndex:(NSUInteger)childIndex customData:(nullable NSDictionary *)customData
{
    // No-op
}

#pragma mark - UICollectionViewLayout

- (nullable NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    NSMutableArray<UICollectionViewLayoutAttributes *> * const layoutAttributes = [NSMutableArray new];
    
    [self forEachVerticalGroupInRect:rect runBlock:^(NSInteger groupIndex) {
        for (NSIndexPath * const indexPath in self.indexPathsByVerticalGroup[@(groupIndex)]) {
            UICollectionViewLayoutAttributes * const layoutAttributesForIndexPath = [self layoutAttributesForItemAtIndexPath:indexPath];

            if (layoutAttributesForIndexPath != nil) {
                [layoutAttributes addObject:layoutAttributesForIndexPath];
            }
        }
    }];
    
    return layoutAttributes;
}

- (nullable UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.layoutAttributesByIndexPath[indexPath];
}

- (BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds
{
    return YES;
}

- (CGSize)collectionViewContentSize
{
    return self.contentSize;
}

#pragma mark - Private utilities

- (id<HUBComponent>)componentForModel:(id<HUBComponentModel>)model
{
    id<HUBComponent> const cachedComponent = self.componentCache[model.componentIdentifier];
    
    if (cachedComponent != nil) {
        return cachedComponent;
    }
    
    id<HUBComponent> const newComponent = [self.componentRegistry createComponentForModel:model];
    self.componentCache[model.componentIdentifier] = newComponent;
    
    if ([newComponent conformsToProtocol:@protocol(HUBComponentWithChildren)]) {
        ((id<HUBComponentWithChildren>)newComponent).childDelegate = self;
    }
    
    return newComponent;
}

- (void)forEachVerticalGroupInRect:(CGRect)rect runBlock:(void(^)(NSInteger groupIndex))block
{
    CGFloat const verticalGroupSize = 100;
    NSInteger const maxVerticalGroup = (NSInteger)(floor(CGRectGetMaxY(rect) / verticalGroupSize));
    NSInteger currentVerticalGroup = (NSInteger)(floor(CGRectGetMinY(rect) / verticalGroupSize));
    
    while (currentVerticalGroup <= maxVerticalGroup) {
        block(currentVerticalGroup);
        currentVerticalGroup++;
    }
}

- (UIEdgeInsets)defaultMarginsForComponent:(id<HUBComponent>)component
                                isInTopRow:(BOOL)componentIsInTopRow
                    componentsOnCurrentRow:(NSArray<id<HUBComponent>> *)componentsOnCurrentRow
                        collectionViewSize:(CGSize)collectionViewSize
{
    NSSet<HUBComponentLayoutTrait> * const componentLayoutTraits = component.layoutTraits;
    UIEdgeInsets margins = UIEdgeInsetsZero;
    
    if (componentIsInTopRow) {
        id<HUBComponentModel> const headerComponentModel = self.viewModel.headerComponentModel;

        if (headerComponentModel != nil) {
            id<HUBComponent> const headerComponent = [self componentForModel:headerComponentModel];
            CGSize headerSize = [headerComponent preferredViewSizeForDisplayingModel:headerComponentModel containerViewSize:collectionViewSize];
            margins.top = headerSize.height + [self.componentLayoutManager verticalMarginBetweenComponentWithLayoutTraits:componentLayoutTraits
                                                                   andHeaderComponentWithLayoutTraits:headerComponent.layoutTraits];
        } else {
            margins.top = [self.componentLayoutManager marginBetweenComponentWithLayoutTraits:componentLayoutTraits
                                                                               andContentEdge:HUBComponentLayoutContentEdgeTop];
        }
    }
    
    if (componentsOnCurrentRow.count == 0) {
        margins.left = [self.componentLayoutManager marginBetweenComponentWithLayoutTraits:componentLayoutTraits
                                                                            andContentEdge:HUBComponentLayoutContentEdgeLeft];
    } else {
        id<HUBComponent> const precedingComponent = [componentsOnCurrentRow lastObject];
        margins.left = [self.componentLayoutManager horizontalMarginForComponentWithLayoutTraits:componentLayoutTraits
                                                                  precedingComponentLayoutTraits:precedingComponent.layoutTraits];
    }
    
    margins.right = [self.componentLayoutManager marginBetweenComponentWithLayoutTraits:componentLayoutTraits
                                                                         andContentEdge:HUBComponentLayoutContentEdgeRight];
    
    return margins;
}

- (CGRect)defaultViewFrameForComponent:(id<HUBComponent>)component
                                 model:(id<HUBComponentModel>)componentModel
                          currentPoint:(CGPoint)currentPoint
                    collectionViewSize:(CGSize)collectionViewSize
{
    CGRect componentViewFrame = CGRectZero;
    componentViewFrame.size = [component preferredViewSizeForDisplayingModel:componentModel containerViewSize:collectionViewSize];
    componentViewFrame.size.width = MIN(CGRectGetWidth(componentViewFrame), collectionViewSize.width);
    return componentViewFrame;
}

- (CGRect)horizontallyAdjustComponentViewFrame:(CGRect)componentViewFrame forCollectionViewSize:(CGSize)collectionViewSize margins:(UIEdgeInsets)margins
{
    CGFloat const horizontalOverflow = CGRectGetMaxX(componentViewFrame) + margins.right - collectionViewSize.width;
    
    if (horizontalOverflow > 0) {
        componentViewFrame.size.width -= horizontalOverflow;
    }
    
    return componentViewFrame;
}

- (void)registerComponentViewFrame:(CGRect)componentViewFrame forIndex:(NSUInteger)componentIndex
{
    NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:(NSInteger)componentIndex inSection:0];
    UICollectionViewLayoutAttributes * const layoutAttributes = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    layoutAttributes.frame = componentViewFrame;
    self.layoutAttributesByIndexPath[indexPath] = layoutAttributes;
    
    [self forEachVerticalGroupInRect:componentViewFrame runBlock:^(NSInteger groupIndex) {
        NSNumber * const encodedGroupIndex = @(groupIndex);
        NSMutableSet<NSIndexPath *> *indexPathsInGroup = self.indexPathsByVerticalGroup[encodedGroupIndex];
        
        if (indexPathsInGroup == nil) {
            indexPathsInGroup = [NSMutableSet new];
            self.indexPathsByVerticalGroup[encodedGroupIndex] = indexPathsInGroup;
        }
        
        [indexPathsInGroup addObject:indexPath];
    }];
}

- (CGSize)contentSizeForContentHeight:(CGFloat)contentHeight
                  bottomRowComponents:(NSArray<id<HUBComponent>> *)bottomRowComponents
                  minimumBottomMargin:(CGFloat)minimumBottomMargin
                   collectionViewSize:(CGSize)collectionViewSize
{
    CGFloat viewBottomMargin = 0;
    
    for (id<HUBComponent> const component in bottomRowComponents) {
        CGFloat const componentBottomMargin = [self.componentLayoutManager marginBetweenComponentWithLayoutTraits:component.layoutTraits
                                                                                                   andContentEdge:HUBComponentLayoutContentEdgeBottom];
        
        viewBottomMargin = MAX(viewBottomMargin, componentBottomMargin);
    }
    
    contentHeight += MAX(viewBottomMargin, minimumBottomMargin);
    
    return CGSizeMake(collectionViewSize.width, contentHeight);
}

- (void)updateLayoutAttributesForComponentsIfNeeded:(NSArray<id<HUBComponent>> *)components
                                 lastComponentIndex:(NSUInteger)lastComponentIndex
                                    firstComponentX:(CGFloat)firstComponentX
                                     lastComponentX:(CGFloat)lastComponentX
                                           rowWidth:(CGFloat)rowWidth
{
    NSArray<NSSet<HUBComponentLayoutTrait> *> *componentsTraits = [components valueForKey:NSStringFromSelector(@selector(layoutTraits))];
    CGFloat adjustment = [self.componentLayoutManager horizontalOffsetForComponentsWithLayoutTraits:componentsTraits
                                                              firstComponentLeadingHorizontalOffset:firstComponentX
                                                              lastComponentTrailingHorizontalOffset:rowWidth - lastComponentX];
    [self updateLayoutAttributesForComponents:components horizontalAdjustment:adjustment lastComponentIndex:lastComponentIndex];
}

- (void)updateLayoutAttributesForComponents:(NSArray<id<HUBComponent>> *)components
                       horizontalAdjustment:(CGFloat)horizontalAdjustment
                         lastComponentIndex:(NSUInteger)lastComponentIndex
{
    if (horizontalAdjustment == 0.0) {
        return;
    }

    NSUInteger indexOfFirstComponentOnTheRow = lastComponentIndex - components.count + 1;
    for (NSUInteger index = indexOfFirstComponentOnTheRow; index <= lastComponentIndex; index++) {
        NSIndexPath * const indexPath = [NSIndexPath indexPathForItem:(NSInteger)index inSection:0];
        UICollectionViewLayoutAttributes * const layoutAttributes = [self layoutAttributesForItemAtIndexPath:indexPath];
        CGRect adjustedFrame = layoutAttributes.frame;
        adjustedFrame.origin.x += horizontalAdjustment;

        [self registerComponentViewFrame:adjustedFrame forIndex:index];
    }
}

@end

NS_ASSUME_NONNULL_END
