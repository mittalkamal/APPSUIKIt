//
//  APPSLayoutConstraintConfiguration.m
//  MRSA
//
//  Created by Sohail Ahmed on 2/13/16.
//  Copyright © 2016 Wayne State University, Pharmacy & Medicine. All rights reserved.
//

@import APPSFoundation;

#import "APPSLayoutConstraintConfiguration.h"
#import "APPSLayoutConstraint.h"


#pragma mark - Constants

static NSString * const kAPPS_FileBasenameFormatString = @"Configuration.Constraints.%@";




@interface APPSLayoutConstraintConfiguration ()
@property (strong, nonatomic) NSCache *fileContentsCache;
@end


@implementation APPSLayoutConstraintConfiguration

// static
static APPSLayoutConstraintConfiguration *__sharedInstance = nil;


#pragma mark - Singleton

+ (instancetype)sharedInstance
{
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        // Instantiation; we use [self class] so we can be subclassed:
        __sharedInstance = (APPSLayoutConstraintConfiguration *)[[[self class] alloc] init];
    });
    
    return __sharedInstance;
}



#pragma mark - Initialization

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        [self configureCache];
    }
    
    return self;
}



#pragma mark - Configuration

- (void)configureCache;
{
    self.fileContentsCache = [[NSCache alloc] init];
}



#pragma mark - Inquiries

+ (NSDictionary *)entryForJSONIdentifier:(NSString *)jsonIdentifier
                                   scene:(NSString *)sceneIdentifier
                              constraint:(NSString *)constraintIdentifier;
{
    return [[self sharedInstance] entryForJSONIdentifier:jsonIdentifier scene:sceneIdentifier constraint:constraintIdentifier];
}


- (NSDictionary *)entryForJSONIdentifier:(NSString *)jsonIdentifier
                                   scene:(NSString *)sceneIdentifier
                              constraint:(NSString *)constraintIdentifier;
{
    NSDictionary *jsonEntries = [self entriesForFile:jsonIdentifier];
    
    NSDictionary *sceneEntries = jsonEntries[sceneIdentifier];
    APPSAssert(sceneEntries, @"Could not find an entry for scene '%@' in JSON custom constraints configuration "
               "file '%@' while ultimately looking to get entry for constraint '%@'.",
               sceneIdentifier, jsonIdentifier, constraintIdentifier);
    
    NSDictionary *constraintEntries = sceneEntries[constraintIdentifier];
    APPSAssert(constraintEntries, @"Could not find an entry for constraint '%@' in JSON custom constraints configuration "
               "file '%@' for scene '%@'.",
               constraintIdentifier, jsonIdentifier, sceneIdentifier);

    return constraintEntries;
}



#pragma mark - Helpers

- (NSDictionary *)entriesForFile:(NSString *)jsonIdentifier;
{
    // Step 1. Check the cache:
    NSDictionary *entries = [self.fileContentsCache objectForKey:jsonIdentifier];
    if (entries) { return entries; }
    
    // Status: We didn't find it in the cache.

    // Step 2. Load from disk:
    NSString *baseName = [NSString stringWithFormat:kAPPS_FileBasenameFormatString, jsonIdentifier];
    APPSResourceLookupUtility *lookup = [[APPSResourceLookupUtility alloc]
                                         initWithBaseName:baseName
                                         bundle:[NSBundle mainBundle]];
    
    entries = [lookup dictionaryFromJSONFile];
    APPSAssert(entries, @"No JSON file with base name '%@' found for APPSLayoutConstraint customization.", jsonIdentifier);

    // 3. Save to cache:
    [self.fileContentsCache setObject:entries forKey:jsonIdentifier];
    
    return entries;
}



@end
