//
//  zQuadrilateral.h
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/23.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface zQuadrilateral : NSObject<NSCopying>

@property (nonatomic, assign) CGPoint topLeft;
@property (nonatomic, assign) CGPoint topRight;
@property (nonatomic, assign) CGPoint bottomLeft;
@property (nonatomic, assign) CGPoint bottomRight;

+ (instancetype)qudrilateralFromRectangleFeature:(CIRectangleFeature *)rectFeature;

+ (zQuadrilateral *)biggestQuadrilateralInQuads:(NSArray<zQuadrilateral *> *)quads;

- (void)applyTransform:(CGAffineTransform)transform;
- (void)applyTransforms:(NSArray<NSValue *> *)transforms;

@end

NS_ASSUME_NONNULL_END
