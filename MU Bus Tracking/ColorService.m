//
//  ColorService.m
//  MU Bus Tracking
//
//  Created by Jake Gregg on 10/14/13.
//  Copyright (c) 2013 Jake Gregg. All rights reserved.
//

#import "ColorService.h"

@implementation ColorService

-(UIColor*) getColorFromHexString:(NSString*)color {
    NSString *hex = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *red = [hex substringWithRange:range];
    range.location = 2;
    NSString *green = [hex substringWithRange:range];
    range.location = 4;
    NSString *blue = [hex substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:red] scanHexInt:&r];
    [[NSScanner scannerWithString:green] scanHexInt:&g];
    [[NSScanner scannerWithString:blue] scanHexInt:&b];
    UIColor *ret = [UIColor colorWithRed:r / 255.0f green:g / 255.0f blue:b / 255.0f alpha:1.0f];
    return ret;
}

@end
