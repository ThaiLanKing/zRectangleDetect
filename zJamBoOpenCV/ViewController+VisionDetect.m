//
//  ViewController+VisionDetect.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2020/1/7.
//  Copyright © 2020 ZYH. All rights reserved.
//

#import "ViewController+VisionDetect.h"
#import "UIImage+zRectangleDetect.h"
#import "zBorderAdjustmentViewController.h"

@import Vision;

@implementation ViewController (VisionDetect)

- (void)detectRectInImage:(UIImage *)srcImg
{
    if (@available(iOS 11.0, *)) {
        VNDetectRectanglesRequest *detectRectsRequest = [[VNDetectRectanglesRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
            if (error) {
                NSLog(@"detectRectsRequest error : %@", error.description);
                return;
            }
            
            NSMutableArray *rects = [NSMutableArray arrayWithCapacity:0];
            for (VNRectangleObservation *rectObservation in request.results) {
                zQuadrilateral *CIQuad = [[zQuadrilateral alloc] init];
                CIQuad.topLeft = rectObservation.topLeft;
                CIQuad.topRight = rectObservation.topRight;
                CIQuad.bottomLeft = rectObservation.bottomLeft;
                CIQuad.bottomRight = rectObservation.bottomRight;
                [rects addObject:CIQuad];
            }
            
            zQuadrilateral *biggestQuad = [zQuadrilateral biggestQuadrilateralInQuads:rects];
            
            if (biggestQuad) {
                //Vision的坐标系是（0-1），需要乘以宽高，才是实际坐标
                CIImage *srcCIImg = [UIImage zCIImageFromUIImage:srcImg];
                CGAffineTransform scaleTransform = CGAffineTransformMakeScale(srcCIImg.extent.size.width, srcCIImg.extent.size.height);
                [biggestQuad applyTransform:scaleTransform];
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                zBorderAdjustmentViewController *dstVC = [[zBorderAdjustmentViewController alloc] init];
                dstVC.srcImg = srcImg;
                dstVC.CIQuad = biggestQuad;
                [dstVC setImageShowMode:kImageShowModeScaleAspectFit];
                [self.navigationController pushViewController:dstVC animated:YES];
            });
        }];
        detectRectsRequest.minimumAspectRatio = 0.2f;
        detectRectsRequest.minimumConfidence = 0.8f;
        detectRectsRequest.maximumObservations = 0;
        detectRectsRequest.quadratureTolerance = 40.0f;
        
        VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCIImage:[UIImage zCIImageFromUIImage:srcImg] options:@{}];
        NSError *error;
        [handler performRequests:@[detectRectsRequest] error:&error];
        if (error) {
            NSLog(@"vision detect error : %@", error.description);
        }
    }
}

@end
