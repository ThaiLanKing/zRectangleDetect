//
//  UILabel+zCustome.h
//  JamBoHealth
//
//  Created by zyh on 16/12/7.
//  Copyright © 2016年 zyh. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (zCustome)

+ (UILabel *)labelWithFontSize:(CGFloat)fontSize
                   andTxtColor:(UIColor *)txtColor;

+ (UILabel *)labelCenterAlignmentWithFontSize:(CGFloat)fontSize
                                  andTxtColor:(UIColor *)txtColor;

+ (UILabel *)labelWithFont:(UIFont *)font
               andTxtColor:(UIColor *)txtColor
           andTxtAlignment:(NSTextAlignment)txtAlignment;

@end
