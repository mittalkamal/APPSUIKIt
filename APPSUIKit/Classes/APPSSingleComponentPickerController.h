//
//  APPSSingleComponentPickerController.h
//
//  Created by Ken Grigsby on 12/4/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@class APPSSingleComponentPickerController;

typedef void(^APPSSingleComponentPickerControllerDidSelectBlock)(APPSSingleComponentPickerController *controller);
typedef NSArray *(^APPSSingleComponentPickerControllerFetchObjectsBlock)();

/**
 APPSSingleComponentPickerController manages a single component UIPickerView. The titles displayed
 come from calling the fetchObjects block and then calling valueForKeyPath on each object
 using the given displayNameKeyPath or description if one is not provided. When an item is
 selected the didSelect block is called. SelectedItem can be called to retrieve the currently
 selected object.
 
 Configure this by setting it as the delegate and dataSource of a UIPickerView and providing
 a fetchObjects block. If the objects returned are NSStrings then a displayNameKeyPath is
 not necessary.
 */

@interface APPSSingleComponentPickerController : NSObject

/**
 Setting the pickerView make this controller the delegate and dataSource of the pickerView.
 It also selects the pickerView row according to it's selected item.
 */
@property (nonatomic, weak) UIPickerView *pickerView;


/**
 If true the first picker item will be blank.
 */
@property (nonatomic, assign) BOOL showEmptyItem;


/**
 *  The string value displayed in the UIPickerView comes from applying displayNameKeyPath
 *  to each item returned from fetchObjects. If displayNameKeyPath is nil then description
 *  is used.
 */
@property (nonatomic, copy) NSString *displayNameKeyPath;


/**
 *  Block called when a UIPickerView selection is made.
 */
@property (nonatomic, copy) APPSSingleComponentPickerControllerDidSelectBlock didSelect;


/**
 *  Block called when the UIPickerView needs objects to display. The result of 
 *  this call is sorted in ascending order using displayNameKeyPath or description
 *  if none provided.
 */
@property (nonatomic, copy) APPSSingleComponentPickerControllerFetchObjectsBlock fetchObjects;


/**
 * The getter returns the selected item. If showEmptyItem is true and it is selected, selectedItem
 returns nil.
 *  The setter sets the selected item by finding a match using the displayNameKeyPath.
 */
@property (nonatomic, strong) id selectedItem;


/**
 *  The getter returns the selectedItem's display name.
 *  The setter sets the selected item by finding a match using the displayNameKeyPath.
 */
@property (nonatomic, strong) NSString *selectedDisplayName;


/**
 *  Array of objects returned from invoking fetchObjects and sorted using
 *  displayNameKeyPath in ascending order. If displayNameKeyPath is not
 *  provided the description of the item is used.
 */
@property (nonatomic, copy, readonly) NSArray *items;

@end
