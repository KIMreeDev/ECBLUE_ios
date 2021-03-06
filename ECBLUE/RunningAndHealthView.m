//
//  RunningAndHealthView.m
//  ECBLUE
//
//  Created by renchunyu on 14/12/19.
//  Copyright (c) 2014年 ecigarfan. All rights reserved.
//

#import "RunningAndHealthView.h"
#import <CoreGraphics/CGBitmapContext.h>


#define DELAYTIME 2//延迟开始统计时间，消除早期噪声
#define TIME 15    //计算秒数
#define FRAME 24  //每秒帧数


@implementation RunningAndHealthView

- (id)initWithFrame:(CGRect)frame
{

    self=[super initWithFrame:frame];
    if (self) {
        self.backgroundColor=COLOR_WHITE_NEW;
        [self viewInit];
    }
    return self;

}


-(void)viewInit
{
    
     sportHintArray = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"sportHint.plist" ofType:nil]];
    
    hintTitle=[[UILabel alloc] initWithFrame:CGRectMake(15, 30, 150, 20)];
    hintTitle.text= NSLocalizedString(@"Small sports knowledge:", nil) ;
    hintTitle.font=[UIFont systemFontOfSize:14];
    hintTitle.textColor=COLOR_MIDDLE_GRAY;
    [self addSubview:hintTitle];
    
    
    hintTextView=[[UITextView alloc] initWithFrame:CGRectMake(10, 70, kScreen_Width-20, 0.6*kScreen_Width)];
    hintTextView.backgroundColor=[UIColor colorWithRed:97/255.0 green:179/255.0 blue:219/255.0 alpha:1.0];
    hintTextView.editable=NO;
    hintTextView.textColor=COLOR_WHITE_NEW;
    hintTextView.font=[UIFont italicSystemFontOfSize:14];
    hintTextView.layer.cornerRadius=16;
    hintTextView.text= NSLocalizedString([sportHintArray objectAtIndex:arc4random()%sportHintArray.count], nil) ;
    [self textViewDidChange:hintTextView];

    [self addSubview:hintTextView];
    
    
    UIButton *testBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    testBtn.frame=CGRectMake(kScreen_Width/2-40, self.frame.size.height-100, 80, 80);
    [testBtn setBackgroundImage:[UIImage imageNamed:@"heartRateBtn"] forState:UIControlStateNormal];
    [testBtn setTitleColor:COLOR_BLUE_NEW forState:UIControlStateNormal];
    [testBtn setTitleColor:COLOR_RED_NEW forState:UIControlStateHighlighted];
    testBtn.titleLabel.font=[UIFont systemFontOfSize:14];
    [testBtn addTarget:self action:@selector(testRate) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:testBtn];
    
    
    //数组初始化
    heartRateArray=[[NSMutableArray alloc] init];
    
    //心率测试开启标志位默认为NO
    isOn=NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    [textView flashScrollIndicators];   // 闪动滚动条
    
     CGFloat maxHeight = kScreen_Height-320;
    CGRect frame = textView.frame;
    CGSize constraintSize = CGSizeMake(frame.size.width, MAXFLOAT);
    CGSize size = [textView sizeThatFits:constraintSize];
    if (size.height >= maxHeight)
    {
        size.height = maxHeight;
        textView.scrollEnabled = YES;   // 允许滚动
    }
    else
    {
        textView.scrollEnabled = NO;    // 不允许滚动，当textview的大小足以容纳它的text的时候，需要设置scrollEnabed为NO，否则会出现光标乱滚动的情况
    }
    textView.frame = CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, size.height);
}



