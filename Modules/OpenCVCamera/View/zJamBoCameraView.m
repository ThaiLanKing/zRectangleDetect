//
//  zJamBoCameraView.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/9/26.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zJamBoCameraView.h"

@interface zJamBoCameraView ()

@property (nonatomic, strong) UIView *previewLayerView;
@property (nonatomic, strong) UIButton *torchBtn;
@property (nonatomic, strong) UIButton *takePhotoBtn;

@end

@implementation zJamBoCameraView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor whiteColor];
        
        [self addSubview:self.previewLayerView];
        [self addSubview:self.torchBtn];
        [self addSubview:self.takePhotoBtn];
        
        [self.torchBtn makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(10);
            make.left.equalTo(self).offset(15);
            make.height.equalTo(60);
            make.width.equalTo(100);
        }];
        
        [self.takePhotoBtn makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.equalTo(70);
            make.centerX.equalTo(self);
            make.bottom.equalTo(self).offset(-40);
        }];
    }
    return self;
}

#pragma mark -

- (UIButton *)torchBtn
{
    if (!_torchBtn) {
        _torchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_torchBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
        [_torchBtn setTitle:@"打开手电筒" forState:UIControlStateNormal];
    }
    return _torchBtn;
}

- (UIView *)previewLayerView
{
    if (!_previewLayerView) {
        CGFloat width = [UIScreen mainScreen].bounds.size.width;
        _previewLayerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 720)];
    }
    return _previewLayerView;
}

- (UIButton *)takePhotoBtn
{
    if (!_takePhotoBtn) {
        _takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *iconImg = [UIImage imageNamed:@"btn_takephotos"];
        [_takePhotoBtn setBackgroundImage:iconImg forState:UIControlStateNormal];
    }
    return _takePhotoBtn;
}

#pragma mark -

- (void)setTorchOn:(BOOL)torchOn
{
    _torchOn = torchOn;
    
    NSString *title = torchOn ? @"关闭手电筒" : @"打开手电筒";
    [self.torchBtn setTitle:title forState:UIControlStateNormal];
}

@end
