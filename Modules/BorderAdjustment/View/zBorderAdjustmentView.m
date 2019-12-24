//
//  zBorderAdjustmentView.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/12/24.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zBorderAdjustmentView.h"
#import "zRectangleDetectHelper.h"
#import "zRectangleBorderUIParam.h"

@interface zBorderAdjustmentView ()
{
    //手指移动的顶点类型
    kRectVertexType _movedVertexType;
    //手指与顶点的平移向量
    CGVector _transformVector;
}

@property (nonatomic, strong) zRectangleBorderUIParam *borderParam;

@end

@implementation zBorderAdjustmentView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor clearColor];
        
        CAShapeLayer *layer = (CAShapeLayer *)(self.layer);
        layer.fillRule = kCAFillRuleEvenOdd;
        layer.fillColor = [UIColor colorWithRed:73/255.0
                                          green:130/255.0
                                           blue:180/255.0
                                          alpha:0.4].CGColor;//[[UIColor lightGrayColor] colorWithAlphaComponent:0.4].CGColor;
        layer.strokeColor = [UIColor whiteColor].CGColor;
        layer.lineWidth = self.borderParam.lineWidth;
    }
    return self;
}

- (zRectangleBorderUIParam *)borderParam
{
    if (!_borderParam) {
        _borderParam = [zRectangleBorderUIParam new];
    }
    return _borderParam;
}

#pragma mark -

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CAShapeLayer *maskLayer = (CAShapeLayer *)(self.layer);
    
    UIBezierPath *borderPath = [UIBezierPath new];
    borderPath.lineWidth = self.borderParam.lineWidth;
    [borderPath moveToPoint:self.rectUIQuad.topLeft];
    [borderPath addLineToPoint:self.rectUIQuad.topRight];
    [borderPath addLineToPoint:self.rectUIQuad.bottomRight];
    [borderPath addLineToPoint:self.rectUIQuad.bottomLeft];
    [borderPath closePath];
    
    CGFloat borderWidth = self.borderParam.lineWidth;
    UIBezierPath *rectPath = [UIBezierPath bezierPathWithRect:CGRectMake(-borderWidth, -borderWidth, rect.size.width + 2*borderWidth, rect.size.height + 2*borderWidth)];
    rectPath.usesEvenOddFillRule = YES;
    [rectPath appendPath:borderPath];
    maskLayer.path = rectPath.CGPath;
    
    // 绘制四个点
    [self drawCornerCircleAtPoint:self.rectUIQuad.topLeft];
    [self drawCornerCircleAtPoint:self.rectUIQuad.topRight];
    [self drawCornerCircleAtPoint:self.rectUIQuad.bottomLeft];
    [self drawCornerCircleAtPoint:self.rectUIQuad.bottomRight];
}

#pragma mark -

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    //搜索距离触点最近的顶点作为移动变化的点
    __block CGFloat shortestDistance = CGFLOAT_MAX;
    NSArray<NSValue *> *vertexes = @[[NSValue valueWithCGPoint:self.rectUIQuad.topLeft],
                                     [NSValue valueWithCGPoint:self.rectUIQuad.topRight],
                                     [NSValue valueWithCGPoint:self.rectUIQuad.bottomLeft],
                                     [NSValue valueWithCGPoint:self.rectUIQuad.bottomRight]];
    [vertexes enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGPoint vertex = [obj CGPointValue];
        CGFloat distanceToVertex = [zRectangleDetectHelper distanceFromPoint:touchPoint toPoint:vertex];
        if (distanceToVertex < shortestDistance) {
            shortestDistance = distanceToVertex;
            _movedVertexType = (kRectVertexType)idx;
            _transformVector = CGVectorMake(touchPoint.x - vertex.x,
                                            touchPoint.y - vertex.y);
        }
    }];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    CGPoint newPoint = CGPointMake(touchPoint.x - _transformVector.dx,
                                   touchPoint.y - _transformVector.dy);
    
    switch (_movedVertexType) {
        case kRectVertexTopLeft:
        {
            self.rectUIQuad.topLeft = newPoint;
        }
            break;
        case kRectVertexTopRight:
        {
            self.rectUIQuad.topRight = newPoint;
        }
            break;
        case kRectVertexBottomLeft:
        {
            self.rectUIQuad.bottomLeft = newPoint;
        }
            break;
        case kRectVertexBottomRight:
        {
            self.rectUIQuad.bottomRight = newPoint;
        }
            break;
        default:
            break;
    }
    
    [self setNeedsDisplay];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self setNeedsDisplay];
}

#pragma mark -

- (void)drawCornerCircleAtPoint:(CGPoint)point
{
    // 绘制四角按钮位置
    UIBezierPath* ovalPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(point.x, point.y) radius:self.borderParam.vertexRadius startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [[self.borderParam.lineColor colorWithAlphaComponent:0.5] setFill];
    [ovalPath fill];
    
    UIBezierPath* innerOvalPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(point.x, point.y) radius:self.borderParam.vertexRadius*3/4 startAngle:0 endAngle:M_PI * 2 clockwise:YES];
    [self.borderParam.lineColor setFill];
    [innerOvalPath fill];
}

@end
