#import "HUBCollectionViewLayout.h"

#import "HUBViewModel.h"
#import "HUBComponentModel.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBComponent.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentLayoutManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface HUBCollectionViewLayout ()

@property (nonatomic, strong, readonly) id<HUBViewModel> viewModel;
@property (nonatomic, strong, readonly) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong, readonly) id<HUBComponentLayoutManager> componentLayoutManager;
@property (nonatomic, strong, readonly) NSMutableDictionary<HUBComponentIdentifier *, id<HUBComponent>> *componentCache;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSIndexPath *, UICollectionViewLayoutAttributes *> *layoutAttributesByIndexPath;
@property (nonatomic, strong, readonly) NSMutableDictionary<NSNumber *, NSMutableSet<NSIndexPath *> *> *indexPathsByVerticalGroup;
@property (nonatomic) CGSize contentSize;

@end

@implementation HUBCollectionViewLayout

- (instancetype)initWithViewModel:(id<HUBViewModel>)viewModel
                componentRegistry:(HUBComponentRegistryImplementation *)componentRegistry
           componentLayoutManager:(id<HUBComponentLayoutManager>)componentLayoutManager
{
    self = [super init];
    
    if (self) {
        _viewModel = viewModel;
        _componentRegistry = componentRegistry;
        _componentLayoutManager = componentLayoutManager;
        _componentCache = [NSMutableDictionary new];
        _layoutAttributesByIndexPath = [NSMutableDictionary new];
        _indexPathsByVerticalGroup = [NSMutableDictionary new];
    }
    
    return self;
}

