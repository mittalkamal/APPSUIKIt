//
//  APPSTextMaskLabel.h
//  Appstronomy
//
//  Created by Ken Grigsby on 10/4/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

/*
 This UILabel provides these functions.
 
  1. A "background" color that isn't removed during highlighting when placed in a tableViewCell.
  2. A mask created from the text so that the background is visible through the text when highlighting
  3. insets to provide spacing around the text
  4. IB designable and inspect able properties for the fillColor, borderColor, cornerRadius, borderWidth, insets.
 
 When using a UILabel as a subview of UITableViewCell the background color is changed to clear during highlighting.
 This information comes from WWDC 2009 Session 101 - Perfecting Your iPhone Table Views
 To work around use this classes fillColor instead of backgroundColor.

 */


#import <UIKit/UIKit.h>


IB_DESIGNABLE
@interface APPSTextMaskLabel : UILabel

/**
 *  Use this property to provide a "background" color that remains during highlighting
 */
@property (strong, nonatomic) IBInspectable UIColor *fillColor;

/**
 *  This property are just passthrough to CALayer. By adding the IBInspectable
 *  attribute they can be set in IB.
 */
@property (strong, nonatomic) IBInspectable UIColor *borderColor;
@property (nonatomic) IBInspectable CGFloat borderWidth;
@property (nonatomic) IBInspectable CGFloat cornerRadius;
@property (nonatomic) IBInspectable BOOL masksToBounds;

/**
 *  Allows a see-through effect when highlighting
 */
@property (nonatomic) IBInspectable BOOL masksToTextWhenHighlighting;

/**
 *  Set edgeInsets to provide a drawing margin around the text
 */
@property (nonatomic) UIEdgeInsets edgeInsets; // IB doesn't support inspectable UIEdgeInsets
@property (nonatomic) IBInspectable CGFloat topEdgeInset;
@property (nonatomic) IBInspectable CGFloat bottomEdgeInset;
@property (nonatomic) IBInspectable CGFloat leftEdgeInset;
@property (nonatomic) IBInspectable CGFloat rightEdgeInset;


@end

