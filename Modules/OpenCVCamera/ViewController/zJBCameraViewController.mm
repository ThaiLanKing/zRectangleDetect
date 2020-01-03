//
//  zJBCameraViewController.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/9/29.
//  Copyright © 2019 ZYH. All rights reserved.
//

#import "zJBCameraViewController.h"
#import "zCameraManager.h"
#import "zJamBoCameraView.h"
#import "zShowScanResultViewController.h"

using namespace cv;
using namespace std;

@interface zJBCameraViewController ()<CvVideoCameraDelegate>
{
    BOOL _bCaptureImg;
}

@property (nonatomic, strong) zJamBoCameraView *cameraView;
@property (nonatomic, strong) zCameraManager *cameraMgr;

@property (nonatomic, strong) CvVideoCamera *videoCamera;

@end

@implementation zJBCameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"选择影像";
    
    [self initView];
    
    self.videoCamera.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self.videoCamera start];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self.videoCamera stop];
}

- (void)initView
{
    [self.view addSubview:self.cameraView];
    [self.cameraView makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
//    if ([self.cameraMgr configSession]) {
//        self.cameraMgr.previewLayer.frame = self.cameraView.previewLayerView.bounds;
//        [self.cameraView.previewLayerView.layer addSublayer:self.cameraMgr.previewLayer];
//    }
}

#pragma mark -

- (zJamBoCameraView *)cameraView
{
    if (!_cameraView) {
        _cameraView = [[zJamBoCameraView alloc] init];
        
        @weakify(self);
        [_cameraView.torchBtn addActionBlock:^(UIButton *sender) {
            @strongify(self);
            if (self.cameraView.torchOn) {
                [self turnOffTorch];
            }
            else {
                [self turnOnTorch];
            }
        }];
        
        [_cameraView.takePhotoBtn addActionBlock:^(UIButton *sender) {
            @strongify(self);
            self->_bCaptureImg = YES;
        }];
    }
    return _cameraView;
}

- (zCameraManager *)cameraMgr
{
    if (!_cameraMgr) {
        _cameraMgr = [[zCameraManager alloc] init];
        @weakify(self);
        _cameraMgr.takePictureSuccessBlock = ^(UIImage * _Nonnull takedPicture) {
            @strongify(self);
            if (!takedPicture) {
                return;
            }
            
//            dispatch_async(dispatch_get_global_queue(0, 0), ^{
//                UIImage *previewImg = [takedPicture normalQualityResizedImage];
//                PCCaseImageItem *imgItem = [[PCCaseImageItem alloc] init];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    imgItem.previewImage = previewImg;
//                    [self.selectedPhotos addObject:imgItem];
//                    self.cameraView.takedPhotos = self.selectedPhotos;
//                });
//                UIImage *highQualityImg = [takedPicture highQualityResizedImage];
//                [imgItem saveOriginalImage:highQualityImg];
//            });
        };
    }
    return _cameraMgr;
}

#pragma mark -

- (void)turnOnTorch
{
    if (self.cameraMgr.torchMode == AVCaptureTorchModeOff) {
        [self.cameraMgr setTorchMode:AVCaptureTorchModeOn];
        self.cameraView.torchOn = YES;
    }
}

- (void)turnOffTorch
{
    if (self.cameraMgr.torchMode == AVCaptureTorchModeOn) {
        [self.cameraMgr setTorchMode:AVCaptureTorchModeOff];
        self.cameraView.torchOn = NO;
    }
}

#pragma mark - OpenCV

- (CvVideoCamera *)videoCamera
{
    if (!_videoCamera) {
        _videoCamera = [[CvVideoCamera alloc] initWithParentView:self.cameraView.previewLayerView];
        _videoCamera.defaultAVCaptureDevicePosition = AVCaptureDevicePositionBack;
        _videoCamera.defaultAVCaptureSessionPreset = AVCaptureSessionPresetHigh;
        _videoCamera.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
        _videoCamera.defaultFPS = 18.0f;
        _videoCamera.grayscaleMode = NO;
    }
    return _videoCamera;
}

#pragma mark - CvVideoCameraDelegate

- (void)processImage:(cv::Mat &)image
{
    Mat src_gray, filtered, edges, dilated_edges;
    
    //获取灰度图像
    cvtColor(image, src_gray, COLOR_BGR2GRAY);
    //滤波，模糊处理，消除某些背景干扰信息
    blur(src_gray, filtered, cv::Size(3, 3));
    //腐蚀操作，消除某些背景干扰信息
    erode(filtered, filtered, Mat(), cv::Point(-1, -1), 3, BORDER_REPLICATE, 1);
    
    int thresh = 30;
    //边缘检测
    Canny(filtered, edges, thresh, thresh*3, 3);
    //膨胀操作，尽量使边缘闭合
    dilate(edges, dilated_edges, Mat(), cv::Point(-1, -1), 3, BORDER_REPLICATE, 1);
    
    vector< vector<cv::Point> > contours, squares, hulls;
    //寻找边框
    findContours(dilated_edges, contours, RETR_LIST, CHAIN_APPROX_SIMPLE);
    
    vector<cv::Point> hull, approx;
    for (size_t i = 0; i < contours.size(); ++i) {
        //边框的凸包
        convexHull(contours[i], hull);
        //多边形拟合凸包边框(此时的拟合的精度较低)
        approxPolyDP(Mat(hull), approx, arcLength(Mat(hull), true)*0.02, true);
        //筛选出面积大于某一阈值的，且四边形的各个角度都接近直角的凸四边形
        if (approx.size() == 4 &&
            fabs(contourArea(Mat(approx))) > 40000 &&
            isContourConvex(Mat(approx)))
        {
            double maxCosine = 0;
            for (int j = 2; j < 5; j++) {
                double cosine = fabs(getAngle(approx[j%4], approx[j-2], approx[j-1]));
                maxCosine = MAX(maxCosine, cosine);
            }
            //角度大概72度
            if (maxCosine < 0.3) {
                squares.push_back(approx);
                hulls.push_back(hull);
            }
        }
    }
    
    //找出外接矩形最大的四边形
    int idex = findLargestSquare(squares);
    if (idex == -1) return;
    vector<cv::Point> largest_square = squares[idex];
    
    //找到这个最大的四边形对应的凸边框，再次进行多边形拟合，此次精度较高，拟合的结果可能是大于4条边的多边形
    //接下来的操作，主要是为了解决，证件有圆角时检测到的四个顶点的连线会有切边的问题
    hull = hulls[idex];
    approxPolyDP(Mat(hull), approx, 3, true);
    vector<cv::Point> newApprox;
    double maxL = arcLength(Mat(approx), true)*0.02;
    //找到高精度拟合时得到的顶点中 距离小于 低精度拟合得到的四个顶点maxL的顶点，排除部分顶点的干扰
    for (cv::Point p : approx) {
        if (!(getSpacePointToPoint(p, largest_square[0]) > maxL &&
              getSpacePointToPoint(p, largest_square[1]) > maxL &&
              getSpacePointToPoint(p, largest_square[2]) > maxL &&
              getSpacePointToPoint(p, largest_square[3]) > maxL))
        {
            newApprox.push_back(p);
        }
    }
    //找到剩余顶点连线中，边长大于 2 * maxL的四条边作为四边形物体的四条边
    vector<Vec4i> lines;
    for (int i = 0; i < newApprox.size(); ++i) {
        cv::Point p1 = newApprox[i];
        cv::Point p2 = newApprox[(i+1) % newApprox.size()];
        if (getSpacePointToPoint(p1, p2) > 2 * maxL) {
            lines.push_back(Vec4i(p1.x, p1.y, p2.x,p2.y));
        }
    }
    
    //计算出这四条边中 相邻两条边的交点，即物体的四个顶点
    vector<cv::Point2f> cornors1;
    for (int i = 0; i < lines.size(); ++i) {
        cv::Point cornor = computeIntersect(lines[i],lines[(i+1)%lines.size()]);
        cornors1.push_back(cornor);
    }
    
    //绘制出四条边
    for (int i = 0; i < cornors1.size(); ++i) {
        //Scalar 参数是BGRA
        line(image, cornors1[i], cornors1[(i+1)%cornors1.size()], Scalar(0,0,0,100), 3);
    }
    
    if (_bCaptureImg) {
        _bCaptureImg = NO;
        
#ifdef DEBUG //测试
        
        sortCorners(cornors1);
        for (int i = 0; i < cornors1.size(); ++i) {
            cv::Point2f point = cornors1[i];
            NSLog(@"cornors1 point x : %.2f, y : %.2f", point.x, point.y);
        }
        
#endif
        
        UIImage *result1 = cropImgFromCorners(image, cornors1);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            zShowScanResultViewController *dstVC = [[zShowScanResultViewController alloc] init];
            dstVC.resultImg = result1;
            [self.navigationController pushViewController:dstVC animated:YES];
        });
        
        return;
    }
}

