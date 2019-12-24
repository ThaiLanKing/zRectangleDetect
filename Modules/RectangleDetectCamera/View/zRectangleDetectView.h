//
//  zRectangleDetectView.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/10.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface zRectangleDetectView : UIView

/// 开始捕获视图
- (void)start;
/// 结束视图捕获
- (void)stop;

@end

NS_ASSUME_NONNULL_END
