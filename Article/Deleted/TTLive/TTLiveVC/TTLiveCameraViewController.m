//
//  TTLiveCameraViewController.m
//  Article
//
//  Created by matrixzk on 7/27/16.
//
//

#import "TTLiveCameraViewController.h"


#import "TTAlphaThemedButton.h"
#import "TTCommonTimerObj.h"
#import "TTBezierPathCircleView.h"
#import "TTThemedAlertController.h"
#import "TTIndicatorView.h"
#import "UIButton+TTAdditions.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <AVKit/AVKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <Masonry/Masonry.h>
#import "TTDeviceHelper.h"
#import <IESMMImportVideoPlayer.h>

///...
#import <HTSVideoEditor.h>


#define TTCameraMaxFactor    4
#define TTCameraMaxVideoTime 60


typedef NS_ENUM(NSUInteger, TTLiveCameraCurrentState)
{
    TTLiveCameraCurrentStatePhoto = 201609, // 拍照
    TTLiveCameraCurrentStateVideo           // 视频
};

@interface TTLiveCameraViewController () <HTSCameraDelegate, TTCommonTimerObjDelegate>

@property (nonatomic,assign) TTLiveCameraType cameraType;          //相机类型
@property (nonatomic,assign) TTLiveCameraCurrentState currentState;  //当前是拍照还是摄像状态
@property (nonatomic,strong) TTAlphaThemedButton *flashBtn;    //闪光灯

@property (nonatomic, strong) SSThemedButton *videoRecordButton;
@property (nonatomic, strong) TTAlphaThemedButton *photoTakenButton;

@property (nonatomic,strong) TTAlphaThemedButton *playBtn; //视频播放
@property (nonatomic,strong) TTAlphaThemedButton *finishBtn; //完成后使用视频或者照片
@property (nonatomic,strong) UIView *realTimeView;   //实时显示的区域容器
@property (nonatomic,strong) SSThemedImageView *photoPreView;  //拍照完成后的预览
@property (nonatomic,strong) SSThemedView *videoPreView;  //录像完成后的预览
@property (nonatomic,strong) AVPlayerLayer *playerLayer;
@property (nonatomic,strong) AVPlayer *videoPrePlayer;
@property (nonatomic,strong) UIImage *preViewImage;  //预览图片
@property (nonatomic,strong) UIView *redDot;  //小红点
@property (nonatomic,strong) SSThemedScrollView *typeIndicateView;  //相机类型指示图
@property (nonatomic,strong) SSThemedView *previewActionView;  //预览的时候需要，如重拍
@property (nonatomic,strong) SSThemedImageView *focusBoxView; //聚焦的时候显示的框
@property (nonatomic,strong) UISlider *factorSlider;    //焦距调节
@property (nonatomic,strong) NSURL *videoUrl; //当前视频路径
@property (nonatomic,assign) BOOL videoEndAction; //终止录像
@property (nonatomic,assign) CMTime videoCurrentTime;
@property (nonatomic,strong) UILabel *timerLabel;  //计时文字
@property (nonatomic,strong) TTCommonTimerObj *videoTimer;  //录像文字计时器
@property (nonatomic,strong) TTCommonTimerObj *progressTimer;  //录像文字计时器
@property (nonatomic,strong) TTBezierPathCircleView *progressCircle; //录像进度圆
@property (nonatomic,strong) TTBezierPathCircleView *whiteCircle; //白色底部圆
@property (nonatomic,strong) UIProgressView *progressView; //录像进度条

@property (nonatomic, strong) NSDictionary *ssTrackerDic;

@property (nonatomic, strong) HTSCamera *videoCamera;

@property (nonatomic, assign) BOOL beautyModeEnable;
@property (nonatomic, assign) BOOL preSelfieEnable;

@end

