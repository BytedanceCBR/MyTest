//
//  TTLiveCellNormalContentView.m
//  TTLive
//
//  Created by matrixzk on 3/30/16.
//
//

#import "TTLiveCellNormalContentView.h"

#import "TTImageView.h"
#import "TTLiveMessage.h"
#import "TTLiveCellHelper.h"
#import "TTModuleBridge.h"
#import "TTAudioPlayer.h"
#import "TTLiveMainViewController.h"
#import "TTLiveAudioManager.h"

#pragma mark - TTLiveCellMetaImageView

#import "UIImageView+WebCache.h"
#import "TTLiveChatTableViewController.h"
#import "ALAssetsLibrary+TTImagePicker.h"
#import "UIButton+TTAdditions.h"
#import <TTUIWidget/VVeboImageView.h>
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceUIUtils.h"
#import "TTArticleCellHelper.h"
#import "TTLabelTextHelper.h"
#import "TTVerifyIconHelper.h"
#import "TTImageView+TrafficSave.h"
#import "SSWebViewController.h"
#import "TTLiveTabCategoryItem.h"
#import "TTLocalAssetMovieController.h"
#import "TTRoute.h"
#import "UIImage+Masking.h"

#import <NSString-Extension.h>
#import <TTImage/TTWebImageManager.h>

#define kExploreMovieViewPlaybackFinishNotification @"kExploreMovieViewPlaybackFinishNotification"
#define kExploreNeedStopAllMovieViewPlaybackNotification @"kExploreNeedStopAllMovieViewPlaybackNotification"
#define kExploreStopMovieViewPlaybackNotification @"kExploreStopMovieViewPlaybackNotification"
#define kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification @"kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification"

@interface TTLiveCellMetaImageView : SSThemedView
@property (nonatomic, strong) VVeboImageView *imgView;
- (void)setupImageWithMessage:(TTLiveMessage *)message;
@end


@implementation TTLiveCellMetaImageView

//- (void)dealloc
//{
//    NSLog(@"TTLiveCellMetaImageView DEALLOC");
//}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // NSLog(@"TTLiveCellMetaImageView initWithFrame");
        self.backgroundColorThemeKey = kColorBackground2;
        _imgView = [[VVeboImageView alloc] initWithFrame:CGRectZero];
        _imgView.repeats = YES;
        _imgView.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:_imgView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _imgView.frame = (CGRect){CGPointZero, self.frame.size};
}

- (void)setupImageWithMessage:(TTLiveMessage *)message
{
    if (message.thumbImage) { // 已生成缩略图
        
        _imgView.image = message.thumbImage;
        
    } else if (message.localSelectedImageURL) { // 本地取图
        
        ALAssetsLibrary *assetsLib = [[ALAssetsLibrary alloc] init];
        [assetsLib assetForURL:message.localSelectedImageURL resultBlock:^(ALAsset *asset) {
            
            UIImage *resultImage = [UIImage imageWithData:UIImageJPEGRepresentation([ALAssetsLibrary tt_getBigImageFromAsset:asset], 0.5)];
            UIImage *thumbImage = [TTLiveCellHelper thumbImageWithSourceImage:resultImage cellLayout:message.cellLayout];
            message.thumbImage = thumbImage;
            self.imgView.image = thumbImage;
            self.imgView.alpha = 0;
            [UIView animateWithDuration:.5f animations:^{
                self.imgView.alpha = 1;
            }];
            
        } failureBlock:nil];
        
    } else if (!isEmptyString([message.imageModel urlStringAtIndex:0])) { // 取server端取图
        
        NSString *currentImageURL = [message.imageModel urlStringAtIndex:0];
        [[TTImageDownloader sharedInstance] downloadImageWithURL:currentImageURL options:0 progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, BOOL finished, NSString * _Nullable url) {
            if (!image || !data || self.imgView.image) {
                return ;
            }
            
            UIImage *thumbImage = image.images ? [VVeboImage gifWithData:data] // GIF image
            : [TTLiveCellHelper thumbImageWithSourceImage:image cellLayout:message.cellLayout];
            message.thumbImage = thumbImage;
            message.sizeOfOriginImage = image.size;
            
            self.imgView.image = thumbImage;
            self.imgView.alpha = 0;
            [UIView animateWithDuration:.5f animations:^{
                self.imgView.alpha = 1;
            }];
        }];
    }
}

@end


#pragma mark - TTLiveCellMetaVideoView

typedef void(^videoPlayFinishBlock)();

@interface TTLiveCellMetaVideoView : SSThemedView
@property (nonatomic, strong) TTLiveCellMetaImageView *coverImgView;
- (void)setupVideoViewWithMessage:(TTLiveMessage *)message;
@end

