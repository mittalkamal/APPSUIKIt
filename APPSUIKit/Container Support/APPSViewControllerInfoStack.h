//
//  APPSViewControllerInfoStack.h
//  Appstronomy UIKit
//
//  Created by Sohail Ahmed on 5/11/13.
//  Copyright (c) 2013 Appstronomy. All rights reserved.
//

#import "APPSViewControllerInfoStackEntry.h"


/**
 We store entries (instances of APPSViewControllerInfoStackEntry) in a private mutable array that we order
 to reflect the position of child view controllers hosted by the containment controller that uses us.
 
 Controllers on higher layers are at the end of our array of entries.
 */
@interface APPSViewControllerInfoStack : NSObject

#pragma mark weak
@property (weak, nonatomic) UIViewController *containmentController;

#pragma mark readonly
@property (readonly, nonatomic) UIViewController *visibleViewController;
@property (readonly, nonatomic) UIViewController *viewControllerBelowVisibleViewController;


#pragma mark - Initialization

- (id)initWithContainmentController:(UIViewController *)containmentController;



#pragma mark - Inquiries

- (APPSViewControllerInfoStackEntry *)entryForController:(UIViewController *)controller;

- (BOOL)hasEntryForController:(UIViewController *)controller;

- (APPSViewControllerInfoStackEntry *)lastEntry;

/**
 Determines which of our entries, working backwards, is the first to claim to have been covered up modally.
 This is the entry whose associated child controller, will be the one our owning Container Controller will
 want to return to when performing a custom modal dismissal.
 
 @return The closest entry working backwards that reported being covered modally. Otherwise, nil.
 */
- (APPSViewControllerInfoStackEntry *)closestModalDismissalReturnEntry;

- (void)logContentsWithNote:(NSString *)note;



#pragma mark - Adding and Removing

- (APPSViewControllerInfoStackEntry *)addEntryForController:(UIViewController *)controller
               transitionType:(APPSContainerControllerTransitionType)transitionType
          transitionDirection:(APPSContainerControllerTransitionDirection)transitionDirection;

- (void)removeEntryForController:(UIViewController *)controller;



#pragma mark - Rearranging Entries

- (void)reorderEntryForController:(UIViewController *)lowerViewController
          belowEntryForController:(UIViewController *)higherViewController;

- (void)insertEntryForController:(UIViewController *)lowerViewController
         belowEntryForController:(UIViewController *)higherViewController;

- (void)reorderEntryForController:(UIViewController *)higherViewController
          aboveEntryForController:(UIViewController *)lowerViewController;

- (void)insertEntryForController:(UIViewController *)higherViewController
         aboveEntryForController:(UIViewController *)lowerViewController;

- (void)replaceEntryForController:(UIViewController *)existingViewController
           withExistingController:(UIViewController *)replacementViewController;

- (void)replaceEntryForController:(UIViewController *)existingViewController
                withNewController:(UIViewController *)replacementViewController;


@end
