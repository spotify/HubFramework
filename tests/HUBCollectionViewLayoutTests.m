#import <XCTest/XCTest.h>

#import "HUBIdentifier.h"
#import "HUBComponentRegistryImplementation.h"
#import "HUBCollectionViewLayout.h"
#import "HUBViewModelBuilderImplementation.h"
#import "HUBViewModelImplementation.h"
#import "HUBComponentLayoutManagerMock.h"
#import "HUBComponentMock.h"
#import "HUBComponentFactoryMock.h"
#import "HUBComponentModelBuilder.h"
#import "HUBJSONSchemaRegistryImplementation.h"
#import "HUBJSONSchemaImplementation.h"
#import "HUBComponentDefaults.h"
#import "HUBComponentFallbackHandlerMock.h"
#import "HUBIconImageResolverMock.h"

@interface HUBCollectionViewLayoutTests : XCTestCase

@property (nonatomic) CGSize collectionViewSize;
@property (nonatomic, strong) HUBComponentMock *compactComponent;
@property (nonatomic, strong) HUBIdentifier *compactComponentIdentifier;

@property (nonatomic, strong) HUBComponentMock *centeredComponent;
@property (nonatomic, strong) HUBIdentifier *centeredComponentIdentifier;

@property (nonatomic, strong) HUBComponentMock *fullWidthComponent;
@property (nonatomic, strong) HUBIdentifier *fullWidthComponentIdentifier;

@property (nonatomic, strong) HUBComponentFactoryMock *componentFactory;
@property (nonatomic, strong) HUBComponentRegistryImplementation *componentRegistry;
@property (nonatomic, strong) HUBComponentLayoutManagerMock *componentLayoutManager;
@property (nonatomic, strong) HUBViewModelBuilderImplementation *viewModelBuilder;

@end

@implementation HUBCollectionViewLayoutTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.collectionViewSize = CGSizeMake(320, 400);
    
    NSString * const componentNamespace = @"namespace";
    NSString * const compactComponentName = @"compact";
    
    self.compactComponent = [HUBComponentMock new];
    [self.compactComponent.layoutTraits addObject:HUBComponentLayoutTraitCompactWidth];
    self.compactComponent.preferredViewSize = CGSizeMake(100, 100);
    self.compactComponentIdentifier = [[HUBIdentifier alloc] initWithNamespace:componentNamespace name:compactComponentName];
    
    self.fullWidthComponent = [HUBComponentMock new];
    [self.fullWidthComponent.layoutTraits addObject:HUBComponentLayoutTraitFullWidth];
    self.fullWidthComponent.preferredViewSize = CGSizeMake(self.collectionViewSize.width, 100);
    self.fullWidthComponentIdentifier = [[HUBIdentifier alloc] initWithNamespace:componentNamespace name:@"fullWidth"];

    self.centeredComponent = [HUBComponentMock new];
    [self.centeredComponent.layoutTraits addObject:HUBComponentLayoutTraitCentered];
    self.centeredComponent.preferredViewSize = CGSizeMake(50, 50);
    self.centeredComponentIdentifier = [[HUBIdentifier alloc] initWithNamespace:componentNamespace name:@"centered"];
    
    self.componentFactory = [[HUBComponentFactoryMock alloc] initWithComponents:@{
        self.compactComponentIdentifier.namePart: self.compactComponent,
        self.fullWidthComponentIdentifier.namePart: self.fullWidthComponent,
        self.centeredComponentIdentifier.namePart: self.centeredComponent
    }];
    
    HUBComponentDefaults * const componentDefaults = [[HUBComponentDefaults alloc] initWithComponentNamespace:componentNamespace
                                                                                                componentName:compactComponentName
                                                                                            componentCategory:@"category"];
    
    id<HUBComponentFallbackHandler> const componentFallbackHandler = [[HUBComponentFallbackHandlerMock alloc] initWithComponentDefaults:componentDefaults];
    HUBJSONSchemaRegistryImplementation * const JSONSchemaRegistry = [[HUBJSONSchemaRegistryImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                                                          iconImageResolver:nil];
    
    self.componentRegistry = [[HUBComponentRegistryImplementation alloc] initWithFallbackHandler:componentFallbackHandler
                                                                               componentDefaults:componentDefaults
                                                                              JSONSchemaRegistry:JSONSchemaRegistry
                                                                               iconImageResolver:nil];
    
    [self.componentRegistry registerComponentFactory:self.componentFactory forNamespace:componentNamespace];
    
    self.componentLayoutManager = [HUBComponentLayoutManagerMock new];
    
    id<HUBIconImageResolver> const iconImageResolver = [HUBIconImageResolverMock new];
    
    id<HUBJSONSchema> const JSONSchema = [[HUBJSONSchemaImplementation alloc] initWithComponentDefaults:componentDefaults
                                                                                      iconImageResolver:iconImageResolver];
    
    self.viewModelBuilder = [[HUBViewModelBuilderImplementation alloc] initWithJSONSchema:JSONSchema
                                                                        componentDefaults:componentDefaults
                                                                        iconImageResolver:iconImageResolver];
}

