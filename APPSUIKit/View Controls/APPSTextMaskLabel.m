//
//  APPSTextMaskLabel.m
//
//  Created by Ken Grigsby on 10/4/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import "APPSTextMaskLabel.h"

@implementation APPSTextMaskLabel

#pragma mark - CALayer properties

- (UIColor *)borderColor
{
    CGColorRef cgColor = self.layer.borderColor;
    return cgColor ? [UIColor colorWithCGColor:cgColor] : nil;
}


- (void)setBorderColor:(UIColor *)borderColor
{
    self.layer.borderColor = borderColor.CGColor;
}


- (CGFloat)cornerRadius
{
    return self.layer.cornerRadius;
}


- (void)setCornerRadius:(CGFloat)cornerRadius
{
    self.layer.cornerRadius = cornerRadius;
}


- (CGFloat)borderWidth
{
    return self.layer.borderWidth;
}


- (void)setBorderWidth:(CGFloat)borderWidth
{
    self.layer.borderWidth = borderWidth;
}


- (BOOL)masksToBounds
{
    return self.layer.masksToBounds;
}


- (void)setMasksToBounds:(BOOL)masksToBounds
{
    self.layer.masksToBounds = masksToBounds;
}



#pragma mark - Edge Insets

- (void)setTopEdgeInset:(CGFloat)topEdgeInset
{
    UIEdgeInsets insets = self.edgeInsets;
    insets.top = topEdgeInset;
    self.edgeInsets = insets;
}


- (CGFloat)topEdgeInset
{
    return self.edgeInsets.top;
}


- (void)setBottomEdgeInset:(CGFloat)bottomEdgeInset
{
    UIEdgeInsets insets = self.edgeInsets;
    insets.bottom = bottomEdgeInset;
    self.edgeInsets = insets;
}


- (CGFloat)bottomEdgeInset
{
    return self.edgeInsets.bottom;
}


- (void)setLeftEdgeInset:(CGFloat)leftEdgeInset
{
    UIEdgeInsets insets = self.edgeInsets;
    insets.left = leftEdgeInset;
    self.edgeInsets = insets;
}


- (CGFloat)leftEdgeInset
{
    return self.edgeInsets.left;
}


- (void)setRightEdgeInset:(CGFloat)rightEdgeInset
{
    UIEdgeInsets insets = self.edgeInsets;
    insets.right = rightEdgeInset;
    self.edgeInsets = insets;
}


- (CGFloat)rightEdgeInset
{
    return self.edgeInsets.right;
}


- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets
{
    _edgeInsets = edgeInsets;
    [self setNeedsLayout];
}

#pragma mark - Drawing with text mask

- (void)drawRect:(CGRect)rect
{
    if (self.isHighlighted && self.masksToTextWhenHighlighting) {
        
        // Mask out the text from the fill so the superview is
        // visible through the text.
        self.maskView = [self textMaskView];
        
        [self drawFillColorRect:rect];
    }
    else {
        self.maskView = nil;
        [self drawFillColorRect:rect];
        [super drawRect:rect];
    }
}


/**
 Create a mask of the text
 */
- (UIImageView *)textMaskView
{
    CGRect rect = self.bounds;
    UIImageView *maskView = nil;
    
    // This creates a bitmap which has 8 bits/component which is the max
    // that CGImageMaskCreate will accept. Using CGBitmapContextCreateImage,
    // as many other implementations (i.e. https://github.com/robinsenior/RSMaskedLabel ),
    // creates a bitmap of 16 bits/component on the iPhone 7/7+ and will cause
    // CGImageMaskCreate to throw an exception.
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    
    // let the superclass draw the label normally
    [super drawRect:rect];
    
    UIImage *uiImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if (uiImage) {
        CGImageRef cgImage = uiImage.CGImage;
        if (cgImage) {
            CGImageRef mask = CGImageMaskCreate(CGImageGetWidth(cgImage),
                                                CGImageGetHeight(cgImage),
                                                CGImageGetBitsPerComponent(cgImage),
                                                CGImageGetBitsPerPixel(cgImage),
                                                CGImageGetBytesPerRow(cgImage),
                                                CGImageGetDataProvider(cgImage),
                                                CGImageGetDecode(cgImage),
                                                CGImageGetShouldInterpolate(cgImage));
            if (mask) {
                UIImage *maskImage = [UIImage imageWithCGImage:mask scale:uiImage.scale orientation:uiImage.imageOrientation];
                CFRelease(mask);
                if (maskImage) {
                    maskView = [[UIImageView alloc] initWithImage:maskImage];
                }
            }
        }
    }
    
    return maskView;
}


- (void)drawFillColorRect:(CGRect)rect
{
    if (self.fillColor) {
        [self.fillColor set];
        UIRectFill(rect);
    }
}



#pragma mark - Drawing with insets

/**
 *  Resizing a UILabel to accomadate insets
 *  http://stackoverflow.com/questions/21167226/resizing-a-uilabel-to-accomodate-insets
 */
- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines
{
    UIEdgeInsets insets = self.edgeInsets;
    CGRect rect = [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, insets)
                    limitedToNumberOfLines:numberOfLines];
    if (!CGRectIsEmpty(rect)) {
        rect.origin.x    -= insets.left;
        rect.origin.y    -= insets.top;
        rect.size.width  += (insets.left + insets.right);
        rect.size.height += (insets.top + insets.bottom);
    }
    
    return rect;
}


- (void)drawTextInRect:(CGRect)rect
{
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, self.edgeInsets)];
}

@end
