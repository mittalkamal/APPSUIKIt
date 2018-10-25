//
//  UIView+Appstronomy.h
//
//  Created by Sohail Ahmed on 6/25/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import UIKit;

#import "APPSUIKitTypeDefs.h"

@interface UIView (Appstronomy)

#pragma mark - Inquiries

/**
 Convenience method which looks at the contentScaleFactor to determine if
 the device is a retina or non/retina device.
 
 @return YES if the device is retina, no otherwise.
 */
- (BOOL)apps_isRetina;


/**
 Returns the thickness in points of a single pixel line. Useful
 for drawing separator lines.
 
 @return The thickness in points of a single pixel line.
 */
+ (CGFloat)apps_hairlineThickness;


/**
 Advises what the common superview is between us and the other view passed in.
 Adapted from: http://stackoverflow.com/a/26405165/535054
 
 @param otherView The other UIView subclass whom we wish to find our common ancestor for.
 
 @return The common ancestor. Returns nil if we have no common superview.
 */
- (UIView *)apps_commonSuperviewWithView:(UIView *)otherView;



#pragma mark - Auto-Layout: Constraints

#pragma mark Centering

- (NSArray *)apps_addConstraintsToCenterWithSuperview;

- (NSArray *)apps_addConstraintsToCenterWithView:(UIView *)otherView;

- (NSArray *)apps_addConstraintsToCenterWithView:(UIView *)otherView
                                         xOffset:(CGFloat)xOffset
                                         yOffset:(CGFloat)yOffset;


#pragma mark Sizing

- (NSArray *)apps_addConstraintsToSizeEqualWithSuperview;

- (NSArray *)apps_addConstraintsToSizeEqualWithView:(UIView *)otherView;

- (NSArray *)apps_addConstraintsToSizeWithWidth:(CGFloat)width andHeight:(CGFloat)height;



#pragma mark - Frame Adjustments: Origin

/**
 Convenience to update our frame origin without having to create a new CGRect and set it.

 @param frameOrigin The new frame origin to set on this view.
 @return The new frame created and applied, for reference.
 */
- (CGRect)apps_setFrameOrigin:(CGPoint)frameOrigin;


/**
 Sets this view's frame origin x-value, leaving everything else about our frame as is.

 @param originX The new x-coordinate of our frame's origin.
 @return The new frame created and applied, for reference.
 */
- (CGRect)apps_setFrameOriginX:(CGFloat)originX;


/**
 Sets this view's origin y-value, leaving everything else about our frame as is.

 @param originY The new y-coordinate of our frame's origin.
 @return The new frame created and applied, for reference.
 */
- (CGRect)apps_setFrameOriginY:(CGFloat)originY;


/**
 Adjust this view's frame origin in the x-coordinate plane, by the specified offset.
 Everything else about our frame is left as it was.

 @param xOffset The amount to move our frame origin in the x-coordinate plane.
    Positive values move it to the right, while negative values to the left.
 @return The new frame created and applied, for reference.
*/
- (CGRect)apps_adjustFrameOriginXBy:(CGFloat)xOffset;


/**
 Adjust this view's frame origin in the y-coordinate plane, by the specified offset.
 Everything else about our frame is left as it was.

 @param yOffset The amount to move our frame origin in the y-coordinate plane.
 Positive values move it down, while negative values move the view up.
 @return The new frame created and applied, for reference.
*/
- (CGRect)apps_adjustFrameOriginYBy:(CGFloat)yOffset;



#pragma mark - Frame Adjustments: Size

/**
 Convenience to update our view's size without having to create a new CGRect and set it.
 We update the size struct on our view's frame to effect the change.

 @param frameSize The new size to update our view with.
 @return The new frame created and applied, for reference.
 */
- (CGRect)apps_setSize:(CGSize)frameSize;


/**
 Convenience to update our view's width without having to create a new CGRect and set it.
 We update the size struct on our view's frame to effect the change.
 
 @param width The new width to update our view with.
 @return The new frame created and applied, for reference.
 */
- (CGRect)apps_setWidth:(CGFloat)width;


/**
 Convenience to update our view's height without having to create a new CGRect and set it.
 We update the size struct on our view's frame to effect the change.
 
 @param height The new height to update our view with.
 @return The new frame created and applied, for reference.
 */
