//
//  APPSRobustArrayDataSourceTestCase.m
//  AppstronomyStandardKit
//
//  Created by Sohail Ahmed on 1/28/16.
//  Copyright © 2016 Appstronomy, LLC. All rights reserved.
//

@import XCTest;
@import APPSUIKit;

#import "APPSRobustArrayDataSource.h"
#import "APPSDummyViewModel.h"

#pragma mark - Constants

static const NSUInteger kAPPSTest_SingleSectionArraySize                 = 10;
static const NSUInteger kAPPSTest_TwoSectionFlatArraySizeSection0        = 10;
static const NSUInteger kAPPSTest_TwoSectionFlatArraySizeSection1        = 23;
static const NSUInteger kAPPSTest_TwoSectionPartitionedArraySizeSection0 = 12;
static const NSUInteger kAPPSTest_TwoSectionPartitionedArraySizeSection1 = 17;

static NSString *const kAPPSTest_ModelSection0Name = @"Model Section 0";
static NSString *const kAPPSTest_ModelSection1Name = @"Model Section 1";


@interface APPSRobustArrayDataSourceTestCase : XCTestCase
@property (strong, nonatomic) NSArray *defaultSingleSectionArray;
@property (strong, nonatomic) NSArray *defaultTwoSectionArray;
@property (strong, nonatomic) NSArray *defaultPartitionedTwoSectionArray;
@property (strong, nonatomic) APPSRobustArrayDataSource *dataSource;
@end


@implementation APPSRobustArrayDataSourceTestCase

#pragma mark - Lifecycle

- (void)setUp;
{
    [super setUp];

    [self populateDefaultTestArrays];
}


#pragma mark - Tests

#pragma mark * Method: -modelItemAtIndexPath:

- (void)test_modelItemAtIndexPath__singleSection;
{
    [self configureDataSoureWithSingleSectionFlatArray];
    
    // Row Index: 0
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    APPSDummyViewModel *expectedModel = self.defaultSingleSectionArray[0];
    APPSDummyViewModel *actualModel = [self.dataSource modelItemAtIndexPath:indexPath];
    
    XCTAssertEqualObjects(expectedModel, actualModel,
                          @"Didn't get a match for:\n%@ \n and \n%@",
                          [expectedModel debugDescription],
                          [actualModel debugDescription]);
    
    // Row Index: 7
    indexPath = [NSIndexPath indexPathForRow:7 inSection:0];
    expectedModel = self.defaultSingleSectionArray[7];
    actualModel = [self.dataSource modelItemAtIndexPath:indexPath];
    
    XCTAssertEqualObjects(expectedModel, actualModel,
                          @"Didn't get a match for:\n%@ \n and \n%@",
                          [expectedModel debugDescription],
                          [actualModel debugDescription]);
}


- (void)test_modelItemAtIndexPath__twoSectionPartitioned;
{
    [self configureDataSoureWithTwoSectionPartionedArray];
    
    // {Section, Row} Index: 0,0
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    APPSDummyViewModel *expectedModel = self.defaultPartitionedTwoSectionArray[0][0];
    APPSDummyViewModel *actualModel = [self.dataSource modelItemAtIndexPath:indexPath];
    
    XCTAssertEqualObjects(expectedModel, actualModel,
                          @"Didn't get a match for:\n%@ \n and \n%@",
                          [expectedModel debugDescription],
                          [actualModel debugDescription]);
    
    // {Section, Row} Index: 1,4
    indexPath = [NSIndexPath indexPathForRow:4 inSection:1];
    expectedModel = self.defaultPartitionedTwoSectionArray[1][4];
    actualModel = [self.dataSource modelItemAtIndexPath:indexPath];
    
    XCTAssertEqualObjects(expectedModel, actualModel,
                          @"Didn't get a match for:\n%@ \n and \n%@",
                          [expectedModel debugDescription],
                          [actualModel debugDescription]);
}


