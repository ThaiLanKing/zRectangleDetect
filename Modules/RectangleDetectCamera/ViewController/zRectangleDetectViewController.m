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

#define SwitchToGLKVersion NO

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
    if (SwitchToGLKVersion) {
        [self.rectangleDetectView start];
    }
    else {
        [self.rectangleCameraView start];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    if (SwitchToGLKVersion) {
        [self.rectangleDetectView stop];
    }
    else {
        [self.rectangleCameraView stop];
    }
}

#pragma mark -

- (void)initView
{
    if (SwitchToGLKVersion) {
        [self.view addSubview:self.rectangleDetectView];
        [self.rectangleDetectView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
    else {
        [self.view addSubview:self.rectangleCameraView];
        [self.rectangleCameraView makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.view);
        }];
    }
}

#pragma mark -

- (zRectangleDetectView *)rectangleDetectView
{
    if (!_rectangleDetectView) {
        _rectangleDetectView = [[zRectangleDetectView alloc] init];
    }
    return _rectangleDetectView;
}

- (zRectangleDetectCameraView *)rectangleCameraView
{
    if (!_rectangleCameraView) {
        _rectangleCameraView = [[zRectangleDetectCameraView alloc] init];
        @weakify(self);
        [_rectangleCameraView.takePhotoBtn addActionBlock:^(UIButton *sender) {
            @strongify(self);
            [self.rectangleCameraView startCaptureImage];
        }];
        _rectangleCameraView.scanRectangleCompleteBlock = ^(UIImage * _Nonnull srcImg, CIRectangleFeature * _Nonnull rectFeature) {
            @strongify(self);
            zBorderAdjustmentViewController *dstVC = [[zBorderAdjustmentViewController alloc] init];
            dstVC.srcImg = srcImg;
            dstVC.CIQuad = [zQuadrilateral qudrilateralFromRectangleFeature:rectFeature];
            [self.navigationController pushViewController:dstVC animated:YES];
        };
    }
    return _rectangleCameraView;
}

@end
