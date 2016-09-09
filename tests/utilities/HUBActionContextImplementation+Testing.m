#import "HUBActionContextImplementation+Testing.h"

#import "HUBViewModelImplementation.h"
#import "HUBComponentModelImplementation.h"
#import "HUBIdentifier.h"

NS_ASSUME_NONNULL_BEGIN

@implementation HUBActionContextImplementation (Testing)

+ (instancetype)contextForTestingWithActionNamespace:(NSString *)actionNamespace name:(NSString *)actionName
{
    HUBIdentifier * const actionIdentifier = [[HUBIdentifier alloc] initWithNamespace:actionNamespace name:actionName];
    NSURL * const viewURI = [NSURL URLWithString:@"spotify:hub:framework"];
    
    id<HUBViewModel> const viewModel = [[HUBViewModelImplementation alloc] initWithIdentifier:nil
                                                                           navigationBarTitle:nil
                                                                         headerComponentModel:nil
                                                                          bodyComponentModels:@[]
                                                                       overlayComponentModels:@[]
                                                                                 extensionURL:nil
                                                                                   customData:nil];
    
    HUBIdentifier * const componentIdentifier = [[HUBIdentifier alloc] initWithNamespace:@"namespace" name:@"name"];
    
    id<HUBComponentModel> const componentModel = [[HUBComponentModelImplementation alloc] initWithIdentifier:@"id"
                                                                                                       index:0
                                                                                         componentIdentifier:componentIdentifier
                                                                                           componentCategory:HUBComponentCategoryCard
                                                                                                       title:nil
                                                                                                    subtitle:nil
                                                                                              accessoryTitle:nil
                                                                                             descriptionText:nil
                                                                                               mainImageData:nil
                                                                                         backgroundImageData:nil
                                                                                             customImageData:@{}
                                                                                                        icon:nil
                                                                                                      target:nil
                                                                                                    metadata:nil
                                                                                                 loggingData:nil
                                                                                                  customData:nil
                                                                                        childComponentModels:nil];
    
    UIViewController * const viewController = [UIViewController new];
    
    
    
    return [[HUBActionContextImplementation alloc] initWithActionIdentifier:actionIdentifier
                                                                    viewURI:viewURI
                                                                  viewModel:viewModel
                                                             componentModel:componentModel
                                                             viewController:viewController];
}

@end

NS_ASSUME_NONNULL_END
