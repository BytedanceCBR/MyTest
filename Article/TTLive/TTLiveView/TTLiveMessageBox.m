
//
//  TTLiveMessageBox.m
//  Article
//
//  Created by xuzichao on 16/1/6.
//
//

#import "TTLiveMessageBox.h"
#import <AVFoundation/AVFoundation.h>

#import "TTAlphaThemedButton.h"
#import "NSStringAdditions.h"
#import "TTAudioRecorder.h"
#import "TTCommonTimerObj.h"
#import "NSStringAdditions.h"

#import "TTIndicatorView.h"

#import "TTLiveMessage.h"

#import <Masonry.h>
#import <TTImagePicker/TTImagePicker.h>

///...
#import "TTThemedAlertController.h"

#import "TTLiveMainViewController.h"
#import "HPGrowingTextView.h"

///...
#import "TTLiveCameraViewController.h"
#import "TTLiveTopBannerInfoModel.h"
#import "TTLivePariseView.h"
#import "TTImageView.h"

#import "UIImage+Masking.h"

//尺寸
#define TTLiveTextUmengName                   @"livetext"
#define TTLiveShotUmengName                   @"liveshot"
#define TTLiveAudioUmengName                  @"liveaudio"
#define TTLiveAlbumUmengName                  @"livelocal"

//标示
typedef enum {
    toastViewImageTag,
    toastViewNumTag,
    toastViewTextTag,
    replyTipViewTag,
    replyUserLabelTag
} TTLiveMessageBoxTag;


@interface TTLiveMessageBox() <TTAudioRecorderDelegate, TTLiveCameraVCDelegate, HPGrowingTextViewDelegate, TTCommonTimerObjDelegate,TTImagePickerControllerDelegate,TTImagePickTrackDelegate>

@property (nonatomic, strong) SSThemedView *audioRecordViewBtn; //长按录音区域
@property (nonatomic, strong) HPGrowingTextView *textFieldView;  //输入框
@property (nonatomic, strong) SSThemedImageView *textImageView;  //输入框图标
@property (nonatomic, strong) SSThemedLabel *textFieldButtonView; //输入框弹起按钮
@property (nonatomic, strong) SSThemedImageView *speakerAvatar;
@property (nonatomic, strong) SSThemedButton *sendTextBtn;  //文本发送按钮
@property (nonatomic, strong) SSThemedView   *btnWrapperView; //媒体按钮包裹视图
@property (nonatomic, assign) TTLiveMessageBoxType messageType;
@property (nonatomic, strong) TTAudioRecorder *audioRecorder;
@property (nonatomic, strong) SSThemedView  *audioToastView; //语音提示
@property (nonatomic, assign) BOOL  audioCanceling; //是否处于上滑动取消状态
@property (nonatomic, strong) NSTimer *audioPowerTimer;
@property (nonatomic, strong) TTCommonTimerObj *audioCountTimer;
@property (nonatomic, assign) BOOL preinstallTime;
@property (nonatomic, strong) TTLiveMessage *replyedMsg;
@property (nonatomic, copy) NSDictionary *ssTrackerDic;
@property (nonatomic, assign) BOOL  hasBeforeMessage;
@property (nonatomic, assign) BOOL  replyMode;
@property (nonatomic, strong) SSThemedLabel *audioTitleLabel;

@property (nonatomic, strong) SSThemedButton *audioBtn;

@property (nonatomic, strong) SSThemedView *inputBarView;
@property (nonatomic, strong) SSThemedButton *pariseButton;
@property (nonatomic, strong) TTImageView *pariseImageView;
@property (nonatomic, strong) SSThemedLabel *pariseCountLabel;

@end

@implementation TTLiveMessageBox {
    NSString *_previousEntry;
    NSString *_replyPreviousEntry;
    NSNumber *_replyId;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.hasBeforeMessage = NO;
        self.replyMode = NO;
        
        //语音录制计时
        self.preinstallTime = NO;
        self.audioCountTimer = [[TTCommonTimerObj alloc] init];
        self.audioCountTimer.delegate = self;
        [self.audioCountTimer timerInterval:1.0];
        [self.audioCountTimer maxTime:60.0];
        [self.audioCountTimer setPrepareTime:51.0];

        //通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [self clearTempVideoFileCache];
    [self.audioPowerTimer invalidate];
    self.audioPowerTimer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)themeChanged:(NSNotification *)notification {
    self.textFieldView.placeholderColor = [UIColor tt_themedColorForKey:kColorText1];
    self.textFieldView.textColor = [UIColor tt_themedColorForKey:kColorText1];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    if (self.tt_safeAreaInsets.bottom > 0){
        CGRect frameInWindow = [self convertRect:self.bounds toView:nil];
        frameInWindow.origin.y -= self.tt_safeAreaInsets.bottom;
        self.frame = [self.superview convertRect:frameInWindow fromView:nil];
    }
}

#pragma mark  --辅助函数
- (NSString *)adjustContentIfNeedWithContent:(NSString *)content{
    int maxLength = 30;
    if (content.length <= maxLength){
        return nil;
    }
    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"字数已达30字上限" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    NSRange maxLimitCharacterSequenceRange = [content rangeOfComposedCharacterSequenceAtIndex:maxLength - 1];
    NSString * resultContent = nil;
    if (maxLimitCharacterSequenceRange.location + maxLimitCharacterSequenceRange.length > maxLength) {
        resultContent = [content substringToIndex:maxLimitCharacterSequenceRange.location];
    }else {
        resultContent = [content substringToIndex:maxLength];
    }
    return resultContent;
}

- (void)setUpOnlyTextSubviews:(SSThemedView *)inputBarView
{
    self.sendTextBtn.hidden = YES;
    [_textFieldButtonView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.inputBarView).offset(-15);
    }];
    
    self.top = self.bottom - kRealHeightOfMsgBoxWithTypeTextOnly();
    self.height = kRealHeightOfMsgBoxWithTypeTextOnly();

    if ((![TTDeviceHelper isPadDevice]) && (self.type != TTLiveTypeMatch) && self.shouldShowPariseButton) {
        [_textFieldButtonView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_inputBarView).offset(15);
            make.top.equalTo(_inputBarView).offset(6);
            make.height.mas_equalTo(32);
            make.right.equalTo(self).offset(-93);
        }];
        
        self.pariseButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [_pariseButton addTarget:self action:@selector(clickPraiseButton:) forControlEvents:UIControlEventTouchUpInside];
        _pariseButton.userInteractionEnabled = YES;
        [self addSubview:_pariseButton];
        [_pariseButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_textFieldButtonView.mas_right).offset(9);
            make.right.equalTo(_inputBarView.mas_right);
            make.centerY.equalTo(_inputBarView.mas_centerY);
            make.height.mas_equalTo(32);
        }];
        
        self.pariseImageView = [[TTImageView alloc] init];
        _pariseImageView.enableNightCover = YES;
        _pariseImageView.layer.cornerRadius = 16;
        _pariseImageView.clipsToBounds = YES;
        _pariseImageView.userInteractionEnabled = NO;
        [_pariseButton addSubview:_pariseImageView];
        [_pariseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.left.equalTo(_pariseButton);
            make.width.mas_equalTo(32);
        }];
        
        self.pariseCountLabel = [[SSThemedLabel alloc] init];
        _pariseCountLabel.textAlignment = NSTextAlignmentLeft;
        _pariseCountLabel.textColorThemeKey = kColorText4;
        _pariseCountLabel.font = [UIFont systemFontOfSize:12];
        [_pariseButton addSubview:_pariseCountLabel];
        [_pariseCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_pariseImageView.mas_right).offset(4);
            make.right.equalTo(_pariseButton.mas_right);
            make.centerY.equalTo(_pariseButton.mas_centerY);
            make.height.mas_equalTo(12);
        }];
