//
//  APPSSimplePresentationController.h
//
//  Created by Sohail Ahmed on 8/15/15.
//

#import <UIKit/UIKit.h>

/**
 A presentation controller that will dim the background so that the incoming (presented)
 view controller (assuming it is not full screen, but has transparency) will reveal
 the presenting view controller underneath, through the dimming screen.
 
 TODO: Remove ICPDDimmingPresentationController once all existing references point to us.
 TODO: Rename this to the the APPSSimplePresentationController. The dimming is now an optional feature.
 */
@interface APPSSimplePresentationController : UIPresentationController

/**
 This defaults to YES. Set it to NO if you just want to use this presentation controller for its ability
 to leave the presenting view controller on screen when the presented view controller appears.
 */
@property (assign, nonatomic) BOOL enableDimming;

@end
