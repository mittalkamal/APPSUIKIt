//
//  APPSArrayDataSource.m
//
//  Created by Sohail Ahmed on 2014-08-29.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "APPSArrayDataSource.h"

@interface APPSArrayDataSource ()
@property (nonatomic, copy) NSString *cellIdentifier;
@property (nonatomic, copy) NSArray *cellIdentifiers;
@property (nonatomic, copy) NSArray *tags;
@property (nonatomic, copy) APPSTableViewCellConfigureBlock configureCellBlock;
@end


@implementation APPSArrayDataSource

#pragma mark - Initialization

- (id)init
{
    return nil;
}


- (id)initWithItems:(NSArray *)items
     cellIdentifier:(NSString *)cellIdentifier
 configureCellBlock:(APPSTableViewCellConfigureBlock)configureCellBlock
{
    self = [super init];
    
    if (self) {
        self.items = items;
        self.cellIdentifier = cellIdentifier;
        self.configureCellBlock = [configureCellBlock copy];
    }
    
    return self;
}


- (id)initWithItems:(NSArray *)items
     cellIdentifiers:(NSArray *)cellIdentifiers
 configureCellBlock:(APPSTableViewCellConfigureBlock)configureCellBlock
{
    self = [super init];
    
    if (self) {
        self.items = items;
        self.cellIdentifiers = cellIdentifiers;
        self.configureCellBlock = [configureCellBlock copy];
    }
    
    return self;

}


- (id)initWithItems:(NSArray *)items
    cellIdentifiers:(NSArray *)cellIdentifiers
               tags:(NSArray *)tags
 configureCellBlock:(APPSTableViewCellConfigureBlock)configureCellBlock
{
    self = [super init];
    
    if (self) {
        self.items = items;
        self.tags = tags;
        self.cellIdentifiers = cellIdentifiers;
        self.configureCellBlock = [configureCellBlock copy];
    }
    
    return self;
    
}



#pragma mark - Inquiries

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath) { return nil; } // We don't want nil to turn to zero in our array dereferencing below.
    
    APPSAssert(indexPath.row < [self.items count],
               @"Asked to get element at index (row): %ld, but we only know of having %ld items.",
               (long)indexPath.row, (unsigned long)[self.items count]);
    
    return self.items[(NSUInteger) indexPath.row];
}


- (id)tagAtIndexPathWithSections:(NSIndexPath *)indexPath
{
    if (!indexPath) { return nil; } // We don't want nil to turn to zero in our array dereferencing below.`1
    APPSAssert(indexPath.section <[self.tags count],
               @"Asked to get element at index (section): %ld, but we only know of having %ld section items.",
               (long)indexPath.section, (unsigned long) [self.items count]);
    APPSAssert(indexPath.row < [(NSArray *)[self.tags objectAtIndex:indexPath.section ] count],
               @"Asked to get element at index (row) for section: %ld, but we only know of having %ld items.",
               (long)indexPath.row, (unsigned long)[(NSArray *)[self.tags objectAtIndex:indexPath.section ] count]);
    
    return ((NSArray *)self.tags[(NSUInteger) indexPath.section])[indexPath.row];
}


- (id)itemAtIndexPathWithSections:(NSIndexPath *)indexPath
{
    if (!indexPath) { return nil; } // We don't want nil to turn to zero in our array dereferencing below.`1
    APPSAssert(indexPath.section <[self.items count],
          @"Asked to get element at index (section): %ld, but we only know of having %ld section items.",
               (long)indexPath.section, (unsigned long) [self.items count]);
    APPSAssert(indexPath.row < [(NSArray *)[self.items objectAtIndex:indexPath.section ] count],
               @"Asked to get element at index (row) for section: %ld, but we only know of having %ld items.",
               (long)indexPath.row, (unsigned long)[(NSArray *)[self.items objectAtIndex:indexPath.section ] count]);
    
    return ((NSArray *)self.items[(NSUInteger) indexPath.section])[indexPath.row];
}


- (NSIndexPath *)indexPathForItem:(id)item;
{
    NSInteger matchingIndex = NSNotFound;
    NSIndexPath *indexPath = nil;
    
    for (id iteratedItem in self.items) {
        if ([iteratedItem isEqual:item]) {
            matchingIndex = [self.items indexOfObject:iteratedItem];
            break;
        }
    }
    
    if (matchingIndex != NSNotFound) {
        indexPath = [NSIndexPath indexPathForRow:matchingIndex inSection:0];
    }
    
    return indexPath;
}


#pragma mark - Protocol: UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.cellIdentifiers==nil) {
        return self.items.count;
    }
    else {
        return [(NSArray *)[self.items objectAtIndex:section] count];
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.cellIdentifiers) {
        return self.cellIdentifiers.count;
    } else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell;
    id item;
    
    if (self.cellIdentifiers == nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:self.cellIdentifier forIndexPath:indexPath];
         item = [self itemAtIndexPath:indexPath];
    }
    else {
        cell = [tableView dequeueReusableCellWithIdentifier:[(NSArray *)[self.cellIdentifiers objectAtIndex:indexPath.section] objectAtIndex:indexPath.row] forIndexPath:indexPath];
        item = [self itemAtIndexPathWithSections:indexPath];
        if (self.tags!=nil) {
            cell.tag = [(NSNumber *)[self tagAtIndexPathWithSections:indexPath] integerValue];
            logInfo(@"Setting cells tag to %ld",(long)cell.tag);
        }
    }
    
    self.configureCellBlock(cell, item);
    return cell;
}


@end
