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
#import "UIImageView+zRectangleDetect.h"
#import "UIImage+zRectangleDetect.h"

NS_ASSUME_NONNULL_BEGIN

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

+ (UIImage *)perspectiveImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                  withFeature:(CIRectangleFeature *)rectFeature;

+ (UIImage *)otherPerspectiveImageFromSampleBuffer:(CMSampleBufferRef)sampleBuffer
                                       withFeature:(CIRectangleFeature *)rectFeature;

#pragma mark -

+ (CGFloat)distanceFromPoint:(CGPoint)startPoint
                     toPoint:(CGPoint)endPoint;

#pragma mark -

+ (zQuadrilateral *)UIQuadFromCIQuad:(zQuadrilateral *)CIQuad
                            forImage:(UIImage *)srcImg
                         inImageView:(UIImageView *)imgView;

+ (zQuadrilateral *)CIQuadFromUIQuad:(zQuadrilateral *)UIQuad
                            forImage:(UIImage *)srcImg
                         inImageView:(UIImageView *)imgView;


+ (zQuadrilateral *)UIQuadTransformWithCIQuad:(zQuadrilateral *)srcQuad
                                      imgSize:(CGSize)imgSize
                                  inViewSized:(CGSize)viewSize;

@end

NS_ASSUME_NONNULL_END
