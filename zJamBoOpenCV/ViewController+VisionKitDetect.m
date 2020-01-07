//
//  ViewController+VisionKitDetect.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2020/1/7.
//  Copyright © 2020 ZYH. All rights reserved.
//

#import "ViewController+VisionKitDetect.h"

@import Vision;

@implementation ViewController (VisionKitDetect)

- (void)VNDocumentScan
{
    if (@available(iOS 13.0, *)) {
        VNDocumentCameraViewController *scanVC = [[VNDocumentCameraViewController alloc] init];
        scanVC.delegate = self;
        [self presentViewController:scanVC animated:YES completion:nil];
    }
    else {
        NSLog(@"系统版本低于iOS13，不可使用");
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"系统版本低于iOS13，不可用！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancelAction];
        [self presentViewController:alertVC animated:YES completion:nil];
    }
}

#pragma mark - VNDocumentCameraViewControllerDelegate

- (void)documentCameraViewController:(VNDocumentCameraViewController *)controller didFinishWithScan:(VNDocumentCameraScan *)scan
API_AVAILABLE(ios(13.0)) {
    for (int i = 0; i < scan.pageCount; ++i) {
        UIImage *img = [scan imageOfPageAtIndex:i];
        NSLog(@"scan img : %d, title : %@", i,  scan.title);
        
        [self recognizeTextInImage:img];
    }
}

- (void)documentCameraViewControllerDidCancel:(VNDocumentCameraViewController *)controller
API_AVAILABLE(ios(13.0)) {
    NSLog(@"scan cancel");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentCameraViewController:(VNDocumentCameraViewController *)controller didFailWithError:(NSError *)error
API_AVAILABLE(ios(13.0)) {
    NSLog(@"scan error : %@", error.description);
}

- (void)recognizeTextInImage:(UIImage *)srcImg
{
    if (@available(iOS 13.0, *)) {
        VNRecognizeTextRequest *request = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
            NSLog(@"request : %d", (int)request.results.count);
            for (VNRecognizedTextObservation *obj in request.results) {
                NSLog(@"reg text : %@", [obj performSelector:@selector(text)]);
            }
        }];
        request.minimumTextHeight = 0.03125;
        request.customWords = @[@"华哥", @"研发"];
        request.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
        request.recognitionLanguages = @[@"zh-CN", @"en-US"];
        request.usesLanguageCorrection = YES;
        
        CGImageRef cgImg = srcImg.CGImage;
        VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:cgImg options:@{}];
        NSError *error;
        [handler performRequests:@[request] error:&error];
        
        if (error) {
            NSLog(@"recognize error : %@", error.description);
        }
    }
}


@end
