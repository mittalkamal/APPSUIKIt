//
//  APPSArrayDataSource.h
//
//  Created by Sohail Ahmed on 2014-08-29.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import UIKit;

#import "APPSUIKitTypeDefs.h"


/**
 This class implements the Array Data Source concept described in the online magazine
 objc.io, in its inaugural issue: http://www.objc.io/issue-1/lighter-view-controllers.html.
 It was written by Chris Eidhof: https://twitter.com/chriseidhof
 
 This class has been adapted to use some Appstronomy conventions and typedefs.
 
 The goal here, is for you to set an instance of this class as your table view controller's 
 data source, instead of burdening your view controller with data source logic. 
 
 This is only applicable if in this case, your backing data can be expressed as an NSArray.
 If your data set is massive, you'll want to instead use an NSFetchedResultsController,
 and an accordingly intelligent data source to drive it.
 */
@interface APPSArrayDataSource : NSObject <UITableViewDataSource>

#pragma mark strong

/**
 These are the items to be displayed. Set this initially using the designated initializer.
 Change this property directly afterwards, if the contents change. If you do change this
 array of items, you are responsible for reloading the table view, and any animations you may
 want to perform in that regard.
 */
@property (nonatomic, strong) NSArray *items;


#pragma mark - Initialization

- (id)initWithItems:(NSArray *)items
    cellIdentifiers:(NSArray *)cellIdentifiers
               tags:(NSArray *)tags
 configureCellBlock:(APPSTableViewCellConfigureBlock)configureCellBlock;

- (id)initWithItems:(NSArray *)items
     cellIdentifier:(NSString *)cellIdentifier
 configureCellBlock:(APPSTableViewCellConfigureBlock)configureCellBlock;


- (id)initWithItems:(NSArray *)items
     cellIdentifiers:(NSArray *)cellIdentifiers
 configureCellBlock:(APPSTableViewCellConfigureBlock)configureCellBlock;

#pragma mark - Inquiries

- (id)itemAtIndexPath:(NSIndexPath *)indexPath;


/**
 This assumes a single section. We retrieve the indexPath at which you can
 find the item (or an equivalent to it) as vended by this data source.
 
 @param item The item whose indexPath is sought.
 
 @return The item's matching indexPath.
 */
- (NSIndexPath *)indexPathForItem:(id)item;


@end
