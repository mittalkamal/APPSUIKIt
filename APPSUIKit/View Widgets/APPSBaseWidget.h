//
//  APPSBaseWidget.h
//
//  Created by Sohail Ahmed on 5/12/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class APPSPlaceholderView;
@class APPSContainerView;


@interface APPSBaseWidget : NSObject

// strong
@property (strong, nonatomic) IBOutlet APPSContainerView *view;

#pragma mark - Instantiation

/**
 Instantiates this widget. If the widget is to be used inside a hosting view that uses Auto Layout,
 this widget should be given an instrinsic content size by way of its view's customSize property.
 
 @return The newly instantiated widget requested.
 */
+ (APPSBaseWidget *)widget;


/**
 Instantiates this widget, installing its view inside the placeholder view provided.
 The widget's view will match the center coordinates of the placeholder, as well as
 take on the same intrinsic content size as the placeholder.
 
 @param placeholderView The encompassing container for the widget's view whose
 center position and intrinsic content size is mimicked by the widget's view.
 @return The newly instantiated widget requested.
 */
+ (APPSBaseWidget *)widgetWithinPlaceholder:(APPSPlaceholderView *)placeholderView;



#pragma mark - View Lifecycle

- (void)viewDidLoad;

@end