@implementation TTLiveCellMetaVideoView
{
    SSThemedLabel *_durationLabel;
    SSThemedLabel *_fileSizeLabel;
    UIImageView *_bottomMaskImageView;
    SSThemedButton *_playButton;
    
    TTLiveMessage *_message;
    UIView *_movieView;
    TTLocalAssetMovieController *_movieController;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _coverImgView = [[TTLiveCellMetaImageView alloc] initWithFrame:CGRectZero];
        _coverImgView.userInteractionEnabled = YES;
        [self addSubview:_coverImgView];
        
        _playButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        UIImage *image = [UIImage themedImageNamed:[TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play"];
        _playButton.frame = CGRectMake(0, 0, image.size.width, image.size.height);
        _playButton.imageName = [TTDeviceHelper isPadDevice] ? @"FullPlay" : @"Play";
        [_playButton addTarget:self action:@selector(videoPlayButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [_coverImgView addSubview:_playButton];
        
        UIImage *maskImg = [[UIImage imageNamed:@"chatroom_video_background"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 2, 0, 5)
                                                                                             resizingMode:UIImageResizingModeStretch];
        _bottomMaskImageView = [[UIImageView alloc] initWithImage:maskImg];
        _bottomMaskImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _bottomMaskImageView.hidden = YES;
        [_coverImgView addSubview:_bottomMaskImageView];
        
        UIFont *textFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:10]];
        
        _fileSizeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _fileSizeLabel.font = textFont;
        _fileSizeLabel.textColorThemeKey = kColorText12;
        _fileSizeLabel.textAlignment = NSTextAlignmentCenter;
        _fileSizeLabel.hidden = YES;
        [_coverImgView addSubview:_fileSizeLabel];
        
        _durationLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _durationLabel.backgroundColorThemeKey = kColorBackground15;
        _durationLabel.textColorThemeKey = kColorText12;
        _durationLabel.font = textFont;
        _durationLabel.layer.masksToBounds = YES;
        _durationLabel.textAlignment = NSTextAlignmentCenter;
        [_coverImgView addSubview:_durationLabel];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideMovieView:) name:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopMovieViewPlayWithoutRemoveMovieView:) name:kExploreStopMovieViewPlaybackWithoutRemoveMovieViewNotification object:nil];

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize coverImgSize = self.frame.size;
    _coverImgView.frame = (CGRect){CGPointZero, coverImgSize};
    
    _playButton.center = CGPointMake(coverImgSize.width/2, coverImgSize.height/2);
    
    _durationLabel.text = [TTLiveCellHelper formattedTimeWithVideoDuration:_message.mediaFileDuration.floatValue];
    
    CGFloat lblSidePadding = SidePaddingOfVideoSizeLabel();
    if (TTLiveMessageNetworkStateSuccess == _message.networkState) {
        
        _bottomMaskImageView.hidden = YES;
        _fileSizeLabel.hidden = YES;
        _durationLabel.backgroundColorThemeKey = kColorBackground15;
        
        [_durationLabel sizeToFit];
        CGSize lblSize = CGSizeMake(CGRectGetWidth(_durationLabel.frame) + [TTDeviceUIUtils tt_padding:8] * 2, [TTDeviceUIUtils tt_padding:20]);
        _durationLabel.layer.cornerRadius = lblSize.height / 2;
        _durationLabel.frame = (CGRect){coverImgSize.width - lblSidePadding - lblSize.width, coverImgSize.height - lblSidePadding - lblSize.height, lblSize};
        
    } else {
        
        _bottomMaskImageView.hidden = NO;
        _bottomMaskImageView.frame = CGRectMake(0, coverImgSize.height - CGRectGetHeight(_bottomMaskImageView.frame),
                                                coverImgSize.width, CGRectGetHeight(_bottomMaskImageView.frame));
        
        _fileSizeLabel.hidden = NO;
        _fileSizeLabel.text = _message.mediaFileSize;
        [_fileSizeLabel sizeToFit];
        CGSize lblSize = _fileSizeLabel.frame.size;
        _fileSizeLabel.frame = (CGRect){lblSidePadding, coverImgSize.height - lblSidePadding - lblSize.height, lblSize};
        
        _durationLabel.backgroundColor = [UIColor clearColor];
        [_durationLabel sizeToFit];
        lblSize = _durationLabel.frame.size;
        _durationLabel.layer.cornerRadius = 0;
        _durationLabel.frame = (CGRect){coverImgSize.width - lblSidePadding - lblSize.width, coverImgSize.height - lblSidePadding - lblSize.height, lblSize};
    }
}

- (void)setupVideoViewWithMessage:(TTLiveMessage *)message
{
    _message = message;
    [_coverImgView setupImageWithMessage:message];
    
    [self setNeedsLayout];
}

- (void)videoPlayButtonPressed:(id)sender
{
    [TTLiveCellHelper dismissCellMenuIfNeeded];
    
    _movieView.alpha = 1;
    _movieView.hidden = NO;
    
    TTLiveMainViewController *chatroom = (TTLiveMainViewController *)[self ss_nextResponderWithClass:[TTLiveMainViewController class]];
    // 停掉视频直播、语音或其余短视频
    [TTLiveAudioManager stopCurrentPlayingAudioIfNeeded];
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreNeedStopAllMovieViewPlaybackNotification object:nil];
    //    [chatroom stopLiveVideoIfNeeded];
    [chatroom pauseLiveVideoIfNeeded];

    if (_movieController == nil) {
        _movieController = [[TTLocalAssetMovieController alloc] init];
        [self addSubview:_movieController.movieView];
        _movieController.movieView.frame = self.bounds;
        WeakSelf;
        _movieController.movieFinishBlock = ^ {
            StrongSelf;
            [self->_movieController stop];
            [self->_movieController.movieView removeFromSuperview];
            self->_movieController = nil;
            [chatroom startLiveVideoIfNeeded];
        };
    }
    TTLocalAssetMoviePlayModel *playModel = [[TTLocalAssetMoviePlayModel alloc] init];
    if (_message.localSelectedVideoURL) { //本地视频
        playModel.playURL = _message.localSelectedVideoURL.absoluteString;
    } else { //在线视频
        playModel.videoID = _message.mediaFileSourceId;
    }
    _movieController.playModel = playModel;
    [_movieController play];
}

