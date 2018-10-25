//
//  APPSBaseSplitViewController.m
//
//  Created by Sohail Ahmed on 5/12/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "APPSBaseSplitViewController.h"


@interface APPSBaseSplitViewController ()
@end


@implementation APPSBaseSplitViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureConnections];
}



#pragma mark - Abstract Methods: Configuration

- (void)configureConnections {}


@end
