//
//  zJamBoCameraView.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/9/26.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface zJamBoCameraView : UIView

@property (nonatomic, strong, readonly) UIView *previewLayerView;
@property (nonatomic, strong, readonly) UIButton *torchBtn;
@property (nonatomic, strong, readonly) UIButton *takePhotoBtn;

@property (nonatomic, assign) BOOL torchOn;

@end

NS_ASSUME_NONNULL_END