-(void)testRate
{
    if (isOn==YES) {
        [self timerFired];
    }else{
        //显示心率背景界面
        [hintTitle removeFromSuperview];
        [hintTextView removeFromSuperview];
        if (_backgroundImageView==nil) {
            _backgroundImageView=[[UIImageView alloc] initWithFrame:CGRectMake(0, 5, kScreen_Width, 0.74*kScreen_Width)];
            _backgroundImageView.image=[UIImage imageNamed:@"heartRate"];
            [self addSubview:_backgroundImageView];
        }
        
        if (_heartRateLabel==nil) {
            _heartRateLabel=[[UILabel alloc] initWithFrame:CGRectMake(kScreen_Width-100, 35, 60, 60)];
            _heartRateLabel.textColor=COLOR_WHITE_NEW;
            _heartRateLabel.font=[UIFont systemFontOfSize:30];
            _heartRateLabel.text=@"0";
            [self addSubview:_heartRateLabel];
        }
        
        
        //打开闪光灯
        [self turnOnLed];
        [self setupCaptureSession];
        
        
        //加波形图
        waveView=[[WaveformView alloc] initWithFrame:CGRectMake(0, 5+0.1625*kScreen_Width, kScreen_Width, 0.5775*kScreen_Width)];
        waveView.backgroundColor=[UIColor clearColor];
        [self addSubview:waveView];
        
        isOn=YES;
    
    }

}



-(void)timerFired
{

    [self turnOffLed];
    [_session stopRunning];
    
    isOn=NO;
}


#pragma -mark 帧捕捉
- (void)captureOutput:(AVCaptureOutput *)captureOutput
didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer
       fromConnection:(AVCaptureConnection *)connection
{
    // Create a UIImage from the sample buffer data

    _inputImage = [self imageFromSampleBuffer:sampleBuffer];
    //改小分辨率以后，不截图
    //_inputImage =[self getImageFromImage:_inputImage Rect:CGRectMake(270, 190, 100, 100)];
   

    
    valueLast=value;
    value=0;
    //计算色深
    [self computeRedChannel:_inputImage];
    
    //判断摄像头被盖住
    if (value/1000000>6) {

    counter++;
    //过滤前2秒数据，要看帧数
    if (counterLast==0) {
        counterLast=DELAYTIME*FRAME;
    }
    
    
//    if (counter%12==0) {
//            NSLog(@"测试色深值%f",value);
//    }
    
    if (counter>DELAYTIME*FRAME) {
        
        //valueDiff=fabs((value-valueLast)/1000);
       
        diffOne=diffTwo;
        diffTwo=diffThree;
        diffThree=(value-valueLast)/100;
        
     
        //保持数据量
        if (heartRateArray.count>100) {
            [heartRateArray removeObjectAtIndex:0];
        }
        [heartRateArray addObject:[NSNumber numberWithFloat:diffThree]];
        
 
        if ((diffTwo<0)&&(diffTwo<diffOne)&&(diffTwo<diffThree)) {
          
            if ((counter-counterLast)<0.4*FRAME) {
                //NSLog(@"%d帧,red差值是:%.1f,波峰值,噪声，清除",counter, diffTwo);
            }else{
            
               // NSLog(@"%d帧,red差值是:%.1f,波峰值",counter, diffTwo);
                heartRate++;
                counterLast=counter;
            }
            
        }else
        {
            
           //  NSLog(@"%d帧,red差值是:%.1f", counter,diffTwo);
      
        }
        //线程间传递
        if (counter%1==0) {
            [self performSelectorOnMainThread:@selector(updateValue) withObject:nil waitUntilDone:NO];
            
        }
     
    }
        //用帧率计算时间，不用计数器
        if (counter>TIME*FRAME) {
            [self timerFired];
        }
        
   }
}




//更新显示
-(void)updateValue
{
  
    //绘制波形图
    waveView.array=heartRateArray;
    [waveView setNeedsDisplay];
   if (counter%FRAME==0) {
       
        _heartRateLabel.text=[NSString stringWithFormat:@"%d",(60/(counter/FRAME-DELAYTIME))*heartRate];
    }
    
}



//数据量过大，截图
-(UIImage *)getImageFromImage:(UIImage*)image Rect:(CGRect)rect{
    
    //定义myImageRect，截图的区域
    CGRect myImageRect = rect;
    CGImageRef imageRef = image.CGImage;
    CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, myImageRect);
    CGSize size;
    size.width = rect.size.width;
    size.height = rect.size.height;
    UIGraphicsBeginImageContext(size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, myImageRect, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    UIGraphicsEndImageContext();
    CFRelease(subImageRef);
    return smallImage;  
    
}

