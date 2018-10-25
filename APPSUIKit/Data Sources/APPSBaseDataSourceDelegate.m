//
//  APPSBaseDataSourceDelegate.m
//
//  Created by Ken Grigsby on 10/7/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "APPSBaseDataSourceDelegate.h"
#import "APPSDataSourceDebug.h"
#import "APPSDataSource_Private.h"

#define UPDATE_DEBUGGING 0

#if UPDATE_DEBUGGING
#define UPDATE_LOG(FORMAT, ...) NSLog(@"%@ " FORMAT, NSStringFromSelector(_cmd), __VA_ARGS__)
#define UPDATE_TRACE(MESSAGE) NSLog(@"%@ " MESSAGE, NSStringFromSelector(_cmd))
#else
#define UPDATE_LOG(FORMAT, ...)
#define UPDATE_TRACE(MESSAGE)
#endif

static void * const APPSDataSourceContext = @"DataSourceContext";

@interface APPSBaseDataSourceDelegate () <APPSDataSourceDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableIndexSet *reloadedSections;
@property (nonatomic, strong) NSMutableIndexSet *deletedSections;
@property (nonatomic, strong) NSMutableIndexSet *insertedSections;
@property (nonatomic, copy) dispatch_block_t updateCompletionHandler;
@property (nonatomic) BOOL performingUpdates;
@property (nonatomic, weak) APPSTablePlaceholderView *placeholderView;
@end

@implementation APPSBaseDataSourceDelegate


#pragma mark - Instantiation

- (instancetype)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (instancetype)initWithTableView:(UITableView *)tableView
{
    NSParameterAssert(tableView != nil);
    
    self = [super init];
    if (self) {
        _tableView = tableView;
        
        //  We need to know when the data source changes on the collection view so we can become the delegate for any APPSDataSource subclasses.
        [tableView addObserver:self forKeyPath:@"dataSource" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:APPSDataSourceContext];

        self.animateTableChanges = YES;
        [self setAllAnimations:UITableViewRowAnimationFade];
    }
    return self;
}


- (void)dealloc
{
    [self.tableView removeObserver:self forKeyPath:@"dataSource" context:APPSDataSourceContext];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    //  For change contexts that aren't the data source, pass them to super.
    if (APPSDataSourceContext != context) {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
        return;
    }
    
    UITableView *tableView = object;
    id<UITableViewDataSource> dataSource = tableView.dataSource;
    
    if ([dataSource isKindOfClass:[APPSDataSource class]]) {
        APPSDataSource *appsDataSource = (APPSDataSource *)dataSource;
        if (!appsDataSource.delegate)
            appsDataSource.delegate = self;
    }
}


#pragma mark - Public API

- (void)setAllAnimations:(UITableViewRowAnimation)animation
{
    [self setAllSectionAnimations:animation];
    [self setAllItemAnimations:animation];
}


- (void)setAllSectionAnimations:(UITableViewRowAnimation)animation
{
    self.addSectionAnimation = animation;
    self.removeSectionAnimation = animation;
    self.updateSectionAnimation = animation;
}


- (void)setAllItemAnimations:(UITableViewRowAnimation)animation
{
    self.addItemAnimation = animation;
    self.removeItemAnimation = animation;
    self.updateItemAnimation = animation;
}



#pragma mark - Protocol: APPSDataSourceDelegate

#if UPDATE_DEBUGGING

- (NSString *)stringFromArrayOfIndexPaths:(NSArray *)indexPaths
{
    NSMutableString *result = [NSMutableString string];
    for (NSIndexPath *indexPath in indexPaths) {
        if ([result length])
            [result appendString:@", "];
        [result appendString:APPSStringFromNSIndexPath(indexPath)];
    }
    return result;
}

#endif


- (void)dataSource:(APPSDataSource *)dataSource didInsertItemsAtIndexPaths:(NSArray *)indexPaths
{
    UPDATE_LOG(@"INSERT ITEMS: %@ DATASOURCE: %@", [self stringFromArrayOfIndexPaths:indexPaths], dataSource);
    [self.tableView insertRowsAtIndexPaths:indexPaths withRowAnimation:self.addItemAnimation];
}


- (void)dataSource:(APPSDataSource *)dataSource didRemoveItemsAtIndexPaths:(NSArray *)indexPaths
{
    UPDATE_LOG(@"REMOVE ITEMS: %@ DATASOURCE: %@", [self stringFromArrayOfIndexPaths:indexPaths], dataSource);
    [self.tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:self.removeItemAnimation];
}