//        TTLiveMainViewController *chatroom = [self chatroom];
        self.mainChatroom.pariseCount = 0;
        [self.mainChatroom pariseView].hidden = NO;
//        [self.mainChatroom firstInDig];
    } else {
        [self.mainChatroom pariseView].hidden = YES;
    }

    [self showShareButtonOnly];
}

- (void)changePariseCommonImage:(NSString *)imageName {
    NSString *placeHoldImageNamed = @"chatroom_icon_bless";
    if (_disableSendMsg){
        placeHoldImageNamed = @"chatroom_icon_good_disableSendMsg";
        _pariseImageView.enableNightCover = NO;
        WeakSelf;
        [_pariseImageView setImageWithURLString:imageName placeholderImage:[UIImage imageNamed:placeHoldImageNamed] options:0 success:^(UIImage *image, BOOL cached) {
            StrongSelf;
            for (UIView *subView in self.pariseImageView.subviews){
                if ([subView isKindOfClass:[UIImageView class]] && subView != self.pariseImageView.imageView){
                    subView.hidden = YES;
                }
            }
            self.pariseImageView.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
            self.pariseImageView.imageView.tintColor = [UIColor tt_themedColorForKey:kColorText12];
        } failure:nil];
    }else{
        [_pariseImageView setImageWithURLString:imageName placeholderImage:[UIImage imageNamed:placeHoldImageNamed]];
    }
    _pariseImageUrl = imageName;
}

//图片声音视频
- (void)setUpCameraAlbumAudioTextSubviews:(SSThemedView *)inputBarView
{
    self.sendTextBtn.hidden = YES;
    [_textFieldButtonView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(_inputBarView).offset(6);
        make.height.mas_equalTo(32);
        make.right.equalTo(self.inputBarView.mas_right).offset(-15);
    }];
    
    self.top = self.bottom - kRealHeightOfMsgBoxWithTypeSupportAll();
    self.height = kRealHeightOfMsgBoxWithTypeSupportAll();
    
    //长按录音按钮
    if (_audioRecordViewBtn == nil) {
        self.audioRecordViewBtn = [[SSThemedView alloc] init];
        self.audioRecordViewBtn.hidden = YES;
        self.audioRecordViewBtn.backgroundColorThemeKey = kColorBackground4;
        self.audioRecordViewBtn.borderColorThemeKey = kColorLine1;
        self.audioRecordViewBtn.layer.cornerRadius = 4.f;
        self.audioRecordViewBtn.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        [self insertSubview:self.audioRecordViewBtn aboveSubview:self.textImageView];
        
        //约束
        [self.audioRecordViewBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.textFieldButtonView);
        }];
        
        UILongPressGestureRecognizer *longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleAudioRecorderGesture:)];
        longPressGesture.minimumPressDuration = 0;
        [self.audioRecordViewBtn addGestureRecognizer:longPressGesture];
        
        if (_audioTitleLabel == nil) {
            _audioTitleLabel = [[SSThemedLabel alloc] init];
            _audioTitleLabel.text = @"按住 说话";
            _audioTitleLabel.textAlignment = NSTextAlignmentCenter;
            _audioTitleLabel.textColorThemeKey = kColorText1;
            _audioTitleLabel.font = [UIFont systemFontOfSize:16];
            [_audioTitleLabel sizeToFit];
            [self.audioRecordViewBtn addSubview:_audioTitleLabel];
            
            [_audioTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.audioRecordViewBtn);
            }];
        }
    }
    
    //媒体消息按钮
    if (_btnWrapperView == nil) {
        self.btnWrapperView = [[SSThemedView alloc] init];
        self.btnWrapperView.backgroundColorThemeKey = kColorBackground4;
        self.btnWrapperView.hidden = NO;
        self.btnWrapperView.userInteractionEnabled = YES;
        
        [self addSubview:self.btnWrapperView];
        self.top = self.bottom - kRealHeightOfMsgBoxWithTypeTextOnly() - kHeightOfBottomMediaView;
        self.height = kRealHeightOfMsgBoxWithTypeTextOnly() + kHeightOfBottomMediaView;
        [self.btnWrapperView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top).offset(86);
            make.right.equalTo(self.mas_right);
            make.height.mas_equalTo(kHeightOfBottomMediaView);
        }];
        [self.inputBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(_btnWrapperView.mas_top);
        }];
        
        //本地照片视频
        SSThemedButton *albumLibraryBtn = [[SSThemedButton alloc] init];
        albumLibraryBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -16, -10);
        albumLibraryBtn.imageName = @"chatroom_picture";
        albumLibraryBtn.highlightedImageName = @"chatroom_picture_press";
        albumLibraryBtn.borderColorThemeKey = kColorLine1;
        [albumLibraryBtn addTarget:self action:@selector(openAlbumAssetsLibrary) forControlEvents:UIControlEventTouchUpInside];
        [self.btnWrapperView addSubview:albumLibraryBtn];
        
        //相机拍摄
        SSThemedButton *cameraBtn = [[SSThemedButton  alloc] init];
        cameraBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -16, -10);
        cameraBtn.imageName = @"chatroom_video";
        cameraBtn.highlightedImageName = @"chatroom_video_press";
        cameraBtn.borderColorThemeKey = kColorLine1;
        [cameraBtn addTarget:self action:@selector(openCameraViewController) forControlEvents:UIControlEventTouchUpInside];
        [self.btnWrapperView addSubview:cameraBtn];
        
        //语音发送
        _audioBtn = [[SSThemedButton  alloc] init];
        _audioBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-5, -10, -16, -10);
        _audioBtn.imageName = @"chatroom_voice";
        _audioBtn.highlightedImageName = @"chatroom_voice_press";
        _audioBtn.borderColorThemeKey = kColorLine1;
        [_audioBtn addTarget:self action:@selector(openAudoRecorder) forControlEvents:UIControlEventTouchUpInside];
        [self.btnWrapperView addSubview:_audioBtn];
        
        //约束
        [_audioBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.btnWrapperView.mas_left).offset(29);
            make.top.equalTo(self.btnWrapperView.mas_top);
        }];
        
        [cameraBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_audioBtn.mas_right).offset(29);
            make.top.equalTo(self.btnWrapperView.mas_top);
        }];
        
        [albumLibraryBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(cameraBtn.mas_right).offset(29);
            make.top.equalTo(self.btnWrapperView.mas_top);
        }];
    }
    if ((![TTDeviceHelper isPadDevice]) && (self.type != TTLiveTypeMatch) && self.shouldShowPariseButton) {
        [self.mainChatroom pariseView].hidden = NO;
    } else {
        [self.mainChatroom pariseView].hidden = YES;
    }
    [self showTextFieldOnly];
}

