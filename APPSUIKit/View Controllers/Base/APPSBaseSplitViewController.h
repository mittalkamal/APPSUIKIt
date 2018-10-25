//
//  APPSBaseSplitViewController.h
//
//  Created by Sohail Ahmed on 5/12/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Use this as the base class for your custom view controller, wherever you would normally
 inherit from UISplitViewController.
 
 We provide some convenient app level services, like easy access to shared instances
 of various classes, via the service property.
 */
@interface APPSBaseSplitViewController : UISplitViewController

#pragma mark - Configuration

/**
 Subclasses are meant to override this. The superclass implementation (ours) is a no-op.
 This base class however, in our viewDidLoad, will call this method to configure all the desired
 connections between master and detail views.
 */
- (void)configureConnections;

@end
