//
//  zRectangleDetectHelper.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/11.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zRectangleDetectHelper.h"

@implementation zRectangleDetectHelper

// 选取feagure rectangles中最大的矩形
+ (CIRectangleFeature *)biggestRectangleFeatureInFeatures:(NSArray *)rectangleFeatures
{
    if ([rectangleFeatures count] == 0) {
        return nil;
    }
    
    float halfPerimiterValue = 0;
    CIRectangleFeature *biggestRectangle;
    
    for (CIRectangleFeature *rect in rectangleFeatures) {
        CGPoint p1 = rect.topLeft;
        CGPoint p2 = rect.topRight;
        CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);
        
        CGPoint p3 = rect.topLeft;
        CGPoint p4 = rect.bottomLeft;
        CGFloat height = hypotf(p3.x - p4.x, p3.y - p4.y);
        
        CGFloat currentHalfPerimiterValue = height + width;
        
        if (halfPerimiterValue < currentHalfPerimiterValue) {
            halfPerimiterValue = currentHalfPerimiterValue;
            biggestRectangle = rect;
        }
    }
    
    return biggestRectangle;
}

+ (CIImage *)imageFilteredUsingContrastOnImage:(CIImage *)image
{
    return [CIFilter filterWithName:@"CIColorControls" withInputParameters:@{@"inputContrast":@(1.1), kCIInputImageKey:image}].outputImage;
}

/// 将任意四边形转换成长方形
+ (CIImage *)correctPerspectiveForImage:(CIImage *)image
                   withRectangleFeature:(CIRectangleFeature *)rectangleFeature
{
    zQuadrilateral *quad = [zQuadrilateral qudrilateralFromRectangleFeature:rectangleFeature];
    return [[self class] imagePerspectiveCorrecttedFromImage:image withQuadrilateral:quad];
}

+ (CIImage *)imagePerspectiveCorrecttedFromImage:(CIImage *)img
                               withQuadrilateral:(zQuadrilateral *)quad
{
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary new];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:quad.topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:quad.topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:quad.bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:quad.bottomRight];
    return [img imageByApplyingFilter:@"CIPerspectiveCorrection" withInputParameters:rectangleCoordinates];
}

#pragma mark -

//需要旋转结果影像
+ (UIImage *)perspectiveImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                  withFeature:(CIRectangleFeature *)rectFeature
{
    if (!CMSampleBufferIsValid(sampleBuffer)) {
        return nil;
    }
    
//    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
//    CIImage *enhancedImage = [CIImage imageWithData:imageData];
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CIImage *enhancedImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    //从完整影像中截取目标影像
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary dictionaryWithCapacity:0];
    rectangleCoordinates[@"inputExtent"] = [CIVector vectorWithCGRect:enhancedImage.extent];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:rectFeature.topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:rectFeature.topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:rectFeature.bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:rectFeature.bottomRight];
    CIImage *resultCIImg = [enhancedImage imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:rectangleCoordinates];
    resultCIImg = [enhancedImage imageByCroppingToRect:resultCIImg.extent];
    
    //将不规则四边形转成长方形
    resultCIImg = [zRectangleDetectHelper correctPerspectiveForImage:resultCIImg withRectangleFeature:rectFeature];
    
    //转换成UIImage
    UIImage *resultImg = [UIImage imageWithCIImage:resultCIImg];
    return resultImg;
}

//不需要旋转结果影像
+ (UIImage *)otherPerspectiveImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                       withFeature:(CIRectangleFeature *)rectFeature
{
    if (!CMSampleBufferIsValid(sampleBuffer)) {
        return nil;
    }
    
    NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:sampleBuffer];
    CIImage *enhancedImage = [CIImage imageWithData:imageData];
    enhancedImage = [zRectangleDetectHelper correctPerspectiveForImage:enhancedImage
                                                  withRectangleFeature:rectFeature];
    CGSize imgSize = CGSizeMake(enhancedImage.extent.size.height,
                                enhancedImage.extent.size.width);
    UIGraphicsBeginImageContext(imgSize);
    [[UIImage imageWithCIImage:enhancedImage
                         scale:1.0
                   orientation:UIImageOrientationRight]
     drawInRect:CGRectMake(0,0, imgSize.width, imgSize.height)];
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return resultImg;
}

#pragma mark -

+ (CGFloat)distanceFromPoint:(CGPoint)startPoint
                     toPoint:(CGPoint)endPoint
{
    CGFloat deltaX = startPoint.x - endPoint.x;
    CGFloat deltaY = startPoint.y - endPoint.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY);
}

#pragma mark -



+ (zQuadrilateral *)UIQuadFromCIQuad:(zQuadrilateral *)CIQuad
                            forImage:(UIImage *)srcImg
                         inImageView:(UIImageView *)imgView
{
    if (!CIQuad || !srcImg || !imgView) {
        return nil;
    }
    
    zBorderTransformParam *transformParam = [[zBorderTransformParam alloc] initWithImage:srcImg showedInViewSized:imgView.bounds.size withMode:(kImageShowMode)imgView.contentMode];

    CGAffineTransform transform = [transformParam transformFromCIToUI];
    
    zQuadrilateral *resultQuad = [CIQuad copy];
    [resultQuad applyTransform:transform];
    return resultQuad;
}

+ (zQuadrilateral *)CIQuadFromUIQuad:(zQuadrilateral *)UIQuad
                            forImage:(UIImage *)srcImg
                         inImageView:(UIImageView *)imgView
{
    if (!UIQuad || !srcImg || !imgView) {
        return nil;
    }
    
    zBorderTransformParam *transformParam = [[zBorderTransformParam alloc] initWithImage:srcImg showedInViewSized:imgView.bounds.size withMode:(kImageShowMode)imgView.contentMode];
    
    CGAffineTransform transform = [transformParam transformFromUIToCI];
    
    zQuadrilateral *resultQuad = [UIQuad copy];
    [resultQuad applyTransform:transform];
    return resultQuad;
}

+ (zQuadrilateral *)UIQuadTransformWithCIQuad:(zQuadrilateral *)srcQuad
                                      imgSize:(CGSize)imgSize
                                  inViewSized:(CGSize)viewSize
{
    zBorderTransformParam *transformParam = [[zBorderTransformParam alloc] initWithImageSized:imgSize showedInViewSized:viewSize withMode:kImageShowModeScaleAspectFill];

    CGAffineTransform transform = [transformParam transformFromCIToUI];
    
    zQuadrilateral *resultQuad = [srcQuad copy];
    [resultQuad applyTransform:transform];
    return resultQuad;
}


@end