//是否显示媒体消息区域
- (void)setMessageViewType:(TTLiveMessageBoxType)messageType {
    self.messageType = messageType;
    
    //文字输入栏包裹视图
    if (_inputBarView == nil) {
        _inputBarView = [[SSThemedView alloc] init];
        _inputBarView.backgroundColorThemeKey = kColorBackground4;
        [self addSubview:_inputBarView];
        
        [self.inputBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.equalTo(self);
            make.bottom.equalTo(self);
            make.left.equalTo(self);
        }];
        
        //上边线
        SSThemedView *topLine = [[SSThemedView alloc] init];
        topLine.backgroundColorThemeKey = kColorLine7;
        [_inputBarView addSubview:topLine];
        
        [topLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_inputBarView.mas_left);
            make.top.equalTo(_inputBarView.mas_top);
            make.width.equalTo(_inputBarView);
            make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
        }];
    }
    
    //输入框
    if (_textFieldView == nil) {
        self.textFieldView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(14.f, 6.f, self.width - 14.f - 60.f, 32.f)];
        CGFloat verticalMargin = (_textFieldView.internalTextView.height - [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]].pointSize - 4.f) / 2.f;
        _textFieldView.internalTextView.textContainerInset = UIEdgeInsetsMake(verticalMargin, _textFieldView.internalTextView.textContainerInset.left, verticalMargin, _textFieldView.internalTextView.textContainerInset.right);
        self.textFieldView.contentInset = UIEdgeInsetsMake(0.f, 7.f, 0.f, 4.f);
        self.textFieldView.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]];
        self.textFieldView.borderColorThemeKey = kColorLine1;
        self.textFieldView.layer.cornerRadius = 16.f;
        self.textFieldView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.textFieldView.clipsToBounds = YES;
        self.textFieldView.delegate = self;
        self.textFieldView.minHeight = 32;
        self.textFieldView.placeholderColor = [UIColor tt_themedColorForKey:kColorText1];
        self.textFieldView.backgroundColorThemeKey = kColorBackground3;
        self.textFieldView.textColor = [UIColor tt_themedColorForKey:kColorText1];
        self.textFieldView.placeholder = @"我来说两句";
        self.textFieldView.hidden = NO;
        
        [self insertSubview:self.textFieldView aboveSubview:_inputBarView];
        [self.textFieldView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_inputBarView.mas_left).offset(15);
            make.right.equalTo(_inputBarView.mas_right).offset(-60);
            make.height.mas_equalTo(32);
            make.bottom.equalTo(self.inputBarView).offset(-6);
        }];
        [self.inputBarView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(_textFieldView.mas_top).offset(-6);
        }];
    }
    
    //发送按钮
    if (_sendTextBtn == nil) {
        self.sendTextBtn = [[SSThemedButton alloc] init];
        _sendTextBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-20, 0, 0, 0);
        [_sendTextBtn setTitle:@"发布" forState:UIControlStateNormal];
        _sendTextBtn.titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16.f]];
        [_sendTextBtn sizeToFit];
        _sendTextBtn.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        _sendTextBtn.titleColorThemeKey = kColorText6;
        _sendTextBtn.disabledTitleColorThemeKey = kColorText9;
        [self.sendTextBtn addTarget:self action:@selector(sendTextMessageOut:) forControlEvents:UIControlEventTouchUpInside];
        [self insertSubview:self.sendTextBtn aboveSubview:self.inputBarView];
       
        [self.sendTextBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_textFieldView.mas_right).offset((60 - _sendTextBtn.width)/2);
            make.centerY.equalTo(_textFieldView);
            make.width.mas_equalTo(_sendTextBtn.width);
        }];
    }
    
    if (_textFieldButtonView == nil) {
        _textFieldButtonView = [[SSThemedLabel alloc] initWithFrame:_inputBarView.bounds];
        _textFieldButtonView.font = [UIFont systemFontOfSize:14];
        _textFieldButtonView.contentInset = UIEdgeInsetsMake(9, 35, 0, 0);
        _textFieldButtonView.textColorThemeKey = kColorText1;
        _textFieldButtonView.borderColorThemeKey = kColorLine1;
        _textFieldButtonView.text = @"我来说两句";
        _textFieldButtonView.layer.cornerRadius = 16.f;
        _textFieldButtonView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _textFieldButtonView.clipsToBounds = YES;
        _textFieldButtonView.backgroundColorThemeKey = kColorBackground3;
        _textFieldButtonView.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldButtonClick:)];
        [_textFieldButtonView addGestureRecognizer:tapGesture];
        
        [self insertSubview:_textFieldButtonView aboveSubview:_textFieldView];
        
        [_textFieldButtonView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(8);
            make.height.mas_equalTo(32);
            make.top.equalTo(_inputBarView).offset(6);
        }];
    }
    
    if (_textImageView == nil){
        _textImageView = [[SSThemedImageView alloc] init];
        _textImageView.imageName = @"write_new";
        _textImageView.tintColor = [UIColor tt_themedColorForKey:kColorText1];
        _textImageView.userInteractionEnabled = NO;
        [self insertSubview:_textImageView aboveSubview:_textFieldButtonView];
        [_textImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_textFieldButtonView.mas_left).offset(12);
            make.centerY.equalTo(_textFieldButtonView);
        }];
    }
    
    //针对类型进行处理
    if (messageType == TTLiveMessageBoxTypeSupportAll) {
        [self setUpCameraAlbumAudioTextSubviews:_inputBarView];
    }
    else if (messageType == TTLiveMessageBoxTypeSupportTextOnly){
        [self setUpOnlyTextSubviews:_inputBarView];
    }
    
    if (_disableSendMsg){
        for (UIView *subView in self.subviews){
            if (subView != self.pariseButton){
                subView.hidden = YES;
            }
        }
        if ([TTDeviceHelper isPadDevice] || (self.type == TTLiveTypeMatch) || self.shouldShowPariseButton == NO || _pariseButton.superview == nil){
            return;
        }
        //换样式
        [_pariseButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_inputBarView.mas_right).offset(-15);
            make.width.mas_equalTo(85);
            make.height.mas_equalTo(32);
            make.bottom.equalTo(self).offset(-20);
        }];
        [_pariseImageView removeFromSuperview];
        [_pariseCountLabel removeFromSuperview];
        UIView *pariseContentView = [[UIView alloc] init];
        pariseContentView.userInteractionEnabled = NO;
        pariseContentView.backgroundColor = [UIColor clearColor];
        [pariseContentView addSubview:_pariseImageView];
        [pariseContentView addSubview:_pariseCountLabel];
        [_pariseButton addSubview:pariseContentView];
        [pariseContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.equalTo(_pariseButton);
            make.centerY.centerX.equalTo(_pariseButton);
            make.left.equalTo(_pariseImageView);
            make.right.equalTo(_pariseCountLabel);
        }];
        
        [_pariseImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(pariseContentView);
            make.height.width.mas_equalTo(18);
            make.right.equalTo(_pariseCountLabel.mas_left).offset(-6);
        }];
        [_pariseCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(pariseContentView);
            make.height.mas_equalTo(12);
        }];
        
        _pariseButton.clipsToBounds = YES;
        _pariseButton.layer.cornerRadius = 16;
        _pariseImageView.layer.cornerRadius = 0;
        _pariseImageView.clipsToBounds = NO;
        _pariseButton.backgroundColorThemeKey = kColorBackground7;
        _pariseCountLabel.textColorThemeKey = kColorText12;
    }
}

- (void)textFieldButtonClick:(UITapGestureRecognizer *)recognizer {
    self.textFieldButtonView.hidden = YES;
    self.textImageView.hidden = YES;
    self.textFieldView.hidden = NO;
    self.sendTextBtn.hidden = NO;
    [self.textFieldView becomeFirstResponder];
}

//- (TTLiveMainViewController *)chatroom {
//    TTLiveMainViewController *chatroom = (TTLiveMainViewController *)[self ss_nextResponderWithClass:[TTLiveMainViewController class]];
//    return chatroom;
//}

- (void)clearDataBySendSuccess
{
    [self clearPreviousData:!self.replyMode replyPreviousData:self.replyMode];
}

//发送消息
- (void)sendTextMessageOut:(UIButton *)sender
{
    if (!self.replyMode) {
        self.replyedMsg = nil;
    }
    
    //传递
    NSString *resultText = [self.textFieldView.text trimmed];
    if (resultText.length == 0) {
        return;
    }
    
    if ([self.delegate respondsToSelector:@selector(ttMessageBox:textBack:)]) {
        [self.delegate ttMessageBox:self textBack:resultText];
    }
    
    //还原UI收起
    if (self.messageType == TTLiveMessageBoxTypeSupportAll) {
        [self showTextFieldOnly];
    }
    
    [self becomeToShortestAtBottom:NO];
    
    //统计
    wrapperTrackEventWithCustomKeys(TTLiveTextUmengName , @"write_button", nil, nil, self.ssTrackerDic);
}

