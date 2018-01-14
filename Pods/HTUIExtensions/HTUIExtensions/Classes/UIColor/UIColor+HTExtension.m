//
//  UIColor+Extension.m
//  Expecta
//
//  Created by yang wang on 2018/1/13.
//

#import "UIColor+HTExtension.h"

@implementation UIColor (HTExtension)
+ (UIColor *)colorWithARGBHex:(unsigned int)hex {
    CGFloat a = (hex >> 24 & 0xff) / 255.0;
    CGFloat r = (hex >> 16 & 0xff) / 255.0;
    CGFloat g = (hex >> 8 & 0xff) / 255.0;
    CGFloat b = (hex & 0xff) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

+ (UIColor *)colorWithRGBHex:(unsigned int)hex {
    CGFloat r = (hex >> 16 & 0xff) / 255.0;
    CGFloat g = (hex >> 8 & 0xff) / 255.0;
    CGFloat b = (hex & 0xff) / 255.0;
    return [UIColor colorWithRed:r green:g blue:b alpha:1.0];
}

+ (UIColor *)colorWithARGBHexString:(NSString *)hexString {
    if ([hexString hasPrefix:@"#"] && hexString.length == 9) {
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        scanner.scanLocation = 1;
        unsigned int hexInt = 0;
        [scanner scanHexInt:&hexInt];
        return [UIColor colorWithARGBHex:hexInt];
    }
    return UIColor.clearColor;
}

+ (UIColor *)colorWithRGBHexString:(NSString *)hexString {
    if ([hexString hasPrefix:@"#"] && hexString.length == 7) {
        NSScanner *scanner = [NSScanner scannerWithString:hexString];
        scanner.scanLocation = 1;
        unsigned int hexInt = 0;
        [scanner scanHexInt:&hexInt];
        return [UIColor colorWithRGBHex:hexInt];
    }
    return UIColor.clearColor;
}
@end
