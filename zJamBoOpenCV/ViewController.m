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
#import "zShowScanResultViewController.h"

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
        make.width.equalTo(120);
        make.height.equalTo(60);
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.view).offset(100);
    }];
    
    [CIVersionBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(180);
        make.height.equalTo(60);
        make.centerX.equalTo(self.view);
        make.top.equalTo(openCVVersionBtn.bottom).offset(30);
    }];
    
    [VNDocumentVersionBtn makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(280);
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
        
        UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:nil message:@"系统版本低于iOS13，不可用！" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"我知道了" style:UIAlertActionStyleCancel handler:nil];
        [alertVC addAction:cancelAction];
        [self presentViewController:alertVC animated:YES completion:nil];
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
            UIImage *testImg = [zJBCameraViewController testCropImg:image];
            
            [picker dismissViewControllerAnimated:YES completion:^{
                zShowScanResultViewController *dstVC = [[zShowScanResultViewController alloc] init];
                dstVC.resultImg = testImg;
                [self.navigationController pushViewController:dstVC animated:YES];
            }];
        }
        else {
            //先调整原图的orientation，然后再识别矩形
            CIImage *srcCIImage = [UIImage zCIImageFromUIImage:image];
            srcCIImage = [zRectangleDetectHelper imageFilteredUsingContrastOnImage:srcCIImage];
            
            NSArray<CIFeature *> *features = [[self rectangleDetector] featuresInImage:srcCIImage];
            // 选取特征列表中最大的矩形
            CIRectangleFeature *borderDetectLastRectangleFeature = [zRectangleDetectHelper biggestRectangleFeatureInFeatures:features];
            
            [picker dismissViewControllerAnimated:YES completion:^{
                zBorderAdjustmentViewController *dstVC = [[zBorderAdjustmentViewController alloc] init];
                dstVC.srcImg = image;
                dstVC.scannedRectFeature = borderDetectLastRectangleFeature;
                [dstVC setImageShowMode:kImageShowModeScaleAspectFit];
                [self.navigationController pushViewController:dstVC animated:YES];
            }];
            
        }
//        UIImage *r1 = [zJBCameraViewController testCropImg:image];
//        UIImage *r2 = [self testCropImg:image];
        
        NSLog(@"process end!");
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"取消选择相片");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -

- (CIDetector *)rectangleDetector
{
    return [CIDetector detectorOfType:CIDetectorTypeRectangle
    context:nil
    options:@{CIDetectorAccuracy : CIDetectorAccuracyHigh}];
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
