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
    self.borderAdjustmentView.rectUIQuad = [CIQuad UIQuadrilateralForImgSize:self.srcImg.size inViewSized:self.borderAdjustmentView.bounds.size];
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
    zQuadrilateral *ciQuad = [self.borderAdjustmentView.rectUIQuad CIQuadrilateralForImgSize:self.srcImg.size inViewSized:self.borderAdjustmentView.bounds.size];
    CIImage *enhancedImage = self.srcImg.CIImage;
    enhancedImage = [zRectangleDetectHelper imagePerspectiveCorrecttedFromImage:enhancedImage withQuadrilateral:ciQuad];
    CGSize imgSize = CGSizeMake(enhancedImage.extent.size.height,
                                enhancedImage.extent.size.width);
    UIGraphicsBeginImageContext(imgSize);
    [[UIImage imageWithCIImage:enhancedImage
                         scale:1.0
                   orientation:UIImageOrientationRight]
     drawInRect:CGRectMake(0,0, imgSize.width, imgSize.height)];
    UIImage *resultImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    zShowScanResultViewController *dstVC = [[zShowScanResultViewController alloc] init];
    dstVC.resultImg = resultImg;
    [self.navigationController pushViewController:dstVC animated:YES];
}

@end