- (void)hideMovieView:(NSNotification *)notice
{
    if (_movieController) {
        [_movieController stop];
        [_movieController.movieView removeFromSuperview];
        _movieController = nil;
    }
}

- (void)stopMovieViewPlayWithoutRemoveMovieView:(NSNotification *)notification
{
    [_movieController pause];

}

@end


#pragma mark - TTLiveCellMetaAudioView

#import <TTAccountBusiness.h>
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"

@interface TTLiveCellMetaAudioView : SSThemedView
- (void)setupAudioViewWithMessage:(TTLiveMessage *)message isIncomingMsg:(BOOL)isIncoming;
@end

@interface TTLiveCellMetaAudioView ()
@property (nonatomic, strong) TTLiveMessage *message;
@end

@implementation TTLiveCellMetaAudioView
{
    UIView *_bubbleBgView;
    SSThemedButton *_playButton;
    SSThemedImageView *_playIcon;
    SSThemedLabel *_durationLabel;
    SSThemedView *_redPointView;
    BOOL _isIncomingMsg;
}

- (void)dealloc
{
    [self removeMessageKVO];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        _bubbleBgView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _bubbleBgView.userInteractionEnabled = YES;
        [self addSubview:_bubbleBgView];
        
        _playButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        [_playButton addTarget:self action:@selector(audioPlayerButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        _playButton.borderColorThemeKey = kColorLine3;
        _playButton.layer.borderWidth = 1;
        _playButton.layer.cornerRadius = 15;
        _playButton.hitTestEdgeInsets = UIEdgeInsetsMake(5, 0, 5, 0);
        [_bubbleBgView addSubview:_playButton];
        
        _playIcon = [[SSThemedImageView alloc] init];
        _playIcon.imageName = @"chatroom_voice_third";
        _playIcon.userInteractionEnabled = NO;
        [_playIcon sizeToFit];
        [_bubbleBgView addSubview:_playIcon];
        
        _durationLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _durationLabel.textColorThemeKey = kColorText6;
        _durationLabel.font = [UIFont systemFontOfSize:TTLiveFontSize(16)];
        [_bubbleBgView addSubview:_durationLabel];
        
        _redPointView = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _redPointView.layer.cornerRadius = SideOfAudioTailRedPointView()/2;
        _redPointView.layer.masksToBounds = YES;
        _redPointView.backgroundColorThemeKey = kColorBackground7;
        [self addSubview:_redPointView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGSize bubbleSize = self.frame.size;
    _bubbleBgView.frame = (CGRect){0, 0, bubbleSize};
    CGFloat minWidth = CGRectGetMaxX(_durationLabel.frame) + [TTDeviceUIUtils tt_padding:4];
    if (minWidth >= bubbleSize.width) {
        CGRect tempFrame = _bubbleBgView.frame;
        tempFrame.size.width = minWidth;
        _bubbleBgView.frame = tempFrame;
    }
    
    CGFloat sidePaddingOfPlayIConAndDurationLabel = TTLivePadding(10);
    _playButton.frame = _bubbleBgView.bounds;
    _playIcon.frame = CGRectMake(_playButton.right - sidePaddingOfPlayIConAndDurationLabel - _playIcon.width, (_playButton.height - _playIcon.height)/2, _playIcon.width, _playIcon.height);
    _durationLabel.text = [NSString stringWithFormat:@"%@\"", _message.mediaFileDuration];
    [_durationLabel sizeToFit];
    _durationLabel.frame = (CGRect){_playButton.left + sidePaddingOfPlayIConAndDurationLabel , (bubbleSize.height - CGRectGetHeight(_durationLabel.frame))/2, _durationLabel.frame.size};
    CGFloat offsetX = -PaddingOfAudioBubbleAndRedPointView() - 2;
    CGFloat top = TopPaddingOfAudioBubbleAndRedPointView();
    if (_isIncomingMsg){
        offsetX = self.superview.width + PaddingOfAudioBubbleAndRedPointView();
    }
    if (_message.isReplyedMsg == NO && (self.message.cellLayout & TTLiveCellLayoutBubbleCoverTop) == 0){
        top += kLivePaddingCellTopInfoViewHeight(_message.cellLayout);
    }
    
    CGRect redPointFrame = CGRectMake(offsetX,top, SideOfAudioTailRedPointView(), SideOfAudioTailRedPointView());
    _redPointView.frame = [self convertRect:redPointFrame fromView:self.superview];
    _redPointView.hidden = _message.audioHadPlayed;
}

- (void)setupAudioViewWithMessage:(TTLiveMessage *)message isIncomingMsg:(BOOL)isIncoming
{
    [self removeMessageKVO];
    
    _message = message;
    _isIncomingMsg = isIncoming;
    
    [self addMessageKVO];
    
    
    _playButton.selected = _message.audioIsPlaying;
    [self setPlayiConIsPlaying:_message.audioIsPlaying];
    
    // 红点未读状态
    if ([_message.userId isEqualToString:[TTAccountManager userID]]) {
        _message.audioHadPlayed = YES;
        return;
    }
    
    NSString *pathStr= [NSTemporaryDirectory()
                         stringByAppendingPathComponent:[NSString stringWithFormat:@"TempAudios/%@.wav", _message.msgId]];
    BOOL hasMsgIdFilePath = [[NSFileManager defaultManager] fileExistsAtPath:pathStr];
    
    _message.audioHadPlayed = hasMsgIdFilePath;
}

- (void)audioPlayerButtonPressed:(id)sender
{
//    [TTLiveManager playAudioWithMessage:self.message];
    TTLiveMainViewController *chatroom = (TTLiveMainViewController *)[self ss_nextResponderWithClass:[TTLiveMainViewController class]];
    [TTLiveAudioManager playAudioWithMessage:self.message chatroom:chatroom];
}

- (void)setPlayiConIsPlaying:(BOOL)playing{
    if (playing){
        NSArray *nameArray = @[@"chatroom_voice_one",@"chatroom_voice_two",@"chatroom_voice_third"];
        NSMutableArray *imageArray = [NSMutableArray arrayWithCapacity:3];
        for (NSString *name in nameArray){
            UIImage *image = [UIImage themedImageNamed:name];
            [imageArray addObject:image];
        }
        _playIcon.animationImages = imageArray;
        _playIcon.animationDuration = 1;
        _playIcon.imageName = nil;
        [_playIcon startAnimating];
    }else{
        [_playIcon stopAnimating];
        _playIcon.imageName = @"chatroom_voice_third";
        _playIcon.animationImages = nil;
    }
}

- (void)addMessageKVO
{
    if (self.message) {
        [self.message addObserver:self forKeyPath:@"audioIsPlaying" options:NSKeyValueObservingOptionNew context:(void *)self];
        [self.message addObserver:self forKeyPath:@"audioHadPlayed" options:NSKeyValueObservingOptionNew context:(void *)self];
    }
}

- (void)removeMessageKVO
{
    if (self.message) {
        [self.message removeObserver:self forKeyPath:@"audioIsPlaying"];
        [self.message removeObserver:self forKeyPath:@"audioHadPlayed"];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ((__bridge id)context == self) {
        
        if ([keyPath isEqualToString:@"audioIsPlaying"]) {
            BOOL audioIsPlaying = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                _playButton.selected = audioIsPlaying;
                [self setPlayiConIsPlaying:audioIsPlaying];
            });
        } else if ([keyPath isEqualToString:@"audioHadPlayed"]) {
            BOOL audioHadPlayed = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
            dispatch_async(dispatch_get_main_queue(), ^{
                _redPointView.hidden = audioHadPlayed;
            });
        }
        
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end

#pragma mark - TTLiveCellMetaCardView
/** 卡片样式 */
@interface TTLiveCellMetaCardView : SSThemedView

/** 头像 */
@property (nonatomic, strong) TTImageView * _Nonnull imgView;
/** 姓名 */
@property (nonatomic, strong) SSThemedLabel * _Nonnull nameView;
/** VIP */
@property (nonatomic, strong) SSThemedImageView * _Nonnull vipView;
/** 简介 */
@property (nonatomic, strong) SSThemedLabel * _Nonnull summaryView;
/** 分割线 */
@property (nonatomic, strong) SSThemedView * _Nonnull splitView;
/** 来源图标 */
@property (nonatomic, strong) TTImageView * _Nonnull sourceIconView;
/** 来源名称 */
@property (nonatomic, strong) SSThemedLabel * _Nonnull sourceNameView;
/** 背景按钮 */
@property (nonatomic, strong) SSThemedButton * _Nonnull backgroundButton;
/** 跳转链接 */
@property (nonatomic, copy) NSString * _Nullable openUrl;

/** 更新卡片Message */
- (void)setupCardWithMessage:(TTLiveMessage * _Nonnull)message isIncoming:(BOOL)isIncoming;

@end

@implementation TTLiveCellMetaCardView {
    BOOL _isIncoming;
    BOOL _isReplyMessage;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
//        self.userInteractionEnabled = NO;
        self.backgroundColorThemeKey = kColorBackground4;
//        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clicked:)];
//        [self addGestureRecognizer:tapGesture];
        [self initSubview];
    }
    return self;
}

- (void)initSubview {
    if (_backgroundButton == nil) {
        _backgroundButton = [[SSThemedButton alloc] initWithFrame:self.bounds];
        _backgroundButton.backgroundColorThemeKey = kColorBackground4;
        _backgroundButton.userInteractionEnabled = YES;
        [_backgroundButton addTarget:self action:@selector(backgroundButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_backgroundButton];
    }
    if (_imgView == nil) {
        _imgView = [[TTImageView alloc] initWithFrame:CGRectMake(SidePaddingCardImageView(), SidePaddingCardImageView(), SideSizeCardImageView(), SideSizeCardImageView())];
        _imgView.borderColorThemeKey = kColorLine1;
        _imgView.enableNightCover = YES;
        _imgView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _imgView.backgroundColorThemeKey = kColorBackground3;
        _imgView.contentMode = UIViewContentModeCenter;
        _imgView.userInteractionEnabled = NO;
        [self addSubview:_imgView];
    }
    if (_nameView == nil) {
        _nameView = [[SSThemedLabel alloc] init];
        _nameView.font = [UIFont tt_fontOfSize:CardTitleFontSize()];
        _nameView.textColorThemeKey = kColorText1;
        _nameView.numberOfLines = 1;
        _nameView.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameView.userInteractionEnabled = NO;
        [self addSubview:_nameView];
    }
    if (_splitView == nil) {
        _splitView = [[SSThemedView alloc] initWithFrame:CGRectMake(SidePaddingCardImageView(), SidePaddingCardImageView() * 2 + SideSizeCardImageView() - [TTDeviceHelper ssOnePixel], 0, [TTDeviceHelper ssOnePixel])];
        _splitView.backgroundColor = [UIColor colorWithPatternImage:[UIImage themedImageNamed:@"chatroom_icon_point"]];
        _splitView.userInteractionEnabled = NO;
        [self addSubview:_splitView];
    }
    if (_sourceIconView == nil) {
        _sourceIconView = [[TTImageView alloc] initWithFrame:CGRectMake(SidePaddingCardImageView(), SidePaddingCardImageView() * 2 + SideSizeCardImageView() + SidePaddingCardSourceImageView(), SideSizeCardSourceImageView(), SideSizeCardSourceImageView())];
        _sourceIconView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _sourceIconView.borderColorThemeKey = kColorLine1;
        _sourceNameView.backgroundColorThemeKey = kColorBackground3;
        _sourceIconView.layer.cornerRadius = 2;
        _sourceIconView.contentMode = UIViewContentModeScaleAspectFit;
        _sourceIconView.userInteractionEnabled = NO;
        [self addSubview:_sourceIconView];
    }
    if (_sourceNameView == nil) {
        _sourceNameView = [[SSThemedLabel alloc] init];
        _sourceNameView.font = [UIFont tt_fontOfSize:CardSourceFontSize()];
        _sourceNameView.textColorThemeKey = kColorText3;
        _sourceNameView.numberOfLines = 1;
        _sourceNameView.lineBreakMode = NSLineBreakByTruncatingTail;
        _sourceNameView.userInteractionEnabled = NO;
        [self addSubview:_sourceNameView];
    }
}

- (SSThemedLabel *)summaryView {
    if (_summaryView == nil) {
        _summaryView = [[SSThemedLabel alloc] init];
        _summaryView.numberOfLines = 2;
        _summaryView.font = [UIFont tt_fontOfSize:CardSubtitleFontSize()];
        _summaryView.textColorThemeKey = kColorText3;
        _summaryView.userInteractionEnabled = NO;
        [self addSubview:_summaryView];
    }
    return _summaryView;
}

- (SSThemedImageView *)vipView {
    if (_vipView == nil) {
        _vipView = [[SSThemedImageView alloc] init];
        _vipView.size = CGSizeMake(14, 14);
        _vipView.image = [UIImage imageNamed:@"all_v_label"];
        _vipView.layer.cornerRadius = _vipView.width / 2;
        _vipView.layer.masksToBounds = YES;
        _vipView.enableNightCover = YES;
        [self addSubview:_vipView];
    }
    return _vipView;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    _splitView.backgroundColor = [UIColor colorWithPatternImage:[UIImage themedImageNamed:@"chatroom_icon_point"]];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (_nameView.numberOfLines == 1) {
        [_nameView sizeToFit];
        _nameView.height = CardTitleFontSize();
        if (_nameView.width > self.width - SidePaddingCardImageView() * 3 - SideSizeCardImageView()) {
            _nameView.width = self.width - SidePaddingCardImageView() * 3 - SideSizeCardImageView();
        }
    } else {
        _nameView.width = self.width - SidePaddingCardImageView() * 3 - SideSizeCardImageView();
        _nameView.height = [TTLabelTextHelper heightOfText:_nameView.text fontSize:CardTitleFontSize() forWidth:_nameView.width forLineHeight:CardTitleLineHeight() constraintToMaxNumberOfLines:2];
    }
    if (_summaryView && !_summaryView.hidden) {
        CGFloat summaryHeight = [TTLabelTextHelper heightOfText:_summaryView.text fontSize:CardSubtitleFontSize() forWidth:(self.width - SidePaddingCardImageView() * 3 - SideSizeCardImageView()) forLineHeight:CardSubtitleLineHeight() constraintToMaxNumberOfLines:2];
        CGFloat totalHeight = _nameView.height + InsidePaddingCardTitleToSubtitle() + summaryHeight - 5;
        _nameView.origin = CGPointMake(SidePaddingCardImageView() * 2 + SideSizeCardImageView(), SidePaddingCardImageView() + (SideSizeCardImageView() - totalHeight) / 2);
        _summaryView.frame = CGRectMake(SidePaddingCardImageView() * 2 + SideSizeCardImageView(), _nameView.bottom + InsidePaddingCardTitleToSubtitle() - 2.5, self.width - SidePaddingCardImageView() * 3 - SideSizeCardImageView(), summaryHeight);
    } else {
        _nameView.left = SidePaddingCardImageView() * 2 + SideSizeCardImageView();
        _nameView.centerY = _imgView.centerY;
    }
    if (_vipView && !_vipView.hidden) {
        if (_vipView.width + LeftPaddingCardVip() + _nameView.width > self.width - SidePaddingCardImageView() * 3 - SideSizeCardImageView()) {
            _vipView.right = self.width - SidePaddingCardImageView();
            _nameView.width = _vipView.left - LeftPaddingCardVip() - _nameView.left;
        } else {
            _vipView.left = _nameView.right + LeftPaddingCardVip();
        }
        _vipView.centerY = _nameView.centerY;
    }
    _splitView.width = self.width - SidePaddingCardImageView() * 2;
    [_sourceNameView sizeToFit];
    _sourceNameView.left = _sourceIconView.right + LeftPaddingCardSourceMessage();
    _sourceNameView.centerY = _sourceIconView.centerY;
    if (_sourceNameView.right > self.width - SidePaddingCardImageView() * 2) {
        _sourceNameView.width = self.width - SidePaddingCardImageView() * 2 - _sourceNameView.left;
    }
    
    self.backgroundColorThemeKey = (_isIncoming ? (_isReplyMessage ? kColorBackground3 : kColorBackground4) : (_isReplyMessage ? kColorBackground4 : kColorBackground3));
    self.backgroundButton.backgroundColorThemeKey = self.backgroundColorThemeKey;
    self.backgroundButton.backgroundColor = [UIColor tt_themedColorForKey:self.backgroundColorThemeKey];
    self.backgroundButton.highlightedBackgroundColorThemeKey = [self.backgroundColorThemeKey stringByAppendingString:@"Highlighted"];
    
    _backgroundButton.frame = self.bounds;
}

- (void)setupCardWithMessage:(TTLiveMessage *)message isIncoming:(BOOL)isIncoming {

    [_imgView setImageWithURLString:message.cardModel.icon placeholderImage:[UIImage themedImageNamed:@"ugc_feed_link"]];
    if (message.msgType == TTLiveMessageTypeArticleCard) {
        _nameView.numberOfLines = 2;
        _nameView.attributedText = [TTLabelTextHelper attributedStringWithString:message.cardModel.name fontSize:CardTitleFontSize() lineHeight:CardTitleLineHeight()];
    } else {
        _nameView.numberOfLines = 1;
        _nameView.text = message.cardModel.name;
    }
    
    if (message.msgType == TTLiveMessageTypeProfileCard && [message.cardModel.vip boolValue]) {
        self.vipView.hidden = NO;
    } else {
        _vipView.hidden = YES;
    }
    
    if (message.msgType != TTLiveMessageTypeArticleCard && !isEmptyString(message.cardModel.summary)) {
        self.summaryView.hidden = NO;
        _summaryView.attributedText = [TTLabelTextHelper attributedStringWithString:message.cardModel.summary fontSize:CardSubtitleFontSize() lineHeight:CardSubtitleLineHeight()];
    } else {
        _summaryView.hidden = YES;
    }

    if (message.msgType == TTLiveMessageTypeArticleCard) {
        [_sourceIconView setImageWithURLString:message.cardModel.sourceIcon placeholderImage:nil];
    } else {
        _sourceIconView.image = [UIImage imageNamed:@"chatroom_icon_toutiao"];
    }
    
    if (message.msgType == TTLiveMessageTypeProfileCard) {
        _sourceNameView.text = @"个人名片";
    } else if (message.msgType == TTLiveMessageTypeMediaCard) {
        _sourceNameView.text = @"头条号名片";
    } else {
        _sourceNameView.text = message.cardModel.sourceName;
    }
    _isIncoming = isIncoming;
    _isReplyMessage = message.isReplyedMsg;
    
    self.backgroundButton.hidden = NO;
    if (!isEmptyString(message.openURLStr)) {
        _openUrl = message.openURLStr;
    } else if (!isEmptyString(message.link)) {
        _openUrl = message.link;
    } else {
        _openUrl = nil;
        _backgroundButton.hidden = YES;
    }
}

- (void)backgroundButtonClicked:(id)sender {
    if (_openUrl) {
        if ([_openUrl hasPrefix:@"http"]) {
            [SSWebViewController openWebViewForNSURL:[NSURL URLWithString:_openUrl] title:@"网页浏览" navigationController:self.navigationController supportRotate:NO];
        } else {
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:_openUrl]];
        }
    }
}

@end

#pragma mark - TTLiveCellNormalContentView

@interface TTLiveCellNormalContentView ()

@property (nonatomic, strong) TTLiveCellMetaVideoView *videoView;
@property (nonatomic, strong) TTLiveCellMetaAudioView *audioView;
@property (nonatomic, strong) TTLiveCellMetaImageView *metaImgView;
@property (nonatomic, strong) TTLiveCellMetaTextView *metaTextView;
@property (nonatomic, strong) TTLiveCellMetaCardView *metaCardView;

@property (nonatomic, strong) SSThemedImageView *arrowImgView;

@end

@implementation TTLiveCellNormalContentView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColors = nil;
    self.layer.cornerRadius = 0;
    if (self.isReplyedMsg) {
        self.backgroundColors = @[@"ffffffdc",@"ffffff19"];
        self.layer.cornerRadius = 2;
    }
    
    BOOL hasMsgText = !isEmptyString(self.message.msgText);
    if (hasMsgText) {
        self.metaTextView.hidden = NO;
        self.metaTextView.origin = CGPointMake(OriginXOfCellContent(), ceil(CGRectGetMaxY(self.topInfoView.frame) + ((self.message.cellLayout & TTLiveCellLayoutBubbleCoverTop) || self.isReplyedMsg ? 0 : SidePaddingOfContentView())));
        CGSize textSize = [TTLiveCellHelper sizeOfTextViewWithMessage:self.message];
        self.metaTextView.size = textSize;
        if (!self.isIncomingMsg) {
            self.metaTextView.right = self.width - OriginXOfCellContent();
        }
        
        /// 调整行间距
        self.metaTextView.font = [UIFont systemFontOfSize:(self.isReplyedMsg ? FontSizeOfReplyedTextMessage() : FontSizeOfTextMessage())];
        self.metaTextView.lineHeight = (self.isReplyedMsg ? LineHeightOfReplyedTextMessage() : LineHeightOfTextMessage());
        self.metaTextView.textColorKey = (self.isReplyedMsg ? kColorText2 : kColorText1);
        self.metaTextView.text = nil;
        self.metaTextView.attributedText = nil;
        if (self.message.cellLayout & TTLiveCellLayoutIsTop) {
            NSDictionary *attributes = [NSString tt_attributesWithFont:self.metaTextView.font lineHeight:self.metaTextView.lineHeight lineBreakMode:self.metaTextView.lineBreakMode firstLineIndent:self.metaTextView.firstLineIndent alignment:self.metaTextView.textAlignment];
            //由于自定义字体有向下偏移的问题，这次处理一下只有公告icon的问题
            if ([self.message.msgText isEqualToString:@"\U0000E613\n\n"]) {
                self.metaTextView.lineHeight = FontSizeOfTopTextLabel();
            }
            self.metaTextView.attributedText = [TTLiveCellHelper topMessageStrWithMessage:self.message extraAttributeDict:attributes];
        } else {
            self.metaTextView.text = self.message.msgText;
        }
        
        // 处理显示广告外链arrow
        if (!isEmptyString(self.message.link)) {
            self.metaTextView.width = self.metaTextView.width - OffsetOfTextView4ADType();
            self.arrowImgView.center = CGPointMake(self.metaTextView.right + OriginXOfCellContent() + WidthOfRightArrow() / 2,
                                                   self.metaTextView.centerY);
            self.arrowImgView.hidden = NO;
        } else {
            _arrowImgView.hidden = YES;
        }
    } else {
        _metaTextView.hidden = YES;
        _metaTextView.text = nil;
        _metaTextView.frame = CGRectZero;
        _arrowImgView.hidden = YES;
    }
    
    if (TTLiveMessageTypeText != self.message.msgType) {
        CGPoint mediaViewOrigin = CGPointMake(OriginXOfCellContent(),
                                              hasMsgText ? _metaTextView.bottom + PaddingOfTextViewAndMediaView()
                                              : CGRectGetMaxY(self.topInfoView.frame) + (self.isReplyedMsg ? 0 : self.message.cellLayout & TTLiveCellLayoutBubbleCoverTop ? 0 : SidePaddingOfContentView()));
        switch (self.message.msgType) {
            case TTLiveMessageTypeImage:
                self.metaImgView.frame = (CGRect){mediaViewOrigin, [TTLiveCellHelper adjustedSizeOfSourceMetaImageSize:self.message.imageModel ? CGSizeMake(self.message.imageModel.width, self.message.imageModel.height) : self.message.sizeOfOriginImage
                                                                                                          isReplyedMsg:self.isReplyedMsg
                                                                                                            cellLayout:self.message.cellLayout]};
                if (!self.isIncomingMsg) {
                    self.metaImgView.right = self.width - OriginXOfCellContent();
                }
                break;
                
            case TTLiveMessageTypeVideo:
                self.videoView.frame = (CGRect){mediaViewOrigin, [TTLiveCellHelper adjustedSizeOfSourceMetaImageSize:self.message.imageModel ? CGSizeMake(self.message.imageModel.width, self.message.imageModel.height) : self.message.sizeOfOriginImage
                                                                                                        isReplyedMsg:self.isReplyedMsg
                                                                                                          cellLayout:self.message.cellLayout]};
                if (!self.isIncomingMsg) {
                    self.videoView.right = self.width - OriginXOfCellContent();
                }
                break;
                
            case TTLiveMessageTypeAudio:
            {
                CGSize contentMediaViewSize = self.frame.size;
                CGSize audioViewSize = [TTLiveCellHelper sizeOfMetaAudioViewWithMessage:self.message];
                self.audioView.frame = (CGRect){self.isIncomingMsg ? OriginXOfCellContent() : contentMediaViewSize.width - audioViewSize.width - OriginXOfCellContent(), mediaViewOrigin.y, audioViewSize};
            }
                break;
            case TTLiveMessageTypeProfileCard:
            case TTLiveMessageTypeMediaCard:
            case TTLiveMessageTypeArticleCard:
            {
                CGFloat width = self.isReplyedMsg ? MaxWidthOfReplyedText(self.message.cellLayout) : MaxWidthOfText(self.message.cellLayout);
                self.metaCardView.frame = (CGRect){mediaViewOrigin, width, SidePaddingCardImageView() * 2 + SideSizeCardImageView() + SidePaddingCardSourceImageView() * 2 + SideSizeCardSourceImageView()};
                if (!self.isIncomingMsg) {
                    self.metaCardView.right = self.width - OriginXOfCellContent();
                }
            }
                break;
                
            default:
                break;
        }
    }
}

- (void)showContentWithMessage:(TTLiveMessage *)message isIncomingMsg:(BOOL)isIncoming
{
    [super showContentWithMessage:message isIncomingMsg:isIncoming];
    
    // 在这个入口处把imgView.image置为nil是为了及时停掉GIF图的播放，还有避免imgView被重用时图片被覆盖的问题。
    _metaImgView.imgView.image = nil;
    _videoView.coverImgView.imgView.image = nil;
    
    switch (message.msgType) {
            
        case TTLiveMessageTypeText:
            _metaImgView.hidden = YES;
            _videoView.hidden = YES;
            _audioView.hidden = YES;
            _metaCardView.hidden = YES;

            break;
            
        case TTLiveMessageTypeImage:
            _metaImgView.hidden = NO;
            _videoView.hidden = YES;
            _audioView.hidden = YES;
            _metaCardView.hidden = YES;

            [self.metaImgView setupImageWithMessage:message];
            
            break;
            
        case TTLiveMessageTypeVideo:
            _videoView.hidden = NO;
            _audioView.hidden = YES;
            _metaImgView.hidden = YES;
            _metaCardView.hidden = YES;

            [self.videoView setupVideoViewWithMessage:message];
            
            break;
            
        case TTLiveMessageTypeAudio:
            _audioView.hidden = NO;
            _videoView.hidden = YES;
            _metaImgView.hidden = YES;
            _metaCardView.hidden = YES;
            
            [self.audioView setupAudioViewWithMessage:message isIncomingMsg:isIncoming];
            
            break;
        case TTLiveMessageTypeProfileCard:
        case TTLiveMessageTypeMediaCard:
        case TTLiveMessageTypeArticleCard:
            _metaCardView.hidden = NO;
            _audioView.hidden = YES;
            _videoView.hidden = YES;
            _metaImgView.hidden = YES;
            [self.metaCardView setupCardWithMessage:message isIncoming:isIncoming];
            break;
        default:
            break;
    }
    
    [self setNeedsLayout];
}

#pragma mark - getter

- (TTLiveCellMetaTextView *)metaTextView
{
    if (!_metaTextView) {
        _metaTextView = [[TTLiveCellMetaTextView alloc] initWithFrame:CGRectZero];
        _metaTextView.font = [UIFont systemFontOfSize:FontSizeOfTextMessage()];
        _metaTextView.numberOfLines = 0;
        _metaTextView.textColorKey = kColorText1;
        [self addSubview:_metaTextView];
    }
    return _metaTextView;
}

- (TTLiveCellMetaVideoView *)videoView
{
    if (!_videoView) {
        _videoView = [[TTLiveCellMetaVideoView alloc] initWithFrame:CGRectZero];
        // _videoView.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_videoView];
    }
    return _videoView;
}

- (TTLiveCellMetaImageView *)metaImgView
{
    if (!_metaImgView) {
        _metaImgView = [[TTLiveCellMetaImageView alloc] initWithFrame:CGRectZero];
        _metaImgView.userInteractionEnabled = YES;
        [self addSubview:_metaImgView];
    }
    return _metaImgView;
}

- (TTLiveCellMetaAudioView *)audioView
{
    if (!_audioView) {
        _audioView = [[TTLiveCellMetaAudioView alloc] initWithFrame:CGRectZero];
        [self addSubview:_audioView];
    }
    return _audioView;
}

- (TTLiveCellMetaCardView *)metaCardView {
    if (_metaCardView == nil) {
        _metaCardView = [[TTLiveCellMetaCardView alloc] initWithFrame:CGRectZero];
        [self addSubview:_metaCardView];
    }
    return _metaCardView;
}

- (SSThemedImageView *)arrowImgView
{
    if (!_arrowImgView) {
        _arrowImgView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, WidthOfRightArrow(), WidthOfRightArrow())];
        _arrowImgView.imageName = @"chatroom_arrow";
        [self addSubview:_arrowImgView];
    }
    return _arrowImgView;
}

@end
