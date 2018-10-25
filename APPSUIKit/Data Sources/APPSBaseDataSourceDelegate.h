//
//  APPSBaseDataSourceDelegate.h
//
//  Created by Ken Grigsby on 10/7/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


/**
 This class provides a base implementation of APPSDataSourceDelegate that
 will make the appropriate tableView calls (i.e. insert/deleteSections, insert/deleteRows, ...) 
 when data changes in the dataSource.
 Create one of these in your view controller and maintain a strong reference to it and assign it to the top level 
 data source delegate.
 */
@interface APPSBaseDataSourceDelegate : NSObject 

- (instancetype)init NS_UNAVAILABLE;

/**
 *  Initializes a APPSBaseDataSourceDelegate for use as the delegate for an APPSDataSource.
 *
 *  @param tableView A weak reference to the tableView to be updated from dataSource changes.
 *
 *  @return Returns an initialized APPSBaseDataSourceDelegate object.
 */
- (instancetype)initWithTableView:(UITableView *)tableView NS_DESIGNATED_INITIALIZER;



#pragma mark - TableViewAnimations

/**
 *  Set this to YES to have the table view animate any changes to the collection list. Otherwise, the tableview will just be reloaded.
 *  @note Defaults to YES.
 */
@property (nonatomic, assign, getter = shouldAnimateTableChanges) BOOL animateTableChanges;


/**
 *  Set the animation style for all section and object changes in your collection list associated with this data source.
 *
 *  @param animation UITableViewRowAnimation style.
 */
- (void)setAllAnimations:(UITableViewRowAnimation)animation;

/**
 *  Set the animation style for all section changes in your collection list associated with this data source.
 *
 *  @param animation UITableViewRowAnimation style.
 */
- (void)setAllSectionAnimations:(UITableViewRowAnimation)animation;

/**
 *  Set the animation style for all item changes in your collection list associated with this data source.
 *
 *  @param animation UITableViewRowAnimation style.
 */
- (void)setAllItemAnimations:(UITableViewRowAnimation)animation;


/**
 *  Specify the UITableViewRowAnimation style for section additions.
 *  @note Defaults to UITableViewRowAnimationFade.
 */
@property (nonatomic, assign) UITableViewRowAnimation addSectionAnimation;


/**
 *  Specify the UITableViewRowAnimation style for section removals.
 *  @note Defaults to UITableViewRowAnimationFade.
 */
@property (nonatomic, assign) UITableViewRowAnimation removeSectionAnimation;


/**
 *  Specify the UITableViewRowAnimation style for section updates.
 *  @note Defaults to UITableViewRowAnimationFade.
 */
@property (nonatomic, assign) UITableViewRowAnimation updateSectionAnimation;


/**
 *  Specify the UITableViewRowAnimation style for item additions.
 *  @note Defaults to UITableViewRowAnimationFade.
 */
@property (nonatomic, assign) UITableViewRowAnimation addItemAnimation;


/**
 *  Specify the UITableViewRowAnimation style for item removals.
 *  @note Defaults to UITableViewRowAnimationFade.
 */
@property (nonatomic, assign) UITableViewRowAnimation removeItemAnimation;


/**
 *  Specify the UITableViewRowAnimation style for item updates.
 *  @note Defaults to UITableViewRowAnimationFade.
 */
@property (nonatomic, assign) UITableViewRowAnimation updateItemAnimation;


@end


