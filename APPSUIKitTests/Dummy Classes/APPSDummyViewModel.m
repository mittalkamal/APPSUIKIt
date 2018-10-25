//
//  APPSDummyViewModel.m
//  AppstronomyStandardKit
//
//  Created by Sohail Ahmed on 1/28/16.
//  Copyright © 2016 Appstronomy, LLC. All rights reserved.
//

@import APPSFoundation;

#import "APPSDummyViewModel.h"

@implementation APPSDummyViewModel

#pragma mark - Debugging Support

- (NSString *)debugDescription;
{
    // Print the class name and memory address, per: http://stackoverflow.com/a/7555194/535054
    NSMutableString *message = [NSMutableString stringWithFormat:@"<%@: %p> ; data: {\n\t", [[self class] description], (__bridge void *)self];
    [message appendFormat:@"name: %@\n\t", self.name];
    [message appendFormat:@"category: %@\n\t", self.category];
    [message appendFormat:@"numberOfWidgets: %lu\n\t", (unsigned long)self.numberOfWidgets];
    [message appendFormat:@"isReady: %@\n\t", boolAsString(self.isReady)];
    [message appendString:@"}\n"];
    
    return message;
}



@end
