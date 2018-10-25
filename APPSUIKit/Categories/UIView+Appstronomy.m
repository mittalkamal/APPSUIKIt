//
//  UIView+Appstronomy.m
//
//  Created by Sohail Ahmed on 6/25/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "UIView+Appstronomy.h"


@implementation UIView (Appstronomy)

#pragma mark - Inquiries

- (BOOL)apps_isRetina;
{
    return self.contentScaleFactor > 1.0;
}


+ (CGFloat)apps_hairlineThickness
{
    static CGFloat hairlineThickness;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Protect against dividing by 0.
        // NativeScale returns 0 when used in an IB_DESIGNABLE view, scale does not.
        CGFloat scale = ([UIScreen mainScreen].nativeScale > 0) ? [UIScreen mainScreen].nativeScale : [UIScreen mainScreen].scale;
        hairlineThickness = 1.0 / scale;
    });
    
    return hairlineThickness;
}


- (UIView *)apps_commonSuperviewWithView:(UIView *)otherView
{
    NSMutableSet *views = [NSMutableSet set];
    UIView *view = self;
    
    do {
        if (view != nil) {
            if ([views member:view]) {
                return view;
            }
            
            [views addObject:view];
            view = view.superview;
        }
        
        if (otherView != nil) {
            if ([views member:otherView]) {
                return otherView;
            }
            
            [views addObject:otherView];
            otherView = otherView.superview;
        }
    } while (view || otherView);
    
    return nil; // We must not have found a common ancestor
}



#pragma mark - Auto-Layout: Constraints

- (NSArray *)apps_addConstraintsToCenterWithSuperview;
{
    return [self apps_addConstraintsToCenterWithView:self.superview];
}


- (NSArray *)apps_addConstraintsToCenterWithView:(UIView *)otherView;
{
    return [self apps_addConstraintsToCenterWithView:otherView xOffset:0 yOffset:0];
}


- (NSArray *)apps_addConstraintsToCenterWithView:(UIView *)otherView
                                         xOffset:(CGFloat)xOffset
                                         yOffset:(CGFloat)yOffset;
{
    NSLayoutConstraint *centreXConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterX
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:otherView
                                                                         attribute:NSLayoutAttributeCenterX
                                                                        multiplier:1
                                                                          constant:xOffset];
    
    NSLayoutConstraint *centreYConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                         attribute:NSLayoutAttributeCenterY
                                                                         relatedBy:NSLayoutRelationEqual
                                                                            toItem:otherView
                                                                         attribute:NSLayoutAttributeCenterY
                                                                        multiplier:1
                                                                          constant:yOffset];
    
    NSArray *constraints = @[centreXConstraint, centreYConstraint];
    UIView *commonSuperview = [self apps_commonSuperviewWithView:otherView];

    if (commonSuperview) {
        [commonSuperview addConstraints:constraints];
    }
    else {
        constraints = nil; // Could not be applied.
    }
    
    return constraints;
}


- (NSArray *)apps_addConstraintsToSizeEqualWithSuperview;
{
    return [self apps_addConstraintsToSizeEqualWithView:self.superview];
}


- (NSArray *)apps_addConstraintsToSizeEqualWithView:(UIView *)otherView;
{
    NSLayoutConstraint *horizontalConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:otherView
                                                                            attribute:NSLayoutAttributeWidth
                                                                           multiplier:1
                                                                             constant:0];
    
    NSLayoutConstraint *verticalConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:otherView
                                                                          attribute:NSLayoutAttributeHeight
                                                                         multiplier:1
                                                                           constant:0];
    
    NSArray *constraints = @[horizontalConstraint, verticalConstraint];
    UIView *commonSuperview = [self apps_commonSuperviewWithView:otherView];
    
    if (commonSuperview) {
        [commonSuperview addConstraints:constraints];
    }
    else {
        constraints = nil; // Could not be applied.
    }
    
    return constraints;
}


- (NSArray *)apps_addConstraintsToSizeWithWidth:(CGFloat)width andHeight:(CGFloat)height;
{
    NSLayoutConstraint *widthConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                            attribute:NSLayoutAttributeWidth
                                                                            relatedBy:NSLayoutRelationEqual
                                                                               toItem:nil
                                                                            attribute:NSLayoutAttributeNotAnAttribute
                                                                           multiplier:1
                                                                             constant:width];
    
    NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:self
                                                                          attribute:NSLayoutAttributeHeight
                                                                          relatedBy:NSLayoutRelationEqual
                                                                             toItem:nil
                                                                          attribute:NSLayoutAttributeNotAnAttribute
                                                                         multiplier:1
                                                                           constant:height];
    
    NSArray *constraints = @[widthConstraint, heightConstraint];

    [self addConstraints:constraints];
    
    return constraints;
}




