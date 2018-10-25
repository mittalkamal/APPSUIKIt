//
//  APPSPlaceholderView.h
//
//  Created by Sohail Ahmed on 5/12/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "APPSContainerView.h"

/**
 We are a containing view whose purpose is to sit in for another view. We participate in Auto Layout constraints
 on behalf of whatever content will sit inside us. We only handle a single child subview, the contentView.
 
 When a view is set with our contentView property, we will remove any subviews we already contain, clear our
 background colour and add the contentView to ourselves. The contentView is then given constraints to center it
 with us, and given the same customSize as that configured for us.
 
 In this way, the contentView will report the same intrinsic content size as we do, and will effectively replace
 us (visually) in our superview.
 
 Use us to mark regions in a Storyboard scene with Auto Layout enabled that need to insert views from other
 components/nibs.
 */
@interface APPSPlaceholderView : APPSContainerView

@property (strong, nonatomic) APPSContainerView *contentView;

@end
