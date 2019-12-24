//
//  UIButton+ActionBlock.h
//  JamBoHealth
//
//  Created by zyh on 16/7/29.
//  Copyright © 2016年 zyh. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ActionBlock)(UIButton *sender);

@interface UIButton (ActionBlock)

/** 不能直接赋值，使用addActionBlock方法*/
@property (nonatomic, copy) ActionBlock actionBlock;

- (void)addActionBlock:(ActionBlock)actionBlock;

@end
