//
//  zRectangleDetectCameraView.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/11.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zRectangleDetectCameraView.h"
#import "zCameraManager.h"
#import "zRectangleDetectHelper.h"

@interface zRectangleDetectCameraView ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    CGFloat _imageDetectionConfidence;
    NSTimer *_borderDetectTimeKeeper;
    CIRectangleFeature *_borderDetectLastRectangleFeature;
    
    BOOL _borderDetectOpened;
    
    BOOL _captureStart;
}

@property (nonatomic, strong) zCameraManager *cameraMgr;
@property (nonatomic, strong) CIDetector *rectangleDetector;

//矩形边框外遮盖层
@property (nonatomic, strong) CAShapeLayer *coverLayer;

@end

@implementation zRectangleDetectCameraView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        if ([self.cameraMgr configSession]) {
            [self.previewLayerView.layer addSublayer:self.cameraMgr.previewLayer];
        }
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.previewLayerView.frame = self.bounds;
    self.cameraMgr.previewLayer.frame = self.bounds;
}

#pragma mark -

- (zCameraManager *)cameraMgr
{
    if (!_cameraMgr) {
        _cameraMgr = [[zCameraManager alloc] init];
        [_cameraMgr.videoOutput setSampleBufferDelegate:self queue:dispatch_get_main_queue()];
    }
    return _cameraMgr;
}

- (CIDetector *)rectangleDetector
{
    if (!_rectangleDetector) {
        _rectangleDetector = [CIDetector detectorOfType:CIDetectorTypeRectangle
                                                context:nil
                                                options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
    }
    return _rectangleDetector;
}

- (CAShapeLayer *)coverLayer
{
    if (!_coverLayer) {
        _coverLayer = [CAShapeLayer layer];
        _coverLayer.fillRule = kCAFillRuleEvenOdd;
        _coverLayer.fillColor = [UIColor colorWithRed:73/255.0
                                                green:130/255.0
                                                 blue:180/255.0
                                                alpha:0.4].CGColor;
        _coverLayer.strokeColor = [UIColor whiteColor].CGColor;
        _coverLayer.lineWidth = 2.0f;
    }
    return _coverLayer;
}

#pragma mark - AVCaptureVideoDataOutputSampleBufferDelegate

- (void)captureOutput:(AVCaptureOutput *)output didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (_captureStart) {
        _captureStart = NO;
        [self stop];
        if (self.scanRectangleCompleteBlock) {
            CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
            CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
            UIImage *srcImg = [UIImage imageWithCIImage:image];            
            self.scanRectangleCompleteBlock(srcImg, _borderDetectLastRectangleFeature);
        }
        NSLog(@"testes");
        return;
    }
    
    if (!CMSampleBufferIsValid(sampleBuffer)) {
        return;
    }
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *image = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    image = [zRectangleDetectHelper imageFilteredUsingContrastOnImage:image];
    
    if (_borderDetectOpened) {
        NSArray<CIFeature *> *features = [self.rectangleDetector featuresInImage:image];
        // 选取特征列表中最大的矩形
        _borderDetectLastRectangleFeature = [zRectangleDetectHelper biggestRectangleFeatureInFeatures:features];
        _borderDetectOpened = NO;
    }
    
    if (_borderDetectLastRectangleFeature) {
        _imageDetectionConfidence += .5;
        
        if ([self isImageDetectionConfidenceEnough]) {
            [self drawBorderForImageRect:image.extent withFeature:_borderDetectLastRectangleFeature];
        }
    }
    else {
        _imageDetectionConfidence = 0.0f;
        if (_coverLayer) {
            _coverLayer.path = nil;
        }
    }
}

- (BOOL)isImageDetectionConfidenceEnough
{
    return _imageDetectionConfidence > 1.0f;
}

#pragma mark -

// 绘制边缘检测图层
- (void)drawBorderForImageRect:(CGRect)imageRect
                   withFeature:(CIRectangleFeature *)rectFeature
{
    if (!self.coverLayer.superlayer) {
        self.previewLayerView.layer.masksToBounds = YES;
        [self.previewLayerView.layer addSublayer:self.coverLayer];
    }

    // 将图像空间的坐标系转换成uikit坐标系
    zQuadrilateral *CIQuad = [zQuadrilateral qudrilateralFromRectangleFeature:rectFeature];
    zQuadrilateral *UIQuad = [CIQuad UIQuadrilateralForImgSize:imageRect.size inViewSized:self.bounds.size];
    
    // 边缘识别路径
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:UIQuad.topLeft];
    [path addLineToPoint:UIQuad.topRight];
    [path addLineToPoint:UIQuad.bottomRight];
    [path addLineToPoint:UIQuad.bottomLeft];
    [path closePath];
    // 背景遮罩路径
    CGFloat lineWidth = self.coverLayer.lineWidth;
    UIBezierPath *rectPath  = [UIBezierPath bezierPathWithRect:CGRectMake(-lineWidth,
                                                                          -lineWidth,
                                                                          self.frame.size.width + lineWidth*2,
                                                                          self.frame.size.height + lineWidth*2)];
    rectPath.usesEvenOddFillRule = YES;
    [rectPath appendPath:path];
    self.coverLayer.path = rectPath.CGPath;
}

#pragma mark -

- (void)start
{
    [self.cameraMgr startCapture];
    
    if (_borderDetectTimeKeeper) {
        [_borderDetectTimeKeeper invalidate];
    }
    _borderDetectTimeKeeper = [NSTimer scheduledTimerWithTimeInterval:0.65f target:self selector:@selector(enableBorderDetectFrame) userInfo:nil repeats:YES];
}

- (void)stop
{
    [self.cameraMgr stopCapture];
    
    if (_borderDetectTimeKeeper) {
        [_borderDetectTimeKeeper invalidate];
    }
}

- (void)enableBorderDetectFrame
{
    _borderDetectOpened = YES;
}

#pragma mark -

- (void)captureImage:(zCaptureDetectedImageBlock)captureImgBlock
{
    _captureStart = YES;
    return;
    
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in self.cameraMgr.imageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts]) {
            if ([[port mediaType] isEqual:AVMediaTypeVideo]) {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) break;
    }
    
    @weakify(self);
    [self.cameraMgr.imageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler: ^(CMSampleBufferRef imageSampleBuffer, NSError *error)
     {
        @strongify(self);
        if (!CMSampleBufferIsValid(imageSampleBuffer)) {
            NSLog(@"capture image failed : %@", error.description);
            return;
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
        CIImage *enhancedImage = [CIImage imageWithData:imageData];
        enhancedImage = [zRectangleDetectHelper imageFilteredUsingContrastOnImage:enhancedImage];
        // 判断边缘识别度阈值, 再对拍照后的进行边缘识别
        CIRectangleFeature *rectangleFeature;
        if ([self isImageDetectionConfidenceEnough])
        {
            // 获取边缘识别最大矩形
            rectangleFeature = [zRectangleDetectHelper biggestRectangleFeatureInFeatures:[self.rectangleDetector featuresInImage:enhancedImage]];
            if (rectangleFeature)
            {
                if (captureImgBlock) {
                    
                    // 获取拍照图片
                    UIImage *resultImg1 = [zRectangleDetectHelper perspectiveImageFromSampleBuffer:imageSampleBuffer withFeature:rectangleFeature];
                    
                    UIImage *resultImg2 = [zRectangleDetectHelper otherPerspectiveImageFromSampleBuffer:imageSampleBuffer withFeature:rectangleFeature];
                    
                    captureImgBlock(resultImg1);
                }
            }
        }
    }];
}

@end
