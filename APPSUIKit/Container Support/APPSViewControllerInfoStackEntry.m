//
//  APPSViewControllerInfoStackEntry.m
//  Appstronomy UIKit
//
//  Created by Sohail Ahmed on 5/11/13.
//  Copyright (c) 2013 Appstronomy. All rights reserved.
//

#import "APPSViewControllerInfoStackEntry.h"
#import "APPSTaggedNaming.h"

@implementation APPSViewControllerInfoStackEntry

#pragma mark - Property Overrides

- (NSString *)taggedName
{
    NSString *taggedName = @"<No Tag Assigned>";
    
    if ([self.controller conformsToProtocol:@protocol(APPSTaggedNaming)]) {
        id <APPSTaggedNaming> taggedController = (id <APPSTaggedNaming>)self.controller;
        taggedName = taggedController.taggedName;
    }

    return taggedName;
}

@end
