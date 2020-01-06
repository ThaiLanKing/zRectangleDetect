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

/**
 * 将有旋转的图片调整到up方向
 * 从CI坐标系转换到UI坐标系
 */
- (CGAffineTransform)zCIOrientationCorrectTransform
{
    //旋转角度
    CGFloat rotateAngle = 0.0f;
    //坐标系调整（以原点为中心旋转后，坐标象限有变化，需要重新调整）
    CGSize coordinateTransformSize = CGSizeMake(0.0f, 0.0f);
    
    //镜像图片的处理可参考fixOrientation的代码
    switch (self.imageOrientation) {
        case UIImageOrientationUp:
        {
            rotateAngle = 0.0f;
        }
            break;
        case UIImageOrientationDown:
        {
            rotateAngle = M_PI;
            coordinateTransformSize = CGSizeMake(self.size.width, self.size.height);
        }
            break;
        case UIImageOrientationLeft:
        {
            rotateAngle = M_PI_2;
            coordinateTransformSize = CGSizeMake(self.size.width, 0);
        }
            break;
        case UIImageOrientationRight:
        {
            rotateAngle = -M_PI_2;
            coordinateTransformSize = CGSizeMake(0, self.size.height);
        }
            break;
            
        default:
            break;
    }
        
    CGAffineTransform rotateTransform = ({
        CGAffineTransform transform = CGAffineTransformMakeRotation(rotateAngle);
        transform;
    });
    
    CGAffineTransform translateTransform = ({
        CGAffineTransform transform = CGAffineTransformMakeTranslation(coordinateTransformSize.width, coordinateTransformSize.height);
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
    CGAffineTransform result = CGAffineTransformInvert([self zCIOrientationCorrectTransform]);
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
