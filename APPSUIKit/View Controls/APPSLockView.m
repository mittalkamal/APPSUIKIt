//
//  ICPDLockView.m
//  Appstronomy UIKit
//
//  Created by Tim Capes on 2014-11-11.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "APPSLockView.h"

const CGFloat APPSLockView_AnimationHeight = 14.0;
const NSTimeInterval APPSLockView_DefaultAnimationDuration = 0.5;

@interface APPSLockView()

@property(weak,nonatomic) IBOutlet  UIImageView *lockBody;
@property(weak,nonatomic) IBOutlet  UIImageView *lockHead;

@end

@implementation APPSLockView



#pragma - External Methods

- (void) closeLockWithDuration: (NSTimeInterval) duration
{
    [self closeLockWithDuration:duration andCompletion:nil];
}

- (void) closeLock
{
    [self closeLockWithDuration:APPSLockView_DefaultAnimationDuration];
}

- (void) closeLockWithCompletion:(void (^)(BOOL))completionBlock
{
    [self closeLockWithDuration: APPSLockView_DefaultAnimationDuration andCompletion: completionBlock];
}

- (void) closeLockWithDuration: (NSTimeInterval) duration andCompletion:(void (^)(BOOL))completionBlock
{
    self.closed = YES;
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView animateWithDuration:APPSLockView_DefaultAnimationDuration delay:0.0
                    options:UIViewAnimationOptionCurveEaseOut animations:^{
                        self.lockHead.frame = CGRectMake(self.lockHead.frame.origin.x, self.lockHead.frame.origin.y+APPSLockView_AnimationHeight,self.lockHead.frame.size.height, self.lockHead.frame.size.width);
                    } completion:completionBlock];
}


@end
