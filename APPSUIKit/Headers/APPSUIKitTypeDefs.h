//
//  APPSFoundationTypeDefs.h
//
//  Created by Sohail Ahmed on 5/7/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import UIKit;

#ifndef Appstronomy_Standard_Kit_APPSTypeDefs_h
#define Appstronomy_Standard_Kit_APPSTypeDefs_h

#pragma mark - Generic Callbacks

typedef void (^APPSCallbackBlock)();
typedef void (^APPSCallbackWithSingleIntBlock)(NSUInteger value);
typedef void (^APPSCallbackWithSingleStringBlock)(NSString *value);
typedef void (^APPSCallbackWithSingleObjectBlock)(id object);
typedef void (^APPSCallbackWithDoubleObjectBlock)(id object1, id object2);
typedef void (^APPSCallbackWithStatusAndErrorBlock)(BOOL success, NSError *error);
typedef void (^APPSCallbackWithStatusBlock)(BOOL success);



#pragma mark - UIView

typedef void (^APPSSubviewBlock) (UIView *view);
typedef void (^APPSSuperviewBlock) (UIView *superview);



#pragma mark - Table View Cells

typedef void (^APPSTableViewCellConfigureBlock)(id cell, id item);
typedef void (^APPSTableViewCellCallbackBlock)(id cell, id item);



#pragma mark - Store Kit

typedef void (^APPSReceiptValidatedBlock)(BOOL success, NSArray *);


#endif