- (void)computeForCollectionViewSize:(CGSize)collectionViewSize
{
    [self.layoutAttributesByIndexPath removeAllObjects];
    [self.indexPathsByVerticalGroup removeAllObjects];
    
    CGFloat contentHeight = 0;
    BOOL componentIsInTopRow = YES;
    NSMutableArray<id<HUBComponent>> * const componentsOnCurrentRow = [NSMutableArray new];
    CGFloat currentRowHeight = 0;
    CGPoint currentPoint = CGPointZero;
    CGPoint firstComponentOnCurrentRowOrigin = CGPointZero;
    NSUInteger const allComponentsCount = self.viewModel.bodyComponentModels.count;
    
    for (NSUInteger componentIndex = 0; componentIndex < allComponentsCount; componentIndex++) {
        id<HUBComponentModel> const componentModel = self.viewModel.bodyComponentModels[componentIndex];
        id<HUBComponent> const component = [self componentForModel:componentModel];
        NSSet<HUBComponentLayoutTrait *> * const componentLayoutTraits = component.layoutTraits;
        
        UIEdgeInsets margins = [self defaultMarginsForComponent:component
                                                     isInTopRow:componentIsInTopRow
                                         componentsOnCurrentRow:componentsOnCurrentRow];
        
        CGRect componentViewFrame = [self defaultViewFrameForComponent:component
                                                                 model:componentModel
                                                               margins:margins
                                                          currentPoint:currentPoint
                                                    collectionViewSize:collectionViewSize];

        BOOL couldFitOnTheRow = CGRectGetMaxX(componentViewFrame) <= collectionViewSize.width;
        
        if (couldFitOnTheRow == NO) {
            [self centerComponentsHorizontallyIfNeeded:componentsOnCurrentRow
                                    lastComponentIndex:componentIndex - 1
                                       firstComponentX:firstComponentOnCurrentRowOrigin.x
                                        lastComponentX:currentPoint.x
                                              rowWidth:collectionViewSize.width];

            if (componentsOnCurrentRow.count > 0) {
                componentViewFrame.origin.y += currentRowHeight;
                margins.top = 0;
                
                for (id<HUBComponent> const verticallyPrecedingComponent in componentsOnCurrentRow) {
                    CGFloat marginToComponent = [self.componentLayoutManager verticalMarginForComponentWithLayoutTraits:componentLayoutTraits
                                                                                         precedingComponentLayoutTraits:verticallyPrecedingComponent.layoutTraits];
                    
                    if (componentIsInTopRow) {
                        marginToComponent += [self.componentLayoutManager marginBetweenComponentWithLayoutTraits:verticallyPrecedingComponent.layoutTraits
                                                                                                  andContentEdge:HUBComponentLayoutContentEdgeTop];
                    }
                    
                    if (marginToComponent > margins.top) {
                        margins.top = marginToComponent;
                    }
                }
            }
            
            componentViewFrame.origin.x = [self.componentLayoutManager marginBetweenComponentWithLayoutTraits:componentLayoutTraits
                                                                                               andContentEdge:HUBComponentLayoutContentEdgeLeft];
            
            componentViewFrame.origin.y = currentPoint.y + currentRowHeight + margins.top;
            componentIsInTopRow = NO;
            [componentsOnCurrentRow removeAllObjects];
            currentPoint.y = CGRectGetMinY(componentViewFrame);
            currentRowHeight = CGRectGetHeight(componentViewFrame);
        } else {
            componentViewFrame.origin.y = currentPoint.y + margins.top;
        }
        
        componentViewFrame = [self horizontallyAdjustComponentViewFrame:componentViewFrame
                                                  forCollectionViewSize:collectionViewSize
                                                                margins:margins];
        
        currentPoint.x = CGRectGetMaxX(componentViewFrame);
        currentRowHeight = MAX(currentRowHeight, CGRectGetHeight(componentViewFrame));
        
        [self registerComponentViewFrame:componentViewFrame forIndex:componentIndex];
        
        contentHeight = currentPoint.y + currentRowHeight;
        [componentsOnCurrentRow addObject:component];

        if (componentsOnCurrentRow.count == 1) {
            firstComponentOnCurrentRowOrigin = componentViewFrame.origin;
        }

        BOOL isLastComponent = (componentIndex == allComponentsCount - 1);
        // We center components if needed when we go to a new row. If it is the last row we need to center it here
        if (isLastComponent) {
            [self centerComponentsHorizontallyIfNeeded:componentsOnCurrentRow
                                    lastComponentIndex:componentIndex
                                       firstComponentX:firstComponentOnCurrentRowOrigin.x
                                        lastComponentX:currentPoint.x
                                              rowWidth:collectionViewSize.width];
        }


    }

    self.contentSize = [self contentSizeForContentHeight:contentHeight
                                     bottomRowComponents:componentsOnCurrentRow
                                      collectionViewSize:collectionViewSize];
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
{
    NSSet<HUBComponentLayoutTrait *> * const componentLayoutTraits = component.layoutTraits;
    UIEdgeInsets margins = UIEdgeInsetsZero;
    
    if (componentIsInTopRow) {
        id<HUBComponentModel> const headerComponentModel = self.viewModel.headerComponentModel;
        
        if (headerComponentModel != nil) {
            id<HUBComponent> const headerComponent = [self componentForModel:headerComponentModel];
            margins.top = [self.componentLayoutManager verticalMarginBetweenComponentWithLayoutTraits:componentLayoutTraits
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
                               margins:(UIEdgeInsets)componentMargins
                          currentPoint:(CGPoint)currentPoint
                    collectionViewSize:(CGSize)collectionViewSize
{
    CGRect componentViewFrame = CGRectZero;
    componentViewFrame.origin.x = currentPoint.x + componentMargins.left;
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

- (CGSize)contentSizeForContentHeight:(CGFloat)contentHeight bottomRowComponents:(NSArray<id<HUBComponent>> *)bottomRowComponents collectionViewSize:(CGSize)collectionViewSize
{
    CGFloat viewBottomMargin = 0;
    
    for (id<HUBComponent> const component in bottomRowComponents) {
        CGFloat const componentBottomMargin = [self.componentLayoutManager marginBetweenComponentWithLayoutTraits:component.layoutTraits
                                                                                                   andContentEdge:HUBComponentLayoutContentEdgeBottom];
        
        viewBottomMargin = MAX(viewBottomMargin, componentBottomMargin);
    }
    
    contentHeight += viewBottomMargin;
    
    return CGSizeMake(collectionViewSize.width, contentHeight);
}

#pragma mark Centering

- (void)centerComponentsHorizontallyIfNeeded:(NSArray *)components
                          lastComponentIndex:(NSUInteger)lastComponentIndex
                             firstComponentX:(CGFloat)minX
                              lastComponentX:(CGFloat)maxX
                                    rowWidth:(CGFloat)rowWidth
{
    NSArray<NSSet<HUBComponentLayoutTrait *> *> *componentsTraits = [components valueForKey:NSStringFromSelector(@selector(layoutTraits))];
    CGFloat adjustment = [self.componentLayoutManager horizontalOffsetForComponentsWithLayoutTraits:componentsTraits
                                                              firstComponentLeadingHorizontalOffset:minX
                                                              lastComponentTrailingHorizontalOffset:rowWidth - maxX];
    [self updateLayoutAttributesForComponents:components originXAdjustment:adjustment lastComponentIndex:lastComponentIndex];
}

- (void)updateLayoutAttributesForComponents:(NSArray *)components
                          originXAdjustment:(CGFloat)horizontalAdjustment
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