@implementation TTLiveCameraViewController {
    TTAlphaThemedButton *cancelBtn;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithCamreraType:(TTLiveCameraType)cameraType beautyModeEnable:(BOOL)beautyEnable preSelfieEnable:(BOOL)preSelfieEnable
{
    self = [super init];
    if (self) {
        _cameraType = cameraType;
        _beautyModeEnable = beautyEnable;
        _preSelfieEnable = preSelfieEnable;
        _videoCurrentTime = kCMTimeZero;
    }
    return self;
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    self.view.frame = [UIScreen mainScreen].bounds;
    self.view.backgroundColor = [UIColor blackColor];
    
    [self initTotalSubviews];
    
    HTSVideoData *videoData = [HTSVideoData videoData];
    videoData.videoFrameRate = 30;
    videoData.outputSize = CGSizeMake(480, 864);
    videoData.bitRate = 1536000; // 1500*1024
    self.videoCamera = [HTSCamera cameraWithView:self.realTimeView videoData:videoData];
    self.videoCamera.previewModeType = HTSCameraPreviewModePreserveAspectRatioAndFill;
    [self.videoCamera enablePreview];
    self.videoCamera.enableTapFocus = YES;
    self.videoCamera.enableTapexposure = YES;
    self.videoCamera.delegate = self;
    if (_preSelfieEnable) { // 初始化为自拍模式
        self.videoCamera.defaultCamera = AVCaptureDevicePositionFront;
        if (_beautyModeEnable) [self.videoCamera applyBeautify:HTSBeautifyNature];
    } else {
        self.videoCamera.defaultCamera = AVCaptureDevicePositionBack;
    }
    // 初始化摄像头
//    self.videoCamera = [[HTSCamera alloc] initWithView:self.realTimeView];
//    self.videoCamera.delegate = self;
//    self.videoCamera.frameRate = 30;
//    self.videoCamera.enableTapFocus = YES;
//    self.videoCamera.previewModeType = HTSCameraPreviewModePreserveAspectRatioAndFill;
//    self.videoCamera.outputSize = CGSizeMake(480, 864);
//    self.videoCamera.bitRate = 1536000; // 1500*1024
//    if (_preSelfieEnable) { // 初始化为自拍模式
//        self.videoCamera.defaultCamera = AVCaptureDevicePositionFront;
//        if (_beautyModeEnable) [self.videoCamera applyFilter:HTSFilterBeautify];
//    } else {
//        self.videoCamera.defaultCamera = AVCaptureDevicePositionBack;
//    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackgroundNotification:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    
/*
#if DEBUG
    UIButton *beautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
    beautyButton.backgroundColor = [UIColor yellowColor];
    beautyButton.frame = CGRectMake(20, CGRectGetHeight(self.view.frame) - 100, 50, 40);
    [self.view addSubview:beautyButton];
    WeakSelf;
    [beautyButton addTarget:self withActionBlock:^{
        StrongSelf;
        HTSFilterType type = self.videoCamera.currFilterType;
        type = type ^ HTSFilterBeautify;
        [self.videoCamera applyFilter:type];
    } forControlEvent:UIControlEventTouchUpInside];
#endif
 */
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    // 开启镜头捕获
    [self.videoCamera startAudioCapture];
    [self.videoCamera startVideoCapture];
    self.videoCamera.isViewOnPresent = YES;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    // 关闭镜头捕获
    [self.videoCamera stopVideoCapture];
    self.videoCamera.isViewOnPresent = NO;
}


- (void)viewDidLayoutSubviews
{
    if ([TTDeviceHelper isPadDevice]) {
//        self.view.frame = [UIScreen mainScreen].bounds;
//        self.realTimeView.frame = self.view.frame;
//        self.photoPreView.frame = self.view.frame;
//        self.videoPreView.frame = self.view.frame;
//        self.playerLayer.frame = self.view.frame;
        self.realTimeView.frame = self.photoPreView.frame
                                = self.videoPreView.frame
                                = self.playerLayer.frame
                                = self.view.frame
                                = [UIScreen mainScreen].bounds;
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (BOOL)prefersHomeIndicatorAutoHidden
{
    return YES;
}

#pragma mark - HTSCameraDelegate Methods

- (void)camera:(HTSCamera *)camera willFocusAtPoint:(CGPoint)focusPoint
{
    [self focusBoxAnimation:focusPoint];
}

- (void)camera:(HTSCamera *)camera didPauseVideoRecordingWithError:(NSError *)error {
    [HTSCamera exportVideoWithVideoData:self.videoCamera.videoData completion:^(NSURL * _Nullable mergeUrl, NSError * _Nullable error) {
        if (!error) {
            self.videoUrl = mergeUrl;
            AVURLAsset *asset = [AVURLAsset assetWithURL:mergeUrl];
            [IESMMImportVideoPlayer getImageWithAsset:asset atTime:0 preferredSize:self.view.size compeletion:^(UIImage * _Nullable image, NSTimeInterval atTime) {
                self.preViewImage = image;
                [self stopVideoProcess];
            }];
        }
        else {
            [self stopVideoProcess];
        }
    }];
}

//- (void)cameraGeneratePreviewImageFinish:(UIImage *)previewImage
//{
////    self.preViewImage = self.videoCamera.previewImage;
//    self.preViewImage = previewImage;
//    [self stopVideoProcess];
//}
//
//- (void)camera:(HTSCamera *)camera didFinishVideoRecordingWithUrl:(nullable NSURL *)url length:(CGFloat)videoLength error:(nullable NSError *)error
//{
//    self.videoUrl = url;
//}


#pragma mark -- 初始化以及界面

- (void)initTotalSubviews
{
    //类型公共视图
    [self setUpCommonSubviews];
    
    //按照类型区别显示
    switch (self.cameraType) {
        case TTLiveCameraTypePhoto: {
            
            self.currentState = TTLiveCameraCurrentStatePhoto;
            
            self.playBtn.hidden = YES;
            [self.finishBtn setTitle:@"使用照片" forState:UIControlStateNormal];
            self.timerLabel.hidden = YES;
            [self.progressCircle setCircleViewColor:[UIColor lightGrayColor]];
            [self.progressCircle drawCircleWithRadiusValue:M_PI*2];
            
            //类型指示
            for (UIView *view in self.typeIndicateView.subviews) {
                if ([view isKindOfClass:[SSThemedLabel class]]) {
                    SSThemedLabel *label = (SSThemedLabel *)view;
                    if (label.tag == self.currentState) {
                        label.textColor = [UIColor whiteColor];
                        [label mas_updateConstraints:^(MASConstraintMaker *make){
                            make.top.equalTo(self.typeIndicateView.mas_top).offset(20);
                            make.centerX.equalTo(self.typeIndicateView.mas_centerX);
                        }];
                    } else {
                        label.hidden = YES;
                    }
                }
            }
            
            [self showVideoRecordButton:NO];
        }
            break;
            
        case TTLiveCameraTypeVideo:
        {
            self.currentState = TTLiveCameraCurrentStateVideo;
            
            //类型指示
            for (UIView *view in self.typeIndicateView.subviews) {
                if ([view isKindOfClass:[SSThemedLabel class]]) {
                    SSThemedLabel *label = (SSThemedLabel *)view;
                    if (label.tag == self.currentState) {
                        label.textColor = [UIColor whiteColor];
                        [label mas_updateConstraints:^(MASConstraintMaker *make){
                            make.top.equalTo(self.typeIndicateView.mas_top).offset(20);
                            make.centerX.equalTo(self.typeIndicateView.mas_centerX);
                        }];
                    } else {
                        label.hidden = YES;
                    }
                }
            }
            
            [self showVideoRecordButton:YES];
        }
            break;
            
        case TTLiveCameraTypeVideoAndPhoto:
        {
            //先默认设置为照相
            self.currentState = TTLiveCameraCurrentStateVideo;
            
            UISwipeGestureRecognizer *swipeRightGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRealTimeViewGesture:)];
            UISwipeGestureRecognizer *swipeLeftGesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleRealTimeViewGesture:)];
            swipeRightGesture.direction = UISwipeGestureRecognizerDirectionLeft;
            [self.realTimeView addGestureRecognizer:swipeLeftGesture];
            [self.realTimeView addGestureRecognizer:swipeRightGesture];
            
            [self showVideoRecordButton:YES];
        }
            break;
            
        default:
            break;
    }
}

