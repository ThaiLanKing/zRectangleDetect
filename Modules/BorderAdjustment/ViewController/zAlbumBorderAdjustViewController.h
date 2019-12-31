//
//  zAlbumBorderAdjustViewController.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/27.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface zAlbumBorderAdjustViewController : UIViewController

@property (nonatomic, strong) UIImage *srcImg;
@property (nonatomic, strong) CIRectangleFeature *scannedRectFeature;

@end

NS_ASSUME_NONNULL_END
