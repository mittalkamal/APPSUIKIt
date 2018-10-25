//
//  UIViewController+Appstronomy.m
//
//  Created by Chris Morris on 7/16/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "UIViewController+Appstronomy.h"
#import <APPSUIKit/APPSUIKit-Swift.h>

@implementation UIViewController (Appstronomy)


#pragma mark - Device Specific Support

/**
 Assumes if not an iPhone, then an iPad. Also assumes storyboard is in this bundle.
 */
- (UIStoryboard *)apps_storyboardWithBaseName:(NSString *)baseName;
{
    UIStoryboard *storyboard = [self apps_storyboardWithBaseName:baseName bundle:nil];
    
//    @try {
//        storyboard = [self apps_storyboardWithBaseName:baseName preferDeviceSpecific:YES bundle:[NSBundle mainBundle]];
//    }
//    @catch (NSException *exception) {
//        // We must have failed to find this storyboard in the main app bundle.
//        // Try our own bundle next:
//        storyboard = [self apps_storyboardWithBaseName:baseName preferDeviceSpecific:YES bundle:nil];
//    }
//    @finally {
//        // No clean up; we'll just end up returning nil if we didn't find a storyboard.
//    }
    
    return storyboard;
}


- (BOOL)apps_doesDeviceSpecificStoryboardExistWithBaseName:(NSString *)baseName bundle:(NSBundle *)bundle;
{
    NSString *suffix = (isIPhone ? @"_iPhone" : @"_iPad");
    NSString *fullName = [NSString stringWithFormat:@"%@%@", baseName, suffix];
    
    return [self apps_doesStoryboardExistWithExactName:fullName bundle:bundle];
}


- (BOOL)apps_doesStoryboardExistWithExactName:(NSString *)exactName bundle:(NSBundle *)bundle;
{
    NSString *path = [bundle pathForResource:exactName ofType:@"storyboard"];
    
    if (!path) { path = [bundle pathForResource:exactName ofType:@"storyboardc"]; };

    return (path != nil);
}


- (NSString *)resolvedNameForStoryboardWithBaseName:(NSString *)baseName bundle:(NSBundle *)bundle;
{
    NSString *resolvedName = nil;
    
    NSString *suffix = (isIPhone ? @"_iPhone" : @"_iPad");
    NSString *fullName = [NSString stringWithFormat:@"%@%@", baseName, suffix];

    if ([self apps_doesStoryboardExistWithExactName:fullName bundle:bundle]) {
        resolvedName = fullName;
    }
    else if ([self apps_doesStoryboardExistWithExactName:baseName bundle:bundle]) {
        resolvedName = baseName;
    }
    
    return resolvedName;
}


- (UIStoryboard *)apps_storyboardWithBaseName:(NSString *)baseName bundle:(NSBundle *)bundle;
{
    UIStoryboard *storyboard = nil;
    
    // Try finding the storyboard (device specific or just the base version) in the specified bundle:
    NSBundle *resolvedBundle = bundle;
    NSString *resolvedStoryboardName = [self resolvedNameForStoryboardWithBaseName:baseName bundle:resolvedBundle];
    
    // Did we find a storyboard in the specified bundle?
    if (resolvedStoryboardName) {
        // YES: Note this.
        logDebug(@"Found storyboard to use ('%@') for base name '%@' in specified bundle with identifier: %@",
                resolvedStoryboardName, baseName, resolvedBundle.bundleIdentifier);
    }
    else {
        // NO: Let's look in the main app bundle, if that wasn't the one asked for
        if (bundle != [NSBundle mainBundle]) {
            resolvedBundle = [NSBundle mainBundle];
            resolvedStoryboardName = [self resolvedNameForStoryboardWithBaseName:baseName bundle:resolvedBundle];
        }
        
        // Do we still not find a storyboard resource?
        if (!resolvedStoryboardName) {
            // Correct. So next, let's look in this very framework bundle,
            // if that wasn't the one originally asked for either.
            NSBundle *frameworkBundle = [APPSUIKit bundle];
            if (bundle != frameworkBundle) {
                resolvedBundle = frameworkBundle;
                resolvedStoryboardName = [self resolvedNameForStoryboardWithBaseName:baseName bundle:resolvedBundle];
            }
        }
    }
    
    // Did we ultimately find a storyboard name and bundle combintation to use?
    if (resolvedStoryboardName) {
        // YES: So we know it is safe to attempt to load that storyboard.
        storyboard = [UIStoryboard storyboardWithName:resolvedStoryboardName bundle:resolvedBundle];
    }
    
    return storyboard;
}



- (UIStoryboard *)apps_storyboardWithBaseName:(NSString *)baseName
                         preferDeviceSpecific:(BOOL)deviceSpecific
                                       bundle:(NSBundle *)bundle;
{
    UIStoryboard *storyboard;
    NSString *fullName;
    
    if (deviceSpecific) {
        NSString *suffix = (isIPhone ? @"_iPhone" : @"_iPad");
        fullName = [NSString stringWithFormat:@"%@%@", baseName, suffix];
    }
    else {
        fullName = baseName;
    }

    // Try finding the device specific storyboard first, in the provided bundle:
    @try {
        storyboard = [UIStoryboard storyboardWithName:fullName bundle:bundle];
    }
    // Since that didn't work, try finding a generic storyboard, in the provided bundle:
    @catch (NSException *deviceSpecificNameException) {
        if (!deviceSpecific) { return nil; } // We won't find anything different using a base name

        logDebug(@"Couldn't find device specific storyboard for base name '%@' in bundle '%@'.",
                 baseName, bundle.bundleIdentifier);
        logDebug(@"Trying base storyboard name on its own in bundle '%@'.", bundle.bundleIdentifier);
        
        @try {
            storyboard = [UIStoryboard storyboardWithName:baseName bundle:bundle];
        }
        @catch (NSException *baseNameFindException) {
            logDebug(@"Couldn't find generic storyboard for base name '%@' in bundle '%@'.",
                     baseName, bundle.bundleIdentifier);
            storyboard = nil;
        }
    }
}