- (void)setUpCommonSubviews
{
    //预览区域容器
    CGFloat topInset = 0;
    if ([TTDeviceHelper isIPhoneXDevice]){
        topInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.top;
    }
    UIPinchGestureRecognizer *pinGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handleRealTimeViewGesture:)];
    
    self.realTimeView = [[UIView alloc] initWithFrame:self.view.frame];
    [self.realTimeView addGestureRecognizer:pinGesture];
    [self.view addSubview:self.realTimeView];
    [self.realTimeView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(self.view);
    }];
    
    //聚焦框
    CGRect focusBoxFrame = CGRectMake(0, 0, 50, 50);
    self.focusBoxView = [[SSThemedImageView alloc] initWithFrame:focusBoxFrame];
    self.focusBoxView.imageName = @"chatroom_photo_focus.png";
    self.focusBoxView.hidden = YES;
    [self.realTimeView addSubview:self.focusBoxView];
    
    //顶部区域
    SSThemedView *headerView = [[SSThemedView alloc] init];
    headerView.backgroundColorThemeKey = kColorBackground9;
    [self.view addSubview:headerView];
    [headerView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.view.mas_left);
        make.top.equalTo(self.view.mas_top);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(80 + topInset);
    }];
    
    // 录像进度条背景view
    SSThemedView *progressTintView = [[SSThemedView alloc] init];
    progressTintView.backgroundColorThemeKey = kColorBackground15;
    [headerView addSubview:progressTintView];
    [progressTintView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(headerView.mas_left);
        make.right.equalTo(headerView.mas_right);
        make.top.equalTo(headerView.mas_top).offset(topInset);
        make.height.mas_equalTo(5);
    }];
    
    // 录像进度条
    self.progressView = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
    self.progressView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
    self.progressView.trackTintColor = [UIColor clearColor];
    self.progressView.progress = 0 ;
    self.progressView.progressTintColor = [UIColor colorWithHexString:@"f85959"];
    [progressTintView addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(progressTintView);
    }];
    
    [headerView bringSubviewToFront:self.progressView];
    
    // 视频录制计时label
    self.timerLabel = [[SSThemedLabel alloc] init];
    self.timerLabel.textColor = [UIColor whiteColor];
    self.timerLabel.font = [UIFont systemFontOfSize:20];
    self.timerLabel.text = @"00:00";
    self.timerLabel.textAlignment = NSTextAlignmentCenter;
    [headerView addSubview:self.timerLabel];
    [self.timerLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.size.mas_equalTo(CGSizeMake(100, 30));
        make.centerX.equalTo(headerView.mas_centerX);
        make.centerY.equalTo(headerView.mas_centerY).offset(topInset / 2);
    }];
    
    self.videoTimer = [[TTCommonTimerObj alloc] init];
    [self.videoTimer maxTime:TTCameraMaxVideoTime];
    [self.videoTimer minTime:3];
    self.videoTimer.delegate = self;
    
    self.progressTimer = [[TTCommonTimerObj alloc] init];
    [self.progressTimer maxTime:TTCameraMaxVideoTime];
    [self.progressTimer timerInterval:0.01];
    self.progressTimer.delegate = self;
    
    // 闪光灯
    CGRect headerBtnFrame = CGRectMake(0, 0, 100, 100);
    self.flashBtn = [[TTAlphaThemedButton alloc] initWithFrame:headerBtnFrame];
    self.flashBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    [self.flashBtn addTarget:self action:@selector(checkFlashAndTorchMode) forControlEvents:UIControlEventTouchUpInside];
    self.flashBtn.imageName = @"chatroom_video_icon_flashlight_close.png";
    [headerView addSubview:self.flashBtn];
    
    // 摄像头切换
    TTAlphaThemedButton *switchCameraBtn = [[TTAlphaThemedButton alloc] initWithFrame:headerBtnFrame];
    switchCameraBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    [switchCameraBtn addTarget:self action:@selector(switchCameraButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    switchCameraBtn.imageName = @"chatroom_video_icon_front_facing_camera.png";
    [headerView addSubview:switchCameraBtn];
    
    // 取消拍照和录像
    cancelBtn = [[TTAlphaThemedButton alloc] initWithFrame:headerBtnFrame];
    cancelBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -5, -10);
    [cancelBtn  addTarget:self action:@selector(cancelCameraAction:) forControlEvents:UIControlEventTouchUpInside];
    cancelBtn .imageName = @"chatroom_video_icon_close.png";
    [headerView addSubview:cancelBtn];
    
    CGSize btnSize = CGSizeMake(30, 30);
    [switchCameraBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(headerView.mas_right).offset(-20);
        make.centerY.equalTo(headerView).offset(topInset / 2);;
        make.size.mas_equalTo(btnSize);
    }];
    
    [self.flashBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(switchCameraBtn.mas_left).offset(-20);
        make.centerY.equalTo(headerView).offset(topInset / 2);;
        make.size.mas_equalTo(btnSize);
    }];
    
    [cancelBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(headerView.mas_left).offset(20);
        make.centerY.equalTo(headerView).offset(topInset / 2);;
        make.size.mas_equalTo(btnSize);
    }];
    
    //底部区域
    CGFloat bottomInset = 0;
    if ([TTDeviceHelper isIPhoneXDevice]){
        bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    }
    SSThemedView *footerView = [[SSThemedView alloc] init];
    footerView.backgroundColorThemeKey = kColorBackground9;
    [self.view addSubview:footerView];
    [footerView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(140 + bottomInset);
    }];
    
    
    // 小圆点
    self.redDot = [[UIView alloc] init];
    self.redDot.backgroundColor = [UIColor colorWithHexString:@"f85959"];
    self.redDot.layer.cornerRadius = 3;
    [footerView addSubview:self.redDot];
    [self.redDot mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(footerView.mas_top).offset(8);
        make.centerX.equalTo(footerView.mas_centerX);
        make.size.mas_equalTo(CGSizeMake(6, 6));
    }];
    
    //照片和视频切换指示
    self.typeIndicateView = [[SSThemedScrollView alloc] init];
    UIButton *videoLabel = [[UIButton alloc] init];
    videoLabel.tag = TTLiveCameraCurrentStateVideo;
    [videoLabel setTitle:@"视频" forState:UIControlStateNormal];
    videoLabel.titleLabel.font = [UIFont systemFontOfSize:14];
    [videoLabel setTitleColor:[UIColor colorWithHexString:@"f85959"] forState:UIControlStateNormal];
    [self.typeIndicateView addSubview:videoLabel];
    
    WeakSelf;
    [videoLabel addTarget:self withActionBlock:^{
        StrongSelf;
        [self switchVideoAndPhotoState:TTLiveCameraCurrentStateVideo];
    } forControlEvent:UIControlEventTouchUpInside];
    
    
    UIButton *photoLabel = [[UIButton alloc] init];
    photoLabel.tag = TTLiveCameraCurrentStatePhoto;
    [photoLabel setTitle:@"照片" forState:UIControlStateNormal];
    photoLabel.titleLabel.font = [UIFont systemFontOfSize:14];
    [photoLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.typeIndicateView addSubview:photoLabel];
    [photoLabel addTarget:self withActionBlock:^{
        StrongSelf;
        [self switchVideoAndPhotoState:TTLiveCameraCurrentStatePhoto];
    } forControlEvent:UIControlEventTouchUpInside];
    [footerView addSubview:self.typeIndicateView];
    [self.typeIndicateView mas_makeConstraints:^(MASConstraintMaker *make){
        make.edges.equalTo(footerView);
    }];
    [photoLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.typeIndicateView.mas_top).offset(20);
        make.centerX.equalTo(self.typeIndicateView.mas_centerX).offset(60);
    }];
    [videoLabel mas_makeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(self.typeIndicateView.mas_top).offset(20);
        make.centerX.equalTo(self.typeIndicateView.mas_centerX);
    }];
    
    // 拍照和录制的按钮
    CGFloat wrapperRadius = 80;
    SSThemedView *btnWrapper = [[SSThemedView alloc] init];
    btnWrapper.layer.cornerRadius = wrapperRadius/2;
    btnWrapper.backgroundColor = [UIColor colorWithWhite:1.f alpha:0.2];
    [footerView addSubview:btnWrapper];
    [btnWrapper mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(footerView);
        make.centerY.equalTo(footerView).offset(18 - bottomInset / 2);
        make.size.mas_equalTo(CGSizeMake(wrapperRadius, wrapperRadius));
    }];
    
    // 按钮里面的环
    self.whiteCircle = [[TTBezierPathCircleView alloc] initWithFrame:CGRectMake(0, 0, wrapperRadius, wrapperRadius)];
    [self.whiteCircle drawCircleWithRadiusValue:M_PI*2];
    [btnWrapper addSubview:self.whiteCircle];
    
    self.progressCircle = [[TTBezierPathCircleView alloc] initWithFrame:self.whiteCircle.frame];
    [self.progressCircle setCircleViewColor:[UIColor colorWithHexString:@"f85959"]];
    [btnWrapper addSubview:self.progressCircle];
    
    
    CGFloat actionBtnRadius = 74;
    
    // 视频录制button
    self.videoRecordButton = [[SSThemedButton alloc] init];
    [self.videoRecordButton setTitle:@"按住拍" forState:UIControlStateNormal];
    [self.videoRecordButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.videoRecordButton.titleLabel.font = [UIFont systemFontOfSize:14];
    self.videoRecordButton.backgroundColor = [UIColor colorWithHexString:@"f85959"];
    self.videoRecordButton.layer.cornerRadius = actionBtnRadius/2;
    UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleVideoRecordGesture:)];
    longPressGesture.minimumPressDuration = 0.2;
    longPressGesture.allowableMovement = 5;
    [self.videoRecordButton addGestureRecognizer:longPressGesture];
    [btnWrapper addSubview:self.videoRecordButton];
    [self.videoRecordButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.center.equalTo(btnWrapper);
        make.size.mas_equalTo(CGSizeMake(actionBtnRadius, actionBtnRadius));
    }];
    
    
    // 拍照button
    self.photoTakenButton = [[TTAlphaThemedButton alloc] init];
    self.photoTakenButton.backgroundColor = [UIColor colorWithHexString:@"f85959"];
    self.photoTakenButton.layer.cornerRadius = actionBtnRadius/2;
    [self.photoTakenButton addTarget:self action:@selector(photoTakenButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [btnWrapper addSubview:self.photoTakenButton];
    [self.photoTakenButton mas_makeConstraints:^(MASConstraintMaker *make){
        make.center.equalTo(btnWrapper);
        make.size.mas_equalTo(CGSizeMake(actionBtnRadius, actionBtnRadius));
    }];
    
    
    // 滑动调整焦距,产品说先隐藏掉
    self.factorSlider = [[UISlider alloc] init];
    UIImage *thumbImage = [UIImage imageNamed:@"ad_banner_close_btn_icon_press"];
    self.factorSlider.value = 1.0;
    self.factorSlider.hidden = YES;
    self.factorSlider.minimumValue = 1.0;
    self.factorSlider.maximumValue = TTCameraMaxFactor;
    [self.factorSlider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [self.factorSlider setThumbImage:thumbImage forState:UIControlStateNormal];
    [self.factorSlider setMaximumTrackTintColor:[UIColor grayColor]];
    [self.factorSlider setMinimumTrackTintColor:[UIColor whiteColor]];
    [self.factorSlider addTarget:self action:@selector(factorValueChangedSlider:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.factorSlider];
    [self.factorSlider mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.view.mas_left).offset(10);
        make.bottom.equalTo(footerView.mas_top);
        make.right.equalTo(self.view.mas_right).offset(-10);
        make.height.equalTo(@40);
    }];
    
    
    // 照片预览View
    self.photoPreView = [[SSThemedImageView alloc] initWithFrame:self.view.frame];
    self.photoPreView.contentMode = UIViewContentModeScaleAspectFit;
    self.photoPreView.hidden = YES;
    self.photoPreView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.photoPreView];
    
    // 视频预览View
    self.videoPreView = [[SSThemedView alloc] initWithFrame:self.view.frame];
    self.videoPreView.hidden = YES;
    self.videoPreView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.videoPreView];
    
    // 视频播放View
    self.videoPrePlayer = [[AVPlayer alloc] initWithURL:self.videoUrl];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerDidFinishPlay:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:self.videoPrePlayer.currentItem];
    self.playerLayer = [AVPlayerLayer playerLayerWithPlayer:self.videoPrePlayer];
    self.playerLayer.frame = self.videoPreView.frame;
    [self.videoPreView.layer addSublayer:self.playerLayer];
    
    
    /// 预览界面操作区
    self.previewActionView = [[SSThemedView alloc] init];
    self.previewActionView.backgroundColor =  [UIColor colorWithWhite:0.f alpha:0.5];
    self.previewActionView.hidden = YES;
    [self.view addSubview:self.previewActionView];
    [self.previewActionView mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.view.mas_left);
        make.bottom.equalTo(self.view.mas_bottom);
        make.right.equalTo(self.view.mas_right);
        make.height.mas_equalTo(73 + bottomInset);
    }];
    
    TTAlphaThemedButton *reActionBtn = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];
    [reActionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [reActionBtn setTitle:@"重拍" forState:UIControlStateNormal];
    reActionBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [reActionBtn addTarget:self action:@selector(restartMedioAction) forControlEvents:UIControlEventTouchUpInside];
    [self.previewActionView addSubview:reActionBtn];
    [reActionBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(self.previewActionView.mas_left).offset(28);
        make.centerY.equalTo(self.previewActionView.mas_centerY).offset(-bottomInset/2);
    }];
    
    TTAlphaThemedButton *finishBtn = [[TTAlphaThemedButton alloc] initWithFrame:reActionBtn.frame];
    self.finishBtn = finishBtn;
    [finishBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [finishBtn setTitle:@"使用视频" forState:UIControlStateNormal];
    finishBtn.titleLabel.font = [UIFont systemFontOfSize:17];
    [finishBtn addTarget:self action:@selector(finishAndSaveMediaAction) forControlEvents:UIControlEventTouchUpInside];
    [self.previewActionView addSubview:finishBtn];
    [finishBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.right.equalTo(self.previewActionView.mas_right).offset(-28);
        make.centerY.equalTo(self.previewActionView.mas_centerY).offset(-bottomInset/2);
    }];
    
    // 播放按钮
    self.playBtn = [[TTAlphaThemedButton alloc] init];
    self.playBtn.titleColorThemeKey = kColorText10;
    [self.playBtn setImage:[UIImage imageNamed:@"chatroom_video_preview_play"] forState:UIControlStateNormal];
    [self.playBtn addTarget:self action:@selector(videoPlayerStart:) forControlEvents:UIControlEventTouchUpInside];
    [self.previewActionView addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make){
        make.centerX.equalTo(self.previewActionView.mas_centerX);
        make.centerY.equalTo(self.previewActionView.mas_centerY).offset(-bottomInset/2);
        make.width.equalTo(@50);
        make.height.equalTo(@200);
    }];
}

