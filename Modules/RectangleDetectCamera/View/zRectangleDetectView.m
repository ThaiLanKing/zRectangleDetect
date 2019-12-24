//
//  zRectangleDetectView.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/10.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zRectangleDetectView.h"
#import "zCameraManager.h"
#import <GLKit/GLKit.h>
#import "zRectangleDetectHelper.h"

@interface zRectangleDetectView ()<AVCaptureVideoDataOutputSampleBufferDelegate>
{
    CIContext *_coreImageContext;
    GLuint _renderBuffer;
    GLKView *_glkView;
    CGFloat _imageDetectionConfidence;
    NSTimer *_borderDetectTimeKeeper;
    CIRectangleFeature *_borderDetectLastRectangleFeature;
    
    BOOL _borderDetectOpened;
}

@property (nonatomic, strong) zCameraManager *cameraMgr;
@property (nonatomic, strong) CIDetector *rectangleDetector;

@property (nonatomic, strong) EAGLContext *context;

//矩形边框外遮盖层
@property (nonatomic, strong) CAShapeLayer *coverLayer;

@end

@implementation zRectangleDetectView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self configGlkView];
        [self.cameraMgr configSession];
    }
    return self;
}

- (void)configGlkView
{
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    _glkView = [[GLKView alloc] initWithFrame:self.bounds];
    _glkView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _glkView.context = self.context;
    _glkView.contentScaleFactor = 1.0f;
    _glkView.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [self insertSubview:_glkView atIndex:0];
    
    glGenRenderbuffers(1, &_renderBuffer);
    glBindRenderbuffer(GL_RENDERBUFFER, _renderBuffer);
    
    _coreImageContext = [CIContext contextWithEAGLContext:self.context];
    [EAGLContext setCurrentContext:self.context];
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
        
        //rectangleDetectionConfidenceHighEnough
        if (_imageDetectionConfidence > 1.0f) {
            [self drawBorderForImageRect:image.extent withFeature:_borderDetectLastRectangleFeature];
        }
    }
    else {
        _imageDetectionConfidence = 0.0f;
        if (_coverLayer) {
            _coverLayer.path = nil;
        }
    }
    
    if (self.context && _coreImageContext)
    {
        
            
            image = [self drawHighlightOverlayForPoints:image topLeft:_borderDetectLastRectangleFeature.topLeft topRight:_borderDetectLastRectangleFeature.topRight bottomLeft:_borderDetectLastRectangleFeature.bottomLeft bottomRight:_borderDetectLastRectangleFeature.bottomRight];
            
        
        // 将捕获到的图片绘制进_coreImageContext
        [_coreImageContext drawImage:image
                              inRect:self.bounds
                            fromRect:image.extent];
        [self.context presentRenderbuffer:GL_RENDERBUFFER];
        [_glkView setNeedsDisplay];
    }
}

#pragma mark -

// 绘制边缘检测图层
- (void)drawBorderForImageRect:(CGRect)imageRect
                   withFeature:(CIRectangleFeature *)rectFeature
{
    if (!self.coverLayer.superlayer) {
        self.layer.masksToBounds = YES;
        [self.layer addSublayer:self.coverLayer];
    }

    // 将图像空间的坐标系转换成uikit坐标系
    TransformCIFeatureRect featureRect = [self transfromImageRect:imageRect
                                                      withFeature:rectFeature];
    
    // 边缘识别路径
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:featureRect.topLeft];
    [path addLineToPoint:featureRect.topRight];
    [path addLineToPoint:featureRect.bottomRight];
    [path addLineToPoint:featureRect.bottomLeft];
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

- (CIImage *)drawHighlightOverlayForPoints:(CIImage *)image topLeft:(CGPoint)topLeft topRight:(CGPoint)topRight bottomLeft:(CGPoint)bottomLeft bottomRight:(CGPoint)bottomRight
{
    CIImage *overlay = [CIImage imageWithColor:[CIColor colorWithRed:0 green:5 blue:20 alpha:0.4]];
    overlay = [overlay imageByCroppingToRect:image.extent];
    overlay = [overlay imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:@{@"inputExtent":[CIVector vectorWithCGRect:image.extent],@"inputTopLeft":[CIVector vectorWithCGPoint:topLeft],@"inputTopRight":[CIVector vectorWithCGPoint:topRight],@"inputBottomLeft":[CIVector vectorWithCGPoint:bottomLeft],@"inputBottomRight":[CIVector vectorWithCGPoint:bottomRight]}];
    
    return [overlay imageByCompositingOverImage:image];
}

/// 坐标系转换
- (TransformCIFeatureRect)transfromImageRect:(CGRect)imageRect
                                 withFeature:(CIRectangleFeature *)rectFeature
{
    CGRect previewRect = self.frame;
    
    return [zRectangleDetectHelper transfromRealCIRectInPreviewRect:previewRect
                                                        imageRect:imageRect
                                                          topLeft:rectFeature.topLeft
                                                         topRight:rectFeature.topRight
                                                       bottomLeft:rectFeature.bottomLeft
                                                      bottomRight:rectFeature.bottomRight];
}

#pragma mark -

- (void)start
{
    [self.cameraMgr startCapture];
    
    if (_borderDetectTimeKeeper) {
        [_borderDetectTimeKeeper invalidate];
    }
    _borderDetectTimeKeeper = [NSTimer scheduledTimerWithTimeInterval:0.65f target:self selector:@selector(enableBorderDetectFrame) userInfo:nil repeats:YES];
    
    [self showGLKView:YES];
}

- (void)stop
{
    [self.cameraMgr stopCapture];
    
    if (_borderDetectTimeKeeper) {
        [_borderDetectTimeKeeper invalidate];
    }
    
    [self showGLKView:NO];
}

- (void)showGLKView:(BOOL)glkViewShowed
{
    [UIView animateWithDuration:0.1 animations:^{
        self->_glkView.alpha = glkViewShowed ? 1.0 : 0.0;
    }];
}

- (void)enableBorderDetectFrame
{
    _borderDetectOpened = YES;
}

@end
