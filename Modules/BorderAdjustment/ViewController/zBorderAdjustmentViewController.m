//
//  zBorderAdjustmentViewController.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/24.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zBorderAdjustmentViewController.h"
#import "zBorderAdjustmentView.h"
#import "zRectangleDetectHelper.h"
#import "zShowScanResultViewController.h"

@interface zBorderAdjustmentViewController ()

@property (nonatomic, strong) UIImageView *srcImageView;
@property (nonatomic, strong) zBorderAdjustmentView *borderAdjustmentView;

@end

@implementation zBorderAdjustmentViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫描结果";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"确认" style:UIBarButtonItemStylePlain target:self action:@selector(saveConfirmedImg)];
    
    [self initView];
    
    self.srcImageView.image = self.srcImg;
}

- (void)initView
{
    [self.view addSubview:self.srcImageView];
    [self.view addSubview:self.borderAdjustmentView];
    
    [self.srcImageView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.borderAdjustmentView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    zQuadrilateral *CIQuad = [zQuadrilateral qudrilateralFromRectangleFeature:self.scannedRectFeature];
    self.borderAdjustmentView.rectUIQuad = [zRectangleDetectHelper UIQuadFromCIQuad:CIQuad forImage:self.srcImg inImageView:self.srcImageView];
}

#pragma mark -

- (UIImageView *)srcImageView
{
    if (!_srcImageView) {
        _srcImageView = [UIImageView new];
        _srcImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _srcImageView;
}

- (zBorderAdjustmentView *)borderAdjustmentView
{
    if (!_borderAdjustmentView) {
        _borderAdjustmentView = [zBorderAdjustmentView new];
    }
    return _borderAdjustmentView;
}

#pragma mark -

- (void)saveConfirmedImg
{
    zQuadrilateral *ciQuad = [zRectangleDetectHelper CIQuadFromUIQuad:self.borderAdjustmentView.rectUIQuad forImage:self.srcImg inImageView:self.srcImageView];
    CIImage *enhancedImage = self.srcImg.CIImage;
    
    //从完整影像中截取目标影像
    NSMutableDictionary *rectangleCoordinates = [NSMutableDictionary dictionaryWithCapacity:0];
    rectangleCoordinates[@"inputExtent"] = [CIVector vectorWithCGRect:enhancedImage.extent];
    rectangleCoordinates[@"inputTopLeft"] = [CIVector vectorWithCGPoint:ciQuad.topLeft];
    rectangleCoordinates[@"inputTopRight"] = [CIVector vectorWithCGPoint:ciQuad.topRight];
    rectangleCoordinates[@"inputBottomLeft"] = [CIVector vectorWithCGPoint:ciQuad.bottomLeft];
    rectangleCoordinates[@"inputBottomRight"] = [CIVector vectorWithCGPoint:ciQuad.bottomRight];
    CIImage *resultCIImg = [enhancedImage imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:rectangleCoordinates];
    resultCIImg = [enhancedImage imageByCroppingToRect:resultCIImg.extent];
    
    //将不规则四边形转成长方形
    enhancedImage = [zRectangleDetectHelper imagePerspectiveCorrecttedFromImage:resultCIImg withQuadrilateral:ciQuad];
    
    //转换成UIImage
    UIImage *resultImg = [UIImage imageWithCIImage:enhancedImage];
    
    zShowScanResultViewController *dstVC = [[zShowScanResultViewController alloc] init];
    dstVC.resultImg = resultImg;
    [self.navigationController pushViewController:dstVC animated:YES];
}

@end
