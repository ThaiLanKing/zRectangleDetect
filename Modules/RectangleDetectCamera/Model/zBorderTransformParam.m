//
//  zBorderTransformParam.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2020/1/2.
//  Copyright © 2020 ZYH. All rights reserved.
//

#import "zBorderTransformParam.h"
#import "UIImage+zRectangleDetect.h"

@interface zBorderTransformParam ()

@property (nonatomic, assign) CGAffineTransform orientationTransform;
@property (nonatomic, assign) CGAffineTransform coordinateTransform;
@property (nonatomic, assign) CGAffineTransform scaleTransform;
@property (nonatomic, assign) CGAffineTransform centerAlignTransform;

@end

@implementation zBorderTransformParam

- (instancetype)initWithImage:(UIImage *)srcImg
            showedInViewSized:(CGSize)viewSize
                     withMode:(kImageShowMode)showMode
{
    if (self = [self initWithImageSized:srcImg.size
                      showedInViewSized:viewSize
                               withMode:showMode]) {
        self.orientationTransform = [srcImg zCIOrientationCorrectTransform];
    }
    return self;
}

- (instancetype)initWithImageSized:(CGSize)imgSize
                 showedInViewSized:(CGSize)viewSize
                          withMode:(kImageShowMode)showMode
{
    if (self = [super init]) {
        CGSize imgScale = [[self class] scaleSizeForImgSized:imgSize showedInViewSized:viewSize withShowMode:showMode];
        
        self.orientationTransform = CGAffineTransformIdentity;
        self.coordinateTransform = [[self class] coordinateTransformForImgSized:imgSize];
        self.scaleTransform = CGAffineTransformMakeScale(imgScale.width, imgScale.height);
        self.centerAlignTransform = [[self class] centerAlignTransformForImgSized:imgSize showedInViewSized:viewSize withShowMode:showMode];
    }
    return self;
}

- (CGAffineTransform)transformFromCIToUI
{
    CGAffineTransform resultTransform = CGAffineTransformIdentity;
    resultTransform = CGAffineTransformConcat(resultTransform, self.orientationTransform);
    resultTransform = CGAffineTransformConcat(resultTransform, self.coordinateTransform);
    resultTransform = CGAffineTransformConcat(resultTransform, self.scaleTransform);
    resultTransform = CGAffineTransformConcat(resultTransform, self.centerAlignTransform);
    return resultTransform;
}

- (CGAffineTransform)transformFromUIToCI
{
    CGAffineTransform imgTransform = [self transformFromCIToUI];
    imgTransform = CGAffineTransformInvert(imgTransform);
    return imgTransform;
}

#pragma mark -
/** 坐标系切换*/
+ (CGAffineTransform)coordinateTransformForImgSized:(CGSize)imgSize
{
    CGAffineTransform transform = CGAffineTransformMakeScale(1.0f, -1.0f);
    transform = CGAffineTransformTranslate(transform, 0, -imgSize.height);
    return transform;
}

+ (CGSize)scaleSizeForImgSized:(CGSize)imgSize
             showedInViewSized:(CGSize)viewSize
                  withShowMode:(kImageShowMode)showMode
{
    CGSize imgScale = CGSizeMake(1.0f, 1.0f);
    CGFloat sx = viewSize.width / imgSize.width;
    CGFloat sy = viewSize.height / imgSize.height;
    
    switch (showMode) {
        case kImageShowModeScaleAspectFit:
        {
            CGFloat scale = MIN(sx, sy);
            imgScale = CGSizeMake(scale, scale);
        }
            break;
        case kImageShowModeScaleAspectFill:
        {
            CGFloat scale = MAX(sx, sy);
            imgScale = CGSizeMake(scale, scale);
        }
            break;
        case kImageShowModeScaleToFill:
        {
            imgScale = CGSizeMake(sx, sy);
        }
            break;
            
        default:
            break;
    }
    return imgScale;
}

+ (CGAffineTransform)centerAlignTransformForImgSized:(CGSize)imgSize
                                   showedInViewSized:(CGSize)viewSize
                                        withShowMode:(kImageShowMode)showMode
{
    CGSize imgScale = [[self class] scaleSizeForImgSized:imgSize showedInViewSized:viewSize withShowMode:showMode];
    
    CGFloat offsetX = (viewSize.width - imgSize.width * imgScale.width)/2.0f;
    CGFloat offsetY = (viewSize.height - imgSize.height * imgScale.height)/2.0f;
    
    CGAffineTransform transform = CGAffineTransformMakeTranslation(offsetX, offsetY);
    return transform;
}

@end
