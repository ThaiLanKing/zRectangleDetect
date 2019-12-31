//
//  ViewController.m
//  zJamBoOpenCV
//
//  Created by ZhangYaoHua on 2019/9/25.
//  Copyright © 2019 ZYH. All rights reserved.
//

/**
 OpenCV方案缺点：
 1.需要引入OpenCV库，文件非常大
 2.图片裁剪的边缘不是很圆滑，比较毛糙
 
 CIDetector方案缺陷：
 1.蒙版的GLKView展示Image会变形，不是等比缩放
 
 最终方案：
 CIDetector搭配PreviewLayer
 */

#import "ViewController.h"
#import "zJBCameraViewController.h"
#import "zRectangleDetectViewController.h"
#import "zBorderAdjustmentViewController.h"
#import "zRectangleDetectHelper.h"

#ifdef DEBUG //测试

#import "zAlbumBorderAdjustViewController.h"
#import "UIImage+zRectangleDetect.h"

#endif

@import VisionKit;
@import Vision;

@interface ViewController ()<UINavigationControllerDelegate,
                             UIImagePickerControllerDelegate,
                             VNDocumentCameraViewControllerDelegate>
{
    BOOL _useOpenCV;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initView];
}

- (void)initView
{
    UIButton *openCVVersionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [openCVVersionBtn setTitle:@"OpenCV版本" forState:UIControlStateNormal];
    @weakify(self);
    [openCVVersionBtn addActionBlock:^(UIButton *sender) {
        @strongify(self);
        [self openCVScan];
    }];
    [self.view addSubview:openCVVersionBtn];
    
    UIButton *CIVersionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [CIVersionBtn setTitle:@"CIDetector版本" forState:UIControlStateNormal];
    [CIVersionBtn addActionBlock:^(UIButton *sender) {
        @strongify(self);
        [self CIDetectorScan];
    }];
    [self.view addSubview:CIVersionBtn];
    
    UIButton *VNDocumentVersionBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    [VNDocumentVersionBtn setTitle:@"VNDocument版本（iOS13专属）" forState:UIControlStateNormal];
    [VNDocumentVersionBtn addActionBlock:^(UIButton *sender) {
        @strongify(self);
        [self VNDocumentScan];
    }];
    [self.view addSubview:VNDocumentVersionBtn];
    
    [openCVVersionBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(100);
        make.height.equalTo(60);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(100);
    }];
    
    [CIVersionBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(160);
        make.height.equalTo(60);
        make.centerX.equalTo(self.view);
        make.top.equalTo(openCVVersionBtn.bottom).offset(30);
    }];
    
    [VNDocumentVersionBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(220);
        make.height.equalTo(60);
        make.centerX.equalTo(self.view);
        make.top.equalTo(CIVersionBtn.bottom).offset(30);
    }];
}

- (void)openCVScan
{
    UIAlertController *sheetVC = [UIAlertController alertControllerWithTitle:@"OpenCV获取影像" message:@"选择获取影像方式" preferredStyle:UIAlertControllerStyleActionSheet];
    
    @weakify(self);
    UIAlertAction *scanAction = [UIAlertAction actionWithTitle:@"相机扫描" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        zJBCameraViewController *dstVC = [[zJBCameraViewController alloc] init];
        [self.navigationController pushViewController:dstVC animated:YES];
    }];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        
        self->_useOpenCV = YES;
        
        UIImagePickerController *pickerVC = [[UIImagePickerController alloc] init];
        pickerVC.delegate = self;
        pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pickerVC animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [sheetVC addAction:scanAction];
    [sheetVC addAction:albumAction];
    [sheetVC addAction:cancelAction];
    
    [self presentViewController:sheetVC animated:YES completion:nil];
}