- (void)showVideoRecordButton:(BOOL)show
{
    self.videoRecordButton.hidden = !show;
    self.photoTakenButton.hidden = show;
}

#pragma mark -- 点击操作与交互
//相机手势处理
- (void)handleRealTimeViewGesture:(UIGestureRecognizer *)gesture
{
    // 缩放
    if ([gesture isKindOfClass:[UIPinchGestureRecognizer class]]) {
        UIPinchGestureRecognizer *pinchGesture = (UIPinchGestureRecognizer *)gesture;
        [self factorValueChangedGesture:pinchGesture];
        
    } // 照相和录像切换
    else if ([gesture isKindOfClass:[UISwipeGestureRecognizer class]]){
        UISwipeGestureRecognizer *swipeGesture = (UISwipeGestureRecognizer *)gesture;
        if (swipeGesture.direction == UISwipeGestureRecognizerDirectionRight) {
            [self switchVideoAndPhotoState:TTLiveCameraCurrentStateVideo];
        } else if (swipeGesture.direction == UISwipeGestureRecognizerDirectionLeft){
            [self switchVideoAndPhotoState:TTLiveCameraCurrentStatePhoto];
        }
    }
}

- (void)switchVideoAndPhotoState:(TTLiveCameraCurrentState)state
{
    // 关闭闪光灯or电筒
    [self closeFlashOrTorchIfNeed];
    
    self.currentState = state;
    
    switch (self.currentState) {
        case TTLiveCameraCurrentStateVideo:
        {
            // 切换到视频录制
            self.videoCamera.cameraMode = HTSCameraModeVideo;
            
            // refresh UI
            self.playBtn.hidden = self.timerLabel.hidden = self.whiteCircle.hidden = self.progressView.superview.hidden = NO;
            [self.progressCircle setCircleViewColor:[UIColor colorWithHexString:@"f85959"]];
            [self.progressCircle drawCircleWithRadiusValue:0];
            [self.finishBtn setTitle:@"使用视频" forState:UIControlStateNormal];
            [self.typeIndicateView setContentOffset:CGPointMake(0, 0) animated:YES];
            [self showVideoRecordButton:YES];
            
            // event track
            [self eventTrackWithLabel:@"switch_to_video"];
        }
            break;
            
        case TTLiveCameraCurrentStatePhoto:
        {
            // 切换到拍照
            self.videoCamera.cameraMode = HTSCameraModePhoto;
            
            // refresh UI
            self.playBtn.hidden = self.timerLabel.hidden = self.whiteCircle.hidden = self.progressView.superview.hidden = YES;
            [self.finishBtn setTitle:@"使用照片" forState:UIControlStateNormal];
            [self.typeIndicateView setContentOffset:CGPointMake(60, 0) animated:YES];
            [self showVideoRecordButton:NO];
            
            // event track
            [self eventTrackWithLabel:@"switch_to_audio"];
        }
            break;
            
        default:
            break;
    }
    
    //改变指示文字的样式
    for (UIView *view in self.typeIndicateView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *label = (UIButton *)view;
            if (label.tag == self.currentState) {
                [label setTitleColor: [UIColor colorWithHexString:@"f85959"] forState:UIControlStateNormal];
            } else {
                [label setTitleColor: [UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }
}

//聚焦框的表现
- (void)focusBoxAnimation:(CGPoint)location
{
    self.focusBoxView.hidden = NO;
    self.focusBoxView.center = location;
    self.focusBoxView.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
    [UIView animateWithDuration:0.3 animations:^(){
        self.focusBoxView.transform = CGAffineTransformMakeScale(0.9f, 0.9f);
    } completion:^(BOOL finished){
        self.focusBoxView.hidden = YES;
    }];
}

//缩放拉近镜头
- (void)cameraAVConnectionFactorChangedValue:(CGFloat)factor velocity:(CGFloat)velocity
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    CGFloat newFactor = factor;    //设置最大焦距
    CGFloat maxFactor = TTCameraMaxFactor;
    
    if (newFactor >= maxFactor) {
        newFactor = maxFactor;
    } else if (newFactor < 1.0){
        newFactor = 1.0;
    }
    
    CGFloat scale = newFactor/device.videoZoomFactor;
    if (scale < 1.0) {
        scale = 1.0;
    }
    
    [UIView animateWithDuration:1/velocity animations:^{
        [device lockForConfiguration:nil];
        device.videoZoomFactor = newFactor;
        [device unlockForConfiguration];
    }];
}

//slider滑动方式
- (void)factorValueChangedSlider:(UISlider *)slider
{
    [self cameraAVConnectionFactorChangedValue:slider.value velocity:50.0];
}

// 手势缩放方式
- (void)factorValueChangedGesture:(UIPinchGestureRecognizer *)pinchGesture
{
    CGFloat scale = pinchGesture.scale;
    
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    CGFloat newFactor = device.videoZoomFactor * scale;
    [self cameraAVConnectionFactorChangedValue:newFactor velocity:pinchGesture.velocity];
    // 同时修改滑动块
    // [self.factorSlider setValue:newFactor animated:YES];
}

//退出
- (void)cancelCameraAction:(id)sender
{
    // 取消视频录制
    [self.videoCamera cancelVideoRecord];
    
    [self dismissViewControllerAnimated:YES completion:^{
        if ([self.delegate respondsToSelector:@selector(ttCameraViewControllerDidCanceled:)]) {
            [self.delegate ttCameraViewControllerDidCanceled:self];
        }
    }];
    
    // event track
    if (sender) {
        if (self.currentState == TTLiveCameraCurrentStateVideo) {
            [self eventTrackWithLabel:@"video_cancel"];
        } else if (self.currentState == TTLiveCameraCurrentStatePhoto) {
            [self eventTrackWithLabel:@"photo_cancel"];
        }
    }
}

//闪光灯与电筒
- (void)checkFlashAndTorchMode
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasFlash] || ![device hasTorch]) {
        return;
    }
    
    [device lockForConfiguration:nil];
    
    if (self.currentState == TTLiveCameraCurrentStatePhoto) {
        
        if (AVCaptureFlashModeOff == device.flashMode) {
            self.flashBtn.imageName = @"chatroom_video_icon_flashlight.png";
            device.flashMode = AVCaptureFlashModeOn;
            // event track
            [self eventTrackWithLabel:@"open_flash"];
        } else if (AVCaptureFlashModeOn == device.flashMode) {
            self.flashBtn.imageName = @"chatroom_video_icon_flashlight_close.png";
            device.flashMode = AVCaptureFlashModeOff;
            // event track
            [self eventTrackWithLabel:@"close_flash"];
        }
        
    } else if (self.currentState == TTLiveCameraCurrentStateVideo) {
        
        if (AVCaptureTorchModeOff == device.torchMode) {
            self.flashBtn.imageName = @"chatroom_video_icon_flashlight.png";
            device.torchMode = AVCaptureTorchModeOn;
        } else if (AVCaptureTorchModeOn == device.torchMode) {
            self.flashBtn.imageName = @"chatroom_video_icon_flashlight_close.png";
            device.torchMode = AVCaptureTorchModeOff;
        }
    }
    
    [device unlockForConfiguration];
}

