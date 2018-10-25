//
//  APPSTableViewHeaderFooterView.m
//
//  Created by Sohail Ahmed on 2/8/16.
//

#import "APPSTableViewHeaderFooterView.h"

@implementation APPSTableViewHeaderFooterView

#pragma mark - Nib/Xib Related

+ (UINib *)nib;
{
    NSString *nibName = NSStringFromClass(self.class);
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    
    return nib;
}


- (UINib *)nib;
{
    UINib *nib = [UINib nibWithNibName:self.nibName bundle:nil];

    return nib;
}

@end
