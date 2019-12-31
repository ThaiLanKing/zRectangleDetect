//
//  zJBCameraViewController.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/9/29.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zQuadrilateral.h"

NS_ASSUME_NONNULL_BEGIN

@interface zJBCameraViewController : UIViewController

#ifdef DEBUG //测试

+ (UIImage *)testCropImg:(UIImage *)srcImg;

+ (zQuadrilateral *)scannedRectangleFromImg:(UIImage *)srcImg;

#endif

@end

NS_ASSUME_NONNULL_END
