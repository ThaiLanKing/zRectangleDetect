//
//  zRectangleBorderUIParam.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/23.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zRectangleBorderUIParam.h"

@implementation zRectangleBorderUIParam

- (instancetype)init
{
    if (self = [super init]) {
        _lineColor = [UIColor colorWithWhite:1.0 alpha:0.6];
        _lineWidth = 1.5f;
        _vertexRadius = 6.0f;
    }
    return self;
}

@end
