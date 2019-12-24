//
//  zRectangleDetectHelper.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/11.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "zQuadrilateral.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct CIFeatureRect {
    CGPoint topLeft;
    CGPoint topRight;
    CGPoint bottomRight;
    CGPoint bottomLeft;
}TransformCIFeatureRect;

typedef NS_ENUM(NSUInteger, kRectVertexType) {
    kRectVertexTopLeft,
    kRectVertexTopRight,
    kRectVertexBottomLeft,
    kRectVertexBottomRight,
};

@interface zRectangleDetectHelper : NSObject

+ (CIRectangleFeature *)biggestRectangleFeatureInFeatures:(NSArray *)rectangleFeatures;

+ (CIImage *)imageFilteredUsingContrastOnImage:(CIImage *)image;

+ (CIImage *)correctPerspectiveForImage:(CIImage *)image
                   withRectangleFeature:(CIRectangleFeature *)rectangleFeature;

+ (CIImage *)imagePerspectiveCorrecttedFromImage:(CIImage *)img
                               withQuadrilateral:(zQuadrilateral *)quad;

+ (TransformCIFeatureRect)transformedCoordinateFromFeature:(CIRectangleFeature *)rectFeature
                                               withImgSize:(CGSize)imgSize
                                                 inPreview:(UIView *)preview;


+ (UIImage *)perspectiveImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                  withFeature:(CIRectangleFeature *)rectFeature;

+ (UIImage *)otherPerspectiveImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                       withFeature:(CIRectangleFeature *)rectFeature;

#pragma mark -

+ (TransformCIFeatureRect)transfromRealCIRectInPreviewRect:(CGRect)previewRect
                                                 imageRect:(CGRect)imageRect
                                                   topLeft:(CGPoint)topLeft
                                                  topRight:(CGPoint)topRight
                                                bottomLeft:(CGPoint)bottomLeft
                                               bottomRight:(CGPoint)bottomRight;

+ (TransformCIFeatureRect)transfromRealCGRectInPreviewRect:(CGRect)previewRect
                                                 imageRect:(CGRect)imageRect
                                                   topLeft:(CGPoint)topLeft
                                                  topRight:(CGPoint)topRight
                                                bottomLeft:(CGPoint)bottomLeft
                                               bottomRight:(CGPoint)bottomRight;

#pragma mark -

+ (CGFloat)distanceFromPoint:(CGPoint)startPoint
                     toPoint:(CGPoint)endPoint;

@end

NS_ASSUME_NONNULL_END
