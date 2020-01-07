//
//  zQuadrilateral.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/23.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zQuadrilateral.h"
#import "zRectangleDetectHelper.h"

#define pointRotatedAroundAnchorPoint(point,anchorPoint,angle) CGPointMake((point.x-anchorPoint.x)*cos(angle) - (point.y-anchorPoint.y)*sin(angle) + anchorPoint.x, (point.x-anchorPoint.x)*sin(angle) + (point.y-anchorPoint.y)*cos(angle)+anchorPoint.y)

@implementation zQuadrilateral

#pragma mark -

- (id)copyWithZone:(NSZone *)zone
{
    zQuadrilateral *quad = [[[self class] allocWithZone:zone] init];
    quad.topLeft = self.topLeft;
    quad.topRight = self.topRight;
    quad.bottomLeft = self.bottomLeft;
    quad.bottomRight = self.bottomRight;
    
    return quad;
}

+ (instancetype)qudrilateralFromRectangleFeature:(CIRectangleFeature *)rectFeature
{
    if (!rectFeature) {
        return nil;
    }
    zQuadrilateral *quad = [zQuadrilateral new];
    quad.topLeft = rectFeature.topLeft;
    quad.topRight = rectFeature.topRight;
    quad.bottomLeft = rectFeature.bottomLeft;
    quad.bottomRight = rectFeature.bottomRight;
    return quad;
}

+ (zQuadrilateral *)biggestQuadrilateralInQuads:(NSArray<zQuadrilateral *> *)quads
{
    if ([quads count] == 0) {
        return nil;
    }
    
    float halfPerimiterValue = 0;
    zQuadrilateral *biggestRectangle;
    
    for (zQuadrilateral *rect in quads) {
        CGPoint p1 = rect.topLeft;
        CGPoint p2 = rect.topRight;
        CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);
        
        CGPoint p3 = rect.topLeft;
        CGPoint p4 = rect.bottomLeft;
        CGFloat height = hypotf(p3.x - p4.x, p3.y - p4.y);
        
        CGFloat currentHalfPerimiterValue = height + width;
        
        if (halfPerimiterValue < currentHalfPerimiterValue) {
            halfPerimiterValue = currentHalfPerimiterValue;
            biggestRectangle = rect;
        }
    }
    
    return biggestRectangle;
}

#pragma mark -

- (void)applyTransform:(CGAffineTransform)transform
{
    self.topLeft = CGPointApplyAffineTransform(self.topLeft, transform);
    self.topRight = CGPointApplyAffineTransform(self.topRight, transform);
    self.bottomLeft = CGPointApplyAffineTransform(self.bottomLeft, transform);
    self.bottomRight = CGPointApplyAffineTransform(self.bottomRight, transform);
}

- (void)applyTransforms:(NSArray<NSValue *> *)transforms
{
    for (NSValue *transformValue in transforms) {
        CGAffineTransform transform = [transformValue CGAffineTransformValue];
        [self applyTransform:transform];
    }
}

#pragma mark -

- (NSString *)description
{
    NSString *result = [NSString stringWithFormat:@"topLeft = %@, \ntopRight = %@, \nbottomLeft = %@, \nbottomRight = %@", NSStringFromCGPoint(self.topLeft), NSStringFromCGPoint(self.topRight), NSStringFromCGPoint(self.bottomLeft), NSStringFromCGPoint(self.bottomRight)];
    return result;
}

@end
