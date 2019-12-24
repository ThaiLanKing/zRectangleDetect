//
//  zRectangleDetectCameraView.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/11.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zJamBoCameraView.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^zCaptureDetectedImageBlock)(UIImage *detectedImg);

typedef void(^zScanRectangleCompleteBlock)(UIImage *srcImg, CIRectangleFeature *rectFeature);

@interface zRectangleDetectCameraView : zJamBoCameraView

@property (nonatomic, copy) zScanRectangleCompleteBlock scanRectangleCompleteBlock;

- (void)start;

- (void)stop;

- (void)captureImage:(zCaptureDetectedImageBlock)captureImgBlock;

@end

NS_ASSUME_NONNULL_END
