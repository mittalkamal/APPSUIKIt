//
//  APPSViewControllerInfoStackEntry.h
//  Appstronomy UIKit
//
//  Created by Sohail Ahmed on 5/11/13.
//  Copyright (c) 2013 Appstronomy. All rights reserved.
//

#import "APPSContainerViewController.h"

@interface APPSViewControllerInfoStackEntry : NSObject

#pragma mark scalar

@property (assign, nonatomic) APPSContainerControllerTransitionType appearingTransitionType;
@property (assign, nonatomic) APPSContainerControllerTransitionDirection appearingTransitionDirection;
@property (assign, nonatomic, getter=wasModallyCovered) BOOL modallyCovered;


#pragma mark weak

@property (weak, nonatomic) NSString *taggedName;


#pragma mark strong

@property (strong, nonatomic) UIViewController *controller; // The container retains controllers added to it.

@end
