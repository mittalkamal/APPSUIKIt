//
//  APPSDesignerLabel.h
//
//  Created by Sohail Ahmed on 2/8/16.
//

#import <UIKit/UIKit.h>

#pragma mark - Constants

static const CGFloat kAPPSDesignerLabel_DefaultShadowBlurRadius   = 2.0;
static const CGFloat kAPPSDesignerLabel_DefaultLineHeightMultiple = 0.8;
static const CGFloat kAPPSDesignerLabel_DefaultLineSpacing        = 0.8;


/**
 We are configured internally with an attributed string, whose properties you can set in Interface Builder.
 
 This class was built to get around the limitations of rich text configuration exposed
 in Interface Builder. For example, until now, there was no way to configure the blur radius
 of a shadow.
 
 The constants given above are what get applied if you don't make any changes in code
 or in the Interface Builder Inspector.
 */
IB_DESIGNABLE
@interface APPSDesignerLabel : UILabel

// scalar
@property (assign, nonatomic) IBInspectable CGFloat     shadowBlurRadius;
@property (assign, nonatomic) IBInspectable CGFloat     lineHeightMultiple;
@property (assign, nonatomic) IBInspectable CGFloat     leading;
@property (assign, nonatomic) IBInspectable BOOL        padIntrinsicSizeForShadowBlurs;

@end
