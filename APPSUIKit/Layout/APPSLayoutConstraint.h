//
//  APPSLayoutConstraint.h
//
//  Created by Sohail Ahmed on 2/13/16.
//

#import <UIKit/UIKit.h>

/**
 This subclass of @c NSLayoutConstraint exists so that multiple values of 'constant' can
 be provided at design time, with the correct one chosen at runtime.
 
 The need for this is simple: several iPhone device screen sizes exist that all share
 the same @2x retina scale factor and size classes. Those two levers are insufficent
 to discribe the varying values of 'constant' needed in some more robust scene layouts.
 
 Currently supported screen sizes:
 
 1. Retina 3.5 (iPhone 4s)
 2. Retina 4.0 (iPhone 5, 5s)
 3. Retina 4.7 (iPhone 6, 6s)
 4. Retina 5.5 (iPhone 6 Plus, 6s Plus)
 
 This class will let you specify different constant values for different Retina screen
 sizes based on:
 
 1. Properties set in Interface Builder (inspectable properties)
 2. Properties set in a JSON configuration file, keyed by {storyboard name, scene identifier, constraint identifer}.
 
 You should always set the @c NSLayoutConstraint property @c constant, as you would a regular
 constraint. We use that as the fallback value if no custom constraint values are provided, or if
 none of the custom constraint values that are supplied, apply.
 
 All of the screen specific constant values you provide are optional. That is, you could
 provide a custom constant for Retina 4.0, but none of the others. In such a case, if the device
 happens to be a smaller screen (i.e. Retina 3.5 in this case), it will fall through and use
 the Retina 4.0 value since an explicit Retina 3.5 value was not specified.
 
 You can disable this fallthrough between custom constant values, by setting the property
 @c explicitMatchOnly to YES.
 
 === JSON Configuration ===
 
 If you do use the JSON file approach, be sure to include the JSON file as a resource in your main app bundle.
 Also, provide a value for ALL of the properties: @c jsonIdentifier, @c sceneIdentifier, @c identifier.
 
 The JSON file we look for will use the naming convention: Configuration.Constraints.<jsonIdentifier>.json.
 
 Once you provide all of the identifiers specified above, we ignore the values in Interface Builder, 
 @em unless a corresponding entry could not be found. In such as case, we log a warning and use the 
 Interface Builder values, if any.
 
 We lean on the companion class, @c APPSLayoutConstraintConfiguration to manage reading from JSON files.
 
 === Xcode Live Rendering ===
 
 Although we are marked as being 'IB Designable' with 'IB Inspectable' properties, we don't get
 the benefit of @em live previews, unfortunately. This is because we are a subclass of @c NSLayoutConstraint,
 which is not a subclass of @c UIView, but of @c NSObject.
 
 However, at runtime you will of course, see your custom constant values in action.
 */
IB_DESIGNABLE
@interface APPSLayoutConstraint : NSLayoutConstraint

#pragma mark scalar

@property (assign, nonatomic, readonly) BOOL hasNumericConstantValueForRetina3_5;
@property (assign, nonatomic, readonly) BOOL hasNumericConstantValueForRetina4_0;
@property (assign, nonatomic, readonly) BOOL hasNumericConstantValueForRetina4_7;
@property (assign, nonatomic, readonly) BOOL hasNumericConstantValueForRetina5_5;

/**
 Defaults to NO. Set to YES if you don't want the fallthrough behavior between
 the custom screen types (sizes) when there's no exact custom constant for the currently
 running screen type. Note that regardless of this setting, we always fallthrough 
 to the @c NSLayoutConstraint property @c constant, if an exact match is not found.
 */
@property (assign, nonatomic) IBInspectable BOOL explicitMatchOnly;


#pragma mark copy

@property (copy, nonatomic) IBInspectable NSString *retina3_5Constant;
@property (copy, nonatomic) IBInspectable NSString *retina4_0Constant;
@property (copy, nonatomic) IBInspectable NSString *retina4_7Constant;
@property (copy, nonatomic) IBInspectable NSString *retina5_5Constant;

/**
 Optional. Represents the name of the JSON file (i.e. without the .json extension)
 from which we should read screen specific constants.
 
 If not provided, we do NOT use JSON based file lookup, and we strictly
 base our lookups from the custom content values provided in Interface Builder.
 */
@property (copy, nonatomic) IBInspectable NSString *jsonIdentifer;

/**
 Optional. Only meaningful if you provide a value for @c jsonIdentifier.
 Represents a subsection of the JSON file which contains information about
 those constraints that belong to our scene. That of course, includes this
 constraint. Use this to help organize constraint entries into their scenes.
 */
@property (copy, nonatomic) IBInspectable NSString *sceneIdentifer;

@end
