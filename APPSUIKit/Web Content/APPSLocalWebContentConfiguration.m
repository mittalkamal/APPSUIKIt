//
//  APPSLocalWebContentConfiguration.m
//
//  Created by Ken Grigsby on 2/4/16.
//

@import APPSFoundation;

#import "APPSLocalWebContentConfiguration.h"
#import <APPSUIKit/APPSUIKit-Swift.h>


#define kAPPSLocalWebContent_DefaultMasterTemplateName      @"APPSLocalWebContentDefaultTemplate"
#define kAPPSLocalWebContent_DefaultMasterStylesheetName    @"APPSLocalWebContentDefaultStylesheet"

@implementation APPSLocalWebContentConfiguration

#pragma mark - Property Overrides

- (NSString *)masterTemplateName
{
    return _masterTemplateName ?: kAPPSLocalWebContent_DefaultMasterTemplateName;
}


- (NSString *)masterStylesheetName
{
    return _masterStylesheetName ?: kAPPSLocalWebContent_DefaultMasterStylesheetName;
}



#pragma mark - Content Preparation

- (NSString *)HTMLString
{
    // Set an empty dictionary in place of a nil body content substitutions dictionary, if needed:
    if (!self.bodyContentSubstitutions) { self.bodyContentSubstitutions = @{}; }
    NSString *scrollingEnabledValueAsString = boolAsTrueFalseString(self.scrollingEnabled);
    
    if (self.bodyContentTemplateName) {
        self.bodyContentTemplateText = [self contentFromTemplateWithName:self.bodyContentTemplateName];
    }
    
    NSString *processedBodyContent = [self contentUsingTemplateText:self.bodyContentTemplateText
                                                 afterSubstitutions:self.bodyContentSubstitutions];
    
    NSString *stylesheetContent = [self contentFromStylesheetName:self.masterStylesheetName];
    
    NSDictionary *masterTemplateSubstitutions = @{
                                                  @"BODY_CONTENT" : processedBodyContent,
                                                  @"STYLESHEET_CONTENT" : stylesheetContent,
                                                  @"SCROLLING_ENABLED" : scrollingEnabledValueAsString
                                                  };
    
    NSString *masterTemplateText = [self contentFromTemplateWithName:self.masterTemplateName];
    NSString *processedPageContent = [self contentUsingTemplateText:masterTemplateText
                                                 afterSubstitutions:masterTemplateSubstitutions];
    
//    if ([APPSBuildConfiguration isDevelopmentBuild]) {
//        logInfo(@"Processed page content to render into UIWebView is:\n%@", processedPageContent);
//    }
    
    return processedPageContent;
}


- (NSString *)contentFromTemplateWithName:(NSString *)templateName
{
    // First look for the template in the main bundle:
    APPSResourceLookupUtility *lookup = [APPSResourceLookupUtility new];
    lookup.bundle = [NSBundle mainBundle];
    lookup.fileExtension = @"html";
    lookup.baseName = templateName;
    NSString *localPath = [lookup firstMatchingFilePath];
    
    // Did we not find the template?
    if (!localPath) {
        // Correct. We'll attempt to find it from our own bundle:
        NSBundle *frameworkBundle = [APPSUIKit bundle];
        lookup.bundle = frameworkBundle;
        localPath = [lookup firstMatchingFilePath];
    }
    
    NSError *error = nil;
    NSString *templateString = [NSString stringWithContentsOfFile:localPath
                                                         encoding:NSStringEncodingConversionExternalRepresentation
                                                            error:&error];
    if (error) {
        logError(@"Error with template: %@", templateName);
        templateString = @"";
    }
    
    return templateString;
}


- (NSString *)contentFromStylesheetName:(NSString *)stylesheetName
{
    // First look for the stylesheet in the main bundle:
    NSString *localPath = [[NSBundle mainBundle] pathForResource:stylesheetName ofType:@"css"];
    
    // Did we not find the stylesheet?
    if (!localPath) {
        // Correct. We'll attempt to find it from our own bundle:
        NSBundle *frameworkBundle = [APPSUIKit bundle];
        localPath = [frameworkBundle pathForResource:stylesheetName ofType:@"css"];
    }
    
    NSError *error = nil;
    NSString *stylesheetString = [NSString stringWithContentsOfFile:localPath
                                                           encoding:NSStringEncodingConversionExternalRepresentation
                                                              error:&error];
    if (error) {
        logError(@"Error with stylesheet: %@", stylesheetName);
        stylesheetString = @"";
    }
    
    return stylesheetString;
}


- (NSString *)contentUsingTemplateText:(NSString *)templateText afterSubstitutions:(NSDictionary *)substitutions;
{
    NSMutableString *contentString = [NSMutableString stringWithString:templateText];
    
    // Enumerate through all bodyContentSubstitutions and apply them wherever they occur:
    for (NSString *key in [substitutions allKeys]) {
        NSString *valueString = [substitutions valueForKey:key];
        NSRange fullStringRange = NSMakeRange(0, [contentString length]);
        NSString *keyString = [NSString stringWithFormat:@"{%@}", key];
        [contentString replaceOccurrencesOfString:keyString
                                       withString:valueString
                                          options:NSLiteralSearch
                                            range:fullStringRange];
    }
    
    return contentString;
}

@end
