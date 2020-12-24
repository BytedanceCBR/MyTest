//
//  LogViewerSettingViewController.m
//  NewsLite
//
//  Created by leo on 2019/3/15.
//

#import "LogViewerSettingViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <TTTracker/TTTracker.h>
#import <TTBaseLib/TTBaseMacro.h>
#import "SSNavigationBar.h"
#if __has_include(<TTTracker/TTTracker.h>)
#import <TTTracker/TTTracker.h>
#endif

#if __has_include(<BDTracker/BDTrackerClient.h>)
#import <BDTracker/BDTrackerClient.h>
#import <BDTracker/BDTrackerSDK+Debug.h>
#endif

#import <objc/runtime.h>
#import <objc/message.h>

#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
@interface LogViewerSettingViewController ()<AVCaptureMetadataOutputObjectsDelegate, CAAnimationDelegate>
{
    AVCaptureSession* _session;
    int _lineTag;
    UIView* _highlightView;
}
@property (nonatomic, strong) UITextField *addressTextField;
@end

@implementation LogViewerSettingViewController

-(void)turnOnETData:(NSString *)address {
    
    [[TTTracker sharedInstance] setDebugLogServerAddress: address];
    
#if __has_include(<BDTracker/BDTrackerClient.h>)
    if (NSClassFromString(@"BDTrackerClient")) {
        BDTrackerClient *client = [NSClassFromString(@"BDTrackerClient") shareInstance];
        [client performSelector:@selector(startLogger)];
    }
    Class cls = NSClassFromString(@"BDTrackerSDK");
    SEL sel = NSSelectorFromString(@"setIsInHouseVersion:");
    if (cls && sel && [cls respondsToSelector:sel]) {
        void (*action)(Class,SEL,BOOL) = (void(*)(Class,SEL,BOOL))objc_msgSend;
        action(cls, sel, YES);
    }
    
#endif
    
    //https://data.bytedance.net/et_api/logview/verify/
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view setBackgroundColor:[UIColor whiteColor]];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView: [SSNavigationBar navigationBackButtonWithTarget:self action:@selector(back:)]];
#if TARGET_OS_SIMULATOR
    [self configForSimulator];
#else
    [self configCamera];
#endif
    
#ifdef DEBUG
    [self turnOnETData:@"https://data.bytedance.net/et_api/logview/verify/"];
#endif
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [_session removeObserver:self forKeyPath:@"running" context:nil];
}

-(void)back:(id)sender {
    [[self navigationController] popViewControllerAnimated:YES];
}

-(void)configForSimulator {
    
    UILabel *label = [UILabel new];
    label.text = @"数据提交地址:";
    [label sizeToFit];
    
    self.addressTextField = [UITextField new];
    self.addressTextField.frame = CGRectMake(0, 0, self.view.bounds.size.width - 32, 20);
    self.addressTextField.borderStyle = UITextBorderStyleRoundedRect;
    self.addressTextField.placeholder = @"https://data.bytedance.net/et_api/logview/verify/";
    self.addressTextField.font = [UIFont systemFontOfSize:12];
    
    UIButton *confirmBtn = [UIButton buttonWithType: UIButtonTypeCustom];
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [confirmBtn sizeToFit];
    [confirmBtn addTarget:self action:@selector(confirmBtnAction:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:label];
    [self.view addSubview:self.addressTextField];
    [self.view addSubview:confirmBtn];
    
    label.center = CGPointMake(self.view.center.x, self.view.center.y - 30);
    self.addressTextField.center = self.view.center;
    confirmBtn.center = CGPointMake(self.view.center.x, self.view.center.y + 30);
}

- (void)confirmBtnAction: (UIButton *)sender {
    NSString *address = self.addressTextField.text.length > 0 ? self.addressTextField.text : self.addressTextField.placeholder;
    [self turnOnETData:address];
    [self back:nil];
}

-(void)configCamera {
    _lineTag = 1872637;
    //获取摄像设备
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    //创建输入流
    AVCaptureDeviceInput * input = [AVCaptureDeviceInput deviceInputWithDevice:device error:nil];
    //创建输出流
    AVCaptureMetadataOutput * output = [[AVCaptureMetadataOutput alloc]init];
    //设置代理 在主线程里刷新
    [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];

    //初始化链接对象
    _session = [[AVCaptureSession alloc]init];
    //高质量采集率
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if (input) {
        [_session addInput:input];
    }
    if (output) {
        [_session addOutput:output];
        //设置扫码支持的编码格式(如下设置条形码和二维码兼容)
        NSMutableArray *a = [[NSMutableArray alloc] init];
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeQRCode]) {
            [a addObject:AVMetadataObjectTypeQRCode];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN13Code]) {
            [a addObject:AVMetadataObjectTypeEAN13Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeEAN8Code]) {
            [a addObject:AVMetadataObjectTypeEAN8Code];
        }
        if ([output.availableMetadataObjectTypes containsObject:AVMetadataObjectTypeCode128Code]) {
            [a addObject:AVMetadataObjectTypeCode128Code];
        }
        output.metadataObjectTypes=a;
    }
    AVCaptureVideoPreviewLayer * layer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    layer.videoGravity=AVLayerVideoGravityResizeAspectFill;
    layer.frame=self.view.layer.bounds;
    [self.view.layer insertSublayer:layer atIndex:0];

    [self setOverlayPickerView];

    [_session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];

    //开始捕获
    [_session startRunning];
}

/**
 *
 *  监听扫码状态-修改扫描动画
 *
 */
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
    if ([object isKindOfClass:[AVCaptureSession class]]) {
        BOOL isRunning = ((AVCaptureSession *)object).isRunning;
        if (isRunning) {
            [self addAnimation];
        }else{
            [self removeAnimation];
        }
    }
}

