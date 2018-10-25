//
//  APPSRobustArrayDataSource.m
//  AppstronomyStandardKit
//
//  Created by Sohail Ahmed on 1/28/16.
//  Copyright © 2016 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "APPSRobustArrayDataSource.h"

@interface APPSRobustArrayDataSource ()

#pragma mark scalar

/**
 Indicates that we are using the partitioned model items array.
 In reality, anytime we have more than one section, even if we 
 weren't provided a partitioned array, we will create on to use,
 setting this property to point to its contents.
 */
@property (assign, nonatomic) BOOL usingPartitionedModelItems;

/**
 Indicates that we are using a single section. In this case, 
 we know that we're dealing with a flat (i.e. one-dimensional)
 array of model items.
 */
@property (assign, nonatomic) BOOL usingSingleSection;

#pragma mark copy

/**
 We capture the provided key path here, for future reference.
 Callers originally provide this in one of our initializers,
 in order to guide us on how to find the section name from
 the model items themselves.
 */
@property (copy, nonatomic) NSString *sectionNameKeyPath;

#pragma mark strong

/**
 Captures section names that are explicitly given to us from the init
 method variation that lets callers specify these explicitly.
 
 To access the section names we are actually using, see the property
 @c resolvedSectionNames.
 */
@property (strong, nonatomic) NSArray *givenSectionNames;

/**
 The section names we inferred through filtering the model items
 using the provided section name key path value, in one of our init 
 method variations.
 
 To access the section names we are actually using, see the property
 @c resolvedSectionNames.
 */
@property (strong, nonatomic) NSArray *inferredSectionNames;

@end



@implementation APPSRobustArrayDataSource

#pragma mark - Initialization

#pragma mark * Single Section

- (instancetype)initWithModelItems:(NSArray *)listOfModelItems
                    cellIdentifier:(NSString *)defaultCellIdentifier
                configureCellBlock:(APPSTableViewCellConfigureBlock)configureCellBlock;
{
    self = [super init];
    
    if (self) {
        self.listOfModelItems = listOfModelItems;
        self.defaultCellIdentifier = defaultCellIdentifier;
        self.configureCellBlock = [configureCellBlock copy];
        self.usingSingleSection = YES;
    }
    
    return self;
}


#pragma mark * Possibly Multiple Sections

- (instancetype)initWithModelItems:(NSArray *)listOfModelItems
        defaultCellIdentifier:(NSString *)defaultCellIdentifier
        customCellIdentifiers:(NSDictionary *)customCellIdentifierMapping
           sectionNameKeyPath:(NSString *)sectionNameKeyPath
           configureCellBlock:(APPSTableViewCellConfigureBlock)configureCellBlock;
{
    self = [super init];
    
    if (self) {
        self.listOfModelItems           = listOfModelItems;
        self.defaultCellIdentifier      = defaultCellIdentifier;
        self.customCellIdentiferMapping = customCellIdentifierMapping;
        self.sectionNameKeyPath         = sectionNameKeyPath;
        self.configureCellBlock         = [configureCellBlock copy];
        self.usingPartitionedModelItems = NO;
        
        // Determine if this flat list of items has more than one section; and set flags appropriately.

        // Were we given a section name key path to determine the number of sections?
        if (sectionNameKeyPath) {
            // YES: We have a keypath, so determine number of sections:
            NSUInteger numberOfSections = [self numberOfUniqueSectionNames];
            self.usingSingleSection = (1 == numberOfSections);
            [self configurePartitionedArrayFromFlatArray];
        }
        else {
            // NO: Without a section keypath and by giving us a flat array of model items,
            // we have no choice but to declare this data source as serving a single section of items.
            self.usingSingleSection = YES;
        }
    }
    
    return self;
}


#pragma mark * Multiple Sections

- (instancetype)initWithSectionPartitionedModelItems:(NSArray *)listOfModelItemsInPartitionedSections
                          defaultCellIdentifier:(NSString *)defaultCellIdentifier
                          customCellIdentifiers:(NSDictionary *)customCellIdentifierMapping
                                   sectionNames:(NSArray *)sectionNames
                             configureCellBlock:(APPSTableViewCellConfigureBlock)configureCellBlock;
{
    self = [super init];
    
    if (self) {
        self.listOfModelItemsInPartitionedSections = listOfModelItemsInPartitionedSections;
        self.defaultCellIdentifier                 = defaultCellIdentifier;
        self.customCellIdentiferMapping            = customCellIdentifierMapping;
        self.givenSectionNames                     = sectionNames;
        self.configureCellBlock                    = [configureCellBlock copy];
        self.usingPartitionedModelItems            = YES;
    }
    
    return self;
}



