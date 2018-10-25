//
//  APPSContainerView.m
//
//  Created by Sohail Ahmed on 5/12/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "APPSContainerView.h"

@implementation APPSContainerView

/**
 Override to UIView's version for cases where a custom size has been set on this container view.
 
 @return A custom intrinsic content size for use by Auto Layout, if customSize was set.
 */
- (CGSize)intrinsicContentSize {
    if (CGSizeEqualToSize(self.customSize, CGSizeZero)) {
        return [super intrinsicContentSize];
    }
    else {
        return self.customSize;
    }
}


@end