//清除数据
- (void)clearPreviousData:(BOOL)clearPrevious replyPreviousData:(BOOL)clearReply
{
    self.replyMode = NO;
    self.replyedMsg = nil;
    self.textFieldView.placeholder = @"我来说两句";
    self.textFieldView.text = nil;
    self.hasBeforeMessage = NO;
    if (clearPrevious) {
        _previousEntry = nil;
    }
    if (clearReply) {
        _replyPreviousEntry = nil;
        _replyId = nil;
    }
}

//只显示发送按钮
- (void)showSendBtnOnly
{
    _pariseButton.hidden = YES;
    _pariseCountLabel.hidden = YES;
    
    self.sendTextBtn.hidden = NO;
    self.sendTextBtn.highlighted = !isEmptyString(self.textFieldView.text);
    
    self.textFieldButtonView.hidden = YES;
    self.textImageView.hidden = YES;
    self.textFieldView.hidden = NO;
}

- (void)showShareButtonOnly
{
    //未输入的状态
    _pariseButton.hidden = NO;
    _pariseCountLabel.hidden = NO;
    self.sendTextBtn.hidden = YES;
    self.textFieldView.hidden = YES;
    self.textFieldButtonView.hidden = NO;
    self.textImageView.hidden = NO;
}

- (void)showTextFieldOnly
{
    _pariseButton.hidden = YES;
    _pariseCountLabel.hidden = YES;
    self.sendTextBtn.hidden = YES;
    self.textFieldView.hidden = YES;
    self.textFieldButtonView.hidden = NO;
    self.textImageView.hidden = NO;
}
//收起到最小
- (void)becomeToShortestAtBottom:(BOOL)isCancel
{
    if ([self.textFieldView isFirstResponder]) {
        self.btnWrapperView.userInteractionEnabled = YES;
        [self.textFieldView resignFirstResponder];
        self.sendTextBtn.highlighted = NO;
        //统计
        if (isCancel) {
            wrapperTrackEventWithCustomKeys(TTLiveTextUmengName , @"write_cancel", nil, nil, self.ssTrackerDic);
        }
    } else {
        [self onlyShowMediaMessageArea:YES];
    }
    self.textFieldView.hidden = YES;
    self.textFieldButtonView.hidden = NO;
    self.textImageView.hidden = NO;
}

//展开，仅仅包括媒体消息区域
- (void)onlyShowMediaMessageArea:(BOOL)show {
    self.btnWrapperView.hidden = NO;
    self.btnWrapperView.userInteractionEnabled = YES;
    CGFloat origingY = self.superview.frame.size.height - kRealHeightOfMsgBoxWithTypeTextOnly() - (self.messageType == TTLiveMessageBoxTypeSupportAll ? kHeightOfBottomMediaView : 0);
    self.top = origingY;
//    self.frame = CGRectMake(self.frame.origin.x, origingY, self.frame.size.width, kRealHeightOfMsgBoxWithTypeTextOnly() + kHeightOfBottomMediaView);
    self.textFieldButtonView.width = self.width - 30;

    //统计
    wrapperTrackEventWithCustomKeys(TTLiveTextUmengName , @"media", nil, nil, self.ssTrackerDic);
}

//本地相册
- (void)openAlbumAssetsLibrary
{
    if ([self.delegate respondsToSelector:@selector(ttMessagePrepareToSendOut)]) {
        [self.delegate ttMessagePrepareToSendOut];
    }
    TTImagePickerController *imagePickerController = [[TTImagePickerController alloc] initWithDelegate:self];
    imagePickerController.maxImagesCount = 9;
    imagePickerController.allowTakePicture = NO;
    imagePickerController.imagePickerMode = TTImagePickerModeAll;
    if ([self.delegate respondsToSelector:@selector(ttLiveMediaMessageEditPrepared:)]) {
        [self.delegate ttLiveMediaMessageEditPrepared:self];
    }
    [imagePickerController presentOn:[TTUIResponderHelper topViewControllerFor:self]];
    [[TTImagePickerTrackManager manager] addTrackDelegate:self];
    
    //统计
    wrapperTrackEventWithCustomKeys(TTLiveAlbumUmengName, @"open_album", nil, nil, self.ssTrackerDic);
    [self becomeToShortestAtBottom:NO];
}

//打开相机
- (void)openCameraViewController
{
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    AVAuthorizationStatus audioAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    
    if (AVAuthorizationStatusDenied == videoAuthStatus && AVAuthorizationStatusDenied != audioAuthStatus) {
        [self showAlertToPromptAuthorizationWithMessage:@"请在手机的「设置-隐私-相机」选项中，允许爱看访问你的相机"];
        return ;
    } else if (AVAuthorizationStatusDenied != videoAuthStatus && AVAuthorizationStatusDenied == audioAuthStatus) {
        [self showAlertToPromptAuthorizationWithMessage:@"请在手机的「设置-隐私-麦克风」选项中，允许爱看访问你的麦克风"];
        return ;
    } else if (AVAuthorizationStatusDenied == videoAuthStatus && AVAuthorizationStatusDenied == audioAuthStatus) {
        [self showAlertToPromptAuthorizationWithMessage:@"请在手机的「设置-隐私-相机」和「设置-隐私-麦克风」选项中，允许爱看访问你的相机和麦克风"];
        return ;
    }
    
    if ([self.delegate respondsToSelector:@selector(ttMessagePrepareToSendOut)]) {
        [self.delegate ttMessagePrepareToSendOut];
    }
    
    if ([self.delegate respondsToSelector:@selector(ttLiveMediaMessageEditPrepared:)]) {
        [self.delegate ttLiveMediaMessageEditPrepared:self];
    }
    
    TTLiveMainViewController *chatroom = (TTLiveMainViewController *)[self ss_nextResponderWithClass:[TTLiveMainViewController class]];
    TTLiveCameraViewController *cameraVC = [[TTLiveCameraViewController alloc] initWithCamreraType:TTLiveCameraTypeVideoAndPhoto
                                                                                  beautyModeEnable:chatroom.overallModel.cameraBeautyEnable
                                                                                   preSelfieEnable:chatroom.overallModel.initializeWithSelfieMode];
    cameraVC.delegate = self;
    [cameraVC setSsTrackerDic:self.ssTrackerDic];
    
    UIViewController *topMost = [TTUIResponderHelper topViewControllerFor:self];
    [topMost presentViewController:cameraVC animated:YES completion:nil];
    
    //统计
    wrapperTrackEventWithCustomKeys(TTLiveShotUmengName , @"click", nil, nil, self.ssTrackerDic);
}

