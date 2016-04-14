#import "HUBContentReloadPolicyMock.h"

@interface HUBContentReloadPolicyMock ()

@property (nonatomic, copy, readwrite) NSURL *lastViewURI;

@end

@implementation HUBContentReloadPolicyMock

- (BOOL)shouldReloadContentForViewURI:(NSURL *)viewURI currentViewModel:(id<HUBViewModel>)currentViewModel
{
    self.lastViewURI = viewURI;
    self.numberOfRequests++;
    
    return self.shouldReload;
}

@end
