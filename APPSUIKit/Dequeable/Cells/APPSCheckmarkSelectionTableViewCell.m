//
//  APPSCheckmarkSelectionTableViewCell.m
//  Appstronomy UIKit
//
//  Created by Sohail Ahmed on 2014-08-29.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "APPSCheckmarkSelectionTableViewCell.h"

@implementation APPSCheckmarkSelectionTableViewCell

#pragma mark - UIView

/**
 We ensure no checkmark selection on initial display.
 */
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.checkmarkSelectionOn = NO;
    self.checkmarkImageView.hidden = YES;
}



#pragma mark - UITableViewCell

/**
 We default to no checkmark selection.
 */
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    self.checkmarkSelectionOn = NO;
    self.checkmarkImageView.hidden = YES;
}



#pragma mark - Property Overrides

- (void)setCheckmarkSelectionOn:(BOOL)checkmarkSelectionOn
{
    if (_checkmarkSelectionOn != checkmarkSelectionOn) {
        _checkmarkSelectionOn = checkmarkSelectionOn;
        
        self.checkmarkImageView.hidden = !_checkmarkSelectionOn;
    }
}





@end
