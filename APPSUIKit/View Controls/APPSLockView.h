//
//  ICPDLockView.h
//  Appstronomy UIKit
//
//  Created by Tim Capes on 2014-11-11.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface APPSLockView : UIView

@property(nonatomic, assign, getter=isClosed) BOOL closed;

//method available to override default duration value for lock
- (void) closeLockWithDuration: (NSTimeInterval) duration;

//The methods below use the default duration
- (void) closeLock;
- (void) closeLockWithCompletion:(void (^)(BOOL))completionBlock;


@end
