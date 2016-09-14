#import "HUBSelectionAction.h"

#import <UIKit/UIKit.h>

#import "HUBActionContext.h"
#import "HUBComponentModel.h"
#import "HUBComponentTarget.h"

@implementation HUBSelectionAction

- (BOOL)performWithContext:(id<HUBActionContext>)context
{
    NSURL * const targetURI = context.componentModel.target.URI;
    
    if (targetURI == nil) {
        return NO;
    }
    
    return [[UIApplication sharedApplication] openURL:targetURI];
}

@end
