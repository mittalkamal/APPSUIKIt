//
//  APPSPlaceholderView.m
//
//  Created by Sohail Ahmed on 5/12/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "APPSPlaceholderView.h"

@implementation APPSPlaceholderView


#pragma - Initialization

/**
 While design time may display a background color, we remove it at runtime so as not to contribute anything ourselves.
 Our goal is to let our contentView take center stage.
 */
- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        logDebug(@"Initializing placeholder view.");
        self.backgroundColor = [UIColor clearColor];
    }
    
    return self;
}



#pragma - Property Overrides

/**
 Setting a contentView will clear out any previous contentView installed, and will have the contentView
 take on our same position and intrinsic dimensions.
 
 @param contentView The new view we are hosting.
 */
- (void)setContentView:(APPSContainerView *)contentView {
    if (_contentView != contentView) {
        _contentView = contentView;
        
        [self removeAnyInteriorSubviews]; // will also remove any previous contentView we might have had
        [self configureContentView]; // install the new contentView to our size and same center
    }
}



#pragma - Preparing for Content View

/**
 Removes all subviews that we have. This also includes any official contentView that we may
 have had as a subview. The goal here, is to clear out any design time placeholder views, labels, etc.
 that don't belong on screen at runtime.
 */
- (void)removeAnyInteriorSubviews {
    // Make a copy of this array so that our upcoming fast-enumeration
    // isn't changing this UIView's internal subviews array while iterating:
    NSArray *subviews = [self.subviews copy];
    
    // Have each of these subviews remove themselves from us:
    for (UIView *iteratedSubview in subviews) {
        [iteratedSubview removeFromSuperview];
    }
}



#pragma - Installing Content View

/**
 We configure our contentView to report our same intrinsic size and to completely overlap us, by
 virtue of setting up Auto Layout constraints to have it share our center (x,y).
 */
- (void)configureContentView {
    if (!_contentView) { return; } // BAIL. We have no contentView as yet.
    
    // Give the content view the same intrinsic size override that we have:
    self.contentView.customSize = self.customSize;
    
    // Add the contentView to this view:
    [self addSubview:self.contentView];
    
    // Center the content view horizontally:
    NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint
                                             constraintWithItem:self.contentView
                                             attribute:NSLayoutAttributeCenterX
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                             attribute:NSLayoutAttributeCenterX
                                             multiplier:1
                                             constant:0];
    
    [self addConstraint:centerXConstraint];
    
    // Center the content view vertically:
    NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint
                                             constraintWithItem:self.contentView
                                             attribute:NSLayoutAttributeCenterY
                                             relatedBy:NSLayoutRelationEqual
                                             toItem:self
                                             attribute:NSLayoutAttributeCenterY
                                             multiplier:1
                                             constant:0];
    
    [self addConstraint:centerYConstraint];
}


@end
