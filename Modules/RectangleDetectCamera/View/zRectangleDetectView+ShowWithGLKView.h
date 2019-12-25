//
//  zRectangleDetectView+ShowWithGLKView.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/25.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zRectangleDetectView.h"

NS_ASSUME_NONNULL_BEGIN

typedef struct CIFeatureRect {
    CGPoint topLeft;
    CGPoint topRight;
    CGPoint bottomRight;
    CGPoint bottomLeft;
}TransformCIFeatureRect;

@interface zRectangleDetectView (ShowWithGLKView)

#pragma mark -

+ (TransformCIFeatureRect)transfromRealCIRectInPreviewRect:(CGRect)previewRect
                                                 imageRect:(CGRect)imageRect
                                              originalRect:(TransformCIFeatureRect)originRect;

+ (TransformCIFeatureRect)transfromRealCGRectInPreviewRect:(CGRect)previewRect
                                                 imageRect:(CGRect)imageRect
                                              originalRect:(TransformCIFeatureRect)originRect;

@end

NS_ASSUME_NONNULL_END
