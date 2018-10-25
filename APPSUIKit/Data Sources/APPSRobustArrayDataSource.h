//
//  APPSRobustArrayDataSource.h
//  AppstronomyStandardKit
//
//  Created by Sohail Ahmed on 1/28/16.
//  Copyright © 2016 Appstronomy, LLC. All rights reserved.
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
 
 We've extended the original concept to include support for multiple sections.
 */
@interface APPSRobustArrayDataSource : NSObject <UITableViewDataSource>

#pragma mark weak

/**
 The section names, if any, that we are using.
 
 As different initializer options for this class are available, you may have given explicit section names,
 or you may have provided a section name keypath for us to infer and coalesce what all the section names are.
 Regardless, through this property, you can determine what we've resolved the section names to be.
 */
@property (weak, nonatomic, readonly) NSArray *resolvedSectionNames;

/**
 Tells you wish of the model items, across all sections, are currently selected.
 
 This only works if your model items have a boolean flag (property) indicating selection state, and you've 
 provided the name of that property as our property, @c selectedFlagKeyPath.
 */
@property (weak, nonatomic, readonly) NSArray *selectedModelItems;


/**
 Tells you wish of the model items, across all sections, are currently NOT selected.
 
 This only works if your model items have a boolean flag (property) indicating selection state, and you've
 provided the name of that property as our property, @c selectedFlagKeyPath.
 */
@property (weak, nonatomic, readonly) NSArray *unselectedModelItems;


#pragma mark strong

/**
 Optional. Required however, if the mutually exclusive property @c listOfModelItemsInPartitionedSections is not provided.
 
 This is a flat, one-dimensional array with the items to be vended to the asking UITableView. 
 
 If you do change this array of items post initializer method setting, then you are responsible for
 reloading the table view, and any animations you may want to perform in that regard.
 
 @example
 
 dataSource.listOfModelItems = @[modelA, modelB, modelC, modelD, modelE, modelF, modelG, modelH, modelI, modelJ];
 */
@property (nonatomic, strong) NSArray *listOfModelItems;


/**
 Optional. Required however, if the mutually exclusive property @c listOfModelItems is not provided.
 
 This is an array of arrays. That is, it is a two-dimensional array. Each array within the top-level
 array represents a section. In each of those section-specific arrays, are the models (items) that
 the UITableView is looking to display in cells.
 
 If you do change this array of items post initializer method settting, then you are responsible for
 reloading the table view, and any animations you may want to perform in that regard.
 
 @example 
 
 NSArray *section1Models = @[modelA, modelB, modelC];
 NSArray *section2Models = @[modelD, modelE, modelF, modelG];
 NSArray *section3Models = @[modelH, modelI, modelJ, modelK, modelL, modelM];
 dataSource.listOfModelItemsInPartitionedSections = @[section1Models, section2Models, section3Models];
 */
@property (nonatomic, strong) NSArray *listOfModelItemsInPartitionedSections;


#pragma mark copy

/**
 Required. You must provide a default cell identifier, even if you don't wish to use one
 because all your models will have custom cell identifiers registered in the 
 @c customCellIdentifierMapping.
 */
@property (nonatomic, copy) NSString *defaultCellIdentifier;

/**
 Optional. This dictionary contains keys that are the model items themselves, and for which the
 corresponding values are strings that represent the Cell Identifier to use when configuring
 that particular model. If not provided or empty, we will just use the defaultCellIdentifier
 for every cell, regardless of section.
 */
@property (nonatomic, copy) NSDictionary *customCellIdentiferMapping;

/**
 Optional. This represents the keypath we can use to determine which models are currently
 marked as selected (or not). To use this, set this key path property to the name of the BOOL
 property on your model item for which a YES value indicates selection. 
 
 You can then use the read-only property @c selectedModelItems to retrieve an array of items
 that are currently selected, or the property @c unselectedModelItems to retrieve an array of
 items that are @em not currently selected.
 */
@property (nonatomic, copy) NSString *selectedFlagKeyPath;

/**
 Required. This is the block we invoke for each table cell returned, in order to configure it with the
 item (model) that backs it.
 */
@property (nonatomic, copy) APPSTableViewCellConfigureBlock configureCellBlock;



#pragma mark - Initialization

#pragma mark * Single Section

/**
 The initializer to use when you have a single section.
 
 @param listOfModelItems      Your model items. They will show up in one section only.
 @param defaultCellIdentifier The cell identifier to use.
 @param configureCellBlock    The callback we should use to configure each cell from its backing model item.
 
 @return A configured data source.
 */
