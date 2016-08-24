#import <XCTest/XCTest.h>

#import "HUBComponentCollectionViewCell.h"
#import "HUBComponentMock.h"

@interface HUBCollectionViewCellTests : XCTestCase

@property (nonatomic, strong) HUBComponentMock *component;
@property (nonatomic, strong) HUBComponentCollectionViewCell *cell;

@end

@implementation HUBCollectionViewCellTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.component = [HUBComponentMock new];
    self.cell = [[HUBComponentCollectionViewCell alloc] initWithFrame:CGRectZero];
    self.cell.component = self.component;
}

#pragma mark - Tests

- (void)testIdentifierNotNil
{
    XCTAssertNotNil(self.cell.identifier);
}

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

@end