- (void)CIDetectorScan
{
    UIAlertController *sheetVC = [UIAlertController alertControllerWithTitle:@"CIDetector获取影像" message:@"选择获取影像方式" preferredStyle:UIAlertControllerStyleActionSheet];
    
    @weakify(self);
    UIAlertAction *scanAction = [UIAlertAction actionWithTitle:@"相机扫描" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        zRectangleDetectViewController *dstVC = [[zRectangleDetectViewController alloc] init];
        [self.navigationController pushViewController:dstVC animated:YES];
    }];
    
    UIAlertAction *albumAction = [UIAlertAction actionWithTitle:@"相册选取" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        @strongify(self);
        
        self->_useOpenCV = NO;
        
        UIImagePickerController *pickerVC = [[UIImagePickerController alloc] init];
        pickerVC.delegate = self;
        pickerVC.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        [self presentViewController:pickerVC animated:YES completion:nil];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    
    [sheetVC addAction:scanAction];
    [sheetVC addAction:albumAction];
    [sheetVC addAction:cancelAction];
    
    [self presentViewController:sheetVC animated:YES completion:nil];
}

- (void)VNDocumentScan
{
    if (@available(iOS 13.0, *)) {
        VNDocumentCameraViewController *scanVC = [[VNDocumentCameraViewController alloc] init];
        scanVC.delegate = self;
        [self presentViewController:scanVC animated:YES completion:nil];
    }
    else {
        NSLog(@"系统版本低于iOS13，不可使用");
    }
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<UIImagePickerControllerInfoKey,id> *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"])
    {
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        if (_useOpenCV) {
            zQuadrilateral *CIQuad = [zJBCameraViewController scannedRectangleFromImg:image];
            
            [picker dismissViewControllerAnimated:YES completion:^{
//                zAlbumBorderAdjustViewController *dstVC = [[zAlbumBorderAdjustViewController alloc] init];
//                dstVC.srcImg = image;
//                dstVC.aspectFitQuad = CIQuad;
//                [self.navigationController pushViewController:dstVC animated:YES];
            }];
        }
        else {
            //先调整原图的orientation，然后再识别矩形
//            image = [self normalizedImage:image];
//            image = [image fixOrientation];
            CIImage *srcCIImage = image.CIImage;
            if (!srcCIImage) {
                if (image.CGImage) {
                    srcCIImage = [CIImage imageWithCGImage:image.CGImage];
                }
                else {
                    NSData *imgData = UIImagePNGRepresentation(image);
                    srcCIImage = [CIImage imageWithData:imgData];
                }
            }
            
            srcCIImage = [zRectangleDetectHelper imageFilteredUsingContrastOnImage:srcCIImage];
            
            NSArray<CIFeature *> *features = [[self rectangleDetector] featuresInImage:srcCIImage];
            // 选取特征列表中最大的矩形
            CIRectangleFeature* borderDetectLastRectangleFeature = [zRectangleDetectHelper biggestRectangleFeatureInFeatures:features];
            
            [picker dismissViewControllerAnimated:YES completion:^{
                zAlbumBorderAdjustViewController *dstVC = [[zAlbumBorderAdjustViewController alloc] init];
                dstVC.srcImg = image;
                dstVC.scannedRectFeature = borderDetectLastRectangleFeature;
                [self.navigationController pushViewController:dstVC animated:YES];
            }];
            
        }
//        UIImage *r1 = [zJBCameraViewController testCropImg:image];
//        UIImage *r2 = [self testCropImg:image];
        
        NSLog(@"process end!");
    }
}

- (UIImage *)normalizedImage:(UIImage *)srcImg {
    if (srcImg.imageOrientation == UIImageOrientationUp) return srcImg;

    UIGraphicsBeginImageContextWithOptions(srcImg.size, NO, srcImg.scale);
    [srcImg drawInRect:(CGRect){0, 0, srcImg.size}];
    UIImage *normalizedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return normalizedImage;
}

#ifdef DEBUG //测试

- (CIDetector *)rectangleDetector
{
    return [CIDetector detectorOfType:CIDetectorTypeRectangle
    context:nil
    options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
}

#endif

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"取消选择相片");
}

#pragma mark -

