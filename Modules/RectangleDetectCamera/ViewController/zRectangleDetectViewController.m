//
//  zRectangleDetectViewController.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/10.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zRectangleDetectViewController.h"
#import "zRectangleDetectView.h"
#import "zRectangleDetectCameraView.h"
#import "zBorderAdjustmentViewController.h"

@interface zRectangleDetectViewController ()

@property (nonatomic, strong) zRectangleDetectView *rectangleDetectView;

@property (nonatomic, strong) zRectangleDetectCameraView *rectangleCameraView;

@end

@implementation zRectangleDetectViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Rectangle Detector";
    
    [self initView];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
//    [self.rectangleDetectView start];
    [self.rectangleCameraView start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.rectangleCameraView stop];
}

#pragma mark -

- (void)initView
{
//    _rectangleDetectView = [[zRectangleDetectView alloc] init];
//    [self.view addSubview:self.rectangleDetectView];
//
//    [self.rectangleDetectView makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self.view);
//    }];
    
    _rectangleCameraView = [[zRectangleDetectCameraView alloc] init];
    @weakify(self);
    [_rectangleCameraView.takePhotoBtn addActionBlock:^(UIButton *sender) {
        @strongify(self);
//        [self.rectangleCameraView stop];
        [self.rectangleCameraView captureImage:^(UIImage * _Nonnull detectedImg) {
            
        }];
    }];
    _rectangleCameraView.scanRectangleCompleteBlock = ^(UIImage * _Nonnull srcImg, CIRectangleFeature * _Nonnull rectFeature) {
        @strongify(self);
        zBorderAdjustmentViewController *dstVC = [[zBorderAdjustmentViewController alloc] init];
        dstVC.srcImg = srcImg;
        dstVC.scannedRectFeature = rectFeature;
        [self.navigationController pushViewController:dstVC animated:YES];
    };
    [self.view addSubview:self.rectangleCameraView];
    
    [self.rectangleCameraView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

@end
