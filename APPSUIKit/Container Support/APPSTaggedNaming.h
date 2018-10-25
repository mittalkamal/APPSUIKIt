//
//  APPSTaggedNaming.h
//  REPSPro
//
//  Created by Sohail Ahmed on 5/26/13.
//  Copyright (c) 2013 Appstronomy. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol APPSTaggedNaming <NSObject>

@required
- (NSString *)taggedName;
- (void)setTaggedName:(NSString *)taggedName;

@end