- (void)closeFlashOrTorchIfNeed
{
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (![device hasFlash] || ![device hasTorch]) {
        return;
    }
    
    [device lockForConfiguration:nil];
    if (self.currentState == TTLiveCameraCurrentStatePhoto) {
        if (AVCaptureFlashModeOn == device.flashMode) {
            device.flashMode = AVCaptureFlashModeOff;
        }
    } else if (self.currentState == TTLiveCameraCurrentStateVideo) {
        if (AVCaptureTorchModeOn == device.torchMode) {
            device.torchMode = AVCaptureTorchModeOff;
        }
    }
    [device unlockForConfiguration];
    
    self.flashBtn.imageName = @"chatroom_video_icon_flashlight_close.png";
}

- (void)switchCameraButtonClick:(UIButton *)sender
{
    // 切换前后摄像头
    [self.videoCamera switchCameraSource];
    
    switch ([self.videoCamera currCameraPosition]) {
        case AVCaptureDevicePositionBack:
        {
            if (self.beautyModeEnable) {
                [self.videoCamera applyFilter:HTSFilterNone];
            }
            self.flashBtn.hidden = NO;
            // event track
            [self eventTrackWithLabel:@"open_back"];
        } break;
            
        case AVCaptureDevicePositionFront:
        {
            if (self.beautyModeEnable) {
                [self.videoCamera applyBeautify:HTSBeautifyNature];
//                [self.videoCamera applyFilter:HTSFilterBeautify];
            }
            self.flashBtn.hidden = YES;
            // event track
            [self eventTrackWithLabel:@"open_front"];
        } break;
            
        default:
            break;
    }
}