- (void)test_modelItemAtIndexPath__twoSectionFlat;
{
    [self configureDataSoureWithTwoSectionFlatArray];
    
    // {Section, Row} Index: 0,0
    NSUInteger rowIndex = 0;
    NSUInteger sectionIndex = 0;
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    APPSDummyViewModel *expectedModel = self.defaultTwoSectionArray[0];
    APPSDummyViewModel *actualModel = [self.dataSource modelItemAtIndexPath:indexPath];
    
    XCTAssertEqualObjects(expectedModel, actualModel,
                          @"Didn't get a match for:\n%@ \n and \n%@",
                          [expectedModel debugDescription],
                          [actualModel debugDescription]);
    
    // {Section, Row} Index: 1,4
    rowIndex = 4;
    sectionIndex = 1;
    indexPath = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
    // Add the first section's entire count, and then the row index, to get at the expected model:
    expectedModel = self.defaultTwoSectionArray[kAPPSTest_TwoSectionFlatArraySizeSection0 + rowIndex];
    actualModel = [self.dataSource modelItemAtIndexPath:indexPath];
    
    XCTAssertEqualObjects(expectedModel, actualModel,
                          @"Didn't get a match for:\n%@ \n and \n%@",
                          [expectedModel debugDescription],
                          [actualModel debugDescription]);
}


#pragma mark * Method: -indexPathForModelItem:

- (void)test_indexPathForModelItem__singleSectionFlatArray;
{
    [self configureDataSoureWithSingleSectionFlatArray];
    
    // Row Index: 0
    NSUInteger expectedSectionIndex = 0;
    NSUInteger expectedRowIndex = 0;
    APPSDummyViewModel *queryModel = self.defaultSingleSectionArray[expectedRowIndex];

    NSIndexPath *expectedIndexPath = [NSIndexPath indexPathForRow:expectedRowIndex inSection:expectedSectionIndex];
    NSIndexPath *actualIndexPath = [self.dataSource indexPathForModelItem:queryModel];

    XCTAssertEqualObjects(expectedIndexPath, actualIndexPath,
                          @"Index Paths did not match up. Expected: %@, but received: %@.",
                          expectedIndexPath, actualIndexPath);
    
    // Row Index: 6
    expectedSectionIndex = 0;
    expectedRowIndex = 6;
    queryModel = self.defaultSingleSectionArray[expectedRowIndex];
    
    expectedIndexPath = [NSIndexPath indexPathForRow:expectedRowIndex inSection:expectedSectionIndex];
    actualIndexPath = [self.dataSource indexPathForModelItem:queryModel];
    
    XCTAssertEqualObjects(expectedIndexPath, actualIndexPath,
                          @"Index Paths did not match up. Expected: %@, but received: %@.",
                          expectedIndexPath, actualIndexPath);
}


- (void)test_indexPathForModelItem__twoSectionFlatArray;
{
    [self configureDataSoureWithTwoSectionFlatArray];
    
    // {Section, Row} Index: 0,0
    NSUInteger expectedSectionIndex = 0;
    NSUInteger expectedRowIndex = 0;
    APPSDummyViewModel *queryModel = self.defaultTwoSectionArray[expectedRowIndex];
    
    NSIndexPath *expectedIndexPath = [NSIndexPath indexPathForRow:expectedRowIndex inSection:expectedSectionIndex];
    NSIndexPath *actualIndexPath = [self.dataSource indexPathForModelItem:queryModel];
    
    XCTAssertEqualObjects(expectedIndexPath, actualIndexPath,
                          @"Index Paths did not match up. Expected: %@, but received: %@.",
                          expectedIndexPath, actualIndexPath);
    
    // {Section, Row} Index: 1,7
    expectedSectionIndex = 1;
    expectedRowIndex = 7;
    queryModel = self.defaultTwoSectionArray[kAPPSTest_TwoSectionFlatArraySizeSection0 + expectedRowIndex];
    
    expectedIndexPath = [NSIndexPath indexPathForRow:expectedRowIndex inSection:expectedSectionIndex];
    actualIndexPath = [self.dataSource indexPathForModelItem:queryModel];
    
    XCTAssertEqualObjects(expectedIndexPath, actualIndexPath,
                          @"Index Paths did not match up. Expected: %@, but received: %@.",
                          expectedIndexPath, actualIndexPath);
}


