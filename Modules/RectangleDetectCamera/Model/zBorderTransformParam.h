//
//  zBorderTransformParam.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2020/1/2.
//  Copyright © 2020 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, kImageShowMode) {
    kImageShowModeScaleToFill = UIViewContentModeScaleToFill,
    kImageShowModeScaleAspectFit = UIViewContentModeScaleAspectFit,
    kImageShowModeScaleAspectFill = UIViewContentModeScaleAspectFill,
};

/**
 默认是CI转为UI的参数
 */
@interface zBorderTransformParam : NSObject

- (instancetype)initWithImage:(UIImage *)srcImg
            showedInViewSized:(CGSize)viewSize
                     withMode:(kImageShowMode)showMode;

- (instancetype)initWithImageSized:(CGSize)imgSize
                 showedInViewSized:(CGSize)viewSize
                          withMode:(kImageShowMode)showMode;

- (CGAffineTransform)transformFromCIToUI;
- (CGAffineTransform)transformFromUIToCI;

@end

NS_ASSUME_NONNULL_END
