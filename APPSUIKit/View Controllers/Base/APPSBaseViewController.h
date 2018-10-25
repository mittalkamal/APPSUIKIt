//
//  APPSBaseViewController.h
//
//  Created by Sohail Ahmed on 5/12/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Use this as the base class for your custom view controller, wherever you would normally
 inherit from UIViewController.

 We provide some convenient app level services, like easy access to shared instances
 of various classes, via the service property.
 */
@interface APPSBaseViewController : UIViewController

#pragma mark strong

/**
 The context in which to work on edits. Your subclass must set this explicitly. In most cases,
 you'll want to grab the @c scratchpadContext for the @c APPSDataStore.
 */
@property (strong, nonatomic) NSManagedObjectContext *editingContext;


@end
