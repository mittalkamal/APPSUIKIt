//
//  APPSLayoutConstraint.m
//
//  Created by Sohail Ahmed on 2/13/16.
//

@import APPSFoundation;

#import "APPSLayoutConstraint.h"
#import "APPSLayoutConstraintConfiguration.h"

// Screen Type
typedef NS_ENUM(NSUInteger, APPSScreenType) {
    APPSScreenType_Unspecified = 0,
    APPSScreenType_Retina3_5,
    APPSScreenType_Retina4_0,
    APPSScreenType_Retina4_7,
    APPSScreenType_Retina5_5
};



#pragma mark - Constants

static NSString * const kAPPSLayoutConstraint_ScreenTypeName_Retina3_5    = @"Retina 3.5";
static NSString * const kAPPSLayoutConstraint_ScreenTypeName_Retina4_0    = @"Retina 4.0";
static NSString * const kAPPSLayoutConstraint_ScreenTypeName_Retina4_7    = @"Retina 4.7";
static NSString * const kAPPSLayoutConstraint_ScreenTypeName_Retina5_5    = @"Retina 5.5";
static NSString * const kAPPSLayoutConstraint_ScreenTypeName_Unrecognized = @"Unrecognized";

static const CGFloat kAPPSLayoutConstraint_ScreenWidthPoints_Retina3_5    = 320;
static const CGFloat kAPPSLayoutConstraint_ScreenHeightPoints_Retina3_5   = 480;
static const CGFloat kAPPSLayoutConstraint_ScreenWidthPoints_Retina4_0    = 320;
static const CGFloat kAPPSLayoutConstraint_ScreenHeightPoints_Retina4_0   = 568;
static const CGFloat kAPPSLayoutConstraint_ScreenWidthPoints_Retina4_7    = 375;
static const CGFloat kAPPSLayoutConstraint_ScreenHeightPoints_Retina4_7   = 667;
static const CGFloat kAPPSLayoutConstraint_ScreenWidthPoints_Retina5_5    = 414;
static const CGFloat kAPPSLayoutConstraint_ScreenHeightPoints_Retina5_5   = 736;


#pragma mark - Static

static BOOL __hasSetScreenType = NO;
static APPSScreenType __screenType;
static NSString *__screenTypeName;



#pragma mark - Helper Functions

BOOL isDeviceRetina3_5() {
    return CGSizeEqualToSize([UIScreen mainScreen].bounds.size,
                             CGSizeMake(kAPPSLayoutConstraint_ScreenWidthPoints_Retina3_5,
                                        kAPPSLayoutConstraint_ScreenHeightPoints_Retina3_5));
}


BOOL isDeviceRetina4_0() {
    return CGSizeEqualToSize([UIScreen mainScreen].bounds.size,
                             CGSizeMake(kAPPSLayoutConstraint_ScreenWidthPoints_Retina4_0,
                                        kAPPSLayoutConstraint_ScreenHeightPoints_Retina4_0));
}


BOOL isDeviceRetina4_7() {
    return CGSizeEqualToSize([UIScreen mainScreen].bounds.size,
                             CGSizeMake(kAPPSLayoutConstraint_ScreenWidthPoints_Retina4_7,
                                        kAPPSLayoutConstraint_ScreenHeightPoints_Retina4_7));
}


BOOL isDeviceRetina5_5() {
    return CGSizeEqualToSize([UIScreen mainScreen].bounds.size,
                             CGSizeMake(kAPPSLayoutConstraint_ScreenWidthPoints_Retina5_5,
                                        kAPPSLayoutConstraint_ScreenHeightPoints_Retina5_5));
}



@interface APPSLayoutConstraint ()
#pragma mark scalar
@property (assign, nonatomic) CGFloat retina3_5ConstantValue; // Do not invoke unless you know there's a numeric value present
@property (assign, nonatomic) CGFloat retina4_0ConstantValue; // Do not invoke unless you know there's a numeric value present
@property (assign, nonatomic) CGFloat retina4_7ConstantValue; // Do not invoke unless you know there's a numeric value present
@property (assign, nonatomic) CGFloat retina5_5ConstantValue; // Do not invoke unless you know there's a numeric value present