- (void)test_indexPathForModelItem__twoSectionPartitionedArray;
{
    [self configureDataSoureWithTwoSectionPartionedArray];
    
    // {Section, Row} Index: 0,0
    NSUInteger expectedSectionIndex = 0;
    NSUInteger expectedRowIndex = 0;
    APPSDummyViewModel *queryModel = self.defaultPartitionedTwoSectionArray[expectedSectionIndex][expectedRowIndex];
    
    NSIndexPath *expectedIndexPath = [NSIndexPath indexPathForRow:expectedRowIndex inSection:expectedSectionIndex];
    NSIndexPath *actualIndexPath = [self.dataSource indexPathForModelItem:queryModel];
    
    XCTAssertEqualObjects(expectedIndexPath, actualIndexPath,
                          @"Index Paths did not match up. Expected: %@, but received: %@.",
                          expectedIndexPath, actualIndexPath);
    
    // {Section, Row} Index: 1,7
    expectedSectionIndex = 1;
    expectedRowIndex = 7;
    queryModel = self.defaultPartitionedTwoSectionArray[expectedSectionIndex][expectedRowIndex];
    
    expectedIndexPath = [NSIndexPath indexPathForRow:expectedRowIndex inSection:expectedSectionIndex];
    actualIndexPath = [self.dataSource indexPathForModelItem:queryModel];
    
    XCTAssertEqualObjects(expectedIndexPath, actualIndexPath,
                          @"Index Paths did not match up. Expected: %@, but received: %@.",
                          expectedIndexPath, actualIndexPath);
}



#pragma mark * Section Names

- (void)test_numberOfUniqueSectionNames;
{
    [self configureDataSoureWithTwoSectionFlatArray];

    NSUInteger expectedSectionsCount = 2;
    NSUInteger actualSectionsCount = [self.dataSource numberOfUniqueSectionNames];
    XCTAssertEqual(expectedSectionsCount, actualSectionsCount,
                   @"The total number of sections inferred (%lu) did not match the count expected (%lu)",
                   (unsigned long)actualSectionsCount, (unsigned long)expectedSectionsCount);
}


- (void)test_orderedSectionNames;
{
    [self configureDataSoureWithTwoSectionFlatArray];
    
    NSString *expectedSection0Name = kAPPSTest_ModelSection0Name;
    NSString *expectedSection1Name = kAPPSTest_ModelSection1Name;
    NSArray  *actualSectionNames = self.dataSource.resolvedSectionNames;
    NSString *actualSection0Name = actualSectionNames[0];
    NSString *actualSection1Name = actualSectionNames[1];

    XCTAssertEqualObjects(expectedSection0Name, actualSection0Name,
                   @"The actual section 0 name retrieved of '%@' did not match the section 0 name expected '%@'.",
                          actualSection0Name, expectedSection0Name);
    
    XCTAssertEqualObjects(expectedSection1Name, actualSection1Name,
                          @"The actual section 1 name retrieved of '%@' did not match the section 1 name expected '%@'.",
                          actualSection1Name, expectedSection1Name);

}


#pragma mark * Selection State

- (void)test_modelItemsMatchingSelectionState__NoSelections;
{
    [self configureDataSoureWithTwoSectionFlatArray];

    self.dataSource.selectedFlagKeyPath = @"selected";
    
    // Selected Items: None
    NSArray *selectedItems = self.dataSource.selectedModelItems;
    XCTAssertEqual(0, [selectedItems count], @"Expected no entries to have been marked as selected as yet.");
    
    // Unselected Items: All
    NSArray *unselectedItems = self.dataSource.unselectedModelItems;
    NSUInteger totalItemsCount = kAPPSTest_TwoSectionFlatArraySizeSection0 + kAPPSTest_TwoSectionFlatArraySizeSection1;
    XCTAssertEqual(totalItemsCount, [unselectedItems count], @"Expected all entries to have been marked as unselected at present.");
}


