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

#pragma mark - 坐标系转换
/**
 将CIFeature（坐标原点在左下角）的坐标转换到UIKit（坐标原点在左上角）下
 */
+ (TransformCIFeatureRect)transformedCoordinateFromFeature:(CIRectangleFeature *)rectFeature
                                               withImgSize:(CGSize)imgSize
                                                 inPreview:(UIView *)preview
{
    CGAffineTransform transform = CGAffineTransformMakeScale(1, -1);
    transform = CGAffineTransformTranslate(transform, 0, -imgSize.height);
    
    CGSize viewSize = preview.bounds.size;
    CGFloat scale = MAX(viewSize.width/imgSize.width,
                        viewSize.height/imgSize.height);
    CGFloat offsetX = (viewSize.width - imgSize.width * scale)/2.0f;
    CGFloat offsetY = (viewSize.height - imgSize.height * scale)/2.0f;
    
    CGAffineTransform scaleTransform = CGAffineTransformMakeScale(scale, scale);
    CGAffineTransform translationTransform = CGAffineTransformMakeTranslation(offsetX, offsetY);
    
    TransformCIFeatureRect featureRect;
    featureRect.topLeft = rectFeature.topLeft;
    featureRect.topRight = rectFeature.topRight;
    featureRect.bottomLeft = rectFeature.bottomLeft;
    featureRect.bottomRight = rectFeature.bottomRight;
    
    featureRect.topLeft = CGPointApplyAffineTransform(featureRect.topLeft, transform);
    featureRect.topLeft = CGPointApplyAffineTransform(featureRect.topLeft, scaleTransform);
    featureRect.topLeft = CGPointApplyAffineTransform(featureRect.topLeft, translationTransform);
    
    featureRect.topRight = CGPointApplyAffineTransform(featureRect.topRight, transform);
    featureRect.topRight = CGPointApplyAffineTransform(featureRect.topRight, scaleTransform);
    featureRect.topRight = CGPointApplyAffineTransform(featureRect.topRight, translationTransform);
    
    featureRect.bottomLeft = CGPointApplyAffineTransform(featureRect.bottomLeft, transform);
    featureRect.bottomLeft = CGPointApplyAffineTransform(featureRect.bottomLeft, scaleTransform);
    featureRect.bottomLeft = CGPointApplyAffineTransform(featureRect.bottomLeft, translationTransform);
    
    featureRect.bottomRight = CGPointApplyAffineTransform(featureRect.bottomRight, transform);
    featureRect.bottomRight = CGPointApplyAffineTransform(featureRect.bottomRight, scaleTransform);
    featureRect.bottomRight = CGPointApplyAffineTransform(featureRect.bottomRight, translationTransform);
    return featureRect;
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

+ (TransformCIFeatureRect)transfromRealCIRectInPreviewRect:(CGRect)previewRect
                                                 imageRect:(CGRect)imageRect
                                                   topLeft:(CGPoint)topLeft
                                                  topRight:(CGPoint)topRight
                                                bottomLeft:(CGPoint)bottomLeft
                                               bottomRight:(CGPoint)bottomRight
{
    
    return [[self class] md_transfromRealRectInPreviewRect:previewRect imageRect:imageRect isUICoordinate:NO topLeft:topLeft topRight:topRight bottomLeft:bottomLeft bottomRight:bottomRight];
}

+ (TransformCIFeatureRect)transfromRealCGRectInPreviewRect:(CGRect)previewRect
                                                 imageRect:(CGRect)imageRect
                                                   topLeft:(CGPoint)topLeft
                                                  topRight:(CGPoint)topRight
                                                bottomLeft:(CGPoint)bottomLeft
                                               bottomRight:(CGPoint)bottomRight
{
    
    return [[self class] md_transfromRealRectInPreviewRect:previewRect imageRect:imageRect isUICoordinate:YES topLeft:topLeft topRight:topRight bottomLeft:bottomLeft bottomRight:bottomRight];
}


+ (TransformCIFeatureRect)md_transfromRealRectInPreviewRect:(CGRect)previewRect
                                                  imageRect:(CGRect)imageRect
                                             isUICoordinate:(BOOL)isUICoordinate
                                                    topLeft:(CGPoint)topLeft
                                                   topRight:(CGPoint)topRight
                                                 bottomLeft:(CGPoint)bottomLeft
                                                bottomRight:(CGPoint)bottomRight
{
    
    // find ratio between the video preview rect and the image rect; rectangle feature coordinates are relative to the CIImage
    CGFloat deltaX = CGRectGetWidth(previewRect)/CGRectGetWidth(imageRect);
    CGFloat deltaY = CGRectGetHeight(previewRect)/CGRectGetHeight(imageRect);
    
    // transform to UIKit coordinate system
    CGAffineTransform transform = CGAffineTransformMakeTranslation(0.f, CGRectGetHeight(previewRect));
    if (!isUICoordinate) {
        transform = CGAffineTransformScale(transform, 1, -1);
    }
    // apply preview to image scaling
    transform = CGAffineTransformScale(transform, deltaX, deltaY);
        
    TransformCIFeatureRect featureRect;
    featureRect.topLeft = CGPointApplyAffineTransform(topLeft, transform);
    featureRect.topRight = CGPointApplyAffineTransform(topRight, transform);
    featureRect.bottomRight = CGPointApplyAffineTransform(bottomRight, transform);
    featureRect.bottomLeft = CGPointApplyAffineTransform(bottomLeft, transform);

    return featureRect;
}

#pragma mark -

+ (CGFloat)distanceFromPoint:(CGPoint)startPoint
                     toPoint:(CGPoint)endPoint
{
    CGFloat deltaX = startPoint.x - endPoint.x;
    CGFloat deltaY = startPoint.y - endPoint.y;
    return sqrt(deltaX*deltaX + deltaY*deltaY);
}



@end
