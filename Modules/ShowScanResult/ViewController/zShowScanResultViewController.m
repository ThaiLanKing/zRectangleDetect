//
//  zShowScanResultViewController.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/13.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zShowScanResultViewController.h"
#import "zRectangleDetectHelper.h"

@interface zShowScanResultViewController ()

@property (nonatomic, strong) UIImageView *resultImgView;

@end

@implementation zShowScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"扫描结果";
    
    [self initView];
    self.resultImgView.image = self.resultImg;
}

- (void)initView
{
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.resultImgView];
    
    [self.resultImgView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

#pragma mark -

- (UIImageView *)resultImgView
{
    if (!_resultImgView) {
        _resultImgView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        _resultImgView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _resultImgView;
}

@end
