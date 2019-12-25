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

@end

NS_ASSUME_NONNULL_END
