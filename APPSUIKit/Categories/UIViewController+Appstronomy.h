//
//  UIViewController+Appstronomy.h
//
//  Created by Chris Morris on 7/16/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class APPSService;

/**
 We provide some convenient app level services, like easy access to shared instances
 of various classes, via the service property.
 */
@interface UIViewController (Appstronomy)


#pragma mark - Device Specific Support

/**
 Only to be used in universal apps where iPhone and iPad storyboards
 use a suffix of "_iPhone" and "_iPad" respectively. We detect the device
 idiom, tack on the appropriate suffix, and then instantiate the storyboard
 with the fully qualified name.
 
 If we don't find a storyboard that has the device specific name, we'll then
 return the storyboard (if found) with just the base name.

 @param baseName The name of the storyboard to instantiate, without its device
 specific suffix.
 @return The device appropriate UIStoryboard.
 */
- (UIStoryboard *)apps_storyboardWithBaseName:(NSString *)baseName;

- (UIStoryboard *)apps_storyboardWithBaseName:(NSString *)baseName bundle:(NSBundle *)bundle;


- (UIStoryboard *)apps_storyboardWithBaseName:(NSString *)baseName
                         preferDeviceSpecific:(BOOL)deviceSpecific
                                       bundle:(NSBundle *)bundle;

- (UIStoryboard *)apps_storyboardWithExactName:(NSString *)exactName
                                        bundle:(NSBundle *)bundle;


/**
 Present modally, the initial controller in the storyboard with
 the given base name.  This delegates to the `apps_storyboardWithBaseName:`
 method to get the proper storyboard by name.

 @param baseName The name of the storyboard to instantiate, without its device
 specific suffix.
 @return The view controller that will be presented.
 */
- (UIViewController *)apps_presentStoryboardWithBaseName:(NSString *)baseName;


/**
 Finds the view controller in the proper storyboard, and instantiates it.  First,
 this will look in the device specific storyboard.  If the view controller is not
 found in that storyboard, it will then look in the shared storyboard.  If it
 is still not found, nil will be returned.

 @param viewControllerIdentifier The identifier of the view controller in the storyboard.
 @param storyboardBaseName The baseName of the storyboard without the device specific portion.

 @return The instantiated view controller or nil if it couldn't be found.
 */
- (id)apps_instantiateViewControllerWithIdentifier:(NSString *)viewControllerIdentifier
                        fromStoryboardWithBaseName:(NSString *)storyboardBaseName;

- (id)apps_instantiateViewControllerWithIdentifier:(NSString *)viewControllerIdentifier
                        fromStoryboardWithBaseName:(NSString *)storyboardBaseName
                                            bundle:(NSBundle *)bundle;



#pragma mark - Storyboard Convenience Wrappers

/**
 Simply wrapping the call to the storyboard method instantiateViewControllerWithIdentifier
 because that method will raise an exception if the identifier is not found in the storyboard.
 Additionally, the storyboard class does not offer any way to introspect the storyboard
 to determine if a given identifier does exist.  As a result, we will try to find it, if
 it doesn't exist, we will return nil.

 https://developer.apple.com/library/ios/documentation/uikit/reference/UIStoryboard_Class/Reference/Reference.html#//apple_ref/occ/instm/UIStoryboard/instantiateViewControllerWithIdentifier:

 Notice the comment in the parameter and the return value.  They seem to
 contradict each other on the behavior when the identifier cannot be found.

 @param viewControllerIdentifier The identifier of the view controller in the storyboard.
 @param storyboard The storyboard we want to search.

 @return The instantiated view controller or nil if it couldn't be found.
 */
- (id)apps_instantiateViewControllerWithIdentifier:(NSString *)viewControllerIdentifier
                                    fromStoryboard:(UIStoryboard *)storyboard;



#pragma mark - Containment Helpers

/**
 Adds the childViewController as a child of self, and then takes the
 childViewController.view and adds it as a subview of the containerView, making
 sure that the bounds of the newly added view extends the entire bounds of the
 containing view.

 @param childViewController The view controller to be added as a child.
 @param containerView The view into which the child view controller's view will
 be contained.
 */
- (void)apps_addChildViewController:(UIViewController *)childViewController
                  intoContainerView:(UIView *)containerView;


/**
 Removes the childViewController as a child of self, and then takes the
 childViewController.view and removes it as a subview of the containerView.
 
 @param childViewController The view controller to be removed as a child.
 */
- (void)apps_removeChildViewController:(UIViewController *)childViewController;

@end