- (void)dataSource:(APPSDataSource *)dataSource didRefreshItemsAtIndexPaths:(NSArray *)indexPaths
{
    UPDATE_LOG(@"REFRESH ITEMS: %@ DATASOURCE: %@", [self stringFromArrayOfIndexPaths:indexPaths], dataSource);
    // Doing a reload on a tableView with more than one section causes the tableView
    // to scroll back and forth. If you get the offset and reset it without animation
    // you don't see the scrolling.
    
    CGPoint offset = self.tableView.contentOffset;
    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:self.updateItemAnimation];
    self.tableView.contentOffset = offset;
}


- (void)dataSource:(APPSDataSource *)dataSource didMoveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)newIndexPath
{
    UPDATE_LOG(@"MOVE ITEM: %@ TO: %@ DATASOURCE: %@", APPSStringFromNSIndexPath(fromIndexPath), APPSStringFromNSIndexPath(newIndexPath), dataSource);
    [self.tableView moveRowAtIndexPath:fromIndexPath toIndexPath:newIndexPath];
}


- (void)dataSource:(APPSDataSource *)dataSource didInsertSections:(NSIndexSet *)sections
{
    if (!sections)  // bail if nil just to keep table view safe and pure
        return;
    
    UPDATE_LOG(@"INSERT SECTIONS: %@ DATASOURCE: %@", APPSStringFromNSIndexSet(sections), dataSource);
    [self.tableView insertSections:sections withRowAnimation:self.addSectionAnimation];
    [self.insertedSections addIndexes:sections];
}


- (void)dataSource:(APPSDataSource *)dataSource didRemoveSections:(NSIndexSet *)sections
{
    if (!sections)  // bail if nil just to keep table view safe and pure
        return;
    
    UPDATE_LOG(@"DELETE SECTIONS: %@ DATASOURCE: %@", APPSStringFromNSIndexSet(sections), dataSource);
    [self.tableView deleteSections:sections withRowAnimation:self.removeSectionAnimation];
    [self.deletedSections addIndexes:sections];
}


- (void)dataSource:(APPSDataSource *)dataSource didMoveSection:(NSInteger)section toSection:(NSInteger)newSection;
{
    UPDATE_LOG(@"MOVE SECTION: %ld TO: %ld DATASOURCE: %@", (long)section, (long)newSection, dataSource);
    [self.tableView moveSection:section toSection:newSection];
}


- (void)dataSource:(APPSDataSource *)dataSource didRefreshSections:(NSIndexSet *)sections
{
    UPDATE_LOG(@"REFRESH SECTIONS: %@ DATASOURCE: %@", APPSStringFromNSIndexSet(sections), dataSource);
    // It's not "legal" to reload a section if you also delete the section later in the same batch update. So we'll just remember that we want to reload these sections when we're performing a batch update and reload them only if they weren't also deleted.
    if (self.performingUpdates)
        [self.reloadedSections addIndexes:sections];
    else
        [self.tableView reloadSections:sections withRowAnimation:self.updateSectionAnimation];
}


- (void)dataSourceDidReloadData:(APPSDataSource *)dataSource
{
    UPDATE_LOG(@"RELOAD DATASOURCE: %@", dataSource);
    [self.tableView reloadData];
}


- (void)dataSource:(APPSDataSource *)dataSource performBatchUpdate:(dispatch_block_t)update complete:(dispatch_block_t)complete
{
    [self performBatchUpdates:^{
        update();
    } completion:^{
        if (complete) {
            complete();
        }
    }];
}

