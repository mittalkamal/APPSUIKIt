//
//  APPSFetchedResultsDataSource.h
//  Appstronomy UIKit
//
//  Created by Ken Grigsby on 10/6/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//
@import CoreData;

#import "APPSDataSource.h"

/**
 A subclass of AAPLDataSource which is an adaptor for NSFetchedResultsController. This class will perform all the necessary updates to animate changes of the objects returned from the NSFetchedResultsController.
 */
@interface APPSFetchedResultsDataSource : APPSDataSource

- (instancetype) initWithFetchedResultsController:(NSFetchedResultsController *)frc NS_DESIGNATED_INITIALIZER;

@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;

/**
 *  Notifies the receiver that CoreData change notifications are about to occur.
 */
- (void)willChangeContent NS_REQUIRES_SUPER;

/**
 *  Notifies the receiver that CoreData change notifications are finished. The
 *  default implementation calls notifyBatchUpdates.
 */
- (void)didChangeContent NS_REQUIRES_SUPER;

@end
