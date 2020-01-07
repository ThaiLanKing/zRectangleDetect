//
//  zBorderAdjustmentViewController.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/24.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "zQuadrilateral.h"
#import "zBorderTransformParam.h"

NS_ASSUME_NONNULL_BEGIN

@interface zBorderAdjustmentViewController : UIViewController

@property (nonatomic, strong) UIImage *srcImg;
@property (nonatomic, strong) zQuadrilateral *CIQuad;

//实时检测的影像是AsepectFill，相册影像是AspectFit
- (void)setImageShowMode:(kImageShowMode)showMode;

@end

NS_ASSUME_NONNULL_END