#pragma mark - Frame Adjustments: Origin

- (CGRect)apps_setFrameOrigin:(CGPoint)frameOrigin {
	CGRect adjustedFrame = self.frame;
	adjustedFrame.origin = frameOrigin;
	self.frame = adjustedFrame;
	
	return self.frame;
}


- (CGRect)apps_setFrameOriginX:(CGFloat)originX {
	CGRect adjustedFrame = self.frame;
	adjustedFrame.origin = CGPointMake(originX, self.frame.origin.y);
	self.frame = adjustedFrame;
	
	return self.frame;
}


- (CGRect)apps_setFrameOriginY:(CGFloat)originY {
	CGRect adjustedFrame = self.frame;
	adjustedFrame.origin = CGPointMake(self.frame.origin.x, originY);
	self.frame = adjustedFrame;
	
	return self.frame;
}


- (CGRect)apps_adjustFrameOriginXBy:(CGFloat)xOffset {
    CGRect adjustedFrame = self.frame;
   	adjustedFrame.origin = CGPointMake(self.frame.origin.x + xOffset, self.frame.origin.y);
   	self.frame = adjustedFrame;
    
   	return self.frame;
}


- (CGRect)apps_adjustFrameOriginYBy:(CGFloat)yOffset {
    CGRect adjustedFrame = self.frame;
   	adjustedFrame.origin = CGPointMake(self.frame.origin.x, self.frame.origin.y + yOffset);
   	self.frame = adjustedFrame;
    
   	return self.frame;
}



#pragma mark - Frame Adjustments: Size

- (CGRect)apps_setSize:(CGSize)frameSize {
	CGRect adjustedFrame = self.frame;
	adjustedFrame.size = frameSize;
	self.frame = adjustedFrame;
	
	return self.frame;
}


- (CGRect)apps_setWidth:(CGFloat)width {
	CGRect adjustedFrame = self.frame;
	adjustedFrame.size = CGSizeMake(width, self.frame.size.height);
	self.frame = adjustedFrame;
	
	return self.frame;
}


- (CGRect)apps_setHeight:(CGFloat)height {
	CGRect adjustedFrame = self.frame;
	adjustedFrame.size = CGSizeMake(self.frame.size.width, height);
	self.frame = adjustedFrame;
	
	return self.frame;
}


- (CGRect)apps_adjustWidthBy:(CGFloat)adjustmentPoints {
    return [self apps_setWidth:self.frame.size.width + adjustmentPoints];
}


- (CGRect)apps_adjustHeightBy:(CGFloat)adjustmentPoints {
    return [self apps_setHeight:self.frame.size.height + adjustmentPoints];
}


- (CGPoint)apps_setCenterX:(CGFloat)centerX;
{
    CGPoint adjustedCenter = CGPointMake(centerX, self.center.y);
    self.center = adjustedCenter;
    
    return self.center;
}


- (CGPoint)apps_setCenterY:(CGFloat)centerY;
{
    CGPoint adjustedCenter = CGPointMake(self.center.x, centerY);
    self.center = adjustedCenter;
    
    return self.center;
}



#pragma mark - Special Effects

- (void)apps_roundCorners:(UIRectCorner)rectCorners radius:(CGFloat)radius
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds
                                                   byRoundingCorners:rectCorners
                                                         cornerRadii:CGSizeMake(radius, radius)];
    
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    
    [self.layer setMask:maskLayer];
}


- (void)apps_strokeMaskPathWithBorderWidth:(CGFloat)borderWidth borderColor:(UIColor *)borderColor;
{
    if (![self.layer.mask isKindOfClass:[CAShapeLayer class]]) {
        logWarn(@"Asked to apply a stroke to a mask layer, but we do not have a CAShapeLayer mask layer.");
        return; // BAIL
    }
    
    static NSString *strokeLayerName = @"APPSUIViewStrokeLayer";
    
    // CREDIT: http://stackoverflow.com/a/27922592/535054
    // Make a transparent, stroked layer which will dispay the stroke.
    CAShapeLayer *maskLayer = (CAShapeLayer *)self.layer.mask;
    
    // Find any existing stroke layer we've setup before, incase the shape has now changed and
    // we don't want to leave such remnants behind.
    NSPredicate *searchPredicate = [NSPredicate predicateWithFormat:@"name == %@", strokeLayerName];
    NSArray *matchingLayers = [[self.layer sublayers] filteredArrayUsingPredicate:searchPredicate];
    CAShapeLayer *strokeLayer;
    
    // Did we find an existing stroke layer?
    if ([matchingLayers count] > 0) {
        // YES. Use it. There should really only be one.
        strokeLayer = [matchingLayers firstObject];
    }
    else {
        // NO. No match was found, so create a new shape layer for the stroke.
        strokeLayer = [CAShapeLayer layer];
        strokeLayer.name = strokeLayerName;
        strokeLayer.fillColor = [UIColor clearColor].CGColor;
    }
    
    strokeLayer.path = maskLayer.path;
    strokeLayer.strokeColor = borderColor.CGColor;

    // the stroke splits the width evenly inside and outside,
    // but the outside part will be clipped by the containerView’s mask.
    strokeLayer.lineWidth = borderWidth * 2;
    
    [self.layer addSublayer:strokeLayer];
}


