//
//  APPSLocalWebContentConfiguration.h
//
//  Created by Ken Grigsby on 2/4/16.
//

#import <Foundation/Foundation.h>


/**
 This class holds properties that deal with HTML templates, HTML body content, CSS stylesheets
 and possible body content substitution. All of this is to produce a string that can be displayed
 by components that display web content, such as @c APPSLocalContentWebContentViewController.
 
 All of the combining and substitutions (if any), happen in this configuration class. As such,
 any component that is web content display capable, need only retrieve our @c -htmlString to 
 get the actual content that should be displayed.
 */
@interface APPSLocalWebContentConfiguration : NSObject

#pragma mark scalar

/**
 This defaults to NO. As such, unless you set this to YES, the web content you display will not be
 scrollable in any way.
 */
@property (assign, nonatomic) BOOL scrollingEnabled;


#pragma mark copy

/**
 Optional. The master template is the outermost level of templating. This is the content that goes
 directly inside of our UIWebView to display HTML content. If not provided explicitly, the default
 APPSLocalWebContentDefaultTemplate.html file will be used (it has the key name of
 "APPSLocalWebContentDefaultTemplate").
 
 Normally, content provided by the file for the property bodyContentTemplateName will sit inside the body
 tags of this master template.
 
 If you do provided your own master template, it MUST contain two substitution placeholders:
 
 1. {STYLESHEET_NAME}
 2. {BODY_CONTENT}
 */
@property (copy, nonatomic) NSString *masterTemplateName;


/**
 Optional. The name of the stylesheet (if any, and minus the .css extension) to include when rendering this
 content. If not provided, we'll use the default stylesheet, APPSLocalWebContentDefaultStylesheet.css.
 */
@property (copy, nonatomic) NSString *masterStylesheetName;


/**
 This is the name of an HTML file resource bundled with the project, minus the ".html" suffix.
 Once set, we'll load that content into the body section of the master HTML template.
 */
@property (copy, nonatomic) NSString *bodyContentTemplateName;


/**
 An alternative to bodyContentTemplateName, for when you already have the chunk of text that represents
 the body content template and don't need it to be loaded from a file on disk.
 */
@property (copy, nonatomic) NSString *bodyContentTemplateText;



#pragma mark strong

/**
 Optional. This is the dictionary of body content substitutions we should apply to the body template that we load.
 Substitutions are optional.
 
 Substitution Variables Format
 -----------------------------
 Substitution placeholders in templates should be in all caps, underscore separated phrases,
 surrounded with curly braces, such as in the following examples:
 
 * {SPECIAL_DISPLAY_VALUE}
 * {YEARS_IN_THE_FUTURE}
 * {USER_FIRST_NAME}
 
 Note that you can pull in a body content template and not have any body content substitutions to perform at all.
 Substitutions are completely optional.
 
 When you do provide a dictionary of substitutions, do NOT include the curly braces in your key names.
 The only time you provide curly braces is when you are building the HTML content and dropping in substitution
 points into a template itself.
 */
@property (strong, nonatomic) NSDictionary *bodyContentSubstitutions;


/**
 Triggers the two levels of templating (master, body) and their substitutions to take place. Content is then
 returned.
 
 It is required that prior to calling this method, all properties in the public interface of this have been set,
 or at the least, are those that have default values which are acceptable to you.
 */
- (NSString *)HTMLString;

@end
