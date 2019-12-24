//
//  UIButton+ActionBlock.m
//  JamBoHealth
//
//  Created by zyh on 16/7/29.
//  Copyright © 2016年 zyh. All rights reserved.
//

#import "UIButton+ActionBlock.h"
#import <objc/runtime.h>

@implementation UIButton (ActionBlock)

- (void)setActionBlock:(ActionBlock)actionBlock
{
    return objc_setAssociatedObject(self, @selector(actionBlock), actionBlock, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (ActionBlock)actionBlock
{
    return objc_getAssociatedObject(self, @selector(actionBlock));
}

- (void)addActionBlock:(ActionBlock)actionBlock
{
    self.actionBlock = actionBlock;
    [self addTarget:self action:@selector(btnTapped:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)btnTapped:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock(sender);
    }
}

@end
