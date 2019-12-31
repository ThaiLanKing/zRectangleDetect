//
//  UIImageView+zRectangleDetect.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/31.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "UIImageView+zRectangleDetect.h"

@implementation UIImageView (zRectangleDetect)

- (CGSize)imgScaleForImage:(UIImage *)srcImg
{
    CGSize imgScale = CGSizeMake(1.0f, 1.0f);
    if (!srcImg) {
        return imgScale;
    }
    CGFloat sx = self.bounds.size.width / srcImg.size.width;
    CGFloat sy = self.bounds.size.height / srcImg.size.height;
    
    switch (self.contentMode) {
        case UIViewContentModeScaleAspectFit:
        {
            CGFloat scale = MIN(sx, sy);
            imgScale = CGSizeMake(scale, scale);
        }
            break;
        case UIViewContentModeScaleAspectFill:
        {
            CGFloat scale = MAX(sx, sy);
            imgScale = CGSizeMake(scale, scale);
        }
            break;
        case UIViewContentModeScaleToFill:
        {
            imgScale = CGSizeMake(sx, sy);
        }
            break;
            
        default:
            break;
    }
    return imgScale;
}

- (CGSize)imgScale
{
    return [self imgScaleForImage:self.image];
}

@end
