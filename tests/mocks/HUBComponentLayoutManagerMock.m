#import "HUBComponentLayoutManagerMock.h"

@implementation HUBComponentLayoutManagerMock

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        _contentEdgeMarginsForLayoutTraits = [NSMutableDictionary new];
        _headerMarginsForLayoutTraits = [NSMutableDictionary new];
        _horizontalComponentMarginsForLayoutTraits = [NSMutableDictionary new];
        _verticalComponentMarginsForLayoutTraits = [NSMutableDictionary new];
        _horizontalComponentOffsetsForArrayOfLayoutTraits = [NSMutableDictionary new];
    }
    
    return self;
}

- (CGFloat)marginBetweenComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)layoutTraits
                                   andContentEdge:(HUBComponentLayoutContentEdge)contentEdge
{
    return [self.contentEdgeMarginsForLayoutTraits[layoutTraits] doubleValue];
}

- (CGFloat)verticalMarginBetweenComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)layoutTraits
                       andHeaderComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)headerLayoutTraits
{
    return [self.headerMarginsForLayoutTraits[layoutTraits] doubleValue];
}

- (CGFloat)horizontalMarginForComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)layoutTraits
                         precedingComponentLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)precedingComponentLayoutTraits
{
    return [self.horizontalComponentMarginsForLayoutTraits[layoutTraits] doubleValue];
}

- (CGFloat)verticalMarginForComponentWithLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)layoutTraits
                       precedingComponentLayoutTraits:(NSSet<HUBComponentLayoutTrait *> *)precedingComponentLayoutTraits
{
    return [self.verticalComponentMarginsForLayoutTraits[layoutTraits] doubleValue];
}

- (CGFloat)horizontalOffsetForComponentsWithLayoutTraits:(NSArray<NSSet<HUBComponentLayoutTrait *> *> *)componentsTraits
                   firstComponentLeadingHorizontalOffset:(CGFloat)firstComponentLeadingOffsetX
                   lastComponentTrailingHorizontalOffset:(CGFloat)lastComponentTrailingOffsetX
{
    return [self.horizontalComponentOffsetsForArrayOfLayoutTraits[componentsTraits] doubleValue];
}

@end