- (UIImage *)testCropImg:(UIImage *)srcImg
{
    if (@available(iOS 10.0, *)) {
        NSDictionary *options = @{CIDetectorAccuracy : CIDetectorAccuracyHigh,
//                                  CIDetectorAspectRatio: @(0.3),
//                                  CIDetectorMaxFeatureCount : @(10),
        };
        CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeRectangle context:nil options:options];
        CIImage *srcCIImg = [[CIImage alloc] initWithImage:srcImg];
        NSArray *features = [detector featuresInImage:srcCIImg];
        
//        for (CIFeature *feature in features) {
//            if ([feature isKindOfClass:[CIRectangleFeature class]]) {
//                CIImage *resultCIImg = [self cropImgFrom:srcCIImg withFeature:feature];
//                UIImage *resultFromCIImg = [UIImage imageWithCIImage:resultCIImg];
//                NSLog(@"CIImgSuccess");
//
//                return resultFromCIImg;
//            }
//        }
//
//        return nil;
        
        CGFloat halfPerimiterValue = 0.0;
        for (CIRectangleFeature *feature in features) {
            CGPoint p1 = feature.topLeft;
            CGPoint p2 = feature.topRight;
            CGFloat width = hypotf(p1.x - p2.x, p1.y - p2.y);

            CGPoint p4 = feature.bottomLeft;
            CGFloat height = hypotf(p1.x - p4.x, p1.y - p4.y);
            CGFloat currentHalfPerimiterValue = height + width;
            if (halfPerimiterValue < currentHalfPerimiterValue) {
                halfPerimiterValue = currentHalfPerimiterValue;

                CIImage *resultCIImg = [self cropImgFrom:srcCIImg withFeature:feature];
                UIImage *resultFromCIImg = [UIImage imageWithCIImage:resultCIImg];
                NSLog(@"CIImgSuccess");
            }
        }
        
        return nil;
    }
    
    return nil;
}

- (CIImage *)cropImgFrom:(CIImage *)srcImg withFeature:(CIRectangleFeature *)feature
{
    NSDictionary *parameter = @{ @"inputExtent" : [CIVector vectorWithCGRect:srcImg.extent],
    @"inputTopLeft" : [CIVector vectorWithCGPoint:feature.topLeft],
    @"inputTopRight" : [CIVector vectorWithCGPoint:feature.topRight],
    @"inputBottomLeft" : [CIVector vectorWithCGPoint:feature.bottomLeft],
    @"inputBottomRight" : [CIVector vectorWithCGPoint:feature.bottomRight] };
    CIImage *result = [srcImg imageByApplyingFilter:@"CIPerspectiveTransformWithExtent" withInputParameters:parameter];
    result = [result imageByCroppingToRect:result.extent];
    return result;
}

//@available(iOS 13.0, *)
#pragma mark - VNDocumentCameraViewControllerDelegate

- (void)documentCameraViewController:(VNDocumentCameraViewController *)controller didFinishWithScan:(VNDocumentCameraScan *)scan
{
    for (int i = 0; i < scan.pageCount; ++i) {
        UIImage *img = [scan imageOfPageAtIndex:i];
        NSLog(@"scan img : %d, title : %@", i,  scan.title);
        
        [self recognizeTextInImage:img];
    }
}

- (void)documentCameraViewControllerDidCancel:(VNDocumentCameraViewController *)controller
{
    NSLog(@"scan cancel");
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)documentCameraViewController:(VNDocumentCameraViewController *)controller didFailWithError:(NSError *)error
{
    NSLog(@"scan error : %@", error.description);
}

- (void)recognizeTextInImage:(UIImage *)srcImg
{
    VNRecognizeTextRequest *request = [[VNRecognizeTextRequest alloc] initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
        NSLog(@"request : %d", request.results.count);
        for (VNRecognizedTextObservation *obj in request.results) {
            NSLog(@"reg text : %@", [obj performSelector:@selector(text)]);
        }
    }];
    request.minimumTextHeight = 0.03125;
    request.customWords = @[@"张尧华", @"研发"];
    request.recognitionLevel = VNRequestTextRecognitionLevelAccurate;
    request.recognitionLanguages = @[@"zh-CN", @"en-US"];
    request.usesLanguageCorrection = YES;
    
    CGImageRef cgImg = srcImg.CGImage;
    VNImageRequestHandler *handler = [[VNImageRequestHandler alloc] initWithCGImage:cgImg options:nil];
    NSError *error;
    [handler performRequests:@[request] error:&error];
    if (error) {
        NSLog(@"recognize error : %@", error.description);
    }
}

@end
