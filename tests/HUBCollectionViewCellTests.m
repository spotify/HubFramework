#import <XCTest/XCTest.h>

#import "HUBComponentCollectionViewCell.h"
#import "HUBComponentMock.h"
#import "HUBGestureRecognizerMock.h"
#import "HUBTouchPhase.h"

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
    self.cell.component = self.component;
    
    self.cell.selected = YES;
    XCTAssertTrue(componentCell.isSelected);
    
    self.cell.selected = NO;
    XCTAssertFalse(componentCell.isSelected);
}

- (void)testHighlightForwardingToComponentCollectionViewCell
{
    UICollectionViewCell * const componentCell = [[UICollectionViewCell alloc] initWithFrame:CGRectZero];
    self.component.view = componentCell;
    self.cell.component = self.component;
    
    self.cell.highlighted = YES;
    XCTAssertTrue(componentCell.isHighlighted);
    
    self.cell.highlighted = NO;
    XCTAssertFalse(componentCell.isHighlighted);
}

- (void)testNoSelectionOrHighlightForwardingForNonCollectionViewCellComponentViews
{
    self.cell.component = self.component;
    
    // Shouldn't generate an exception
    self.cell.selected = YES;
    self.cell.highlighted = YES;
}

- (void)testTouchEventsForwardedToComponentCellGestureRecognizer
{
    UICollectionViewCell * const componentCell = [[UICollectionViewCell alloc] initWithFrame:CGRectZero];
    self.component.view = componentCell;
    self.cell.component = self.component;
    
    HUBGestureRecognizerMock * const gestureRecgonizer = [HUBGestureRecognizerMock new];
    [componentCell addGestureRecognizer:gestureRecgonizer];
    
    [self.cell touchesBegan:[NSSet new] withEvent:[UIEvent new]];
    XCTAssertEqualObjects(gestureRecgonizer.touchPhaseValue, @(HUBTouchPhaseBegan));
    
    [self.cell touchesMoved:[NSSet new] withEvent:[UIEvent new]];
    XCTAssertEqualObjects(gestureRecgonizer.touchPhaseValue, @(HUBTouchPhaseMoved));
    
    [self.cell touchesEnded:[NSSet new] withEvent:[UIEvent new]];
    XCTAssertEqualObjects(gestureRecgonizer.touchPhaseValue, @(HUBTouchPhaseEnded));
    
    [self.cell touchesCancelled:[NSSet new] withEvent:[UIEvent new]];
    XCTAssertEqualObjects(gestureRecgonizer.touchPhaseValue, @(HUBTouchPhaseCancelled));
}

@end