//按住说话
- (void)openAudoRecorder
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    if (AVAuthorizationStatusDenied == authStatus) {
        [self showAlertToPromptAuthorizationWithMessage:@"请在手机的「设置-隐私-麦克风」选项中，允许爱看访问你的麦克风"];
        return ;
    }
    
    if (self.audioRecordViewBtn.hidden) {
        [[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
        if ([self.delegate respondsToSelector:@selector(ttMessagePrepareToSendOut)]) {
            [self.delegate ttMessagePrepareToSendOut];
        }
        
        self.audioRecordViewBtn.hidden = NO;
        
        _audioBtn.imageName = @"chatroom_keyboard";
        _audioBtn.highlightedImageName = @"chatroom_keyboard_press";
        _textFieldButtonView.hidden = YES;
        _textImageView.hidden = YES;
        _textFieldView.hidden = YES;
    }
    else {
        self.audioRecordViewBtn.hidden = YES;
        
        _audioBtn.imageName = @"chatroom_voice";
        _audioBtn.highlightedImageName = @"chatroom_voice_press";
        _textFieldButtonView.hidden = YES;
        _textImageView.hidden = YES;
        _textFieldView.hidden = NO;
        [self.textFieldView becomeFirstResponder];
    }
    
    if (self.replyMode == YES && self.audioRecordViewBtn.hidden) {
        [self.textFieldView becomeFirstResponder];
    }
    
    //统计
    wrapperTrackEventWithCustomKeys(TTLiveAudioUmengName , @"audio_click", nil, nil, self.ssTrackerDic);
}

- (void)handleAudioRecorderGesture:(UILongPressGestureRecognizer *)gesture
{
    
    //判断触控区域，上滑取消
    if ([gesture locationInView:self.audioRecordViewBtn].y < 0) {
        [self moveUpAudioRecorderCancle];
    }
    else {
        self.audioCanceling = NO;
    }
    
    //开始
    if (gesture.state == UIGestureRecognizerStateBegan) {
        
        if ([self.delegate respondsToSelector:@selector(ttLiveMediaMessageEditPrepared:)]) {
            [self.delegate ttLiveMediaMessageEditPrepared:self];
        }
        
        self.audioTitleLabel.text = @"松开 发送";
        //录制的时候播放停止
        //        [TTLiveManager stopCurrentPlayingAudioIfNeeded];
        //        [[TTLiveManager sharedManager].ttLiveMainViewController stopLiveVideoIfNeeded];
        
        //录音计时
        [self.audioCountTimer startTimer];
        
        self.audioRecordViewBtn.backgroundColorThemeKey = kColorBackground3;
        if (!self.audioRecorder) {
            self.audioRecorder = [[TTAudioRecorder alloc] init];
            self.audioRecorder.delegate = self;
            [self.audioRecorder setAudioRecorderMeteringEnabled:YES];
        }
        [self.audioRecorder startRecording];
        [self makeAudioToastView];
        [self audioRecorderDoRecording];
        
        self.audioPowerTimer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(getAudioRecorderPowerRatio) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.audioPowerTimer  forMode:NSRunLoopCommonModes];
        
        //统计
        wrapperTrackEventWithCustomKeys(TTLiveAudioUmengName , @"audio_long_click", nil, nil, self.ssTrackerDic);
    }
    //结束
    else if(gesture.state == UIGestureRecognizerStateEnded || gesture.state == UIGestureRecognizerStateFailed || gesture.state == UIGestureRecognizerStateCancelled){
        
        [self.audioCountTimer clearTimer];
        
        self.audioToastView.hidden = YES;
        self.audioRecordViewBtn.backgroundColorThemeKey = kColorBackground4;
        [self.audioPowerTimer invalidate];
        self.audioPowerTimer = nil;
        
        self.audioTitleLabel.text = @"按住 说话";
        
        //区别正常录制结束或者取消
        if ([gesture locationInView:self.audioRecordViewBtn].y >= 0) {
            
            [self.audioRecorder endRecording];
        }
        else {
            [self.audioRecorder cancelRecording];
            
            // event track
            wrapperTrackEventWithCustomKeys(@"liveaudio", @"audio_sent_cancel", nil, nil, self.ssTrackerDic);
        }
        
    }
}

- (void)showAlertToPromptAuthorizationWithMessage:(NSString *)msg
{
    NSString *message = msg;
    if (isEmptyString(message)) {
        message = @"请在手机的「设置-隐私」选项中，允许爱看访问你的麦克风和相机";
    }
    TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:@"无访问权限" message:message preferredType:TTThemedAlertControllerTypeAlert];
    [alert addActionWithTitle:@"确定" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
    TTLiveMainViewController *chatroom = (TTLiveMainViewController *)[self ss_nextResponderWithClass:[TTLiveMainViewController class]];
    [alert showFrom:chatroom animated:YES];
}

//音频录制提示
- (void)makeAudioToastView
{
    if (self.audioToastView == nil) {
        
        //录音提示toaster
        self.audioToastView = [[SSThemedView alloc] init];
        self.audioToastView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.8];
        self.audioToastView.layer.cornerRadius = 15;
        self.audioToastView.hidden = YES;
        
        //图片
        SSThemedImageView *toastImageView = [[SSThemedImageView alloc] init];
        [toastImageView setTag:toastViewImageTag];
        [toastImageView setImage:[UIImage imageNamed:@"chatroom_voice_press"]];
        [self.audioToastView addSubview:toastImageView];
        
        //计数文字
        SSThemedLabel *numLabel = [[SSThemedLabel alloc] init];
        numLabel.textColorThemeKey = kColorText10;
        numLabel.font = [UIFont systemFontOfSize:80];
        numLabel.tag = toastViewNumTag;
        numLabel.text = @"5";
        numLabel.hidden = YES;
        numLabel.textAlignment = NSTextAlignmentCenter;
        [self.audioToastView addSubview:numLabel];
        
        //提示文字
        SSThemedLabel *toastLabel = [[SSThemedLabel alloc] init];
        toastLabel.textColorThemeKey = kColorText10;
        toastLabel.font = [UIFont systemFontOfSize:14];
        toastLabel.tag = toastViewTextTag;
        toastLabel.text = @"手指上滑,取消发送";
        toastLabel.textAlignment = NSTextAlignmentCenter;
        [self.audioToastView addSubview:toastLabel];
        
        [toastLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.audioToastView.mas_left).offset(5);
            make.right.equalTo(self.audioToastView.mas_right).offset(-5);
            make.bottom.equalTo(self.audioToastView.mas_bottom).offset(-15);
            make.height.equalTo(@20);
        }];
        
        [toastImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.audioToastView.mas_top).offset(31);
            make.bottom.equalTo(toastLabel.mas_top).offset(-21);
            make.left.equalTo(self.audioToastView.mas_left).offset(41);
            make.right.equalTo(self.audioToastView.mas_right).offset(-41);
        }];
        
        [numLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(toastImageView.mas_centerX);
            make.centerY.equalTo(toastImageView.mas_centerY);
        }];
        
        UIViewController *currentVC = [TTUIResponderHelper topViewControllerFor:self];
        [currentVC.view addSubview:self.audioToastView];
        [self.audioToastView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(currentVC.view.mas_centerY);
            make.centerX.equalTo(currentVC.view.mas_centerX);
            make.width.equalTo(@150);
            make.height.equalTo(@150);
        }];
    }
    else {
        self.audioToastView.hidden = NO;
        SSThemedImageView *imageView = (SSThemedImageView *)[self getViewFromParentView:self.audioToastView
                                                                                withTag:toastViewImageTag];
        imageView.hidden = NO;
        SSThemedLabel *numLabel = (SSThemedLabel *)[self getViewFromParentView:self.audioToastView
                                                                       withTag:toastViewNumTag];
        numLabel.hidden = YES;
        numLabel.text = @"5";
    }
    
}


//显示上滑取消提示
- (void)moveUpAudioRecorderCancle
{
    self.audioCanceling = YES;
    
    SSThemedImageView *imageView = (SSThemedImageView *)[self getViewFromParentView:self.audioToastView
                                                                            withTag:toastViewImageTag];
    [imageView setImage:[UIImage imageNamed:@"chatroom_warning_prompt"]];
    
    SSThemedLabel *label = (SSThemedLabel *)[self getViewFromParentView:self.audioToastView withTag:toastViewTextTag];
    label.text = @"松开手指,取消发送";
    
}

//显示正在录制提示
- (void)audioRecorderDoRecording
{
    self.audioCanceling = NO;
    
    SSThemedImageView *imageView = (SSThemedImageView *)[self getViewFromParentView:self.audioToastView
                                                                            withTag:toastViewImageTag];
    [imageView setImage:[UIImage imageNamed:@"chatroom_voice_prompt1"]];
    
    SSThemedLabel *label = (SSThemedLabel *)[self getViewFromParentView:self.audioToastView withTag:toastViewTextTag];
    label.text = @"手指上滑,取消发送";
    
    self.audioToastView.hidden = NO;
    self.audioToastView.layer.opacity = 0.8;
    
}

//输入框默认提示文字颜色
- (void)setInputPlaceholder:(NSString *)defaultText TextColor:(UIColor *)color
{
    self.textFieldView.placeholder = defaultText;
    if (color) {
        //        self.textFieldView.placeholderColorThemeKey = nil;
        self.textFieldView.placeholderColor = color;
    }
}

