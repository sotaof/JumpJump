//
//  UIColor+Extension.h
//  Expecta
//
//  Created by yang wang on 2018/1/13.
//

#import <UIKit/UIKit.h>

@interface UIColor (HTExtension)
+ (UIColor *)colorWithARGBHex:(unsigned int)hex;
+ (UIColor *)colorWithRGBHex:(unsigned int)hex;
+ (UIColor *)colorWithARGBHexString:(NSString *)hex;
+ (UIColor *)colorWithRGBHexString:(NSString *)hex;
@end
