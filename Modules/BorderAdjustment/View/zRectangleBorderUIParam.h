//
//  zRectangleBorderUIParam.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/23.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface zRectangleBorderUIParam : NSObject

@property (nonatomic, strong) UIColor *lineColor;
@property (nonatomic, assign) CGFloat lineWidth;
@property (nonatomic, assign) CGFloat vertexRadius;

@end

NS_ASSUME_NONNULL_END
