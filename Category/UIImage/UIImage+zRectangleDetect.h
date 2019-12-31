//
//  UIImage+zRectangleDetect.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/31.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zQuadrilateral.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (zRectangleDetect)

+ (CIImage *)zCIImageFromUIImage:(UIImage *)srcImg;

- (CGAffineTransform)zOrientationCorrectTransform;

- (CGAffineTransform)zUIOrientationCorrectTransform;

- (UIImage *)fixOrientation;

@end

NS_ASSUME_NONNULL_END
