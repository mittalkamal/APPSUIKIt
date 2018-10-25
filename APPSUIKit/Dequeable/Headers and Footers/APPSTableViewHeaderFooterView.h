//
//  APPSTableViewHeaderFooterView.h
//
//  Created by Sohail Ahmed on 2/8/16.
//

#import <UIKit/UIKit.h>

/**
 Use this base class for your custom @c UITableViewHeaderFooterView subclassing needs.
 The benefit here, is that we assume a nib name based on the name of the subclass that 
 you create. Further, we can retrieve an instance of that nib for you, on that basis.
 
 This is handy when registering a nib in your @c UITableViewController for a given
 section header or footer view.
 
 When instantiating nibs, we look in the default bundle.
 */
@interface APPSTableViewHeaderFooterView : UITableViewHeaderFooterView

#pragma mark copy

/**
 Set this if you are using an instance of @c APPSTableViewHeaderFooterView without
 subclassing it, or your subclass is using different nibs on a per-instance basis.
 */
@property (copy, nonatomic) NSString *nibName;



#pragma mark - Nib/Xib Related

/**
 Returns the nib for this cell. This applies at the class level. 
 If you don't have a custom subclass of @c APPSTableViewHeaderFooterView, and just 
 wish to use it generically, you should set the instance property @c nibName and use
 the instance @c -nib method instead.
 
 @return A nib instance.
 */
+ (UINib *)nib;


/**
 Like the @c +nib class method, this instance variation will return you a nib.
 However, we use the nib name set with the instance property @c nibName.
 If you call this method without setting that property, you will raise an exception.
 
 @return A nib instance.
 */
- (UINib *)nib;

@end