// CREDIT: http://stackoverflow.com/a/33035655/535054
- (void)apps_addBordersToEdge:(UIRectEdge)edge withColor:(UIColor *)color andWidth:(CGFloat)borderWidth;
{
    if (edge & UIRectEdgeTop) {
        UIView *border = [UIView new];
        border.backgroundColor = color;
        [border setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin];
        border.frame = CGRectMake(0, 0, self.frame.size.width, borderWidth);
        [self addSubview:border];
    }
    
    if (edge & UIRectEdgeLeft) {
        UIView *border = [UIView new];
        border.backgroundColor = color;
        border.frame = CGRectMake(0, 0, borderWidth, self.frame.size.height);
        [border setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleRightMargin];
        [self addSubview:border];
    }
    
    if (edge & UIRectEdgeBottom) {
        UIView *border = [UIView new];
        border.backgroundColor = color;
        [border setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin];
        border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, borderWidth);
        [self addSubview:border];
    }
    
    if (edge & UIRectEdgeRight) {
        UIView *border = [UIView new];
        border.backgroundColor = color;
        [border setAutoresizingMask:UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin];
        border.frame = CGRectMake(self.frame.size.width - borderWidth, 0, borderWidth, self.frame.size.height);
        [self addSubview:border];
    }
}



#pragma mark - Screenshot Image

- (UIImageView *)apps_screenshotImageView {
    APPSAssert([[NSThread currentThread] isMainThread],
            @"This screenshot utility method can only be invoked on the main thread.");
    
    // We'll take a "screenshot" of the current view
    // by rendering its CALayer into the an ImageContext then saving that off to a UIImage
    CGSize viewSize = self.bounds.size;
    UIGraphicsBeginImageContextWithOptions(viewSize, NO, 1.0);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    // Read the UIImage object
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return [[UIImageView alloc] initWithImage:snapshotImage];
}


- (UIImageView *)apps_screenshotImageViewWithCroppingRect:(CGRect)croppingRect {
    APPSAssert([[NSThread currentThread] isMainThread],
            @"This screenshot utility method can only be invoked on the main thread.");
    
    // For dealing with Retina displays as well as non-Retina, we need to check
    // the scale factor, if it is available. Note that we use the size of the cropping Rect
    // passed in, and not the size of the view we are taking a screenshot of.
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(croppingRect.size, YES, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(croppingRect.size);
    }
    
    // Create a graphics context and translate it the view we want to crop so
    // that even in grabbing (0,0), that origin point now represents the actual
    // cropping origin desired:
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(ctx, -croppingRect.origin.x, -croppingRect.origin.y);
    [self.layer renderInContext:ctx];
    
    // Retrieve a UIImage from the current image context:
    UIImage *snapshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    // Return the image in a UIImageView:
    return [[UIImageView alloc] initWithImage:snapshotImage];
}


- (UIImage *)apps_screenshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, [UIScreen mainScreen].scale);
    
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:YES];
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}



#pragma mark - Recursive Traversal

/**
 Runs the provided block on each view (including us) as we exhaustively make our way through
 the tree of descendant views.
 
 @param block The block operation to be executed for each view traversed.
 */
- (void)apps_runBlockOnAllSubviews:(APPSSubviewBlock)block;
{
    block(self); // Run on ourself before descending into our tree of children.
    
    for (UIView *view in [self subviews]) {
        [view apps_runBlockOnAllSubviews:block];
    }
}


/**
 Runs the provided block on each view (including us) as we exhaustively make our way through
 the singular path of ancestral views.
 
 @param block The block operation to be executed for each view traversed.
 */
- (void)apps_runBlockOnAllSuperviews:(APPSSuperviewBlock)block;
{
    block(self); // Run on ourself before ascending through our ancestors.
    
    if (self.superview) {
        [self.superview apps_runBlockOnAllSuperviews:block];
    }
}

@end