#pragma mark - zyh

- (UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {//可以根据这个决定使用哪种
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}

+ (UIImage *)testCropImg:(UIImage *)srcImg
{
    Mat image;
    UIImageToMat(srcImg, image);
    
    Mat src_gray, filtered, edges, dilated_edges;
    
    //获取灰度图像
    cvtColor(image, src_gray, COLOR_BGR2GRAY);
    //滤波，模糊处理，消除某些背景干扰信息
    blur(src_gray, filtered, cv::Size(3, 3));
    //腐蚀操作，消除某些背景干扰信息
    erode(filtered, filtered, Mat(), cv::Point(-1, -1), 3, BORDER_REPLICATE, 1);
    
    int thresh = 30;
    //边缘检测
    Canny(filtered, edges, thresh, thresh*3, 3);
    //膨胀操作，尽量使边缘闭合
    dilate(edges, dilated_edges, Mat(), cv::Point(-1, -1), 3, BORDER_REPLICATE, 1);
    
    vector< vector<cv::Point> > contours, squares, hulls;
    //寻找边框
    findContours(dilated_edges, contours, RETR_LIST, CHAIN_APPROX_SIMPLE);
    
    vector<cv::Point> hull, approx;
    for (size_t i = 0; i < contours.size(); ++i) {
        //边框的凸包
        convexHull(contours[i], hull);
        //多边形拟合凸包边框(此时的拟合的精度较低)
        approxPolyDP(Mat(hull), approx, arcLength(Mat(hull), true)*0.02, true);
        //筛选出面积大于某一阈值的，且四边形的各个角度都接近直角的凸四边形
        if (approx.size() == 4 &&
            fabs(contourArea(Mat(approx))) > 40000 &&
            isContourConvex(Mat(approx)))
        {
            double maxCosine = 0;
            for (int j = 2; j < 5; j++) {
                double cosine = fabs(getAngle(approx[j%4], approx[j-2], approx[j-1]));
                maxCosine = MAX(maxCosine, cosine);
            }
            //角度大概72度
            if (maxCosine < 0.3) {
                squares.push_back(approx);
                hulls.push_back(hull);
            }
        }
    }
    
    //找出外接矩形最大的四边形
    int idex = findLargestSquare(squares);
    if (idex == -1) return nil;
    vector<cv::Point> largest_square = squares[idex];
    
    //找到这个最大的四边形对应的凸边框，再次进行多边形拟合，此次精度较高，拟合的结果可能是大于4条边的多边形
    //接下来的操作，主要是为了解决，证件有圆角时检测到的四个顶点的连线会有切边的问题
    hull = hulls[idex];
    approxPolyDP(Mat(hull), approx, 3, true);
    vector<cv::Point> newApprox;
    double maxL = arcLength(Mat(approx), true)*0.02;
    //找到高精度拟合时得到的顶点中 距离小于 低精度拟合得到的四个顶点maxL的顶点，排除部分顶点的干扰
    for (cv::Point p : approx) {
        if (!(getSpacePointToPoint(p, largest_square[0]) > maxL &&
              getSpacePointToPoint(p, largest_square[1]) > maxL &&
              getSpacePointToPoint(p, largest_square[2]) > maxL &&
              getSpacePointToPoint(p, largest_square[3]) > maxL))
        {
            newApprox.push_back(p);
        }
    }
    //找到剩余顶点连线中，边长大于 2 * maxL的四条边作为四边形物体的四条边
    vector<Vec4i> lines;
    for (int i = 0; i < newApprox.size(); ++i) {
        cv::Point p1 = newApprox[i];
        cv::Point p2 = newApprox[(i+1) % newApprox.size()];
        if (getSpacePointToPoint(p1, p2) > 2 * maxL) {
            lines.push_back(Vec4i(p1.x, p1.y, p2.x,p2.y));
        }
    }
    
    //计算出这四条边中 相邻两条边的交点，即物体的四个顶点
    vector<cv::Point2f> cornors1;
    for (int i = 0; i < lines.size(); ++i) {
        cv::Point cornor = computeIntersect(lines[i],lines[(i+1)%lines.size()]);
        cornors1.push_back(cornor);
    }
    
    UIImage *result1 = cropImgFromCorners(image, cornors1);
    
    return result1;
}

+ (zQuadrilateral *)scannedRectangleFromImg:(UIImage *)srcImg
{
    Mat image;
    UIImageToMat(srcImg, image);
    
    Mat src_gray, filtered, edges, dilated_edges;
    
    //获取灰度图像
    cvtColor(image, src_gray, COLOR_BGR2GRAY);
    //滤波，模糊处理，消除某些背景干扰信息
    blur(src_gray, filtered, cv::Size(3, 3));
    //腐蚀操作，消除某些背景干扰信息
    erode(filtered, filtered, Mat(), cv::Point(-1, -1), 3, BORDER_REPLICATE, 1);
    
    int thresh = 30;
    //边缘检测
    Canny(filtered, edges, thresh, thresh*3, 3);
    //膨胀操作，尽量使边缘闭合
    dilate(edges, dilated_edges, Mat(), cv::Point(-1, -1), 3, BORDER_REPLICATE, 1);
    
    vector< vector<cv::Point> > contours, squares, hulls;
    //寻找边框
    findContours(dilated_edges, contours, RETR_LIST, CHAIN_APPROX_SIMPLE);
    
    vector<cv::Point> hull, approx;
    for (size_t i = 0; i < contours.size(); ++i) {
        //边框的凸包
        convexHull(contours[i], hull);
        //多边形拟合凸包边框(此时的拟合的精度较低)
        approxPolyDP(Mat(hull), approx, arcLength(Mat(hull), true)*0.02, true);
        //筛选出面积大于某一阈值的，且四边形的各个角度都接近直角的凸四边形
        if (approx.size() == 4 &&
            fabs(contourArea(Mat(approx))) > 40000 &&
            isContourConvex(Mat(approx)))
        {
            double maxCosine = 0;
            for (int j = 2; j < 5; j++) {
                double cosine = fabs(getAngle(approx[j%4], approx[j-2], approx[j-1]));
                maxCosine = MAX(maxCosine, cosine);
            }
            //角度大概72度
            if (maxCosine < 0.3) {
                squares.push_back(approx);
                hulls.push_back(hull);
            }
        }
    }
    
    //找出外接矩形最大的四边形
    int idex = findLargestSquare(squares);
    if (idex == -1) return nil;
    vector<cv::Point> largest_square = squares[idex];
    
    //找到这个最大的四边形对应的凸边框，再次进行多边形拟合，此次精度较高，拟合的结果可能是大于4条边的多边形
    //接下来的操作，主要是为了解决，证件有圆角时检测到的四个顶点的连线会有切边的问题
    hull = hulls[idex];
    approxPolyDP(Mat(hull), approx, 3, true);
    vector<cv::Point> newApprox;
    double maxL = arcLength(Mat(approx), true)*0.02;
    //找到高精度拟合时得到的顶点中 距离小于 低精度拟合得到的四个顶点maxL的顶点，排除部分顶点的干扰
    for (cv::Point p : approx) {
        if (!(getSpacePointToPoint(p, largest_square[0]) > maxL &&
              getSpacePointToPoint(p, largest_square[1]) > maxL &&
              getSpacePointToPoint(p, largest_square[2]) > maxL &&
              getSpacePointToPoint(p, largest_square[3]) > maxL))
        {
            newApprox.push_back(p);
        }
    }
    //找到剩余顶点连线中，边长大于 2 * maxL的四条边作为四边形物体的四条边
    vector<Vec4i> lines;
    for (int i = 0; i < newApprox.size(); ++i) {
        cv::Point p1 = newApprox[i];
        cv::Point p2 = newApprox[(i+1) % newApprox.size()];
        if (getSpacePointToPoint(p1, p2) > 2 * maxL) {
            lines.push_back(Vec4i(p1.x, p1.y, p2.x,p2.y));
        }
    }
    
    //计算出这四条边中 相邻两条边的交点，即物体的四个顶点
    vector<cv::Point2f> cornors1;
    for (int i = 0; i < lines.size(); ++i) {
        cv::Point cornor = computeIntersect(lines[i],lines[(i+1)%lines.size()]);
        cornors1.push_back(cornor);
    }
    
    //绘制出四条边
    for (int i = 0; i < cornors1.size(); ++i) {
        //Scalar 参数是BGRA
        line(image, cornors1[i], cornors1[(i+1)%cornors1.size()], Scalar(0,0,0,100), 3);
    }
    
    vector<cv::Point2f> corners = cornors1;
    
    //对顶点顺时针排序
    sortCorners(corners);
    
    //计算目标图像的尺寸
    cv::Point2f p0 = corners[0];
    cv::Point2f p1 = corners[1];
    cv::Point2f p2 = corners[2];
    cv::Point2f p3 = corners[3];
    float space0 = getSpacePointToPoint(p0, p1);
    float space1 = getSpacePointToPoint(p1, p2);
    float space2 = getSpacePointToPoint(p2, p3);
    float space3 = getSpacePointToPoint(p3, p0);
    
    float width = space1 > space3 ? space1 : space3;
    float height = space0 > space2 ? space0 : space2;
    
    cv::Mat quad = cv::Mat::zeros(height * 3, width * 3, CV_8UC3);
    std::vector<cv::Point2f> quad_pts;
    quad_pts.push_back(cv::Point2f(0, quad.rows));
    quad_pts.push_back(cv::Point2f(0, 0));
    quad_pts.push_back(cv::Point2f(quad.cols, 0));
    quad_pts.push_back(cv::Point2f(quad.cols, quad.rows));
    
    zQuadrilateral *resutQuad = [zQuadrilateral new];
    {
        cv::Point point = quad_pts[0];
        resutQuad.topLeft = CGPointMake(point.x, point.y);
    }
    
    {
        cv::Point point = quad_pts[1];
        resutQuad.topRight = CGPointMake(point.x, point.y);
    }
    
    {
        cv::Point point = quad_pts[2];
        resutQuad.bottomRight = CGPointMake(point.x, point.y);
    }
    
    {
        cv::Point point = quad_pts[3];
        resutQuad.bottomLeft = CGPointMake(point.x, point.y);
    }
    
    return resutQuad;
}

#pragma mark zyh end

#pragma mark - =========== 寻找最大边框 ===========

int findLargestSquare(const vector<vector<cv::Point>>& squares)
{
    if (squares.size() <= 0) return -1;

    int max_width = 0;
    int max_height = 0;
    int max_square_idx = -1;
    
    for (int i = 0; i < squares.size(); ++i) {
        cv::Rect rectangle = boundingRect(Mat(squares[i]));
        if ((rectangle.width >= max_width) && (rectangle.height >= max_height)) {
            max_width = rectangle.width;
            max_height = rectangle.height;
            max_square_idx = i;
        }
    }
    return max_square_idx;
}

/**
 根据三个点计算中间那个点的夹角   pt1 pt0 pt2
 */
static double getAngle(cv::Point pt1, cv::Point pt2, cv::Point pt0)
{
    double dx1 = pt1.x - pt0.x;
    double dy1 = pt1.y - pt0.y;
    double dx2 = pt2.x - pt0.x;
    double dy2 = pt2.y - pt0.y;
    return ( dx1*dx2 + dy1*dy2 ) / sqrt( (dx1*dx1 + dy1*dy1)*(dx2*dx2 + dy2*dy2) + 1e-10 );
}

/**
 点到点的距离

 @param p1 点1
 @param p2 点2
 @return 距离
 */
static double getSpacePointToPoint(cv::Point p1, cv::Point p2)
{
    int a = p1.x - p2.x;
    int b = p1.y - p2.y;
    return sqrt(a * a + b * b);
}

/**
 两直线的交点

 @param a 线段1
 @param b 线段2
 @return 交点
 */
cv::Point2f computeIntersect(cv::Vec4i a, cv::Vec4i b)
{
    int x1 = a[0], y1 = a[1], x2 = a[2], y2 = a[3], x3 = b[0], y3 = b[1], x4 = b[2], y4 = b[3];

    if (float d = ((float)(x1 - x2) * (y3 - y4)) - ((y1 - y2) * (x3 - x4)))
    {
        cv::Point2f pt;
        pt.x = ((x1 * y2 - y1 * x2) * (x3 - x4) - (x1 - x2) * (x3 * y4 - y3 * x4)) / d;
        pt.y = ((x1 * y2 - y1 * x2) * (y3 - y4) - (y1 - y2) * (x3 * y4 - y3 * x4)) / d;
        return pt;
    }
    else
        return cv::Point2f(-1, -1);
}

/**
 对多个点按顺时针排序

 @param corners 点的集合
 */
void sortCorners(std::vector<cv::Point2f>& corners)
{
    if (corners.size() == 0) return;
    //先延 X轴排列
    cv::Point pl = corners[0];
    int index = 0;
    for (int i = 1; i < corners.size(); i++)
    {
        cv::Point point = corners[i];
        if (pl.x > point.x)
        {
            pl = point;
            index = i;
        }
    }
    corners[index] = corners[0];
    corners[0] = pl;

    cv::Point lp = corners[0];
    for (int i = 1; i < corners.size(); i++)
    {
        for (int j = i+1; j<corners.size(); j++)
        {
            cv::Point point1 = corners[i];
            cv::Point point2 = corners[j];
            if ((point1.y-lp.y*1.0)/(point1.x-lp.x)>(point2.y-lp.y*1.0)/(point2.x-lp.x))
            {
                cv::Point temp = point1;
                corners[i] = corners[j];
                corners[j] = temp;
            }
        }
    }
}

UIImage *cropImgFromCorners(cv::Mat srcImg, vector<cv::Point2f> corners)
{
    if (corners.size() < 4) {
        return nil;
    }
    
    //对顶点顺时针排序
    sortCorners(corners);
    
    //计算目标图像的尺寸
    cv::Point2f p0 = corners[0];
    cv::Point2f p1 = corners[1];
    cv::Point2f p2 = corners[2];
    cv::Point2f p3 = corners[3];
    float space0 = getSpacePointToPoint(p0, p1);
    float space1 = getSpacePointToPoint(p1, p2);
    float space2 = getSpacePointToPoint(p2, p3);
    float space3 = getSpacePointToPoint(p3, p0);
    
    float width = space1 > space3 ? space1 : space3;
    float height = space0 > space2 ? space0 : space2;
    
    cv::Mat quad = cv::Mat::zeros(height * 3, width * 3, CV_8UC3);
    std::vector<cv::Point2f> quad_pts;
    quad_pts.push_back(cv::Point2f(0, quad.rows));
    quad_pts.push_back(cv::Point2f(0, 0));
    quad_pts.push_back(cv::Point2f(quad.cols, 0));
    quad_pts.push_back(cv::Point2f(quad.cols, quad.rows));
    
    //提取图像
    cv::Mat transmtx = cv::getPerspectiveTransform(corners , quad_pts);
    cv::warpPerspective(srcImg, quad, transmtx, quad.size());
    
    Mat imageMat;
    Mat kernel = (Mat_<float>(3,3) << 0, -1, 0,  -1, 5, -1, 0, -1, 0);
    filter2D(quad, imageMat, quad.depth(), kernel);
    //Mat --> UIImage
    UIImage *result = MatToUIImage(imageMat);
    
//    Mat imgRGBAMat;
//    cvtColor(imageMat, imgRGBAMat, CV_BGRA2RGBA);
//    UIImage *result = MatToUIImage(imgRGBAMat);
    return result;
}

@end
