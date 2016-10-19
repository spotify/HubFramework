#import <XCTest/XCTest.h>
#import <UIKit/UIGestureRecognizerSubclass.h>

#import "HUBComponentGestureRecognizer.h"
#import "HUBTouchMock.h"

@interface HUBComponentGestureRecognizerTests : XCTestCase

@property (nonatomic, strong) HUBComponentGestureRecognizer *gestureRecognizer;
@property (nonatomic, strong) UIView *view;

@end

@implementation HUBComponentGestureRecognizerTests

#pragma mark - XCTestCase

- (void)setUp
{
    [super setUp];
    
    self.gestureRecognizer = [HUBComponentGestureRecognizer new];
    self.view =  [[UIView alloc] initWithFrame:CGRectZero];;
    [self.view addGestureRecognizer:self.gestureRecognizer];
}

#pragma mark - Tests

- (void)testGestureRecognizerAddedToView
{
    XCTAssertEqual(self.gestureRecognizer.view, self.view);
}

- (void)testTouchesBeganSetsBeganState
{
    [self.gestureRecognizer touchesBegan:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateBegan);
}

- (void)testTouchesMovedInsideOfViewDoesNotAffectState
{
    self.view.frame = CGRectMake(0, 0, 300, 300);
    
    HUBTouchMock * const touch = [HUBTouchMock new];
    touch.location = CGPointMake(150, 150);
    
    [self.gestureRecognizer touchesMoved:[NSSet setWithObject:touch] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStatePossible);
}

- (void)testTouchesMovedHorizontallyOutsideOfViewSetsFailedState
{
    self.view.frame = CGRectMake(0, 0, 300, 300);
    
    HUBTouchMock * const touch = [HUBTouchMock new];
    touch.location = CGPointMake(-150, 150);
    
    [self.gestureRecognizer touchesMoved:[NSSet setWithObject:touch] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateFailed);
}

- (void)testTouchesMovedVerticallyOutsideOfViewSetsFailedState
{
    self.view.frame = CGRectMake(0, 0, 300, 300);
    
    HUBTouchMock * const touch = [HUBTouchMock new];
    touch.location = CGPointMake(150, 500);
    
    [self.gestureRecognizer touchesMoved:[NSSet setWithObject:touch] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateFailed);
}

- (void)testTouchesEndedSetsEndedState
{
    [self.gestureRecognizer touchesEnded:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateEnded);
}

- (void)testTouchesEndedWhenAlreadyFailedDoesNotAffectState
{
    HUBTouchMock * const moveTouch = [HUBTouchMock new];
    moveTouch.location = CGPointMake(-150, 150);
    [self.gestureRecognizer touchesMoved:[NSSet setWithObject:moveTouch] withEvent:[UIEvent new]];
    
    [self.gestureRecognizer touchesEnded:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateFailed);
}

- (void)testTouchesCancelledSetsFailedState
{
    [self.gestureRecognizer touchesCancelled:[NSSet setWithObject:[UITouch new]] withEvent:[UIEvent new]];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateFailed);
}

- (void)testManualCancelSetsFailedState
{
    [self.gestureRecognizer cancel];
    XCTAssertEqual(self.gestureRecognizer.state, UIGestureRecognizerStateFailed);
}

@end
