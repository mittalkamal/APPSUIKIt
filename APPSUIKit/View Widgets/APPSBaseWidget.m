//
//  APPSBaseWidget.m
//
//  Created by Sohail Ahmed on 5/12/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "APPSBaseWidget.h"
#import "APPSPlaceholderView.h"
#import "APPSContainerView.h"

@implementation APPSBaseWidget

#pragma mark - Instantiation

+ (APPSBaseWidget *)widget {
	logDebug(@"");
    
    // Instantiate the widget here (as contrasted with retrieving from the nib):
    APPSBaseWidget *widget = [[self alloc] init];
    
    // Load the view from a nib, setting the newly instantiated widget as the File's Owner:
    NSString *nibName = [[self class] description];
	[self loadNibNamed:nibName withOwner:widget];
    [widget viewDidLoad];
    
	return widget;
}


+ (APPSBaseWidget *)widgetWithinPlaceholder:(APPSPlaceholderView *)placeholderView {
    APPSBaseWidget *widget = [self widget];
    
    // Place the widget's view inside the placeholder, which will give the widget
    // intrinsic dimensions that match those of its encasing placeholder:
    placeholderView.contentView = widget.view;
    
    return widget;
}



#pragma mark - Nib Loading

+ (NSArray *)loadNibNamed:(NSString *)nibName withOwner:(id)owner  {
	NSMutableDictionary *injections = [[NSMutableDictionary alloc] init];
	
	NSDictionary *proxied = [NSDictionary dictionaryWithObject:injections forKey:UINibExternalObjects];
    NSBundle *mainBundle = [NSBundle mainBundle];
	NSArray *wired = [mainBundle loadNibNamed:nibName owner:owner options:proxied];
	
	return wired;
}



#pragma mark - View Lifecycle

/**
 This is meant to be overridden by subclasses so they can but in initialization code that depends on their view
 having been loaded from a nib.
 
 This is only meant for those widgets that don't exist inside the nib, but are instantiated in code and then load a nib
 and bind to it as File's Owner.
 */
- (void)viewDidLoad {
    // Subclasses meant to override for any initialization.
}


@end
