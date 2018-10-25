//
//  APPSPlaceholderView.h
//
//  Created by Ken Grigsby on 8/30/14.
//  Copyright (c) 2014 Appstronomy, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

/// A placeholder view that approximates the standard iOS no content view.
@interface APPSLoadableContentPlaceholderView : UIView

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *message;
@property (nonatomic, copy) NSString *buttonTitle;
@property (nonatomic, copy) void (^buttonAction)(void);

/// Initialize a placeholder view. A message is required in order to display a button.
- (instancetype)initWithFrame:(CGRect)frame title:(NSString *)title message:(NSString *)message image:(UIImage *)image buttonTitle:(NSString *)buttonTitle buttonAction:(dispatch_block_t)buttonAction NS_DESIGNATED_INITIALIZER;

- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;
@end

/// A placeholder view for use in the table view. This placeholder includes the loading indicator.
@interface APPSTablePlaceholderView : UIView

- (void)showActivityIndicator:(BOOL)show;
- (void)showPlaceholderWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)image animated:(BOOL)animated;
- (void)hidePlaceholderAnimated:(BOOL)animated;

@end


/// A placeholder cell. Used when it's not appropriate to display the full size placeholder view in the table view, but a smaller placeholder is desired.
@interface APPSPlaceholderCell : UITableViewCell

- (void)showPlaceholderWithTitle:(NSString *)title message:(NSString *)message image:(UIImage *)image animated:(BOOL)animated;
- (void)hidePlaceholderAnimated:(BOOL)animated;

@end
