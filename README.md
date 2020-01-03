# ImageProcessUseOpenCV

>本工程中包含使用OpenCV实时检测票据边缘，并支持截取票据影像的功能，本项目的初始意图是使用OpenCV检测矩形边框，然后透视矫正，后来发现iOS SDK自带的CIDetector功能效果也很好，所以项目改为以使用iOS原生api为主。  
>
>注意：下载项目代码后需要重新pod install OpenCV的库才可以编译运行，请知悉

使用CIDetector检测矩形边框  
1. 支持截取矩形框中内容并透视矫正  
2. 支持手动调节矩形边框，提高截取精度  
3. 支持实时检测和相册影像检测  

可以用来识别证件、票据，截取后透视矫正，方便后台进行后续的OCR识别。票据与背景的色差越大，识别越准确。

支持的系统：iOS9 later

参考项目：  
[MADRectDetect](https://github.com/madaoCN/MADRectDetect)
初始的代码逻辑有参考这个项目，获益良多，但是这个项目有两个缺点：1.摄像头实时预览用的是GLKView展示影像，影像是非等比缩放，导致影像是变形的； 2.该项目没有做相册影像的矩形检测。

[WeScan](https://github.com/WeTransfer/WeScan)项目也有借鉴，但是个人觉得WeScan项目的代码逻辑太过复杂，可阅读性不是很好