- (void)performBatchUpdates:(void(^)())updates completion:(void(^)())completion
{
    NSAssert([NSThread isMainThread], @"You can only call -performBatchUpdates:completion: from the main thread.");
    
    // We're currently updating the table view, so we can't call -performBatchUpdates:completion: on it.
    if (self.performingUpdates) {
        UPDATE_TRACE(@"  PERFORMING UPDATES IMMEDIATELY");
        
        // Chain the completion handler if one was given
        if (completion) {
            dispatch_block_t oldCompletion = self.updateCompletionHandler;
            self.updateCompletionHandler = ^{
                oldCompletion();
                completion();
            };
        }
        // Now immediately execute the new updates
        if (updates)
            updates();
        return;
    }
    
#if UPDATE_DEBUGGING
    static NSInteger updateNumber = 0;
#endif
    UPDATE_LOG(@"%ld: PERFORMING BATCH UPDATE", (long)++updateNumber);
    
    self.reloadedSections = [NSMutableIndexSet indexSet];
    self.deletedSections = [NSMutableIndexSet indexSet];
    self.insertedSections = [NSMutableIndexSet indexSet];
    
    __block dispatch_block_t completionHandler = nil;
    
    [CATransaction begin];
    
    [CATransaction setCompletionBlock:^{
        UPDATE_LOG(@"%ld:  BEGIN COMPLETION HANDLER", (long)updateNumber);
        if (completionHandler)
            completionHandler();
        UPDATE_LOG(@"%ld:  END COMPLETION HANDLER", (long)updateNumber);
    }];
    
    [self.tableView beginUpdates];
    {
        UPDATE_LOG(@"%ld:  BEGIN UPDATE", (long)updateNumber);
        self.performingUpdates = YES;
        self.updateCompletionHandler = completion;
        
        updates();
        
        // Perform delayed reloadSections calls
        NSMutableIndexSet *sectionsToReload = [[NSMutableIndexSet alloc] initWithIndexSet:self.reloadedSections];
        
        // UITableView doesn't like it if you reload a section that was either inserted or deleted. So before we can call -reloadSections: all sections that were inserted or deleted must be removed.
        [sectionsToReload removeIndexes:self.deletedSections];
        [sectionsToReload removeIndexes:self.insertedSections];
        
        [self.tableView reloadSections:sectionsToReload withRowAnimation:self.updateSectionAnimation];
        UPDATE_LOG(@"%ld:  RELOADED SECTIONS: %@", (long)updateNumber, APPSStringFromNSIndexSet(sectionsToReload));
        
        UPDATE_LOG(@"%ld:  END UPDATE", (long)updateNumber);
        self.performingUpdates = NO;
        completionHandler = self.updateCompletionHandler;
        self.updateCompletionHandler = nil;
        self.reloadedSections = nil;
        self.deletedSections = nil;
        self.insertedSections = nil;
    }
    [self.tableView endUpdates];
    
    [CATransaction commit];
    
    
}


- (void)dataSource:(APPSDataSource *)dataSource didDismissPlaceholderForSections:(NSIndexSet *)sections
{
    UPDATE_LOG(@"Dismiss placeholder: sections=%@ DATASOURCE: %@", APPSStringFromNSIndexSet(sections), dataSource);
    [self.reloadedSections addIndexes:sections];
    
    [self dataSource:dataSource updatePlaceholderViewForSections:sections];
    self.placeholderView = nil;
}


- (void)dataSource:(APPSDataSource *)dataSource didPresentActivityIndicatorForSections:(NSIndexSet *)sections
{
    UPDATE_LOG(@"Present activity indicator: sections=%@ DATASOURCE: %@", APPSStringFromNSIndexSet(sections), dataSource);
    [self.reloadedSections addIndexes:sections];
    
    if (!_placeholderView) {
        _placeholderView = [dataSource dequeuePlaceholderViewForTableView:self.tableView];
    }
    
    [self dataSource:dataSource updatePlaceholderViewForSections:sections];
}


- (void)dataSource:(APPSDataSource *)dataSource didPresentPlaceholderForSections:(NSIndexSet *)sections
{
    UPDATE_LOG(@"Present placeholder: sections=%@ DATASOURCE: %@", APPSStringFromNSIndexSet(sections), dataSource);
    [self.reloadedSections addIndexes:sections];
    
    if (!_placeholderView) {
        _placeholderView = [dataSource dequeuePlaceholderViewForTableView:self.tableView];
    }
    
    [self dataSource:dataSource updatePlaceholderViewForSections:sections];
}


- (void)dataSourceWillLoadContent:(APPSDataSource *)dataSource
{
    UPDATE_LOG(@"WILL LOAD CONTENT DATASOURCE: %@", dataSource);

    if (!self.shouldAnimateTableChanges) {
        [UIView setAnimationsEnabled:NO];
    }
}


- (void)dataSource:(APPSDataSource *)dataSource didLoadContentWithError:(NSError *)error
{
    UPDATE_LOG(@"DID LOAD CONTENT DATASOURCE: %@", dataSource);
    
    if (!self.shouldAnimateTableChanges) {
        [UIView setAnimationsEnabled:YES];
    }
}


#pragma mark - Helper

- (void)dataSource:(APPSDataSource *)dataSource updatePlaceholderViewForSections:(NSIndexSet *)sections
{
    NSInteger sectionIndex = 0;
    if (sections.count == 1) {
        sectionIndex = sections.firstIndex;
    }
    [dataSource updatePlaceholderView:self.placeholderView forSectionAtIndex:sectionIndex];
    
}


@end