#pragma mark - Tests

- (void)testTopLeftContentEdgeMargins
{
    [self addBodyComponentWithIdentifier:self.compactComponentIdentifier];
    
    CGFloat const edgeMargin = 20;
    CGSize const componentSize = self.compactComponent.preferredViewSize;
    self.componentLayoutManager.contentEdgeMarginsForLayoutTraits[self.compactComponent.layoutTraits] = @(edgeMargin);
    
    HUBCollectionViewLayout * const layout = [self computeLayout];
    
    NSIndexPath * const componentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    CGRect const componentViewFrame = [layout layoutAttributesForItemAtIndexPath:componentIndexPath].frame;
    CGRect const expectedComponentViewFrame = CGRectMake(edgeMargin, edgeMargin, componentSize.width, componentSize.height);
    
    XCTAssertTrue(CGRectEqualToRect(componentViewFrame, expectedComponentViewFrame));
}

- (void)testRightContentEdgeMargin
{
    [self addBodyComponentWithIdentifier:self.compactComponentIdentifier];
    
    self.compactComponent.preferredViewSize = CGSizeMake(self.collectionViewSize.width, 50);
    
    CGFloat const edgeMargin = 20;
    self.componentLayoutManager.contentEdgeMarginsForLayoutTraits[self.compactComponent.layoutTraits] = @(edgeMargin);
    
    HUBCollectionViewLayout * const layout = [self computeLayout];
    
    NSIndexPath * const componentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    CGRect const componentViewFrame = [layout layoutAttributesForItemAtIndexPath:componentIndexPath].frame;
    CGRect const expectedComponentViewFrame = CGRectMake(
        edgeMargin,
        edgeMargin,
        self.compactComponent.preferredViewSize.width - edgeMargin * 2,
        self.compactComponent.preferredViewSize.height
    );
    
    XCTAssertTrue(CGRectEqualToRect(componentViewFrame, expectedComponentViewFrame));
}

- (void)testVerticalMarginToHeaderComponent
{
    self.viewModelBuilder.headerComponentModelBuilder.componentName = self.fullWidthComponentIdentifier.namePart;
    [self addBodyComponentWithIdentifier:self.fullWidthComponentIdentifier];
    
    CGFloat const headerMargin = 30;
    CGSize const componentSize = self.fullWidthComponent.preferredViewSize;
    self.componentLayoutManager.headerMarginsForLayoutTraits[self.fullWidthComponent.layoutTraits] = @(headerMargin);
    
    HUBCollectionViewLayout * const layout = [self computeLayout];
    
    NSIndexPath * const componentIndexPath = [NSIndexPath indexPathForItem:0 inSection:0];
    CGRect const componentViewFrame = [layout layoutAttributesForItemAtIndexPath:componentIndexPath].frame;
    CGRect const expectedComponentViewFrame = CGRectMake(0, headerMargin, componentSize.width, componentSize.height);
    
    XCTAssertTrue(CGRectEqualToRect(componentViewFrame, expectedComponentViewFrame));
}

- (void)testCollectionViewContentSize
{
    [self addBodyComponentWithIdentifier:self.compactComponentIdentifier];
    [self addBodyComponentWithIdentifier:self.fullWidthComponentIdentifier];
    [self addBodyComponentWithIdentifier:self.compactComponentIdentifier];
    [self addBodyComponentWithIdentifier:self.fullWidthComponentIdentifier];
    [self addBodyComponentWithIdentifier:self.centeredComponentIdentifier];

    CGFloat const bottomContentEdgeMargin = 40;
    CGSize const compactComponentSize = self.compactComponent.preferredViewSize;
    CGSize const fullWidthComponentSize = self.fullWidthComponent.preferredViewSize;
    CGSize const centeredComponentSize = self.centeredComponent.preferredViewSize;
    self.componentLayoutManager.contentEdgeMarginsForLayoutTraits[self.centeredComponent.layoutTraits] = @(bottomContentEdgeMargin);
    
    HUBCollectionViewLayout * const layout = [self computeLayout];
    
    CGSize const expectedCollectionViewContentSize = CGSizeMake(
        self.collectionViewSize.width,
        compactComponentSize.height * 2 + fullWidthComponentSize.height * 2 + centeredComponentSize.height + bottomContentEdgeMargin
    );
    
    XCTAssertTrue(CGSizeEqualToSize(expectedCollectionViewContentSize, layout.collectionViewContentSize));
}