- (void)photoTakenButtonPressed:(UIButton *)button
{
    [self enableRealTimeInteraction:NO];
    //TODO:
    [self.videoCamera captureSourcePhotoAsImageWithCompletionHandler:^(UIImage * _Nonnull processedImage, NSError * _Nonnull error) {
        //NSLog(@"\n%s\n%@", __func__, error);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!processedImage || error) {
                TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"提示" message:@"拍摄失败，请重新拍摄" preferredType:TTThemedAlertControllerTypeAlert];
                [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
                    [self restartMedioAction];
                }];
                [alert showFrom:self animated:YES];
                
            } else {
                [self.photoPreView setImage:processedImage];
                self.photoPreView.hidden = NO;
                self.previewActionView.hidden = NO;
                self.preViewImage = processedImage;
                [self stopVideoProcess];
            }
        });
    }];
//    [self.videoCamera capturePhotoAsImageWithOrientation:UIImageOrientationUp withCompletionHandler:^(UIImage * _Nonnull processedImage, NSError * _Nonnull error) {
//        NSLog(@"\n%s\n%@", __func__, error);
//
//        if (!processedImage || error) {
//            TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"提示" message:@"拍摄失败，请重新拍摄" preferredType:TTThemedAlertControllerTypeAlert];
//            [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
//                [self restartMedioAction];
//            }];
//            [alert showFrom:self animated:YES];
//
//        } else {
//
//            [self.photoPreView setImage:processedImage];
//            self.photoPreView.hidden = NO;
//            self.previewActionView.hidden = NO;
//        }
//    }];
    
    // event track
    [self eventTrackWithLabel:@"photo_click"];
}