#pragma mark strong
@property (strong, nonatomic) APPSIBDesignableLogger *designableLogger;
@end



@implementation APPSLayoutConstraint

#pragma mark - UIView

- (void)prepareForInterfaceBuilder
{
    [self renderDesignableContent];
}



#pragma mark - NSLayoutConstraint

- (CGFloat)constant;
{
    return [self screenSpecificConstant];
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


- (CGFloat)retina3_5ConstantValue;
{
    APPSAssert(self.hasNumericConstantValueForRetina3_5,
               @"Expected 'retina3_5Constant' property to hold a numeric value. "
               "Instead, it contained '%@'.", self.retina3_5Constant);
    
    return [self floatValueFrom:self.retina3_5Constant];
}


- (CGFloat)retina4_0ConstantValue;
{
    APPSAssert(self.hasNumericConstantValueForRetina4_0,
               @"Expected 'retina4_0Constant' property to hold a numeric value. "
               "Instead, it contained '%@'.", self.retina4_0Constant);
    
    return [self floatValueFrom:self.retina4_0Constant];
}


- (CGFloat)retina4_7ConstantValue;
{
    APPSAssert(self.hasNumericConstantValueForRetina4_7,
               @"Expected 'retina4_7Constant' property to hold a numeric value. "
               "Instead, it contained '%@'.", self.retina4_7Constant);
    
    return [self floatValueFrom:self.retina4_7Constant];
}


- (CGFloat)retina5_5ConstantValue;
{
    APPSAssert(self.hasNumericConstantValueForRetina5_5,
               @"Expected 'retina5_5Constant' property to hold a numeric value. "
               "Instead, it contained '%@'.", self.retina5_5Constant);
    
    return [self floatValueFrom:self.retina5_5Constant];
}



#pragma mark - Inquiries

+ (APPSScreenType)screenType;
{
    if (!__hasSetScreenType) {
        __screenType = [self determineScreenType];
        __hasSetScreenType = YES;
    }
    
    return __screenType;
}


+ (APPSScreenType)determineScreenType;
{
    if (isDeviceRetina3_5()) {
        __screenTypeName = kAPPSLayoutConstraint_ScreenTypeName_Retina3_5;
        return APPSScreenType_Retina3_5;
    }
    else if (isDeviceRetina4_0()) {
        __screenTypeName = kAPPSLayoutConstraint_ScreenTypeName_Retina4_0;
        return APPSScreenType_Retina4_0;
    }
    else if (isDeviceRetina4_7()) {
        __screenTypeName = kAPPSLayoutConstraint_ScreenTypeName_Retina4_7;
        return APPSScreenType_Retina4_7;
    }
    else if (isDeviceRetina5_5()) {
        __screenTypeName = kAPPSLayoutConstraint_ScreenTypeName_Retina5_5;
        return APPSScreenType_Retina5_5;
    }
    else {
        __screenTypeName = kAPPSLayoutConstraint_ScreenTypeName_Unrecognized;
        return APPSScreenType_Unspecified;
    }
}


- (BOOL)hasNumericConstantValueForRetina3_5;
{
    return [self hasNumericValue:self.retina3_5Constant];
}


- (BOOL)hasNumericConstantValueForRetina4_0;
{
    return [self hasNumericValue:self.retina4_0Constant];
}


- (BOOL)hasNumericConstantValueForRetina4_7;
{
    return [self hasNumericValue:self.retina4_7Constant];
}


- (BOOL)hasNumericConstantValueForRetina5_5;
{
    return [self hasNumericValue:self.retina5_5Constant];
}


- (BOOL)hasNumericValue:(id)propertyObject;
{
    if (!propertyObject) {
        return NO;
    }
    else if ([propertyObject isKindOfClass:[NSNumber class]]) {
        return YES;
    }
    else {
        return [propertyObject apps_isNumeric];
    }
}


- (CGFloat)floatValueFrom:(id)propertyObject;
{
    APPSAssert(propertyObject, @"No 'propertyObject' parameter was provided.");
    
    return [propertyObject floatValue];
}



- (CGFloat)screenSpecificConstant;
{
    [self applyConfigurationFileEntry];
    
    // Purposely default to the 'constant' inherited from NSLayoutConstraint itself.
    CGFloat customizedConstant = super.constant;
    
    switch ([APPSLayoutConstraint screenType]) {
        case APPSScreenType_Unspecified: {
            // Default to the normal design time stock 'constant' when the type isn't known.
            customizedConstant = super.constant;
            break;
        }
        case APPSScreenType_Retina3_5: {
            if (self.hasNumericConstantValueForRetina3_5) {
                customizedConstant = self.retina3_5ConstantValue;
                break;
            }
            else if (self.explicitMatchOnly) {
                break;
            }
            // Purposely fall through to next closest case.
        }
        case APPSScreenType_Retina4_0: {
            if (self.hasNumericConstantValueForRetina4_0) {
                customizedConstant = self.retina4_0ConstantValue;
                break;
            }
            else if (self.explicitMatchOnly) {
                break;
            }
            // Purposely fall through to next closest case.
        }
        case APPSScreenType_Retina4_7: {
            if (self.hasNumericConstantValueForRetina4_7) {
                customizedConstant = self.retina4_7ConstantValue;
                break;
            }
            else if (self.explicitMatchOnly) {
                break;
            }
            // Purposely fall through to next closest case.
        }
        case APPSScreenType_Retina5_5: {
            if (self.hasNumericConstantValueForRetina5_5) {
                customizedConstant = self.retina5_5ConstantValue;
                break;
            }
            else if (self.explicitMatchOnly) {
                break;
            }
        }
        default: {
            // Default to the normal design time stock 'constant' when an explicit
            // constant for the current screen size (or larger) was not provided.
            // Since this was done above before this switch statement, we don't need to do anything here.
            break;
        }
    }
    
    NSString *identifierSnippet = (self.identifier ? [NSString stringWithFormat:@"'%@' ", self.identifier] : @"");
    logInfo(@"%@%@: Using constraint constant of %0.1f", identifierSnippet, __screenTypeName, customizedConstant);

    return customizedConstant;
}



#pragma mark - Helpers

/**
 If relevant, we'll retrieve an entry from a configuration file, to supersede the values
 we had set in Interface Builder.
 */
- (void)applyConfigurationFileEntry;
{
    // Do we have every type of identifier set to warrant asking the
    // APPSLayoutConstraintConfiguration to lookup an entry for us?
    if (self.jsonIdentifer && self.sceneIdentifer && self.identifier) {
        NSDictionary *entry = [APPSLayoutConstraintConfiguration entryForJSONIdentifier:self.jsonIdentifer
                                                                                  scene:self.sceneIdentifer
                                                                             constraint:self.identifier];
        if (entry) {
            [self applyEntry:entry];
        }
        else {
            logWarn(@"Could not find a JSON configuration entry for "
                    "{jsonIdentifier = '%@', sceneIdentifier = '%@', identifier = '%@'}.",
                    self.jsonIdentifer, self.sceneIdentifer, self.identifier);
        }
    }
}


- (void)applyEntry:(NSDictionary *)entry;
{
    logInfo(@"'%@': Applying constraint entry: %@", self.identifier, entry);
    
    self.retina3_5Constant = entry[kAPPSLayoutConstraint_ScreenTypeName_Retina3_5];
    self.retina4_0Constant = entry[kAPPSLayoutConstraint_ScreenTypeName_Retina4_0];
    self.retina4_7Constant = entry[kAPPSLayoutConstraint_ScreenTypeName_Retina4_7];
    self.retina5_5Constant = entry[kAPPSLayoutConstraint_ScreenTypeName_Retina5_5];
}



#pragma mark - IBDesignable

/**
 Note: Since we're not a UIView subclass, this method never gets called, because
 @c -prepareForInterfaceBuilder never gets called either.
 */
- (void)renderDesignableContent;
{
    [self.designableLogger log:@"In -renderDesignableContent for APPSLayoutConstraint!"];
}



@end