#pragma mark - Configuration

- (void)configurePartitionedArrayFromFlatArray;
{
    self.inferredSectionNames = [self retrieveInferredSectionNamesForSectionKeypath];
    NSMutableArray *partitionedList = [NSMutableArray arrayWithCapacity:self.inferredSectionNames.count];
    
    // Loop through each section name, gathering associated objects into their own section array.
    // Then, add this section array to the partitioned list.
    for (NSString *iteratedSectionName in self.inferredSectionNames) {
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", self.sectionNameKeyPath, iteratedSectionName];
        NSArray *filteredArrayForIteratedSection = [self.listOfModelItems filteredArrayUsingPredicate:predicate];
        [partitionedList addObject:filteredArrayForIteratedSection];
    }
    
    self.listOfModelItemsInPartitionedSections = [NSArray arrayWithArray:partitionedList];
    
    self.usingPartitionedModelItems = YES;
}



#pragma mark - Property Overrides

- (NSArray *)resolvedSectionNames;
{
    if (self.givenSectionNames) {
        return self.givenSectionNames;
    }
    else {
        return self.inferredSectionNames;
    }
}


- (NSArray *)selectedModelItems;
{
    APPSAssert(self.selectedFlagKeyPath, @"Asked for 'selectedModelItems', but have not yet set the "
               "'selectedFlagKeyPath' property on the data source to help us identify such.");

    return [self modelItemsMatchingSelectionState:YES];
}


- (NSArray *)unselectedModelItems;
{
    APPSAssert(self.selectedFlagKeyPath, @"Asked for 'unselectedModelItems', but have not yet set the "
               "'selectedFlagKeyPath' property on the data source to help us identify such.");
    
    return [self modelItemsMatchingSelectionState:NO];
}



#pragma mark - Inquiries

- (NSString *)cellIdentifierForModelItem:(id)modelItem;
{
    NSString *identifier = nil;
    
    // First, consult the mapped identifiers:
    if (self.customCellIdentiferMapping) {
        identifier = self.customCellIdentiferMapping[modelItem];
    }
    
    // Next, fallback to the default identifier:
    if (!identifier) { identifier = self.defaultCellIdentifier; }
    
    return identifier;
}


- (id)modelItemAtIndexPath:(NSIndexPath *)indexPath;
{
    if (!indexPath) { return nil; } // No model if there's no index path.
    
    id modelItem = nil;
    
    // Are we configured as a single section data source?
    if (self.usingSingleSection) {
        // YES: We are configured as a single section.
        APPSAssert(0 == indexPath.section, @"Asked for model using an index path with a section other "
                   "than zero (%lu), in a single section configured data source.",
                   (unsigned long)indexPath.section);
        modelItem = self.listOfModelItems[(NSUInteger)indexPath.row];
    }
    else {
        // NO: We have multiple sections. Are they partitioned?
        if (self.usingPartitionedModelItems) {
            // YES: The multiple sections ARE partitioned.
            NSArray *sectionContents = self.listOfModelItemsInPartitionedSections[(NSUInteger)indexPath.section];
            APPSAssert(sectionContents, @"The section '%lu' is out of bounds. "
                       "Asked for indexPath %@ when we only have %lu sections.",
                       (unsigned long)indexPath.section, indexPath,
                       (unsigned long)[self.listOfModelItemsInPartitionedSections count]);
            APPSAssert(indexPath.row < [sectionContents count],
                       @"Asked for indexPath %@ when we only have %lu items in section %lu.",
                       indexPath, (unsigned long)[sectionContents count], (unsigned long)indexPath.section);
            
            modelItem = sectionContents[(NSUInteger)indexPath.row];
        }
        else {
            // NO: The multiple sections that we do have, are NOT stored by us in partitioned fashion.
            APPSAssert(NO, @"Failed to partition our flat array on initialization, "
                       "for what is a multi-section collection of model objects.");
        }
    }
    
    return modelItem;
}