- (void)testComponentMovedToNewRowIfWidthExceedsAvailableSpace
{
    [self addBodyComponentWithIdentifier:self.compactComponentIdentifier];
    [self addBodyComponentWithIdentifier:self.compactComponentIdentifier];
    [self addBodyComponentWithIdentifier:self.compactComponentIdentifier];

    CGFloat const componentVerticalMargin = 20;
    CGFloat const componentContentEdgeMargin = 15;
    CGSize const componentSize = self.compactComponent.preferredViewSize;
    self.componentLayoutManager.verticalComponentMarginsForLayoutTraits[self.compactComponent.layoutTraits] = @(componentVerticalMargin);
    self.componentLayoutManager.contentEdgeMarginsForLayoutTraits[self.compactComponent.layoutTraits] = @(componentContentEdgeMargin);

    HUBCollectionViewLayout * const layout = [self computeLayout];

    // H:|-15-[c1(100)][c2(100)][c3(100)]-15-|
    // but total width (330) > collectionView width (320) so component 3 have to be moved to a new row

    NSIndexPath * const componentIndexPath = [NSIndexPath indexPathForItem:2 inSection:0];
    CGRect const componentViewFrame = [layout layoutAttributesForItemAtIndexPath:componentIndexPath].frame;
    CGRect const expectedComponentViewFrame = CGRectMake(componentContentEdgeMargin,
                                                         componentContentEdgeMargin + componentSize.height + componentVerticalMargin,
                                                         componentSize.width,
                                                         componentSize.height);

    XCTAssertTrue(CGRectEqualToRect(componentViewFrame, expectedComponentViewFrame));
}

- (void)testComponentMovedToNewRowIfItsHorizontalMarginIsBiggerThanCollectionViewWidth
{
    [self addBodyComponentWithIdentifier:self.centeredComponentIdentifier];
    [self addBodyComponentWithIdentifier:self.compactComponentIdentifier];

    CGFloat const componentVerticalMargin = 20;
    CGSize const compactComponentSize = self.compactComponent.preferredViewSize;
    CGSize const centeredComponentSize = self.centeredComponent.preferredViewSize;

    self.componentLayoutManager.verticalComponentMarginsForLayoutTraits[self.compactComponent.layoutTraits] = @(componentVerticalMargin);
    self.componentLayoutManager.horizontalComponentMarginsForLayoutTraits[self.compactComponent.layoutTraits] = @(CGFLOAT_MAX);

    HUBCollectionViewLayout * const layout = [self computeLayout];

    // Check that the second component is on new row because it is not centered and the first one is
    NSIndexPath * const secondComponentIndexPath = [NSIndexPath indexPathForItem:1 inSection:0];
    CGRect const secondComponentViewFrame = [layout layoutAttributesForItemAtIndexPath:secondComponentIndexPath].frame;
    CGRect const expectedFrameForSecondComponent = CGRectMake(0, centeredComponentSize.height + componentVerticalMargin, compactComponentSize.width, compactComponentSize.height);
    XCTAssertTrue(CGRectEqualToRect(secondComponentViewFrame, expectedFrameForSecondComponent));
}

- (void)testComponentOrigins
{
    [self addBodyComponentWithIdentifier:self.centeredComponentIdentifier];
    [self addBodyComponentWithIdentifier:self.centeredComponentIdentifier];

    CGFloat const componentVerticalMargin = 20;

    self.componentLayoutManager.verticalComponentMarginsForLayoutTraits[self.compactComponent.layoutTraits] = @(componentVerticalMargin);
    self.componentLayoutManager.verticalComponentMarginsForLayoutTraits[self.centeredComponent.layoutTraits] = @(componentVerticalMargin);
    NSArray *componentsLayoutTraits = @[self.centeredComponent.layoutTraits, self.centeredComponent.layoutTraits];
    self.componentLayoutManager.horizontalComponentOffsetsForArrayOfLayoutTraits[componentsLayoutTraits] = @(110);

    HUBCollectionViewLayout * const layout = [self computeLayout];

    NSIndexPath * const componentIndexPath1 = [NSIndexPath indexPathForItem:0 inSection:0];
    CGRect const componentViewFrame1 = [layout layoutAttributesForItemAtIndexPath:componentIndexPath1].frame;
    XCTAssertEqualWithAccuracy(componentViewFrame1.origin.x, 110, 0.001);

    NSIndexPath * const componentIndexPath2 = [NSIndexPath indexPathForItem:1 inSection:0];
    CGRect const componentViewFrame2 = [layout layoutAttributesForItemAtIndexPath:componentIndexPath2].frame;
    XCTAssertEqualWithAccuracy(componentViewFrame2.origin.x, 160, 0.001);
}

#pragma mark - Utilities

- (void)addBodyComponentWithIdentifier:(HUBIdentifier *)componentIdentifier
{
    NSString * const modelIdentifier = [NSUUID UUID].UUIDString;
    [self.viewModelBuilder builderForBodyComponentModelWithIdentifier:modelIdentifier].componentName = componentIdentifier.namePart;
}

- (HUBCollectionViewLayout *)computeLayout
{
    id<HUBViewModel> const viewModel = [self.viewModelBuilder build];
    HUBCollectionViewLayout * const layout = [[HUBCollectionViewLayout alloc] initWithViewModel:viewModel
                                                                              componentRegistry:self.componentRegistry
                                                                         componentLayoutManager:self.componentLayoutManager];
    
    [layout computeForCollectionViewSize:self.collectionViewSize];
    
    return layout;
}

@end
