//
//  APPSLayoutConstraintConfiguration.h
//  MRSA
//
//  Created by Sohail Ahmed on 2/13/16.
//  Copyright © 2016 Wayne State University, Pharmacy & Medicine. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 Maintains a cache of JSON file contents representing custom constraint values
 based on screen type. We manage the retrieval of custom constraint contant values
 based on the hierarchy of:
 
 1. JSON Identifier
 2. Scene Identifier
 3. Constraint Identifier
 
 When queried, we'll return the full dictionary of all screen type values, for a given
 constraint. Our companion class, @c APPSLayoutConstraint is responsible for mapping this
 information onto itself.
 
 When looking up JSON files, we use the following file nameing convention:
 
 Configuration.Constraints.<jsonIdentifier>.json
 */
@interface APPSLayoutConstraintConfiguration : NSObject

#pragma mark - Singleton

+ (instancetype)sharedInstance;


#pragma mark - Inquiries

+ (NSDictionary *)entryForJSONIdentifier:(NSString *)jsonIdentifier
                                   scene:(NSString *)sceneIdentifier
                              constraint:(NSString *)constraintIdentifier;



@end