- (NSIndexPath *)indexPathForModelItem:(id)modelItem;
{
    if (!modelItem) { return nil; } // We won't have an index path if there's no model provided.
    
    NSIndexPath *indexPath = nil;
    NSInteger sectionIndex = NSNotFound;
    NSInteger rowIndex = NSNotFound;
    
    // Are we using a single section?
    if (self.usingSingleSection) {
        // YES: We'll just find the index in the one-dimensional array.
        sectionIndex = 0; // By definition, a single section.
        rowIndex = [self.listOfModelItems indexOfObject:modelItem];
    }
    else {
        // NO: We're using multiple sections.
        APPSAssert(self.listOfModelItemsInPartitionedSections,
                   @"For not having a single section, we should have had the property 'listOfModelItemsInPartitionedSections' set.");
        
        // Loop through each section, in search of this model item:
        for (NSArray *iteratedSectionArray in self.listOfModelItemsInPartitionedSections) {
            // Look for the model object in this flat array, devoted to the one section being iterated:
            rowIndex = [iteratedSectionArray indexOfObject:modelItem];
            
            // Did we find a match?
            if (rowIndex != NSNotFound) {
                // YES: We found the model item. We already set the rowIndex
                sectionIndex = [self.listOfModelItemsInPartitionedSections indexOfObject:iteratedSectionArray];
                break;
            }
        }
    }
    
    // Did we find a valid section index and row index?
    if (sectionIndex >=0 && rowIndex >= 0) {
        indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    }
    
    return indexPath;
}


/**
 Uses the @c sectionNameKeyPath property to tally how many unique sections exist.
 
 @return The tally (count) of unique sections, using the @c sectionNameKeyPath as the tool.
 */
- (NSUInteger)numberOfUniqueSectionNames;
{
    NSString *distinctKeyPathCommandString = [NSString stringWithFormat:@"@distinctUnionOfObjects.%@", self.sectionNameKeyPath];
    NSNumber *countValue = [[self.listOfModelItems valueForKeyPath:distinctKeyPathCommandString] valueForKeyPath:@"@count"];
    
    return [countValue unsignedIntegerValue];
}


- (NSArray *)retrieveInferredSectionNamesForSectionKeypath;
{
    // Here, we cannot use @distinctUnionOfObjects with -valueForKeyPath: because that union does NOT preserve ordering.
    NSArray *sectionNames = [self.listOfModelItems valueForKey:self.sectionNameKeyPath];
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:sectionNames];
    return [orderedSet array];
}


- (NSString *)sectionNameForIndex:(NSUInteger)sectionIndex;
{
    return [self resolvedSectionNames][sectionIndex];
}


/**
 This relies on the assumption that the property @c selectedFlagKeyPath has a valid keypath value
 into the model item.
 
 @param selected Indicates whether you are interested in selected items (YES) or unselected items (NO).
 
 @return The matching entries (view models).
 */
- (NSArray *)modelItemsMatchingSelectionState:(BOOL)selected;
{
    NSArray *matchingEntries = nil;
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K = %@", self.selectedFlagKeyPath, @(selected)];
    
    // Are we dealing with a single section?
    if (self.usingSingleSection) {
        // YES: So we only need to run a predicate filter on that one, flat array:
        matchingEntries = [self.listOfModelItems filteredArrayUsingPredicate:predicate];
    }
    else {
        // NO: So we only need to run a predicate filter on each section array:
        NSMutableArray *accumulatedEntries = [NSMutableArray arrayWithCapacity:10];
        for (NSArray *iteratedSectionArray in self.listOfModelItemsInPartitionedSections) {
            [accumulatedEntries addObjectsFromArray:[iteratedSectionArray filteredArrayUsingPredicate:predicate]];
        }
        
        matchingEntries = [NSArray arrayWithArray:accumulatedEntries];
    }
    
    return matchingEntries;
}



#pragma mark - Protocol: UITableViewDataSource

#pragma mark * Sections

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger numberOfSections;
    
    if (self.usingSingleSection) {
        numberOfSections = 1;
    }
    else {
        numberOfSections = [self.listOfModelItemsInPartitionedSections count];
    }
 
    return numberOfSections;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;
{
    return [self sectionNameForIndex:(NSUInteger)section];
}


#pragma mark * Rows

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSUInteger numberOfRows;
    
    if (self.usingSingleSection) {
        numberOfRows = [self.listOfModelItems count];
    }
    else {
        numberOfRows = [self.listOfModelItemsInPartitionedSections[(NSUInteger)section] count];
    }
    
    return numberOfRows;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    NSString *cellIdentifier;
    id modelItem;
    
    modelItem = [self modelItemAtIndexPath:indexPath];
    cellIdentifier = [self cellIdentifierForModelItem:modelItem];
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];

    self.configureCellBlock(cell, modelItem);

    return cell;
}


@end