//输入框左边显示的图标
- (void)setInputBarSpeakerAvatar:(UIImage *)image
{
    self.speakerAvatar.image = image;
}

//获取前段音频强度
- (void)getAudioRecorderPowerRatio
{
    //设定一段音频强度范围 -45 -- 0，0最强，-45最低，实测办公室一般为-45
    
    //不与上滑取消提示冲突
    if (!self.audioCanceling) {
        
        SSThemedLabel *label = (SSThemedLabel *)[self getViewFromParentView:self.audioToastView withTag:toastViewTextTag];
        label.text = @"手指上滑,取消发送";
        
        SSThemedImageView *imageView = (SSThemedImageView *)[self getViewFromParentView:self.audioToastView
                                                                                withTag:toastViewImageTag];
        
        float power = [self.audioRecorder getAudioPower];
        
        if (power > -5) {
            
            [imageView setImage:[UIImage imageNamed:@"chatroom_voice_prompt8"]];
        }
        else if (power > -12 && power <= -5) {
            
            [imageView setImage:[UIImage imageNamed:@"chatroom_voice_prompt7"]];
        }
        else if (power > -19  && power <= -12) {
            
            [imageView setImage:[UIImage imageNamed:@"chatroom_voice_prompt6"]];
            
        }
        else if (power > -26  && power <= -19) {
            
            [imageView setImage:[UIImage imageNamed:@"chatroom_voice_prompt5"]];
            
        }
        else if (power > -35  && power <= -26) {
            
            [imageView setImage:[UIImage imageNamed:@"chatroom_voice_prompt4"]];
            
        }
        else if (power > -42  && power <= 35) {
            
            [imageView setImage:[UIImage imageNamed:@"chatroom_voice_prompt3"]];
            
        }
        else if (power > -49  && power <= 42) {
            
            [imageView setImage:[UIImage imageNamed:@"chatroom_voice_prompt2"]];
            
        }
        else if (power <= -49) {
            
            [imageView setImage:[UIImage imageNamed:@"chatroom_voice_prompt1"]];
            
        }
        
    }
    
    
}

//设置回复用户名
- (void)activedWithType:(TTLiveMessageBoxType)type replyedMessage:(TTLiveMessage *)replyedMsg
{
    self.replyMode = YES;
    self.replyedMsg = replyedMsg;
    [self.textFieldView becomeFirstResponder];
    
    //    SSThemedView *replyView = (SSThemedView *)[self getViewFromParentView:self withTag:replyTipViewTag];
    //    replyView.hidden = NO;
    //    SSThemedLabel *replyLabel = (SSThemedLabel *)[self getViewFromParentView:replyView withTag:replyUserLabelTag];
    self.textFieldView.placeholder = [NSString stringWithFormat:@"回复：%@", replyedMsg.userDisplayName];
    //    replyLabel.text = [NSString stringWithFormat:@"回复：%@", replyedMsg.userDisplayName];
}


//获取视图
- (UIView *)getViewFromParentView:(UIView *)parentView  withTag:(NSInteger)viewTag
{
    UIView *view;
    for (UIView *viewTemp in parentView.subviews) {
        if (viewTemp.tag == viewTag) {
            view = viewTemp;
        }
    }
    
    return view;
}

//删除视频文件
- (void)clearTempVideoFileCache
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory= NSTemporaryDirectory();
    NSString *tempVideosGroupPath = [NSString stringWithFormat:@"%@TempVideos/",documentsDirectory];
    
    // 判断文件夹是否存在
    if ([fileManager fileExistsAtPath:tempVideosGroupPath]) {
        
        NSArray *contents = [fileManager contentsOfDirectoryAtPath:tempVideosGroupPath error:nil];
        for (NSString *fileName in contents) {
            [fileManager removeItemAtPath:[tempVideosGroupPath stringByAppendingPathComponent:fileName] error:nil];
        }
    }
}

//检查文件路径
- (void)checkCameraFileGroup
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentsDirectory= NSTemporaryDirectory();
    NSString *cameraVideoGroupPath = [NSString stringWithFormat:@"%@TempVideos",documentsDirectory];
    
    // 判断文件夹是否存在
    if ([[NSFileManager defaultManager] fileExistsAtPath:cameraVideoGroupPath]) {
        return;
    }
    
    //如果不存在，则创建
    [fileManager createDirectoryAtPath:cameraVideoGroupPath
           withIntermediateDirectories:YES
                            attributes:nil
                                 error:&error];
}

//统计参数
- (void)setSsTrackerDic:(NSDictionary *)ssTrackerDic
{
    _ssTrackerDic = ssTrackerDic;
}

- (void)setPariseCount:(NSString *)count {
    _pariseCountLabel.text = count;
}

#pragma mark -- TTCommonTimerObjDelegate

- (void)ttTimer:(TTCommonTimerObj *)timer StopLessThanMinTime:(BOOL)isLess
{
    if (isLess) {
        
        //统计
        wrapperTrackEventWithCustomKeys(TTLiveAudioUmengName , @"audio_too_short", nil, nil, self.ssTrackerDic);
    }
}

- (void)ttTimerReachMaxTimeStop:(TTCommonTimerObj *)timer
{
    //收尾，停止录音
    [self.audioCountTimer clearTimer];
    [self.audioRecorder endRecording];
    
    self.audioToastView.hidden = YES;
    self.preinstallTime = NO;
    self.audioCanceling = NO;
    SSThemedImageView *imageView = (SSThemedImageView *)[self getViewFromParentView:self.audioToastView
                                                                            withTag:toastViewImageTag];
    imageView.hidden = NO;
    SSThemedLabel *numLabel = (SSThemedLabel *)[self getViewFromParentView:self.audioToastView
                                                                   withTag:toastViewNumTag];
    numLabel.hidden = YES;
    numLabel.text = @"5";
    
    //统计
    wrapperTrackEventWithCustomKeys(TTLiveAudioUmengName , @"audio_more_60s", nil, nil, self.ssTrackerDic);
}

- (void)ttTimer:(TTCommonTimerObj *)timer EachIntervalAction:(float)currentCountTime
{
    if (self.preinstallTime) {
        
        SSThemedLabel *numLabel = (SSThemedLabel *)[self getViewFromParentView:self.audioToastView
                                                                       withTag:toastViewNumTag];
        
        
        numLabel.text = [NSString stringWithFormat:@"%d",(int)(timer.maxTime - currentCountTime + 1)];
    }
}

- (void)ttTimer:(TTCommonTimerObj *)timer preinstallTime:(float)countTime
{
    //关闭声音强度计时
    [self.audioPowerTimer invalidate];
    self.audioPowerTimer = nil;
    self.preinstallTime = YES;
    self.audioCanceling = NO;
    
    //显示倒计时视图
    SSThemedImageView *imageView = (SSThemedImageView *)[self getViewFromParentView:self.audioToastView
                                                                            withTag:toastViewImageTag];
    imageView.hidden = YES;
    
    SSThemedLabel *numLabel = (SSThemedLabel *)[self getViewFromParentView:self.audioToastView
                                                                   withTag:toastViewNumTag];
    numLabel.hidden = NO;
}

#pragma mark --TTAudioRecorderDelegate

- (void)ttAudioRecorderFinishedWithURL:(NSURL *)audioUrl duration:(CGFloat)duration
{
    if ([self.delegate respondsToSelector:@selector(ttMessageAudioRecordFinishedWithURL:duration:)]) {
        
        if (self.replyMode) {
            self.hasBeforeMessage = YES;
        }
        else {
            
            self.replyedMsg = nil;
        }
        
        [self.delegate ttMessageAudioRecordFinishedWithURL:audioUrl duration:duration];
        
    }
    
    if ([self.delegate respondsToSelector:@selector(ttLiveMediaMessageEditDidFinished:)]) {
        [self.delegate ttLiveMediaMessageEditDidFinished:self];
    }
    
    if (self.replyMode) {
        [self becomeToShortestAtBottom:NO];
    }
    [self clearPreviousData:NO replyPreviousData:NO];
    
    //统计
    wrapperTrackEventWithCustomKeys(TTLiveAudioUmengName , @"audio_sent", nil, nil, self.ssTrackerDic);
}
- (void)ttAudioRecorderFailBackError:(NSError *)error
{
    
}

