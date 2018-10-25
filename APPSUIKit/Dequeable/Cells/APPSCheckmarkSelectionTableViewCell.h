//
//  APPSCheckmarkSelectionTableViewCell.h
//  Appstronomy UIKit
//
//  Created by Sohail Ahmed on 2014-08-29.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "APPSBaseTableViewCell.h"

@interface APPSCheckmarkSelectionTableViewCell : APPSBaseTableViewCell

#pragma mark scalar
@property (assign, nonatomic) BOOL checkmarkSelectionOn;

#pragma mark IBOutlet: weak
@property (weak, nonatomic) IBOutlet UIImageView *checkmarkImageView;

@end