- (void)handleVideoRecordGesture:(UIGestureRecognizer *)gesture
{
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
        {
            [self.videoCamera startVideoRecordWithRate:1.0];
            
            // event track
            if (!self.typeIndicateView.hidden) {
                [self eventTrackWithLabel:@"video_start"];
            }
            
            [self.progressTimer startTimer];
            [self.videoTimer startTimer];
            self.videoEndAction = NO;
            
            [self enableRealTimeInteraction:NO];
            
            self.videoRecordButton.alpha = 0.5;
            cancelBtn.hidden = YES;
        }
            break;
            
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateFailed:
        {
            [self.videoCamera pauseVideoRecord];
            
            [self.videoTimer clearTimer];
            [self.progressTimer clearTimer];
            
            self.videoRecordButton.alpha = 1;
        }
            break;
            
        default:
            break;
    }
}

// 修改交互状态，防止错乱
- (void)enableRealTimeInteraction:(BOOL)enable
{
    self.redDot.hidden = self.typeIndicateView.hidden = !enable;
    self.realTimeView.userInteractionEnabled = enable;
    for (UIView *view in self.typeIndicateView.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            view.userInteractionEnabled = enable;
        }
    }
}

//停止拍摄参数
- (void)stopVideoProcess
{
    self.timerLabel.text = @"00:00";
    [self.progressCircle drawCircleWithRadiusValue:0];
    [self.progressView setProgress:0 animated:YES];
    self.videoEndAction = YES;
    self.previewActionView.hidden = NO;
    self.photoPreView.hidden = NO;
    self.photoPreView.image = self.preViewImage;
    self.videoPreView.hidden = YES;
}

// 重拍
- (void)restartMedioAction
{
    //恢复交互
    [self enableRealTimeInteraction:YES];
    
    self.preViewImage = nil;
    self.previewActionView.hidden = YES;
    
    //拍照
    self.photoPreView.image = nil;
    self.photoPreView.hidden = YES;
    
    //摄像
    self.videoPreView.hidden = YES;
    [self.videoPrePlayer pause];
    [self.videoPrePlayer.currentItem cancelPendingSeeks];
    [self.videoPrePlayer.currentItem.asset cancelLoading];
    
    [self playerDidFinishPlay:nil];
    
    // event track
    if (self.currentState == TTLiveCameraCurrentStateVideo) {
        [self eventTrackWithLabel:@"video_reclick"];
    } else if (self.currentState == TTLiveCameraCurrentStatePhoto) {
        [self eventTrackWithLabel:@"photo_reclick"];
    }
}

// 完成拍摄,预览界面,点击完成和使用
- (void)finishAndSaveMediaAction
{
    ALAuthorizationStatus author = [ALAssetsLibrary authorizationStatus];
    if (author == ALAuthorizationStatusRestricted || author == ALAuthorizationStatusDenied){
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"无访问权限" message:@"请在手机的「设置-隐私-照片」选项中，允许爱看访问你的相册" preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alert showFrom:self animated:YES];
        return;
    }
    
    switch (self.currentState) {
        case TTLiveCameraCurrentStatePhoto:
            [self photoSaveAction];
            break;
            
        case TTLiveCameraCurrentStateVideo:
            [self videoSaveAction];
            break;
            
        default:
            break;
    }
}

- (void)photoSaveAction
{
    [self cancelCameraAction:nil];
    
    UIImage *resultImage = self.photoPreView.image;
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeImageToSavedPhotosAlbum:resultImage.CGImage orientation:ALAssetOrientationUp completionBlock:^(NSURL *assetURL, NSError *error) {
        if ([self.delegate respondsToSelector:@selector(ttCameraPhotoBackAssetUrl:image:)]) {
            [self.delegate ttCameraPhotoBackAssetUrl:assetURL image:resultImage];
        }
    }];

    // event track
    [self eventTrackWithLabel:@"photo_use"];
}

- (void)videoSaveAction
{
    [self cancelCameraAction:nil];
    
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    [library writeVideoAtPathToSavedPhotosAlbum:self.videoUrl completionBlock:^(NSURL *assetURL, NSError *error){
        if ([self.delegate respondsToSelector:@selector(ttCameraVideoBack:previewImage:)]) {
            [self.delegate ttCameraVideoBack:self.videoUrl previewImage:self.preViewImage];
        }
    }];
    
    // event track
    [self eventTrackWithLabel:@"video_use"];
}