- (void)ttAudioRecorderLessThanOneSecond
{
    SSThemedImageView *imageView = (SSThemedImageView *)[self getViewFromParentView:self.audioToastView
                                                                            withTag:toastViewImageTag];
    [imageView setImage:[UIImage imageNamed:@"chatroom_warning_prompt"]];
    
    SSThemedLabel *label = (SSThemedLabel *)[self getViewFromParentView:self.audioToastView withTag:toastViewTextTag];
    label.text = @"说话时间太短";
    
    self.audioToastView.hidden = NO;
    self.audioToastView.layer.opacity = 0.8;
    self.audioRecordViewBtn.userInteractionEnabled = NO;
    
    [UIView animateWithDuration:1.0 animations:^{
        self.audioToastView.layer.opacity = 0;
    } completion:^(BOOL finished){
        self.audioToastView.hidden = YES;
        self.audioRecordViewBtn.userInteractionEnabled = YES;
    }];
}

#pragma mark -- TTCameraDelegate

- (void)ttCameraPhotoBackAssetUrl:(NSURL *)url image:(UIImage *)cameraImage;
{
    if ([self.delegate respondsToSelector:@selector(ttMessageCameraPhotoBackAssetUrl:image:)]) {
        
        if (self.replyMode) {
            self.hasBeforeMessage = YES;
        }
        else {
            
            self.replyedMsg = nil;
        }
        
        [self.delegate ttMessageCameraPhotoBackAssetUrl:url image:cameraImage];
        [self clearPreviousData:NO replyPreviousData:NO];
    }
    
    if ([self.delegate respondsToSelector:@selector(ttLiveMediaMessageEditDidFinished:)]) {
        [self.delegate ttLiveMediaMessageEditDidFinished:self];
    }
}

- (void)ttCameraVideoBack:(NSURL *)videoUrl previewImage:(UIImage *)previewImage
{
    if ([self.delegate respondsToSelector:@selector(ttMessageCameraVideoBack:previewImage:)]) {
        
        if (self.replyMode) {
            self.hasBeforeMessage = YES;
        }
        
        [self.delegate ttMessageCameraVideoBack:videoUrl previewImage:previewImage];
        [self clearPreviousData:NO replyPreviousData:NO];
    }
    
    //    if (self.replyMode) {
    //        [self becomeToShortestAtBottom:NO];
    //    }
    
    if ([self.delegate respondsToSelector:@selector(ttLiveMediaMessageEditDidFinished:)]) {
        [self.delegate ttLiveMediaMessageEditDidFinished:self];
    }
    // 尝试续播视频
    //    [[TTLiveManager sharedManager].ttLiveMainViewController startLiveVideoIfNeeded];
}

- (void)ttCameraViewControllerDidCanceled:(TTLiveCameraViewController *)cameraViewController
{
    if (self.replyMode == YES) {
        [self.textFieldView becomeFirstResponder];
    }
    
    //    [self becomeToShortestAtBottom:NO];
    
    if ([self.delegate respondsToSelector:@selector(ttLiveMediaMessageEditDidFinished:)]) {
        [self.delegate ttLiveMediaMessageEditDidFinished:self];
    }
    // 尝试续播视频
    //    [[TTLiveManager sharedManager].ttLiveMainViewController startLiveVideoIfNeeded];
}

#pragma mark -- TTImagePickerControllerDelegate

- (void)ttImagePickerControllerDidCancel:(TTImagePickerController *)picker
{
    wrapperTrackEventWithCustomKeys(@"topic_post", @"cancel_album", nil, nil, self.ssTrackerDic);
    if ([self.delegate respondsToSelector:@selector(ttLiveMediaMessageEditDidFinished:)]) {
        [self.delegate ttLiveMediaMessageEditDidFinished:self];
    }
    if (self.replyMode == YES) {
        [self.textFieldView becomeFirstResponder];
    }
    [[TTImagePickerTrackManager manager] removeTrackDelegate:self];
}

- (void)ttimagePickerController:(TTImagePickerController *)picker didFinishPickerPhotosAndVideoWithSourceAssets:(NSArray<TTAssetModel *> *)assets
{
    [[TTImagePickerTrackManager manager] removeTrackDelegate:self];
    //统计
    __block BOOL hasPhoto = NO;
    __block BOOL hasVideo = NO;
    
    NSMutableArray *videoUrlArray = [[NSMutableArray alloc] init];
    NSMutableArray *assetsArray = [[NSMutableArray alloc] init];
    
    WeakSelf;
    void (^finishBlock)() = ^{
        StrongSelf;
        //视频放后面，界面显示的时候就在前面
        [assetsArray addObjectsFromArray:videoUrlArray];
        
        if ([self.delegate respondsToSelector:@selector(ttMessageAlbumPhotoLibraryBack:)]) {
            
            if (self.replyMode) {
                self.hasBeforeMessage = YES;
            }
            else {
                
                self.replyedMsg = nil;
            }
            
            [self.delegate ttMessageAlbumPhotoLibraryBack:assetsArray];
            
            [self becomeToShortestAtBottom:NO];
            [self clearPreviousData:NO replyPreviousData:NO];
        }
        
        //统计
        if (hasVideo && !hasPhoto) {
            wrapperTrackEventWithCustomKeys(TTLiveAlbumUmengName, @"album_video", nil, nil, self.ssTrackerDic);
        }
        else if (!hasVideo && hasPhoto) {
            wrapperTrackEventWithCustomKeys(TTLiveAlbumUmengName, @"album_photo", nil, nil, self.ssTrackerDic);
        }
        else if (hasVideo && hasPhoto) {
            wrapperTrackEventWithCustomKeys(TTLiveAlbumUmengName, @"album_video_photo", nil, nil, self.ssTrackerDic);
        }
        
        if ([self.delegate respondsToSelector:@selector(ttLiveMediaMessageEditDidFinished:)]) {
            [self.delegate ttLiveMediaMessageEditDidFinished:self];
        }
    };
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"type == %d",TTAssetModelMediaTypeVideo];
    NSMutableArray *mutAsset = [NSMutableArray arrayWithArray:assets];
    NSArray *videoArray = [mutAsset filteredArrayUsingPredicate:predicate];
    [mutAsset removeObjectsInArray:videoArray];
    [mutAsset addObjectsFromArray:videoArray];
    assets = [mutAsset copy];
    
    __block NSInteger completeCount = 0;
    [assets enumerateObjectsUsingBlock:^(TTAssetModel *  _Nonnull ttAsset, NSUInteger idx, BOOL * _Nonnull stop){
        if (ttAsset.type == TTAssetModelMediaTypeVideo) {
            hasVideo = YES;
            [[TTImagePickerManager manager] getVideoAVURLAsset:ttAsset.asset completion:^(AVURLAsset *asset) {
                if (!asset) {
                    [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                              indicatorText:@"暂不支持的视频格式"
                                             indicatorImage:nil
                                                autoDismiss:YES
                                             dismissHandler:nil];
                    
                }else{
                    //相册资源视频转换为沙盒路径
                    [self checkCameraFileGroup];
                    
                    //文件路径
                    NSString *fileName = [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
                    NSString *filePath = [NSTemporaryDirectory()
                                          stringByAppendingPathComponent:[NSString stringWithFormat:@"TempVideos/%@.mp4",fileName]];
                    
                    [videoUrlArray addObject:[NSURL fileURLWithPath:filePath]];
                    
                    NSData *data = [NSData dataWithContentsOfURL:asset.URL];
                    [data writeToFile:filePath atomically:YES];
                }
                completeCount += 1;
                
                if (completeCount == videoArray.count){
                    finishBlock();
                }
            }];
        }
        else if(ttAsset.type == TTAssetModelMediaTypePhoto)
        {
            [assetsArray addObject:ttAsset.asset];
            
            hasPhoto = YES;
            
        }
    }];
    
    if (!hasVideo){
        finishBlock();
    }
}

