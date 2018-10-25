//
//  APPSViewControllerInfoStack.m
//  Appstronomy UIKit
//
//  Created by Sohail Ahmed on 5/11/13.
//  Copyright (c) 2013 Appstronomy. All rights reserved.
//

@import APPSFoundation;

#import "APPSViewControllerInfoStack.h"
#import "APPSViewControllerInfoStackEntry.h"
#import "APPSTaggedNaming.h"

@interface APPSViewControllerInfoStack ()
// strong
@property (strong, nonatomic) NSMutableArray *entries;
@end


@implementation APPSViewControllerInfoStack

#pragma mark - Initialization

- (id)initWithContainmentController:(UIViewController *)containmentController
{
    self = [super init];
    if (self) {
        APPSAssert(containmentController, @"We require a containment controller.");
        self.containmentController = containmentController;
        self.entries = [NSMutableArray array];
    }
    
    return self;
}



#pragma mark - Property Overrides

/**
 Retrieves the UIViewController associated with the last entry in our stack. This is presumed to be the
 currently visible child view controller.
 */
- (UIViewController *)visibleViewController
{
    APPSViewControllerInfoStackEntry *visibleViewControllerEntry = [self lastEntry];

    if (visibleViewControllerEntry) {
        return visibleViewControllerEntry.controller;
    }

    return nil; // We must not have found a view controller entry from which to extract the view controller.
}


/**
 Retrieves the UIViewController associated with the second last entry in our stack. This is presumed to be the
 child view controller immediately below the currently visible child view controller.
*/
- (UIViewController *)viewControllerBelowVisibleViewController
{
    // Do we have at least 2 entries, so that one is visible and one is below that?
    if ([self.entries count] >= 2) {
        NSUInteger secondLastIndex = [self.entries count] - 2; // since last index would have been ([self.entries count] - 1)
        APPSViewControllerInfoStackEntry *belowEntry = [self.entries objectAtIndex:secondLastIndex];
        return belowEntry.controller;
    }

    logDebug(@"Did not find a child view controller immediately below the visible view controller. "
            "We only have a record of %lu child view controllers.", (unsigned long)[self.entries count]);

    return nil; // We don't have enough entries to have a 'below' view controller.
}



#pragma mark - Inquiries

- (APPSViewControllerInfoStackEntry *)entryForController:(UIViewController *)controller
{
    for (APPSViewControllerInfoStackEntry *iteratedEntry in self.entries) {
        if (iteratedEntry.controller == controller) {
            return iteratedEntry; // We found it
        }
    }

    return nil; // We must not have found it.
}


- (BOOL)hasEntryForController:(UIViewController *)controller
{
    APPSViewControllerInfoStackEntry *soughtEntry = [self entryForController:controller];

    return (soughtEntry != nil);
}


- (APPSViewControllerInfoStackEntry *)lastEntry
{
    return [self.entries lastObject];
}


- (APPSViewControllerInfoStackEntry *)closestModalDismissalReturnEntry
{
    APPSViewControllerInfoStackEntry *closestEntry = nil;

    for (APPSViewControllerInfoStackEntry *iteratedEntry in [self.entries reverseObjectEnumerator]) {
        // Does this entry report that its associated view controller was modally covered?
        if ([iteratedEntry wasModallyCovered]) {
            closestEntry = iteratedEntry;
            break; // Exit out of the enumeration; we have our match.
        }
    }

    return closestEntry;
}


- (void)logContentsWithNote:(NSString *)note
{
    logInfo(@"--------------------------------------------------------------------"
            "--------------------------------------------------------------------------");
    logInfo(@"%@ - Top layers listed first (with higher indices)", note);
    logInfo(@"Number of Child Controllers per info stack: %lu | per containment controller itself: %lu",
             (unsigned long)self.entries.count, (unsigned long)self.containmentController.childViewControllers.count);

    APPSViewControllerInfoStackEntry *iteratedEntry = nil;

    // Count backwards through our entries, so the top most view controllers
    // are displayed first:
    for (long index = (self.entries.count - 1); index >= 0; index--) {
        iteratedEntry = self.entries[index];
        logInfo(@"%ld - '%@' -%@ - %@ - Type: %lu, Direction: %lu", index,
        [iteratedEntry taggedName],
        [iteratedEntry.controller class],
        iteratedEntry.controller,
        (unsigned long)iteratedEntry.appearingTransitionType,
        (unsigned long)iteratedEntry.appearingTransitionDirection);
    }
    
    logInfo(@"--------------------------------------------------------------------"
            "--------------------------------------------------------------------------");
}



