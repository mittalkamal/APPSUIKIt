//
//  APPSDesignerLabel.m
//
//  Created by Sohail Ahmed on 2/8/16.
//

@import APPSFoundation;

#import "APPSDesignerLabel.h"



@interface APPSDesignerLabel ()
@property (strong, nonatomic) APPSIBDesignableLogger *designableLogger;
@property (strong, nonatomic) NSString *originalText;
@end


@implementation APPSDesignerLabel

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        [self applyDefaults];
        [self commonInitialization];
        [self renderDesignableContent];
    }
    
    return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self applyDefaults];
        [self commonInitialization];
        [self renderDesignableContent];
    }
    
    return self;
}


- (void)layoutSubviews;
{
    [super layoutSubviews];
    
    [self renderDesignableContent];
}


- (void)commonInitialization;
{
    if (!self.originalText && self.text) {
        self.originalText = self.text;
    }
    
    if (self.originalText) {
        self.attributedText = [self configuredAttributedString];
    }
}



#pragma mark - Defaults

- (void)applyDefaults;
{
    self.shadowBlurRadius   = kAPPSDesignerLabel_DefaultShadowBlurRadius;
    self.lineHeightMultiple = kAPPSDesignerLabel_DefaultLineHeightMultiple;
    self.leading            = kAPPSDesignerLabel_DefaultLineSpacing;
}


#pragma mark - Property Overrides

- (APPSIBDesignableLogger *)designableLogger;
{
    if (!_designableLogger) {
        _designableLogger = [APPSIBDesignableLogger new];
        _designableLogger.componentName = [[self class] description];
    }
    
    return  _designableLogger;
}



#pragma mark - Custom Configuration

- (void)renderDesignableContent
{
    [self commonInitialization];
    
    //[self.designableLogger log:[self debugDescription]];
}



- (NSAttributedString *)configuredAttributedString;
{
    // Create the attributed string
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.originalText];
    
    NSUInteger rangeLength = [self.originalText length];
    
    // Declare the fonts
    UIFont *font = self.font;
    
    // Declare the colors
    UIColor *foregroundColor = self.textColor;
    
    // Declare the paragraph styles
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.alignment          = self.textAlignment;
    paragraphStyle.lineHeightMultiple = self.lineHeightMultiple;
    paragraphStyle.lineSpacing        = self.leading;
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = self.shadowColor;
    shadow.shadowBlurRadius = self.shadowBlurRadius;
    shadow.shadowOffset = self.shadowOffset;
    
    // Create the attributes and add them to the string
    [attributedString addAttribute:NSShadowAttributeName value:shadow range:NSMakeRange(0, rangeLength)];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:foregroundColor range:NSMakeRange(0, rangeLength)];
    [attributedString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, rangeLength)];
    [attributedString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, rangeLength)];
    
    return [[NSAttributedString alloc] initWithAttributedString:attributedString];
}


- (void)setText:(NSString *)text
{
    super.text = [text mutableCopy];
    self.originalText = [text mutableCopy];
}


#pragma mark - UIView

- (void)drawRect:(CGRect)rect
{
    [self renderDesignableContent];
    
    [super drawRect:rect];
}


- (CGSize)intrinsicContentSize;
{
    CGSize adjustedSize = [super intrinsicContentSize];
    
    if (self.padIntrinsicSizeForShadowBlurs) {
        adjustedSize.height += (2 * self.shadowBlurRadius);
        adjustedSize.width  += (2 * self.shadowBlurRadius);
    }
    
    return adjustedSize;
}


/**
 When we need layout, we also need to be displayed, since our reason for being is primarily for
 Interface Builder based design time rendering and layout.
 */
- (void)setNeedsLayout
{
    [super setNeedsLayout];
    
    [self setNeedsDisplay];
}


- (void)prepareForInterfaceBuilder
{
    [self renderDesignableContent];
}



#pragma mark - Debugging Support

- (NSString *)debugDescription;
{
    // Print the class name and memory address, per: http://stackoverflow.com/a/7555194/535054
    NSMutableString *message = [NSMutableString stringWithFormat:@"<%@: %p> ; data: {\n\t", [[self class] description], (__bridge void *)self];
    [message appendFormat:@"frame: %@\n\t", NSStringFromCGRect(self.frame)];
    [message appendFormat:@"text: %@\n\t", self.text];
    [message appendFormat:@"textColor: %@\n\t", self.textColor];
    [message appendFormat:@"font: %@\n\t", self.font];
    
    [message appendString:@"}\n"];
    
    return message;
}




@end