#pragma mark -- TTImagePickerTrackDelegate

- (void)ttImagePickOnTrackType:(TTImagePickerTrackKey)type extra:(NSDictionary *)extra
{
    switch (type) {
        case TTImagePickerTrackKeyPhotoVideoPreview:
            wrapperTrackEventWithCustomKeys(TTLiveAlbumUmengName, @"preview", nil, nil, self.ssTrackerDic);
            break;
        case TTImagePickerTrackKeyPhotoVideoPreviewPhoto:
        case TTImagePickerTrackKeyPhotoVideoPreviewVideo:
            wrapperTrackEventWithCustomKeys(TTLiveAlbumUmengName, @"preview_photo", nil, nil, self.ssTrackerDic);
            break;
        case TTImagePickerTrackKeyPreviewFlip:
            wrapperTrackEventWithCustomKeys(TTLiveAlbumUmengName, @"flip", nil, nil, self.ssTrackerDic);
            break;
        case TTImagePickerTrackKeyPhotoVideoClickAlbumList:
            wrapperTrackEventWithCustomKeys(TTLiveAlbumUmengName, @"album_list", nil, nil, self.ssTrackerDic);
            break;
        default:
            break;
    }
}
#pragma mark -- 键盘事件

///键盘显示事件
- (void)keyboardShow:(NSNotification *)notification
{
    if (![self.mainChatroom roleOfCurrentUserIsLeader]) {
        [self.mainChatroom.view bringSubviewToFront:self];
    }
    if ([self.textFieldView isFirstResponder]) {
        [self showSendBtnOnly];
        if (isEmptyString(self.textFieldView.text)) {
            if (_replyMode) {
                if (_replyedMsg.msgId == _replyId) {
                    self.textFieldView.text = _replyPreviousEntry;
                } else {
                    self.textFieldView.text = nil;
                }
            } else {
                self.textFieldView.text = _previousEntry;
            }
        }
    }else{
        return;
    }
    self.audioRecordViewBtn.hidden = YES;
    
    CGFloat keyboardHeight = CGRectGetHeight([[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue]);
    NSTimeInterval animationDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] integerValue];
    
    UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = animationCurve << 16;
            break;
    }
    
    CGFloat origingY = CGRectGetHeight(self.superview.frame) - kRealHeightOfMsgBoxWithTypeTextOnly() - (_messageType == TTLiveMessageBoxTypeSupportAll ? kHeightOfBottomMediaView : 0) - keyboardHeight;
    [UIView animateWithDuration:animationDuration delay:0 options:options animations:^{
        CGRect temp = self.frame;
        temp.origin.y = origingY;
        self.frame = temp;
    } completion:^(BOOL finished) {
    }];
}


///键盘消失事件
- (void)keyboardWillHide:(NSNotification *)notification
{
    //键盘的动画时间
    double keyboardDuration = [[notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    //下移动
//    if (self.btnWrapperView.hidden || self.btnWrapperView.userInteractionEnabled == NO) {
        CGFloat origingY = self.superview.frame.size.height - kRealHeightOfMsgBoxWithTypeTextOnly() - (_messageType == TTLiveMessageBoxTypeSupportAll ? kHeightOfBottomMediaView : 0);
        [UIView animateWithDuration:keyboardDuration animations:^{
            self.frame = CGRectMake(self.frame.origin.x,
                                    origingY,
                                    self.frame.size.width,
                                    self.frame.size.height);
        } completion:^(BOOL finished) {
            if (![self.mainChatroom roleOfCurrentUserIsLeader]) {
                [self.mainChatroom.view bringSubviewToFront:self.mainChatroom.pariseView];
            }
            //            self.btnWrapperView.hidden = YES;
        }];
//    }
//    else {
//        [self onlyShowMediaMessageArea:YES];
//    }
    
    switch (self.messageType) {
        case TTLiveMessageBoxTypeSupportTextOnly:
        {
            // 显示分享按钮，隐藏发送按钮
            [self showShareButtonOnly];
            self.sendTextBtn.hidden = YES;
            
//            CGRect tempFrame = self.textFieldButtonView.frame;
//            tempFrame.size.width = CGRectGetMinX(_shareButton.frame) - CGRectGetMinX(_textFieldButtonView.frame) - 15;
//            self.textFieldButtonView.frame = tempFrame;
        }
            break;
            
        case TTLiveMessageBoxTypeSupportAll:
        {
            [self showTextFieldOnly];
        }
            break;
            
        default:
            break;
    }
    if (!isEmptyString(self.textFieldView.text)) {
        if (_replyMode) {
            _replyPreviousEntry = self.textFieldView.text;
            _replyId = self.replyedMsg.msgId;
        } else {
            _previousEntry = self.textFieldView.text;
        }
        self.textFieldView.text = nil;
    }
}

#pragma mark --输入框事件
- (void)growingTextViewDidBeginEditing:(HPGrowingTextView *)growingTextView {
    if ([self.delegate respondsToSelector:@selector(ttMessageTextBeginEditing:)]) {
        [self.delegate ttMessageTextBeginEditing:growingTextView];
    }
    
    if ([self.delegate respondsToSelector:@selector(ttMessagePrepareToSendOut)]) {
        [self.delegate ttMessagePrepareToSendOut];
    }
}

- (void)growingTextViewDidEndEditing:(HPGrowingTextView *)growingTextView {
    if ([self.delegate respondsToSelector:@selector(ttMessageTextEndEditing:)]) {
        [self.delegate ttMessageTextEndEditing:growingTextView];
    }
    
    //统计
    wrapperTrackEventWithCustomKeys(TTLiveTextUmengName , @"write", nil, nil, self.ssTrackerDic);
}

- (void)growingTextViewDidChange:(HPGrowingTextView *)growingTextView {
    //NSString *text = [growingTextView.text stringByRemoveAllWhitespaceAndNewlineCharacters];
    NSString *text = growingTextView.text;
    if (isEmptyString(text)) {
        self.sendTextBtn.enabled = NO;
        return;
    }
    
    self.sendTextBtn.enabled = YES;
    if ([self.delegate respondsToSelector:@selector(ttMessageTextEditDidChange:)]) {
        [self.delegate ttMessageTextEditDidChange:growingTextView];
    }
    if (growingTextView.internalTextView.markedTextRange.end == nil && self.messageType == TTLiveMessageBoxTypeSupportTextOnly){
        NSString *adjustedString = [self adjustContentIfNeedWithContent:self.textFieldView.text];
        if (adjustedString){
            self.textFieldView.text = adjustedString;
        }
    }
}

- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height {
    [_textFieldView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
}

//外部点击收起盒子
- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    if (point.y < _textFieldView.top - 6 && event && event.type == UIEventTypeTouches) {
        if ([self.textFieldView isFirstResponder]) {
            [self becomeToShortestAtBottom:YES];
            [self clearPreviousData:NO replyPreviousData:NO];
        }
        return nil;
    }
    return [super hitTest:point withEvent:event];
}

- (BOOL)currentIsEditing
{
    return self.textFieldView.isFirstResponder;
}

#pragma mark 点赞相关

- (void)clickPraiseButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tt_clickPariseByUserWithCommonImage:)]) {
        [self.delegate tt_clickPariseByUserWithCommonImage:_pariseImageUrl];
    }
}

@end
