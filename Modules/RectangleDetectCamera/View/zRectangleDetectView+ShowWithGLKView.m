//
//  zRectangleDetectView+ShowWithGLKView.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/25.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zRectangleDetectView+ShowWithGLKView.h"

@implementation zRectangleDetectView (ShowWithGLKView)

#pragma mark -

+ (TransformCIFeatureRect)transfromRealCIRectInPreviewRect:(CGRect)previewRect
                                                 imageRect:(CGRect)imageRect
                                                   originalRect:(TransformCIFeatureRect)originRect
{
    
    return [[self class] transfromRealRectInPreviewRect:previewRect
                                              imageRect:imageRect
                                         isUICoordinate:NO
                                           originalRect:originRect];
}

+ (TransformCIFeatureRect)transfromRealCGRectInPreviewRect:(CGRect)previewRect
                                                 imageRect:(CGRect)imageRect
                                                   originalRect:(TransformCIFeatureRect)originRect
{
    
    return [[self class] transfromRealRectInPreviewRect:previewRect
                                              imageRect:imageRect
                                         isUICoordinate:YES
                                           originalRect:originRect];
}

+ (TransformCIFeatureRect)transfromRealRectInPreviewRect:(CGRect)previewRect
                                               imageRect:(CGRect)imageRect
                                          isUICoordinate:(BOOL)isUICoordinate
                                            originalRect:(TransformCIFeatureRect)originRect
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
    featureRect.topLeft = CGPointApplyAffineTransform(originRect.topLeft, transform);
    featureRect.topRight = CGPointApplyAffineTransform(originRect.topRight, transform);
    featureRect.bottomRight = CGPointApplyAffineTransform(originRect.bottomRight, transform);
    featureRect.bottomLeft = CGPointApplyAffineTransform(originRect.bottomLeft, transform);

    return featureRect;
}

@end