//视频播放
- (void)videoPlayerStart:(UIButton *)btn
{
    ///...
    // TODO: 需要知道视频已录制结束
//    if (self.videoCamera.status != HTSCameraStatusIdle) {
//        return;
//    }
    
    //播放与暂停
    if (!btn.selected) {
        
        //刚开始播放的时候的加载
        if (CMTimeCompare(kCMTimeZero, self.videoCurrentTime) == 0) {
            AVPlayerItem *item = [[AVPlayerItem alloc] initWithURL:self.videoUrl];
            [self.videoPrePlayer replaceCurrentItemWithPlayerItem:item];
        }
        
        //播放器是否准备好
        if (self.videoPrePlayer.status == AVPlayerStatusReadyToPlay) {
            
            //视频是否加载成功
            if(self.videoPrePlayer.currentItem.status == AVPlayerItemStatusFailed){
                // NSLog(@"相视频机预览playItemError---%@",self.videoPrePlayer.currentItem.error);
                [self cameraVideoFailed];
                return;
            }
            
            if (self.videoPreView.hidden) {
                self.videoPreView.hidden = NO;
            }
            
            [self.videoPrePlayer seekToTime:self.videoCurrentTime toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished){
                [self.videoPrePlayer play];
            }];
            
            btn.selected = YES;
            [btn setImage:[UIImage imageNamed:@"chatroom_video_preview_stop"] forState:UIControlStateNormal];
            
        } else {
            //播放器未就绪
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                      indicatorText:@"视频正在保存中..."
                                     indicatorImage:nil
                                        autoDismiss:YES
                                     dismissHandler:nil];
        }
        
    } else {
        
        btn.selected = NO;
        [btn setImage:[UIImage imageNamed:@"chatroom_video_preview_play"] forState:UIControlStateNormal];
        
        [self.videoPrePlayer pause];
        self.videoCurrentTime = self.videoPrePlayer.currentTime;
    }
}

//视频预览播放完毕
- (void)playerDidFinishPlay:(NSNotification *)notice
{
    self.playBtn.selected = NO;
    self.videoCurrentTime = kCMTimeZero;
    [self.playBtn setImage:[UIImage imageNamed:@"chatroom_video_preview_play"] forState:UIControlStateNormal];
}


//被外界中断情况
- (void)sessionInterruptionStartAction
{
    [self.videoTimer clearTimer];
    [self.progressTimer clearTimer];
}

- (void)sessionInterruptioFinishedeAction
{
    // NSLog(@"finished interruption!");
}

//统计参数
- (void)setSsTrackerDic:(NSDictionary *)ssTrackerDic
{
    _ssTrackerDic = ssTrackerDic;
}

#pragma mark -- Notification

- (void)applicationDidEnterBackgroundNotification:(NSNotification *)notification
{
    if (self.currentState == TTLiveCameraCurrentStateVideo) {
        self.flashBtn.imageName = @"chatroom_video_icon_flashlight_close.png";
    }
}

#pragma mark -- TTCommonTimerObjDelegate

- (void)ttTimer:(TTCommonTimerObj *)timer StopLessThanMinTime:(BOOL)isLess
{
    if (timer != self.videoTimer) {
        return;
    }
    
    // 停止视频录制
    [self.videoCamera pauseVideoRecord];
    
    if (isLess) {
        // event track
        [self eventTrackWithLabel:@"video_less_3s"];
        
        self.previewActionView.hidden = self.videoPreView.hidden = self.photoPreView.hidden = YES;
        
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"提示" message:@"最少录制3秒" preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
            [self restartMedioAction];
        }];
        [alert showFrom:self animated:YES];
    } else {
        // event track
        [self eventTrackWithLabel:@"video_more_3s"];
    }
    cancelBtn.hidden = NO;
}

- (void)ttTimerReachMaxTimeStop:(TTCommonTimerObj *)timer
{
    if (timer != self.videoTimer) {
        return;
    }
    // event track
    [self eventTrackWithLabel:@"video_more_60s"];
}

- (void)ttTimer:(TTCommonTimerObj *)timer EachIntervalAction:(float)currentCountTime
{
    if (timer == self.videoTimer) {
        NSInteger totalSeconds = (NSInteger)currentCountTime;
        self.timerLabel.text = [self getTimeStringFromSeconds:totalSeconds];
    } else if (timer == self.progressTimer) {
        CGFloat percentage = currentCountTime/TTCameraMaxVideoTime;
        [self.progressCircle drawCircleWithRadiusValue:percentage * M_PI * 2];
        [self.progressView setProgress:percentage animated:YES];
    }
}

//录制失败
- (void)cameraVideoFailed
{
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"提示" message:@"录制失败，请重新录制" preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeCancel actionBlock:^{
        [self.videoTimer clearTimer];
        [self.progressTimer clearTimer];
        [self restartMedioAction];
    }];
    [alert showFrom:self animated:YES];
}

// 计时字符串
- (NSString *)getTimeStringFromSeconds:(NSInteger)totalSeconds
{
    NSString *minutes;
    NSString *seconds;
    
    if (totalSeconds / 60 > 9) {
        minutes = [NSString stringWithFormat:@"%ld",totalSeconds / 60];
    } else {
        minutes = [NSString stringWithFormat:@"0%ld",totalSeconds / 60];
    }
    
    if (totalSeconds % 60 > 9) {
        seconds = [NSString stringWithFormat:@"%ld",totalSeconds % 60];
    } else {
        seconds = [NSString stringWithFormat:@"0%ld",totalSeconds % 60];
    }
    
    return [NSString stringWithFormat:@"%@:%@",minutes,seconds];
}

- (void)eventTrackWithLabel:(NSString *)label
{
    if (isEmptyString(label)) {
        return;
    }
    wrapperTrackEventWithCustomKeys(@"liveshot" , label, nil, nil, self.ssTrackerDic);
}

@end
