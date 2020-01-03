//
//  zRectangleDetectView.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/10.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

/**
 用GLKView实时显示影像，但是有个缺点：显示的影像是缩放变形的
 保留这个版本是为了留下GLKView的使用范例
 */
@interface zRectangleDetectView : UIView

/// 开始捕获视图
- (void)start;
/// 结束视图捕获
- (void)stop;

@end

NS_ASSUME_NONNULL_END
