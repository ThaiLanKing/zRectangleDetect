//
//  zCameraManager.m
//  JBPhotoClaim
//
//  Created by zyh on 2019/3/4.
//  Copyright © 2019 zyh. All rights reserved.
//

#import "zCameraManager.h"

@interface zCameraManager ()

@property (nonatomic, strong) AVCaptureSession *captureSession;
@property (nonatomic, strong) AVCaptureDeviceInput *captureInput;
@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
@property (nonatomic, strong) AVCaptureVideoDataOutput *videoOutput;
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation zCameraManager

#pragma mark -

- (AVCaptureSession *)captureSession
{
    if (!_captureSession) {
        _captureSession = [[AVCaptureSession alloc] init];
    }
    return _captureSession;
}

- (AVCaptureDeviceInput *)captureInput
{
    if (!_captureInput) {
        NSError *error = nil;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        _captureInput = [[AVCaptureDeviceInput alloc] initWithDevice:device error:&error];
        if (error) {
            NSLog(@"captureInput error = %@", [error description]);
        }
    }
    return _captureInput;
}

- (AVCaptureStillImageOutput *)imageOutput
{
    if (!_imageOutput) {
        _imageOutput = [[AVCaptureStillImageOutput alloc] init];
        _imageOutput.outputSettings = @{AVVideoCodecKey : AVVideoCodecJPEG};
    }
    return _imageOutput;
}

- (AVCaptureVideoDataOutput *)videoOutput
{
    if (!_videoOutput) {
        _videoOutput = [[AVCaptureVideoDataOutput alloc] init];
        _videoOutput.alwaysDiscardsLateVideoFrames = YES;
        _videoOutput.videoSettings = @{(__bridge NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    }
    return _videoOutput;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.captureSession];
        [_previewLayer setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    }
    return _previewLayer;
}

#pragma mark -

- (AVCaptureDevice *)activeCamera
{
    return self.captureInput.device;
}

- (BOOL)configSession
{
    [self.captureSession beginConfiguration];
    
    self.captureSession.sessionPreset = AVCaptureSessionPresetPhoto;
    
    if ([self.captureSession canAddInput:self.captureInput]) {
        [self.captureSession addInput:self.captureInput];
    }
    else {
        return NO;
    }
    
    if ([self.captureSession canAddOutput:self.videoOutput]) {
        [self.captureSession addOutput:self.videoOutput];
    }
    else {
        return NO;
    }
    
    if ([self.captureSession canAddOutput:self.imageOutput]) {
        [self.captureSession addOutput:self.imageOutput];
    }
    else {
        return NO;
    }

    [self configConnection];
    
    AVCaptureDevice *device = [self activeCamera];
    
    if(YES == [device lockForConfiguration:NULL]) {
        if([device respondsToSelector:@selector(setSmoothAutoFocusEnabled:)] && [device isSmoothAutoFocusSupported]) {
            [device setSmoothAutoFocusEnabled:YES];
        }
        
        AVCaptureFocusMode currentMode = [device focusMode];
        if(currentMode == AVCaptureFocusModeLocked) {
            currentMode = AVCaptureFocusModeAutoFocus;
        }
        if([device isFocusModeSupported:currentMode]) {
            [device setFocusMode:currentMode];
        }
        [device unlockForConfiguration];
    }
    [self.captureSession commitConfiguration];
    
    return YES;
}

- (void)configConnection
{
    AVCaptureConnection *videoConnection;
    for (AVCaptureConnection *connection in [self.imageOutput connections]) {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
    }
    if ([videoConnection isVideoStabilizationSupported]) {
        videoConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
    }
    
    if (self.videoOutput) {
        [[self.videoOutput.connections firstObject] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    }
}

- (void)startSession
{
    if (![self.captureSession isRunning]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession startRunning];
        });
    }
}

- (void)stopSession
{
    if ([self.captureSession isRunning]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.captureSession stopRunning];
        });
    }
}

- (void)startCapture
{
    if (![self.captureSession isRunning]) {
        [self startSession];
    }
}

- (void)stopCapture
{
    if ([self.captureSession isRunning]) {
        [self stopSession];
    }
}

