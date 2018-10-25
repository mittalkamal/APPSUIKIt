//
//  APPSLocalWebContentViewController.h
//
//  Created by Sohail Ahmed on 8/13/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "APPSBaseViewController.h"

@class WKWebView;
@class APPSLocalWebContentConfiguration;

/**
 This view controller displays the contents of an HTML file inside a full view controller canvas.
 
 We understand how to load the content, and optionally perform body content substitutions to replace
 placeholders in the templated HTML with dynamic values.
 
 At this stage, we still require callers to set our view controller title, should we be displayed
 inside a UINavigationController (which is typical). Callers will provide a body template name,
 which we will use to lookup a resource.

 Mandatory Project Resources:
 * APPSLocalWebContentDefaultTemplate.html : used to provide the top level HTML template.
 * APPSLocalWebContentDefaultStylesheet.css : used to provide a default set of CSS styles.

 To be clear, there are two levels of HTML templating:
 1. The top-level, master template. By default, this is APPSLocalWebContentDefaultTemplate.html file.
    You can however, override the property masterTemplateName to provide your own.
 2. The inner body-content template, whose contents will get dropped in between the body tags
    of the master template.

 You can optionally specify the name of a stylesheet file. Otherwise, the default stylesheet file
 will be used.
 
 You may also provide a value for bodyContentTemplateText instead of bodyContentTemplateName,
 to provide the text directly (instead of loading it from disk). Substitutions provided for body content
 will still attempt to resolve using the body content template text provided.
 */
@interface APPSLocalWebContentViewController : APPSBaseViewController


/**
 Returns the web view used for the main content of the view controller. (read-only)
 */
@property (strong, nonatomic, readonly) WKWebView *webView;


#pragma mark scalar

/**
 In some situations with custom navigation bars installed, you'll want use the top layout guide,
 which is skipped by default. By "using the top layout guide", what we mean is that in this view
 controller's auto-layout code, we'll use the top layout guide to pin the web view's top boundary,
 as opposed to pinning it to the superview's top edge.
 */
@property (assign, nonatomic) BOOL useTopLayoutGuide;



#pragma mark copy

/**
 The callback for us to invoke if we're displayed in a navigation controller and our top right
 bar button item is tapped. Typically, callers will use this to have us dismissed in some fashion.
 */
@property (copy, nonatomic) APPSCallbackBlock topRightBarButtonTappedCallback;



#pragma mark strong

/**
 A APPSLocalWebContentConfiguration object is a collection of properties with
 which to initialize a web content controller.
 */
@property (strong, nonatomic, readonly) APPSLocalWebContentConfiguration *configuration;



#pragma mark - UI Customization

/**
 Sets the button title for an optional top-right bar button item. Only relevant when
 we are presented inside a navigation controller. Tapping this button will invoke the
 topRightBarButtonTappedCallback, if a callback was indeed provided.
 */
- (void)installTopRightBarButtonItemWithTitle:(NSString *)buttonTitle;



#pragma mark - Operations

/**
 Convenience method to set the body template and substitutions. Once provided, we immediately process this 
 for rendering. If you need to override the master template and/or the master stylesheet, you should do that
 before calling this method.
 
 An alternative to this method is to simply set the bodyContentTemplateName and bodyContentSubstitutions properties
 directly yourself. This method is merely convenience API.
 */
- (void)loadContentsForBodyTemplateWithName:(NSString *)bodyContentTemplateName applyingSubsitutions:(NSDictionary *)substitutions;


/**
 Triggers the two levels of templating (master, body) and their substitutions to take place. Content is then
 rendered into our web view.
 
 It is required that prior to calling this method, all properties in this header have been set,
 or at the least, are those that have default values which are acceptable to you.
 */
- (void)updateContents;



#pragma mark - Navigation Controller Embedding

/**
 Creates a @c UINavigationController and embeds us in it. In doing so,
 we install a 'Close' button in the top right of the navigation bar
 which is wired to dismiss this view controller when tapped.
 
 Callers are responsible for keeping a strong reference to the returned
 navigation controller, as we do not.
 
 @return A preconfigured navigation controller with this controller as its root view controller.
 */
- (UINavigationController *)preconfiguredNavigationController;


/**
 Call this when you want this view controller to be available for deallocation, and you've
 called @c -preconfiguredNavigationController at least once before.
 
 We ensure that any navigation controller that we may be referenced by, no longer references us.
 */
- (void)removeFromEmbeddingInNavigationController;


@end
