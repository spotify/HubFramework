#import "HUBComponent.h"

@protocol HUBComponentImageData;

NS_ASSUME_NONNULL_BEGIN

/**
 *  Extended Hub component protocol that adds the ability to handle images
 *
 *  Use this protocol if your component will display images, either for itself or for any
 *  child components that it could potentially be managing. See `HUBComponent` for more info.
 */
@protocol HUBComponentWithImageHandling <HUBComponent>

/**
 *  Return the size that the component prefers that a certain image gets once loaded
 *
 *  @param imageData The data that will be used to load the image
 *  @param model The current model for the component
 *  @param containerViewSize The size of the container in which the view will be displayed
 */
- (CGSize)preferredSizeForImageFromData:(id<HUBComponentImageData>)imageData
                                  model:(id<HUBComponentModel>)model
                      containerViewSize:(CGSize)containerViewSize;

/**
 *  Update the view to display an image that was loaded
 *
 *  @param image The image that was loaded
 *  @param imageData The data that was used to load the image
 *  @param model The current model for the component
 *  @param animated Whether the update should be applied with an animation
 */
- (void)updateViewForLoadedImage:(UIImage *)image
                        fromData:(id<HUBComponentImageData>)imageData
                           model:(id<HUBComponentModel>)model
                        animated:(BOOL)animated;

@end

NS_ASSUME_NONNULL_END
