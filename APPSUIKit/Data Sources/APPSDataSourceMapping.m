//
//  APPSDataSourceMapping.h
//
//  Created by Ken Grigsby on 8/3/15.
//  Copyright (c) 2015 Appstronomy, LLC. All rights reserved.
//
//
// This code was taken from the WWDC 2015 Sample Code for Session AdvancedCollectionView: Advanced User Interfaces Using Collection View
// https://developer.apple.com/sample-code/wwdc/2015/?q=advanced%20user%20interfaces.

/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 A subclass of AAPLDataSource with multiple child data sources. Child data sources may have multiple sections. Load content messages will be sent to all child data sources.
 
  This file contains some classes used internally by the AAPLComposedDataSource to manage the mapping between external NSIndexPaths and child data source NSIndexPaths. Of particular interest is the AAPLComposedViewWrapper which proxies messages to UICollectionView.
 */

#import "APPSDataSourceMapping.h"
#import "APPSDataSource.h"

#import <objc/runtime.h>

@protocol APPSShadowRegistrarVending <NSObject>
@property (nonatomic, readonly) APPSShadowRegistrar *shadowRegistrar;
@end


@interface APPSDataSourceMapping ()

@property (nonatomic, strong) NSMutableDictionary *globalToLocalSections;
@property (nonatomic, strong) NSMutableDictionary *localToGlobalSections;
@property (nonatomic, readwrite) NSInteger numberOfSections;

@end

@implementation APPSDataSourceMapping

- (instancetype)initWithDataSource:(APPSDataSource *)dataSource
{
    self = [super init];
    if (!self)
        return nil;

    _dataSource = dataSource;
    _globalToLocalSections = [NSMutableDictionary dictionary];
    _localToGlobalSections = [NSMutableDictionary dictionary];
    return self;
}

- (nonnull instancetype)initWithDataSource:(APPSDataSource *)dataSource globalSectionIndex:(NSInteger)sectionIndex
{
    self = [self initWithDataSource:dataSource];
    if (!self)
        return nil;

    [self updateMappingStartingAtGlobalSection:sectionIndex withBlock:^(NSInteger globalSectionIndex){}];
    return self;
}

- (instancetype)init
{
    [NSException raise:NSInvalidArgumentException format:@"Don't call %@.", @(__PRETTY_FUNCTION__)];
    return nil;
}

- (id)copyWithZone:(NSZone *)zone
{
    APPSDataSourceMapping *result = [[[self class] allocWithZone:zone] init];
    result.dataSource = self.dataSource;
    result.globalToLocalSections = self.globalToLocalSections;
    result.localToGlobalSections = self.localToGlobalSections;

    return result;
}

- (NSInteger)localSectionForGlobalSection:(NSInteger)globalSection
{
    NSNumber *localSection = _globalToLocalSections[@(globalSection)];
    if (!localSection)
        return NSNotFound;
    return [localSection unsignedIntegerValue];
}

- (NSIndexSet *)localSectionsForGlobalSections:(NSIndexSet *)globalSections
{
    NSMutableIndexSet *localSections = [[NSMutableIndexSet alloc] init];

    [globalSections enumerateIndexesUsingBlock:^(NSUInteger globalSection, BOOL *stop) {
        NSNumber *localSection = _globalToLocalSections[@(globalSection)];
        if (!localSection)
            return;
        [localSections addIndex:localSection.unsignedIntegerValue];
    }];

    return localSections;
}

- (NSInteger)globalSectionForLocalSection:(NSInteger)localSection
{
    NSNumber *globalSection = _localToGlobalSections[@(localSection)];
    NSAssert(globalSection != nil,@"localSection %ld not found in localToGlobalSections:%@",(long)localSection,_localToGlobalSections);
    return [globalSection unsignedIntegerValue];
}

- (NSIndexSet *)globalSectionsForLocalSections:(NSIndexSet *)localSections
{
    NSMutableIndexSet *globalSections = [[NSMutableIndexSet alloc] init];

    [localSections enumerateIndexesUsingBlock:^(NSUInteger localSection, BOOL *stop) {
        NSNumber *globalSection = _localToGlobalSections[@(localSection)];
        NSAssert(globalSection != nil,@"localSection %ld not found in localToGlobalSections:%@",(long)localSection,_localToGlobalSections);
        [globalSections addIndex:globalSection.unsignedIntegerValue];
    }];

    return globalSections;
}

- (NSIndexPath *)localIndexPathForGlobalIndexPath:(NSIndexPath *)globalIndexPath
{
    NSInteger section = [self localSectionForGlobalSection:globalIndexPath.section];
    if (NSNotFound == section)
        return nil;
    return [NSIndexPath indexPathForItem:globalIndexPath.item inSection:section];
}

- (NSIndexPath *)globalIndexPathForLocalIndexPath:(NSIndexPath *)localIndexPath
{
    NSInteger section = [self globalSectionForLocalSection:localIndexPath.section];
    return [NSIndexPath indexPathForItem:localIndexPath.item inSection:section];
}

- (void)addMappingFromGlobalSection:(NSInteger)globalSection toLocalSection:(NSInteger)localSection
{
    NSNumber *globalNum = @(globalSection);
    NSNumber *localNum = @(localSection);
    NSAssert(_localToGlobalSections[localNum] == nil, @"collision while trying to add to a mapping");
    _globalToLocalSections[globalNum] = localNum;
    _localToGlobalSections[localNum] = globalNum;
}

- (void)updateMappingStartingAtGlobalSection:(NSInteger)globalSection withBlock:(void (^)(NSInteger globalSection))block
{
    _numberOfSections = _dataSource.numberOfSections;
    [_globalToLocalSections removeAllObjects];
    [_localToGlobalSections removeAllObjects];

    for (NSInteger localSection = 0; localSection<_numberOfSections; localSection++) {
        [self addMappingFromGlobalSection:globalSection toLocalSection:localSection];
        block(globalSection++);
    }
}

- (NSArray *)localIndexPathsForGlobalIndexPaths:(NSArray *)globalIndexPaths
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[globalIndexPaths count]];
    for (NSIndexPath *globalIndexPath in globalIndexPaths) {
        NSIndexPath *localIndexPath = [self localIndexPathForGlobalIndexPath:globalIndexPath];
        if (localIndexPath)
            [result addObject:localIndexPath];
    }

    return result;
}

- (NSArray *)globalIndexPathsForLocalIndexPaths:(NSArray *)localIndexPaths
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:[localIndexPaths count]];
    for (NSIndexPath *localIndexPath in localIndexPaths)
        [result addObject:[self globalIndexPathForLocalIndexPath:localIndexPath]];

    return result;
}

@end