- (void)test_modelItemsMatchingSelectionState__SomeSelections;
{
    [self configureDataSoureWithTwoSectionFlatArray];
    
    self.dataSource.selectedFlagKeyPath = @"selected";
    
    // Mark a few models as selected:
    APPSDummyViewModel *modelItemA = [self.dataSource modelItemAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
    APPSDummyViewModel *modelItemB = [self.dataSource modelItemAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]];
    APPSDummyViewModel *modelItemC = [self.dataSource modelItemAtIndexPath:[NSIndexPath indexPathForRow:5 inSection:1]];
    
    modelItemA.selected = YES;
    modelItemB.selected = YES;
    modelItemC.selected = YES;
    
    // --- Selected Items: Should be (3)
    NSArray *selectedItems = self.dataSource.selectedModelItems;
    XCTAssertEqual(3, [selectedItems count], @"Expected 3 entries to have been marked as selected thus far.");
    
    XCTAssertTrue([selectedItems containsObject:modelItemA], @"This model item was expected to be found amongst the returned array of selections.");
    XCTAssertTrue([selectedItems containsObject:modelItemB], @"This model item was expected to be found amongst the returned array of selections.");
    XCTAssertTrue([selectedItems containsObject:modelItemC], @"This model item was expected to be found amongst the returned array of selections.");
    
    // --- Unselected Items: Should be ALL but (3)
    NSArray *unselectedItems = self.dataSource.unselectedModelItems;
    NSUInteger totalItemsCount = kAPPSTest_TwoSectionFlatArraySizeSection0 + kAPPSTest_TwoSectionFlatArraySizeSection1 - 3;
    XCTAssertEqual(totalItemsCount, [unselectedItems count], @"Expected all entries but 3 to have been marked as unselected at present.");
}



#pragma mark - Helpers

- (void)populateDefaultTestArrays;
{
    // Single Section: Flat Array
    self.defaultSingleSectionArray = [self singleSectionModelItemsOfSize:kAPPSTest_SingleSectionArraySize];
    
    // Two Sections: Flat Array
    self.defaultTwoSectionArray = [self twoSectionModelItemsOfSizeFirstSection:kAPPSTest_TwoSectionFlatArraySizeSection0
                                                                 secondSection:kAPPSTest_TwoSectionFlatArraySizeSection1];
    
    // Two Sections: Partitioned Array
    self.defaultPartitionedTwoSectionArray = [self twoSectionPartitionedModelItemsOfSizeFirstSection:kAPPSTest_TwoSectionPartitionedArraySizeSection0 secondSection:kAPPSTest_TwoSectionPartitionedArraySizeSection1];
}


- (void)configureDataSoureWithSingleSectionFlatArray;
{
    self.dataSource = [[APPSRobustArrayDataSource alloc] initWithModelItems:self.defaultSingleSectionArray
                                                             cellIdentifier:@"TestCellIdentifier"
                                                         configureCellBlock:^(id cell, id item) { }];
}


- (void)configureDataSoureWithTwoSectionFlatArray;
{
    self.dataSource = [[APPSRobustArrayDataSource alloc] initWithModelItems:self.defaultTwoSectionArray
                                                      defaultCellIdentifier:@"TestCellIdentifier"
                                                      customCellIdentifiers:nil
                                                         sectionNameKeyPath:@"category"
                                                         configureCellBlock:^(id cell, id item) { }];
}


- (void)configureDataSoureWithTwoSectionPartionedArray;
{
    self.dataSource = [[APPSRobustArrayDataSource alloc] initWithSectionPartitionedModelItems:self.defaultPartitionedTwoSectionArray
                                                                        defaultCellIdentifier:@"TestCellIdentifier"
                                                                        customCellIdentifiers:nil
                                                                                 sectionNames:@[@"Section A", @"Section B"]
                                                                           configureCellBlock:^(id cell, id item) { }];
}



/**
 Creates and returns a basic dummy view model.
 Tests and other helpers can then modify a subset of the model's 
 properties in order to create the variation desired.
 */
- (APPSDummyViewModel *)dummyViewModel;
{
    APPSDummyViewModel *model = [APPSDummyViewModel new];
    model.name = @"Model A";
    model.category = @"Group 1";
    model.ready = YES;
    model.numberOfWidgets = 10;
    
    return model;
}


