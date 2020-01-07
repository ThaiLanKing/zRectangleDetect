//
//  ViewController+VisionKitDetect.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2020/1/7.
//  Copyright © 2020 ZYH. All rights reserved.
//

#import "ViewController.h"

@import VisionKit;

NS_ASSUME_NONNULL_BEGIN

@interface ViewController (VisionKitDetect)<VNDocumentCameraViewControllerDelegate>

- (void)VNDocumentScan;

@end

NS_ASSUME_NONNULL_END