/**
 *
 *  创建扫码页面
 */
- (void)setOverlayPickerView
{
    //左侧的view
    UIImageView *leftView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, ScreenHeight)];
    leftView.alpha = 0.5;
    leftView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:leftView];
    //右侧的view
    UIImageView *rightView = [[UIImageView alloc] initWithFrame:CGRectMake(ScreenWidth-30, 0, 30, ScreenHeight)];
    rightView.alpha = 0.5;
    rightView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:rightView];

    //最上部view
    UIImageView* upView = [[UIImageView alloc] initWithFrame:CGRectMake(30, 0, ScreenWidth - 60, (self.view.center.y-(ScreenWidth-60)/2))];
    upView.alpha = 0.5;
    upView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:upView];

//    UIButton *cancleBtn = [[UIButton alloc] initWithFrame:CGRectMake(5, 20, 44, 44)];
//    [cancleBtn setImage:[UIImage imageNamed:@"nav_backButton_image"] forState:UIControlStateNormal];
//    [cancleBtn addTarget:self action:@selector(cancleBtnClick) forControlEvents:UIControlEventTouchUpInside];
//    [self.view addSubview:cancleBtn];




    //底部view
    UIImageView * downView = [[UIImageView alloc] initWithFrame:CGRectMake(30, (self.view.center.y+(ScreenWidth-60)/2), (ScreenWidth-60), (ScreenHeight-(self.view.center.y-(ScreenWidth-60)/2)))];
    downView.alpha = 0.5;
    downView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:downView];

    UIImageView *centerView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth-60, ScreenHeight-60)];
    centerView.center = self.view.center;
    centerView.image = [UIImage imageNamed:@"scan_circle"];
    centerView.contentMode = UIViewContentModeScaleAspectFit;
    centerView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:centerView];

    UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(30, CGRectGetMaxY(upView.frame), ScreenWidth-60, 2)];
    line.tag = _lineTag;
    line.image = [UIImage imageNamed:@"scan_line"];
    line.contentMode = UIViewContentModeScaleAspectFill;
    line.backgroundColor = [UIColor clearColor];
    [self.view addSubview:line];

    UILabel *msg = [[UILabel alloc] initWithFrame:CGRectMake(30, CGRectGetMinY(downView.frame), ScreenWidth-60, 60)];
    msg.backgroundColor = [UIColor clearColor];
    msg.textColor = [UIColor whiteColor];
    msg.textAlignment = NSTextAlignmentCenter;
    msg.font = [UIFont systemFontOfSize:16];
    msg.text = @"将二维码放入框内,即可自动扫描";
    [self.view addSubview:msg];

    //    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, ScreenHeight-100, ScreenWidth, 100)];
    //    label.backgroundColor = [UIColor clearColor];
    //    label.textColor = [UIColor whiteColor];
    //    label.textAlignment = NSTextAlignmentCenter;
    //    label.font = [UIFont systemFontOfSize:15];
    //    label.text = @"";
    //    [self.view addSubview:label];







}


/**
 *
 *  获取扫码结果
 */
-(void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection{
    if (metadataObjects.count>0) {
        [_session stopRunning];
//        NSURL *url=[[NSBundle mainBundle]URLForResource:@"scanSuccess.wav" withExtension:nil];
//        //2.加载音效文件，创建音效ID（SoundID,一个ID对应一个音效文件）
//        SystemSoundID soundID=8787;
//        AudioServicesCreateSystemSoundID((__bridge CFURLRef)url, &soundID);
//        //3.播放音效文件
//        //下面的两个函数都可以用来播放音效文件，第一个函数伴随有震动效果
//        AudioServicesPlayAlertSound(soundID);
//
//        AudioServicesPlaySystemSound(8787);

        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex :0];

        //输出扫描字符串
        NSString *data = metadataObject.stringValue;
        NSLog(@"data: %@", data);
        if (!isEmptyString(data)) {
            [self turnOnETData:data];
        }
        [self.navigationController popViewControllerAnimated:YES];
//        ScanResultViewController *resultVC = [[ScanResultViewController alloc] init];
//        resultVC.title = @"扫描结果";
//        resultVC.result = data;
//        [self.navigationController pushViewController:resultVC animated:YES];

    }
}

/**
 *
 *  添加扫码动画
 */
- (void)addAnimation{
    UIView *line = [self.view viewWithTag:_lineTag];
    line.hidden = NO;
    CABasicAnimation *animation = [[self class] moveYTime:2 fromY:[NSNumber numberWithFloat:0] toY:[NSNumber numberWithFloat:ScreenWidth-60-2] rep:OPEN_MAX];
    [line.layer addAnimation:animation forKey:@"LineAnimation"];
}

+ (CABasicAnimation *)moveYTime:(float)time fromY:(NSNumber *)fromY toY:(NSNumber *)toY rep:(int)rep
{
    CABasicAnimation *animationMove = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    [animationMove setFromValue:fromY];
    [animationMove setToValue:toY];
    animationMove.duration = time;
    animationMove.delegate = self;
    animationMove.repeatCount  = rep;
    animationMove.fillMode = kCAFillModeForwards;
    animationMove.removedOnCompletion = NO;
    animationMove.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    return animationMove;
}


/**
 *  @author Whde
 *
 *  去除扫码动画
 */
- (void)removeAnimation{
    UIView *line = [self.view viewWithTag:_lineTag];
    [line.layer removeAnimationForKey:@"LineAnimation"];
    line.hidden = YES;
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
