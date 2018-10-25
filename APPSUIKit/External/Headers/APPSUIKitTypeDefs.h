//
//  APPSUIKitTypeDefs.h
//
//  Created by Sohail Ahmed on 5/7/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import UIKit;

#ifndef APPSUIKitTypeDefs_h
#define APPSUIKitTypeDefs_h


#pragma mark - UIView

typedef void (^APPSSubviewBlock) (UIView *view);
typedef void (^APPSSuperviewBlock) (UIView *superview);



#pragma mark - Table View Cells

typedef void (^APPSTableViewCellConfigureBlock)(id cell, id item);
typedef void (^APPSTableViewCellCallbackBlock)(id cell, id item);


#endif
