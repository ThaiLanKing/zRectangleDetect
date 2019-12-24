//
//  zCameraManager.h
//  JBPhotoClaim
//
//  Created by zyh on 2019/3/4.
//  Copyright © 2019 zyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^zCMTakePictureSuccessBlock)(UIImage *takedPicture);

@interface zCameraManager : NSObject

@property (nonatomic, strong, readonly) AVCaptureVideoPreviewLayer *previewLayer;
@property (nonatomic, strong, readonly) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong, readonly) AVCaptureVideoDataOutput *videoOutput;

@property (nonatomic, copy) zCMTakePictureSuccessBlock takePictureSuccessBlock;

- (AVCaptureDevice *)activeCamera;

#pragma mark -

- (BOOL)configSession;

- (void)configConnection;

- (void)startSession;
- (void)stopSession;

- (void)startCapture;
- (void)stopCapture;

- (void)takePicture;

#pragma mark -

// 闪关灯
- (AVCaptureFlashMode)flashMode;
- (void)setFlashMode:(AVCaptureFlashMode)flashMode;

// 手电筒
- (BOOL)cameraHasTorch;
- (AVCaptureTorchMode)torchMode;
- (void)setTorchMode:(AVCaptureTorchMode)torchMode;

// 焦距
- (BOOL)cameraSupportsTapToFocus;
- (void)focusAtPoint:(CGPoint)point;

// 重置曝光
- (void)resetFocusAndExposureModes;

@end

NS_ASSUME_NONNULL_END