- (void)takePicture
{
    AVCaptureConnection *captureConnection = [self.imageOutput connectionWithMediaType:AVMediaTypeVideo];
    if (!captureConnection) {
        return;
    }
    
    @weakify(self);
    [self.imageOutput captureStillImageAsynchronouslyFromConnection:captureConnection completionHandler:^(CMSampleBufferRef  _Nullable imageDataSampleBuffer, NSError * _Nullable error) {
        @strongify(self);
        if (!imageDataSampleBuffer) {
            return;
        }
        
        NSData *imgData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *img = [UIImage imageWithData:imgData];
        if (self.takePictureSuccessBlock) {
            self.takePictureSuccessBlock(img);
        }
    }];
}

#pragma mark - 闪光灯

- (AVCaptureFlashMode)flashMode
{
    return [self.activeCamera flashMode];
}

- (void)setFlashMode:(AVCaptureFlashMode)flashMode {
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.flashMode != flashMode &&
        [device isFlashModeSupported:flashMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.flashMode = flashMode;
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"setFlashMode error : %@", error.description);
        }
    }
}

#pragma mark - 手电筒

- (BOOL)cameraHasTorch
{
    return [self.activeCamera hasTorch];
}

- (AVCaptureTorchMode)torchMode
{
    return [self.activeCamera torchMode];
}

- (void)setTorchMode:(AVCaptureTorchMode)torchMode
{
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.torchMode != torchMode &&
        [device isTorchModeSupported:torchMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.torchMode = torchMode;
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"setTorchMode error : %@", error.description);
        }
    }
}

#pragma mark - 焦距

- (BOOL)cameraSupportsTapToFocus
{
    return [self.activeCamera isFocusPointOfInterestSupported];
}

- (void)focusAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    
    if (device.isFocusPointOfInterestSupported &&
        [device isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.focusPointOfInterest = point;
            device.focusMode = AVCaptureFocusModeAutoFocus;
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"focusAtPoint error : %@", error.description);
        }
    }
}

static const NSString *THCameraAdjustingExposureContext;

- (void)exposeAtPoint:(CGPoint)point {
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureExposureMode exposureMode =
    AVCaptureExposureModeContinuousAutoExposure;
    
    if (device.isExposurePointOfInterestSupported &&
        [device isExposureModeSupported:exposureMode]) {
        NSError *error;
        if ([device lockForConfiguration:&error]) {
            device.exposurePointOfInterest = point;
            device.exposureMode = exposureMode;
            
            if ([device isExposureModeSupported:AVCaptureExposureModeLocked]) {
                [device addObserver:self
                         forKeyPath:@"adjustingExposure"
                            options:NSKeyValueObservingOptionNew
                            context:&THCameraAdjustingExposureContext];
            }
            [device unlockForConfiguration];
        }
        else {
            NSLog(@"exposeAtPoint error : %@", error.description);
        }
    }
}
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == &THCameraAdjustingExposureContext) {
        AVCaptureDevice *device = (AVCaptureDevice *)object;
        
        if (!device.isAdjustingExposure &&
            [device isExposureModeSupported:AVCaptureExposureModeLocked]) {
            [object removeObserver:self
                        forKeyPath:@"adjustingExposure"
                           context:&THCameraAdjustingExposureContext];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                NSError *error;
                if ([device lockForConfiguration:&error]) {
                    device.exposureMode = AVCaptureExposureModeLocked;
                    [device unlockForConfiguration];
                } else {
                    NSLog(@"adjustingExposure error : %@", error.description);
                }
            });
        }
    }
    else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

//重置曝光
- (void)resetFocusAndExposureModes {
    AVCaptureDevice *device = [self activeCamera];
    
    AVCaptureExposureMode exposureMode =
    AVCaptureExposureModeContinuousAutoExposure;
    
    AVCaptureFocusMode focusMode = AVCaptureFocusModeContinuousAutoFocus;
    
    BOOL canResetFocus = [device isFocusPointOfInterestSupported] &&
    [device isFocusModeSupported:focusMode];
    
    BOOL canResetExposure = [device isExposurePointOfInterestSupported] &&
    [device isExposureModeSupported:exposureMode];
    
    CGPoint centerPoint = CGPointMake(0.5f, 0.5f);
    
    NSError *error;
    if ([device lockForConfiguration:&error]) {
        if (canResetFocus) {
            device.focusMode = focusMode;
            device.focusPointOfInterest = centerPoint;
        }
        
        if (canResetExposure) {
            device.exposureMode = exposureMode;
            device.exposurePointOfInterest = centerPoint;
        }
        
        [device unlockForConfiguration];
    }
    else {
        NSLog(@"resetFocusAndExposureModes error : %@", error.description);
    }
}

@end
