//
//  UILabel+zCustome.m
//  JamBoHealth
//
//  Created by zyh on 16/12/7.
//  Copyright © 2016年 zyh. All rights reserved.
//

#import "UILabel+zCustome.h"

#define FontWithSize(fontSize) [UIFont systemFontOfSize:(fontSize)]
#define BoldFontWithSize(fontSize) [UIFont boldSystemFontOfSize:(fontSize)]

@implementation UILabel (zCustome)

+ (UILabel *)labelWithFontSize:(CGFloat)fontSize
                   andTxtColor:(UIColor *)txtColor
{
    return [self labelWithFont:FontWithSize(fontSize)
                   andTxtColor:txtColor
               andTxtAlignment:NSTextAlignmentLeft];
}

+ (UILabel *)labelCenterAlignmentWithFontSize:(CGFloat)fontSize
                                  andTxtColor:(UIColor *)txtColor
{
    return [self labelWithFont:FontWithSize(fontSize)
                   andTxtColor:txtColor
               andTxtAlignment:NSTextAlignmentCenter];
}

+ (UILabel *)labelWithFont:(UIFont *)font
               andTxtColor:(UIColor *)txtColor
           andTxtAlignment:(NSTextAlignment)txtAlignment
{
    UILabel *lbl = [UILabel new];
    lbl.font = font;
    lbl.textColor = txtColor;
    lbl.textAlignment = txtAlignment;
    return lbl;
}

@end