- (CGRect)apps_setHeight:(CGFloat)height;


/**
 Convenience to update our view's width without having to create a new CGRect and set it.
 The new width set is based on an adjustment of our current width.
 We update the size struct on our view's frame to effect the change.
 
 @param adjustmentPoints The increase (positive values) or decrease (negative values)
    that we should apply to our current width.
 @return The new frame created and applied, for reference.
 */
- (CGRect)apps_adjustWidthBy:(CGFloat)adjustmentPoints;


/**
 Convenience to update our view's height without having to create a new CGRect and set it.
 The new height set is based on an adjustment of our current height.
 We update the size struct on our view's frame to effect the change.
 
 @param adjustmentPoints The increase (positive values) or decrease (negative values)
 that we should apply to our current height.
 @return The new frame created and applied, for reference.
 */
- (CGRect)apps_adjustHeightBy:(CGFloat)adjustmentPoints;


/**
 Sets the center of the view to the given X coordinate, leaving all else as is.
 The change is applied by creating a new center point for our view
 
 @param centerX The new x-coordinate to be applied to our view's center point.
 @return The new center point created to reflect the requested change.
 */
- (CGPoint)apps_setCenterX:(CGFloat)centerX;


/**
 Sets the center of the view to the given Y coordinate, leaving all else as is.
 The change is applied by creating a new center point for our view
 
 @param centerY The new y-coordinate to be applied to our view's center point.
 @return The new center point created to reflect the requested change.
 */
- (CGPoint)apps_setCenterY:(CGFloat)centerY;

#pragma mark - Special Effects

/**
 Rounds the provided bitmasked corners of this view, with the specified radius.
 CREDIT: Adapted from: http://stackoverflow.com/a/12350410/535054
 
 @param rectCorners The bitmask OR of corners to be rounded.
 @param radius The radius in points that will be used for the rounding effect.
 */
- (void)apps_roundCorners:(UIRectCorner)rectCorners radius:(CGFloat)radius;


- (void)apps_strokeMaskPathWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;


/**
 Adds a border of the specified thickness to the specified edges of this UIView.
 
 @example 
 
 [self.view addBordersToEdge:(UIRectEdgeLeft|UIRectEdgeRight)
     withColor:[UIColor grayColor]
     andWidth:1.0];
 
 You can even use this with the @c -apps_hairlineThickness method of this category as your width.
 
 @param edge        The UIRectEdge ORing of all the edges that you want.
 @param color       The color to apply to all edges you've asked to be drawn.
 @param borderWidth The width (line thickness) to use.
 */
- (void)apps_addBordersToEdge:(UIRectEdge)edge withColor:(UIColor *)color andWidth:(CGFloat)borderWidth;


#pragma mark - Screenshot Image

/**
 This returns a UIImageView that is a screenshot of this view in it's current state.
 NOTE: You must only call this on the main thread, otherwise, it will return nil.
 
 CREDIT: Nick Harris. See post: http://nickharris.wordpress.com/2012/02/05/ios-slide-out-navigation-code/
 */
- (UIImageView *)apps_screenshotImageView;


/**
 Takes a screenshot of a UIView at a specific point and size, as denoted by
 the provided croppingRect parameter. Returns a UIImageView of this cropped
 region.
 
 CREDIT: This is based on @escrafford's answer at http://stackoverflow.com/a/15304222/535054
 */
- (UIImageView *)apps_screenshotImageViewWithCroppingRect:(CGRect)croppingRect;


- (UIImage *)apps_screenshot;



#pragma mark - Recursive Traversal

/**
 Runs the provided block on each view (including us) as we exhaustively make our way through
 the tree of descendant views.
 
 @param block The block operation to be executed for each view traversed.
 */
- (void)apps_runBlockOnAllSubviews:(APPSSubviewBlock)block;


/**
 Runs the provided block on each view (including us) as we exhaustively make our way through
 the singular path of ancestral views.
 
 @param block The block operation to be executed for each view traversed.
 */
- (void)apps_runBlockOnAllSuperviews:(APPSSuperviewBlock)block;






@end
