//
//  APPSContainerView.h
//
//  Created by Sohail Ahmed on 5/12/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 Represents a UIView whose only purpose is to be a container for other views, be it one subview or several subviews.
 This view has no responsibility and no knowledge of any controllers or other associated objects to the views
 placed within us.
 
 For Auto Layout purposes, you can define a customSize, which gets used as our intrinsicContentSize. With this, you
 can use us as containing view for you subviews, and know that we will try to maintain this fixed custom size.
 */
@interface APPSContainerView : UIView

@property (assign, nonatomic) CGSize customSize;


@end
