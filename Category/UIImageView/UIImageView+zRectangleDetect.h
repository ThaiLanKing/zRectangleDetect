//
//  UIImageView+zRectangleDetect.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/31.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIImageView (zRectangleDetect)

- (CGSize)imgScale;
- (CGSize)imgScaleForImage:(UIImage *)srcImg;

@end

NS_ASSUME_NONNULL_END