- (instancetype)initWithModelItems:(NSArray *)listOfModelItems
               cellIdentifier:(NSString *)defaultCellIdentifier
           configureCellBlock:(APPSTableViewCellConfigureBlock)configureCellBlock;


#pragma mark * Possibly Multiple Sections

/**
 The initializer to use when you have a single section or multiple sections. Use when you have a flat list of model items,
 potentially some custom cell identifier mappings, and/or desire to organize sections by a keypath from within the model items.
 
 @param listOfModelItems            Your model items. They may actually belong to more than one section.
 @param defaultCellIdentifier       The default cell identifier to use.
 @param customCellIdentifierMapping Optional. A mapping of {model item --> cell identifer} you can provide for 
                                    zero, one, many or all model items. When not provided, model items get configured 
                                    to use the cell given by the default cell identifier.
 @param sectionNameKeyPath          Optional for single section data sources. Required for multi-section when you want to be able to use section names.
 @param configureCellBlock          The callback we should use to configure each cell from its backing model item.
 
 @return A configured data source.
 */
- (instancetype)initWithModelItems:(NSArray *)listOfModelItems
        defaultCellIdentifier:(NSString *)defaultCellIdentifier
        customCellIdentifiers:(NSDictionary *)customCellIdentifierMapping
           sectionNameKeyPath:(NSString *)sectionNameKeyPath
           configureCellBlock:(APPSTableViewCellConfigureBlock)configureCellBlock;


#pragma mark * Multiple Sections

/**
 The initializer to use when your multi-section model items are already organized in distinct arrays, one per section.
 We'll use section names based on what you provide to us explicitly.
 
 @param listOfModelItemsInPartitionedSections   A two-dimensional array containing your model items. 
                                                The first dimension's elements represent sections. Each of those elements 
                                                (a section) is actually an array with model items belonging to that section.
 @param defaultCellIdentifier                   The default cell identifier to use.
 @param customCellIdentifierMapping             Optional. A mapping of {model item --> cell identifer} you can provide for
                                                zero, one, many or all model items. When not provided, model items get configured
                                                to use the cell given by the default cell identifier.
 @param sectionNames                            An explicit list of the section names we should use.
 @param configureCellBlock                      The callback we should use to configure each cell from its backing model item.
 
 @return A configured data source.
 */
- (instancetype)initWithSectionPartitionedModelItems:(NSArray *)listOfModelItemsInPartitionedSections
                          defaultCellIdentifier:(NSString *)defaultCellIdentifier
                          customCellIdentifiers:(NSDictionary *)customCellIdentifierMapping
                                   sectionNames:(NSArray *)sectionNames
                             configureCellBlock:(APPSTableViewCellConfigureBlock)configureCellBlock;


#pragma mark - Inquiries

/**
 Retrieves the cell identifier to be used for the given model item.
 If all we're using is a default cell identifier, you'll get that back everytime
 you ask, and for every model item. However, if you've provided a value 
 for the property @c customCellIdentiferMapping, then we'll resolve consulting that 
 first, and then using the default identifier as a fallback.
 
 @param modelItem The model item whose cell identifier is being sought.
 
 @return The resolved cell identifier.
 */
- (NSString *)cellIdentifierForModelItem:(id)modelItem;


/**
 Retrieves the model item present at the specified index path.
 
 @param indexPath Provide this so we can retrieve the corresponding model for you.
 
 @return The sought model item, or nil if that index path is out of bounds.
 */
- (id)modelItemAtIndexPath:(NSIndexPath *)indexPath;


/**
 We retrieve the indexPath at which you can find the item (or an equivalent to it) 
 as vended by this data source. If dealing with multiple sections, you will have that
 correctly represented in the indexPath returned to you.
 
 @param modelItem The item whose indexPath is sought.
 
 @return The item's matching indexPath.
 */
- (NSIndexPath *)indexPathForModelItem:(id)modelItem;


/**
 Uses the @c sectionNameKeyPath property to tally how many unique sections exist.
 
 @return The tally (count) of unique sections, using the @c sectionNameKeyPath as the tool.
 */
- (NSUInteger)numberOfUniqueSectionNames;


/**
 Retrieves the name for the section with the given index.
 
 @param sectionIndex The index to search.
 
 @return The name of the section.
 */
- (NSString *)sectionNameForIndex:(NSUInteger)sectionIndex;

@end
