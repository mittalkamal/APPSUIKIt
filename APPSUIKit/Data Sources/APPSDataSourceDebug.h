//
//  APPSDataSourceDebug.h
//  PKPDCalculator
//
//  Created by Ken Grigsby on 8/3/15.
//  Copyright (c) 2015 Appstronomy, LLC. All rights reserved.
//
// This code was taken from the WWDC 2015 Sample Code for Session AdvancedCollectionView: Advanced User Interfaces Using Collection View
// https://developer.apple.com/sample-code/wwdc/2015/?q=advanced%20user%20interfaces.


/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 Helper functions for debugging.
 */

@import Foundation;

#import "APPSDataSourceDebug.h"

NSString *APPSStringFromBOOL(BOOL value)
{
    return value ? @"YES" : @"NO";
}

NSString *APPSStringFromNSIndexPath(NSIndexPath *indexPath)
{
    NSMutableArray *indexes = [NSMutableArray array];
    NSUInteger numberOfIndexes = indexPath.length;
    
    for (NSUInteger currentIndex = 0; currentIndex < numberOfIndexes; ++ currentIndex)
        [indexes addObject:@([indexPath indexAtPosition:currentIndex])];
    
    return [NSString stringWithFormat:@"(%@)", [indexes componentsJoinedByString:@", "]];
}

NSString *APPSStringFromNSIndexSet(NSIndexSet *indexSet)
{
    NSMutableArray *result = [NSMutableArray array];
    
    [indexSet enumerateRangesUsingBlock:^(NSRange range, BOOL *stop) {
        switch (range.length) {
            case 0:
                [result addObject:@"empty"];
                break;
            case 1:
                [result addObject:[NSString stringWithFormat:@"%ld", (unsigned long)range.location]];
                break;
            default:
                [result addObject:[NSString stringWithFormat:@"%ld..%lu", (unsigned long)range.location, (unsigned long)(range.location + range.length - 1)]];
                break;
        }
    }];
    
    return [NSString stringWithFormat:@"(%@)", [result componentsJoinedByString:@", "]];
}