/**
 Creates a one-dimensonal array of view models who are meant to all belong to the same section.
 
 @param numItems The number of items you'd like in the returned array.
 */
- (NSArray *)singleSectionModelItemsOfSize:(NSUInteger)numItems;
{
    NSMutableArray *modelItems = [NSMutableArray arrayWithCapacity:numItems];
    
    for (int index = 0; index < numItems; index++) {
        APPSDummyViewModel *viewModel = [self dummyViewModel];
        viewModel.name = [NSString stringWithFormat:@"Model Row %d", index];
        viewModel.category = kAPPSTest_ModelSection0Name;
        [modelItems addObject:viewModel];
    }
    
    return modelItems;
}


/**
 Creates a one-dimensonal array of view models who belong to two (2) different sections.
 The number in each section is dictated by you, the caller. You must provide a value greater
 than zero in each section, for this to be meaningful.
 
 We'll denote the sections with names {"Model Section 0", "Model Section 1"}. This marking
 is done by setting these strings into the view model's property 'category'.
 */
- (NSArray *)twoSectionModelItemsOfSizeFirstSection:(NSUInteger)numItemsFirstSection
                                      secondSection:(NSUInteger)numItemsSecondSection;
{
    NSMutableArray *modelItems = [NSMutableArray arrayWithCapacity:numItemsFirstSection + numItemsSecondSection];
    
    // Populate the First Section
    for (int index = 0; index < numItemsFirstSection; index++) {
        APPSDummyViewModel *viewModel = [self dummyViewModel];
        viewModel.name = [NSString stringWithFormat:@"Model Row %d", index];
        viewModel.category = kAPPSTest_ModelSection0Name; // 1st Section
        [modelItems addObject:viewModel];
    }
    
    // Populate the Second Section
    for (int index = 0; index < numItemsSecondSection; index++) {
        APPSDummyViewModel *viewModel = [self dummyViewModel];
        viewModel.name = [NSString stringWithFormat:@"Model Row %d", index];
        viewModel.category = kAPPSTest_ModelSection1Name; // 2nd Section
        [modelItems addObject:viewModel];
    }
    
    return modelItems;
}


/**
 Creates a two-dimensonal ("partitioned") array of view models who belong to two (2) different sections.
 The number in each section is dictated by you, the caller. You must provide a value greater
 than zero in each section, for this to be meaningful.
 
 We'll denote the sections with names {"Model Section 0", "Model Section 1"}. This marking
 is done by setting these strings into the view model's property 'category'.
 
 Note that the array you get back will have two elements in it. Each element is itself an array,
 containing model items for its respective section. This array of arrays is what we mean by "partitioned".
 
 Here, section affiliation is explicit based on which of the two top-level arrays a model item belongs to.
 Of course, in constructing this data for you, we will mark each model item's 'category' property to be 
 consistent with the section (interior) arrays we give you.
 */
- (NSArray *)twoSectionPartitionedModelItemsOfSizeFirstSection:(NSUInteger)numItemsFirstSection
                                                 secondSection:(NSUInteger)numItemsSecondSection;
{
    NSMutableArray *modelItemsSection0 = [NSMutableArray arrayWithCapacity:numItemsFirstSection];
    NSMutableArray *modelItemsSection1 = [NSMutableArray arrayWithCapacity:numItemsSecondSection];
    
    // Populate the First Section
    for (int index = 0; index < numItemsFirstSection; index++) {
        APPSDummyViewModel *viewModel = [self dummyViewModel];
        viewModel.name = [NSString stringWithFormat:@"Model Row %d", index];
        viewModel.category = kAPPSTest_ModelSection0Name; // 1st Section
        [modelItemsSection0 addObject:viewModel];
    }
    
    // Populate the Second Section
    for (int index = 0; index < numItemsSecondSection; index++) {
        APPSDummyViewModel *viewModel = [self dummyViewModel];
        viewModel.name = [NSString stringWithFormat:@"Model Row %d", index];
        viewModel.category = kAPPSTest_ModelSection1Name; // 2nd Section
        [modelItemsSection1 addObject:viewModel];
    }
    
    return @[modelItemsSection0, modelItemsSection1];
}



@end
