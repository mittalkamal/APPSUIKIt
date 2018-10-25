//
//  APPSLocalWebContentViewController.m
//
//  Created by Sohail Ahmed on 8/13/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;
@import WebKit;

#import "APPSLocalWebContentViewController.h"
#import "APPSLocalWebContentConfiguration.h"

@interface APPSLocalWebContentViewController () <WKNavigationDelegate>
#pragma mark weak
@property (weak, nonatomic) UINavigationController *preconfiguredNavigationController;
#pragma mark strong
@property (strong, nonatomic) WKWebView *webView;
@end



@implementation APPSLocalWebContentViewController

@synthesize configuration = _configuration;

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([APPSBuildConfiguration isDevelopmentBuild]) {
        logInfo(@"Using value of self.masterStylesheetName: %@", self.configuration.masterStylesheetName);
    }
    
    [self installWebView];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([APPSBuildConfiguration isDevelopmentBuild]) {
        logInfo(@"Using value of self.masterStylesheetName: %@", self.configuration.masterStylesheetName);
    }

    // Do we already have enough to go on to render the contents?
    if (self.configuration.bodyContentTemplateText || self.configuration.bodyContentTemplateName) {
        // YES: So go ahead and do that.
        [self updateContents];
    }
}



#pragma mark - Property Overrides

- (APPSLocalWebContentConfiguration *)configuration {
    if (!_configuration) {
        _configuration = [[APPSLocalWebContentConfiguration alloc] init];
    }
    return _configuration;
}



#pragma mark - Configuration

- (void)installWebView
{
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
    
    [self.view addSubview:self.webView];
    
    [self.webView setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    id topGuide = self.topLayoutGuide;
    id webView = self.webView;
    NSDictionary *viewsDictionary = NSDictionaryOfVariableBindings(webView, topGuide);
    logDebug(@"viewsDictionary: %@", viewsDictionary);

    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[webView]|"
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
    
    NSString *visualFormatString;
    
    if (self.useTopLayoutGuide) {
        visualFormatString = @"V:|[topGuide][webView]|";
    }
    else {
        visualFormatString = @"V:|[webView]|";
    }
    
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:visualFormatString
                                                                      options:0
                                                                      metrics:nil
                                                                        views:viewsDictionary]];
}


#pragma mark - User Interface

- (IBAction)handleTopRightBarButtonItemTapped:(id)sender
{
    if (self.topRightBarButtonTappedCallback) {
        self.topRightBarButtonTappedCallback();
    }
}



#pragma mark - UI Customization

- (void)installTopRightBarButtonItemWithTitle:(NSString *)buttonTitle;
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]
                                              initWithTitle:buttonTitle
                                              style:UIBarButtonItemStyleDone
                                              target:self
                                              action:@selector(handleTopRightBarButtonItemTapped:)];
}



#pragma mark - Navigation Controller Embedding

- (void)embedInNavigationController;
{
    // Configure us to have a UIBarButtonItem that triggers a modal dismissal:
    __weak APPSLocalWebContentViewController *weakSelf = self;
    [self installTopRightBarButtonItemWithTitle:@"Close"];
    self.topRightBarButtonTappedCallback = ^{
        [weakSelf.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    };
}


- (void)removeFromEmbeddingInNavigationController;
{
    NSMutableArray *adjustedViewControllers = [self.navigationController.viewControllers mutableCopy];
    [adjustedViewControllers removeObject:self]; // Remove us from the list of view controllers
    
    self.navigationController.viewControllers = adjustedViewControllers;
    self.topRightBarButtonTappedCallback      = nil;
    self.navigationItem.rightBarButtonItem    = nil;
}


- (UINavigationController *)preconfiguredNavigationController;
{
    UINavigationController *prebuiltNavigationController = [[UINavigationController alloc] initWithRootViewController:self];
    [self embedInNavigationController];
    
    return prebuiltNavigationController;
}




#pragma mark - Operations

- (void)loadContentsForBodyTemplateWithName:(NSString *)bodyContentTemplateName
                       applyingSubsitutions:(NSDictionary *)substitutions;
{
    self.configuration.bodyContentTemplateName = bodyContentTemplateName;
    self.configuration.bodyContentSubstitutions = substitutions;
    [self updateContents];
}



#pragma mark - Content Preparation

- (void)updateContents
{
    APPSAssert(self.configuration.masterTemplateName,
               @"We don't yet have a master template name set, and we've been asked to update our contents.");
    
    NSURL *baseURL = [NSURL fileURLWithPath:[[NSBundle mainBundle] resourcePath] isDirectory:YES]; // TODO: Move this to a cached property

    NSString *processedPageContent = self.configuration.HTMLString;
    
    [self.view bringSubviewToFront:self.webView];
    
    if ([APPSBuildConfiguration isDevelopmentBuild]) {
        logInfo(@"Processed page content to render into UIWebView is:\n%@", processedPageContent);
    }
    
    [self.webView loadHTMLString:processedPageContent baseURL:baseURL];
}


@end