#pragma mark - Adding and Removing

- (APPSViewControllerInfoStackEntry *)addEntryForController:(UIViewController *)controller
               transitionType:(APPSContainerControllerTransitionType)transitionType
          transitionDirection:(APPSContainerControllerTransitionDirection)transitionDirection
{
    APPSViewControllerInfoStackEntry *entry = [[APPSViewControllerInfoStackEntry alloc] init];
    entry.controller = controller;
    entry.appearingTransitionType = transitionType;
    entry.appearingTransitionDirection = transitionDirection;

    [self.entries addObject:entry];

    return entry;
}


- (void)removeEntryForController:(UIViewController *)controller
{
    APPSViewControllerInfoStackEntry *soughtEntry = [self entryForController:controller];

    if (soughtEntry) {
        [self.entries removeObject:soughtEntry];
    }
}




#pragma mark - Rearranging Entries

- (void)reorderEntryForController:(UIViewController *)lowerViewController
          belowEntryForController:(UIViewController *)higherViewController;
{
    APPSViewControllerInfoStackEntry *lowerEntry = [self entryForController:lowerViewController];
    APPSViewControllerInfoStackEntry *higherEntry = [self entryForController:higherViewController];
    
    // Remove the lowerEntry before inserting it at its new position, because NSArray inserts
    // don't check for uniqueness, and would otherwise, gladly insert what would be a duplicate:
    [self.entries removeObject:lowerEntry];
    [self.entries insertObject:lowerEntry atIndex:[self.entries indexOfObject:higherEntry]];
}


- (void)insertEntryForController:(UIViewController *)lowerViewController
         belowEntryForController:(UIViewController *)higherViewController;
{
    [self addEntryForController:lowerViewController
                 transitionType:APPSContainerControllerTransitionType_None
            transitionDirection:APPSContainerControllerTransitionDirection_None];

    [self reorderEntryForController:lowerViewController belowEntryForController:higherViewController];
}


- (void)reorderEntryForController:(UIViewController *)higherViewController
          aboveEntryForController:(UIViewController *)lowerViewController;
{
    APPSViewControllerInfoStackEntry *lowerEntry = [self entryForController:lowerViewController];
    APPSViewControllerInfoStackEntry *higherEntry = [self entryForController:higherViewController];
    
    // Remove the lowerEntry before inserting it at its new position, because NSArray inserts
    // don't check for uniqueness, and would otherwise, gladly insert what would be a duplicate:
    [self.entries removeObject:lowerEntry];
    [self.entries insertObject:lowerEntry atIndex:[self.entries indexOfObject:higherEntry]];
}


- (void)insertEntryForController:(UIViewController *)higherViewController
         aboveEntryForController:(UIViewController *)lowerViewController;
{
    [self addEntryForController:higherViewController
                 transitionType:APPSContainerControllerTransitionType_None
            transitionDirection:APPSContainerControllerTransitionDirection_None];

    [self reorderEntryForController:higherViewController aboveEntryForController:lowerViewController];
}


- (void)replaceEntryForController:(UIViewController *)existingViewController
           withExistingController:(UIViewController *)replacementViewController;
{
    APPSViewControllerInfoStackEntry *existingEntry = [self entryForController:existingViewController];
    APPSViewControllerInfoStackEntry *replacementEntry = [self entryForController:replacementViewController];
    [self.entries apps_replaceObject:existingEntry withObject:replacementEntry];
}


- (void)replaceEntryForController:(UIViewController *)existingViewController
                withNewController:(UIViewController *)replacementViewController;
{
    [self addEntryForController:replacementViewController
                 transitionType:APPSContainerControllerTransitionType_None
            transitionDirection:APPSContainerControllerTransitionDirection_None];

    [self replaceEntryForController:existingViewController withExistingController:replacementViewController];
}


@end
