#import <XCTest/XCTest.h>

#import "HUBComponentCollectionViewCell.h"
#import "HUBComponentWrapperImplementation.h"
#import "HUBComponentMock.h"
#import "HUBComponentIdentifier.h"
#import "HUBComponentModelImplementation.h"
#import "HUBComponentUIStateManager.h"

@interface HUBCollectionViewCellTests : XCTestCase <HUBComponentWrapperDelegate>

@property (nonatomic, strong) HUBComponentMock *component;
@property (nonatomic, strong) HUBComponentWrapperImplementation *componentWrapper;
@property (nonatomic, strong) HUBComponentCollectionViewCell *cell;

@end

@implementation HUBCollectionViewCellTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.component = [HUBComponentMock new];
    self.componentWrapper = [self createComponentWrapperWithParentComponentWrapper:nil];
    self.cell = [[HUBComponentCollectionViewCell alloc] initWithFrame:CGRectZero];
    self.cell.component = self.componentWrapper;
}

#pragma mark - Tests

- (void)testSelectionForwardingToComponentCollectionViewCell
{
    UICollectionViewCell * const componentCell = [[UICollectionViewCell alloc] initWithFrame:CGRectZero];
    self.component.view = componentCell;
    
    self.cell.selected = YES;
    XCTAssertTrue(componentCell.isSelected);
    
    self.cell.selected = NO;
    XCTAssertFalse(componentCell.isSelected);
}

- (void)testHighlightForwardingToComponentCollectionViewCell
{
    UICollectionViewCell * const componentCell = [[UICollectionViewCell alloc] initWithFrame:CGRectZero];
    self.component.view = componentCell;
    
    self.cell.highlighted = YES;
    XCTAssertTrue(componentCell.isHighlighted);
    
    self.cell.highlighted = NO;
    XCTAssertFalse(componentCell.isHighlighted);
}

- (void)testNoSelectionOrHighlightForwardingForNonCollectionViewCellComponentViews
{
    [self.component loadView];
    
    // Shouldn't generate an exception
    self.cell.selected = YES;
    self.cell.highlighted = YES;
}

#pragma mark - HUBComponentWrapperDelegate

- (id<HUBComponentWrapper>)componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
                     childComponentForModel:(id<HUBComponentModel>)model
{
    return [self createComponentWrapperWithParentComponentWrapper:componentWrapper];
}

- (void)componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
  childComponentWithView:(UIView *)childComponentView
       willAppearAtIndex:(NSUInteger)childIndex
{
    // No-op
}

- (void)componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
  childComponentWithView:(UIView *)childComponentView
     didDisappearAtIndex:(NSUInteger)childIndex
{
    // No-op
}

- (void)componentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
  childComponentWithView:(UIView *)childComponentView
         selectedAtIndex:(NSUInteger)childIndex
{
    // No-op
}

- (void)sendComponentWrapperToReusePool:(HUBComponentWrapperImplementation *)componentWrapper
{
    // No-op
}

- (CGSize)containerViewSizeForComponentWrapper:(HUBComponentWrapperImplementation *)componentWrapper
{
    return CGSizeZero;
}

#pragma mark - Utilities

- (id<HUBComponentWrapper>)createComponentWrapperWithParentComponentWrapper:(nullable HUBComponentWrapperImplementation *)parentWrapper
{
    HUBComponentIdentifier * const componentIdentifier = [[HUBComponentIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    id<HUBComponentModel> const model = [[HUBComponentModelImplementation alloc] initWithIdentifier:@"id"
                                                                                              index:0
                                                                                componentIdentifier:componentIdentifier
                                                                                  componentCategory:HUBComponentCategoryRow
                                                                                              title:nil
                                                                                           subtitle:nil
                                                                                     accessoryTitle:nil
                                                                                    descriptionText:nil
                                                                                      mainImageData:nil
                                                                                backgroundImageData:nil
                                                                                    customImageData:@{}
                                                                                               icon:nil
                                                                                          targetURL:nil
                                                                             targetInitialViewModel:nil
                                                                                           metadata:nil
                                                                                        loggingData:nil
                                                                                         customData:nil
                                                                               childComponentModels:nil];
    
    HUBComponentUIStateManager * const UIStateManager = [HUBComponentUIStateManager new];
    
    return [[HUBComponentWrapperImplementation alloc] initWithComponent:self.component
                                                                  model:model
                                                         UIStateManager:UIStateManager
                                                               delegate:self
                                                 parentComponentWrapper:parentWrapper];
}

@end