//计算通道色深
-(void)computeRedChannel:(UIImage*)image
{
    CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(image.CGImage));
    const UInt8* data = CFDataGetBytePtr(pixelData);
    for (int i=0; i<(int)image.size.width*image.size.height; i++) {
        value+=data[4*i+2]; //绿色通道，噪声更少,顺序为bgra
    }

     CFRelease(pixelData);
}





#pragma --mark 摄像头部分


// Create a UIImage from sample buffer data
- (UIImage *) imageFromSampleBuffer:(CMSampleBufferRef) sampleBuffer
{

    
    // Get a CMSampleBuffer's Core Video image buffer for the media data
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    // Lock the base address of the pixel buffer
    CVPixelBufferLockBaseAddress(imageBuffer, 0);
    
    // Get the number of bytes per row for the pixel buffer
    void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
    
    // Get the number of bytes per row for the pixel buffer
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    // Get the pixel buffer width and height
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    // Create a device-dependent RGB color space
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // Create a bitmap graphics context with the sample buffer data
    CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
                                                 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    // Create a Quartz image from the pixel data in the bitmap graphics context
    CGImageRef quartzImage = CGBitmapContextCreateImage(context);
    // Unlock the pixel buffer
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
    // Free up the context and color space
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    
    // Create an image object from the Quartz image
    //UIImage *image = [UIImage imageWithCGImage:quartzImage];
    UIImage *image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:UIImageOrientationRight];
    
    // Release the Quartz image
    CGImageRelease(quartzImage);
    
    return (image);
}


// Create and configure a capture session and start it running
- (void)setupCaptureSession
{
    NSError *error = nil;
    
    // Create the session
    _session = [[AVCaptureSession alloc] init];
    
    // Configure the session to produce lower resolution video frames, if your
    // processing algorithm can cope. We'll specify medium quality for the
    // chosen device.
    _session.sessionPreset = AVCaptureSessionPresetLow;
    
    // Find a suitable AVCaptureDevice
    AVCaptureDevice *device = [AVCaptureDevice
                               defaultDeviceWithMediaType:AVMediaTypeVideo];//这里默认是使用后置摄像头，你可以改成前置摄像头
    
    // Create a device input with the device and add it to the session.
    AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device
                                                                        error:&error];

    
    if (!input) {
        // Handling the error appropriately.
    }
    [_session addInput:input];
    
    // Create a VideoDataOutput and add it to the session
    AVCaptureVideoDataOutput *output = [[AVCaptureVideoDataOutput alloc] init];
    [_session addOutput:output];
    
    // Configure your output.
    dispatch_queue_t queue = dispatch_queue_create("myQueue", NULL);
    [output setSampleBufferDelegate:self queue:queue];
    
    // Specify the pixel format
//   	output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
//                            [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,
//                            [NSNumber numberWithInt: 320], (id)kCVPixelBufferWidthKey,
//                            [NSNumber numberWithInt: 240], (id)kCVPixelBufferHeightKey,
//                            nil];
    

    output.videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                            [NSNumber numberWithInt:kCVPixelFormatType_32BGRA], kCVPixelBufferPixelFormatTypeKey,nil];
    

        //预览层，不需要则隐藏
//        AVCaptureVideoPreviewLayer* preLayer = [AVCaptureVideoPreviewLayer layerWithSession: _session];
//        //preLayer = [AVCaptureVideoPreviewLayer layerWithSession:session];
//        preLayer.frame = CGRectMake(0, 0, 640, 480);
//        preLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
//        [self.layer addSublayer:preLayer];
    
    //设置帧率
    [device lockForConfiguration:nil];
    [device setActiveVideoMinFrameDuration:CMTimeMake(1, FRAME)];
  
    
    // Start the session running to start the flow of data
    [_session startRunning];
    
    // Assign session to an ivar.
    //[self setSession:session];
}



#pragma --mark 闪光灯

-(void)turnOffLed {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device.torchMode == AVCaptureTorchModeOn) {
        [device lockForConfiguration:nil];

        [device setTorchMode: AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
    
}

-(void)turnOnLed {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device.torchMode != AVCaptureTorchModeOn) {
        [device lockForConfiguration:nil];
        [device setTorchMode: AVCaptureTorchModeOn];
        [device unlockForConfiguration];
    }
    
    
    
}


- (void)drawRect:(CGRect)rect {
    // Drawing code
    
}


@end