- (UIStoryboard *)apps_storyboardWithExactName:(NSString *)exactName
                                        bundle:(NSBundle *)bundle;
{
    UIStoryboard *storyboard;

    // First, try finding storyboard in the provided bundle:
    @try {
        storyboard = [UIStoryboard storyboardWithName:exactName bundle:bundle];
    }
    // Since that didn't work, try finding the storyboard in our framework bundle:
    @catch (NSException *deviceSpecificNameException) {
        logDebug(@"Couldn't find exact storyboard with name '%@' in bundle '%@'.",
                 exactName, bundle.bundleIdentifier);
        logDebug(@"Trying storyboard name in our framework bundle.");
        
        @try {
            storyboard = [UIStoryboard storyboardWithName:exactName bundle:nil];
        }
        @catch (NSException *baseNameFindException) {
            logDebug(@"Couldn't find storyboard with name '%@' in bundle '%@' nor could "
                     "we find it in our own framework bundle.",
                     exactName, bundle.bundleIdentifier);
            storyboard = nil;
        }
    }
    
    return storyboard;
}




/**
 Presents the initial controller of the storyboard modally.
 */
- (UIViewController *)apps_presentStoryboardWithBaseName:(NSString *)baseName;
{
    UIStoryboard     *storyboard        = [self apps_storyboardWithBaseName:baseName];
    UIViewController *initialController = [storyboard instantiateInitialViewController];

    [self presentViewController:initialController animated:YES completion:NULL];

    return initialController;
}


- (id)apps_instantiateViewControllerWithIdentifier:(NSString *)viewControllerIdentifier
                        fromStoryboardWithBaseName:(NSString *)storyboardBaseName;
{
    return [self apps_instantiateViewControllerWithIdentifier:viewControllerIdentifier
                                   fromStoryboardWithBaseName:storyboardBaseName
                                                       bundle:[NSBundle mainBundle]];
}


/**
 Search for the view controller through the different storyboards and instantiate it.
 */
- (id)apps_instantiateViewControllerWithIdentifier:(NSString *)viewControllerIdentifier
                        fromStoryboardWithBaseName:(NSString *)storyboardBaseName
                                            bundle:(NSBundle *)bundle;
{
    logDebug(@"Looking for view controller with identifier: '%@' in storyboard with base name: '%@' "
            "found in bundle with path: '%@'", viewControllerIdentifier, storyboardBaseName, bundle.bundleURL);
    
    UIStoryboard     *storyboard = [self apps_storyboardWithBaseName:storyboardBaseName bundle:bundle];
    UIViewController *viewController = [self apps_instantiateViewControllerWithIdentifier:viewControllerIdentifier
                                                                           fromStoryboard:storyboard];

    if (!viewController) {
        storyboard = [self apps_storyboardWithExactName:storyboardBaseName
                                                 bundle:bundle];
        
        APPSAssert(storyboard, @"Expected to retrieve a storyboard just using its base name: '%@', "
                   "but instead, found no such storyboard, searching in the bundle '%@'.",
                   storyboardBaseName, bundle.bundleIdentifier);

        viewController = [self apps_instantiateViewControllerWithIdentifier:viewControllerIdentifier
                                                             fromStoryboard:storyboard];
    }
    
    APPSAssert(viewController, @"Expected to retrieve a view controller with identifier: %@, "
               "but are instead, going to return nil to the caller.", viewControllerIdentifier);

    return viewController;
}





#pragma mark - Storyboard Convenience Wrappers

/**
 Catch the exception.
 */
- (id)apps_instantiateViewControllerWithIdentifier:(NSString *)viewControllerIdentifier
                                    fromStoryboard:(UIStoryboard *)storyboard
{
    UIViewController *viewController = nil;

    @try {
        viewController = [storyboard instantiateViewControllerWithIdentifier:viewControllerIdentifier];
    }
    @catch (NSException *exception) {
        // Nothing to do here.
    }

    return viewController;
}



#pragma mark - Containment Helpers

/**
 Add VC as a child and then put its view in the containerView.
 */
- (void)apps_addChildViewController:(UIViewController *)childViewController
                  intoContainerView:(UIView *)containerView
{
    [self addChildViewController:childViewController];
    childViewController.view.frame = containerView.bounds;
    [containerView addSubview:childViewController.view];
    [childViewController didMoveToParentViewController:self];
}


- (void)apps_removeChildViewController:(UIViewController *)childViewController
{
    [childViewController willMoveToParentViewController:nil];
    [childViewController.view removeFromSuperview];
    [childViewController removeFromParentViewController];
}

@end
