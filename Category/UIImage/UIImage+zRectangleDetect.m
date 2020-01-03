//
//  UIImage+zRectangleDetect.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/31.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "UIImage+zRectangleDetect.h"

@implementation UIImage (zRectangleDetect)

+ (CIImage *)zCIImageFromUIImage:(UIImage *)srcImg
{
    CIImage *srcCIImage = srcImg.CIImage;
    if (!srcCIImage) {
        if (srcImg.CGImage) {
            srcCIImage = [CIImage imageWithCGImage:srcImg.CGImage];
        }
        else {
            NSData *imgData = UIImagePNGRepresentation(srcImg);
            srcCIImage = [CIImage imageWithData:imgData];
        }
    }
    return srcCIImage;
}

#pragma mark - 矩形边框矫正（有旋转方向的图片）

- (CGFloat)zRotateAngleFromCIToUI
{
    CGFloat r;
    switch (self.imageOrientation) {
        case UIImageOrientationUp:
            r = 0;
            break;
        case UIImageOrientationDown:
            r = -1.0f;
            break;
        case UIImageOrientationLeft:
            r = 0.5;
            break;
        case UIImageOrientationRight:
            r = -0.5;
            break;
            
        default:
            r = 0;
            break;
    }
    
    return M_PI*r;
}

- (CGAffineTransform)zRotateTransformWithAngle:(CGFloat)rotateAngle
{
    CIImage *srcCIImage = [UIImage zCIImageFromUIImage:self];
    CGFloat imgWidth = srcCIImage.extent.size.width;
    CGFloat imgHeight = srcCIImage.extent.size.height;
    
    CGFloat cx = imgWidth/2.0f;
    CGFloat cy = imgHeight/2.0f;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformTranslate(transform, cx, cy);
    transform = CGAffineTransformRotate(transform, rotateAngle);
    transform = CGAffineTransformTranslate(transform, -cx, -cy);
    
    return transform;
}

- (CGAffineTransform)zCenterAlignTransformFromSize:(CGSize)srcSize
                                            toSize:(CGSize)dstSize
{
    CGFloat tx = (dstSize.width - srcSize.width)/2.0f;
    CGFloat ty = (dstSize.height - srcSize.height)/2.0f;
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(tx, ty);
    return transform;
}

/**
 * 将有旋转的图片调整到up方向
 * 从CI坐标系转换到UI坐标系
 */
- (CGAffineTransform)zCIOrientationCorrectTransform
{
    CGAffineTransform rotateTransform = ({
        CGFloat rotateAngle = [self zRotateAngleFromCIToUI];
        CGAffineTransform transform = [self zRotateTransformWithAngle:rotateAngle];
        transform;
    });
    
    CGAffineTransform translateTransform = ({
        CIImage *srcCIImage = [UIImage zCIImageFromUIImage:self];
        CGSize CIImgSize = srcCIImage.extent.size;
        CGSize imgSize = self.size;
        
        CGAffineTransform transform = [self zCenterAlignTransformFromSize:CIImgSize toSize:imgSize];
        transform;
    });
    
    CGAffineTransform result = CGAffineTransformConcat(rotateTransform, translateTransform);
    return result;
}

/**
 * 将有旋转的图片调整到up方向
 * 从UI坐标系转换到CI坐标系
 */
- (CGAffineTransform)zUIOrientationCorrectTransform
{
    CGAffineTransform rotateTransform = ({
        CGFloat rotateAngle = -[self zRotateAngleFromCIToUI];
        CGAffineTransform transform = [self zRotateTransformWithAngle:rotateAngle];
        transform;
    });
    
    CGAffineTransform translateTransform = ({
        CIImage *srcCIImage = [UIImage zCIImageFromUIImage:self];
        CGSize CIImgSize = srcCIImage.extent.size;
        CGSize imgSize = self.size;
        
        CGAffineTransform transform = [self zCenterAlignTransformFromSize:imgSize toSize:CIImgSize];
        transform;
    });
    
    CGAffineTransform result = CGAffineTransformConcat(translateTransform, rotateTransform);
    return result;
}

#pragma mark -

- (UIImage *)fixOrientation {

    // No-op if the orientation is already correct
    if (self.imageOrientation == UIImageOrientationUp) return self;

    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;

    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, self.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;

        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;

        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, self.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }

    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;

        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, self.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
            break;
    }

    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL, self.size.width, self.size.height,
                                             CGImageGetBitsPerComponent(self.CGImage), 0,
                                             CGImageGetColorSpace(self.CGImage),
                                             CGImageGetBitmapInfo(self.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.height,self.size.width), self.CGImage);
            break;

        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,self.size.width,self.size.height), self.CGImage);
            break;
    }

    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)normalizedImage {
    if (self.imageOrientation == UIImageOrientationUp) return self;

    UIGraphicsBeginImageContextWithOptions(self.size, NO, self.scale);
    [self drawInRect:(CGRect){0, 0, self.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

@end
