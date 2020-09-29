//
//  AWEVideoContainerCollectionViewCell.m
//  Pods
//
//  Created by Zuyang Kou on 19/06/2017.
//
//

#import "AWEVideoContainerCollectionViewCell.h"
#import "TSVShortVideoOriginalData.h"
#import "AWEVideoDetailScrollConfig.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "AWEVideoDetailControlOverlayViewController.h"
#import "TTSettingsManager.h"
#import "TSVVideoDetailControlOverlayUITypeConfig.h"
#import <AVFoundation/AVFoundation.h>
#import "FHShortVideoTracerUtil.h"
#import "TTAccountManager.h"

@interface AWEVideoContainerCollectionViewCell () <AWEVideoPlayViewDelegate>

@property (nonatomic, strong) AWEVideoPlayView *videoPlayView;
@property (nonatomic, assign) NSTimeInterval totalPlayTime;
@property (nonatomic, assign) BOOL usingFirstFrameCover;
@property (nonatomic, strong, readwrite) FHFeedUGCCellModel *videoDetail;

@end

@implementation AWEVideoContainerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.videoPlayView = ({
            AWEVideoPlayView *view = [[AWEVideoPlayView alloc] initWithFrame:self.bounds];
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            view.delegate = self;
            view;
        });
        [self.contentView addSubview:self.videoPlayView];

        UIView *doubleTapMaskView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.contentView.bounds), CGRectGetHeight(self.contentView.bounds) - 50 - 25)];
        doubleTapMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        doubleTapMaskView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:doubleTapMaskView];

        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onPlayerDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onPlayerSingleTap:)];
        singleTap.numberOfTapsRequired = 1;
        
        [doubleTapMaskView addGestureRecognizer:doubleTap];
        [doubleTapMaskView addGestureRecognizer:singleTap];

        [singleTap requireGestureRecognizerToFail:doubleTap];
    }

    return self;
}

- (void)_onPlayerDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (!self.videoDetail) {
        return;
    }
    if ([self.overlayViewController isKindOfClass:[AWEVideoDetailControlOverlayViewController class]]) {
        if (![TTAccountManager isLogin]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            NSString *page_type = [FHShortVideoTracerUtil pageType];
            [params setObject:page_type forKey:@"enter_from"];
            [params setObject:@"click_publisher" forKey:@"enter_type"];
            // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
            [params setObject:@(YES) forKey:@"need_pop_vc"];
            [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
                if (type == TTAccountAlertCompletionEventTypeDone) {
                    //登录成功 走发送逻辑
                    if ([TTAccountManager isLogin]) {
                        [(AWEVideoDetailControlOverlayViewController *)self.overlayViewController diggShowAnima:YES];
                    }
                }
            }];
            
        }else {
            [(AWEVideoDetailControlOverlayViewController *)self.overlayViewController diggShowAnima:YES];
        }
    }
}

- (void)_onPlayerSingleTap:(UITapGestureRecognizer *)recognizer
{
    if (!self.videoDetail) {
        return;
    }

    if ([self.overlayViewController isKindOfClass:[AWEVideoDetailControlOverlayViewController class]]) {
        [(AWEVideoDetailControlOverlayViewController *)self.overlayViewController tapToFoldRecCard];
    }
    [self.videoPlayView pauseOrPlayVideo];
    if (self.videoPlayView.isPlaying) {
        [FHShortVideoTracerUtil videoPlayOrPauseWithName:@"video_play" eventModel:self.videoDetail eventIndex:_selfIndex];
    }else {
        [FHShortVideoTracerUtil videoPlayOrPauseWithName:@"video_pause" eventModel:self.videoDetail eventIndex:_selfIndex];
    }
    
}
# pragma mark - Digg Animation

- (CGRect)_scaleRect:(CGRect)rect scale:(CGFloat)scale
{
    CGFloat addedWidth = rect.size.width * (scale - 1);
    CGFloat addedHeight = rect.size.height * (scale - 1);
    return CGRectMake(rect.origin.x - addedWidth * 0.5,
                      rect.origin.y - addedHeight * 0.5,
                      rect.size.width + addedWidth,
                      rect.size.height + addedHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect frame = self.bounds;

    switch ([AWEVideoDetailScrollConfig direction]) {
        case AWEVideoDetailScrollDirectionHorizontal:
            frame.size.width -= self.spacingMargin;
            break;
        case AWEVideoDetailScrollDirectionVertical:
            frame.size.height -= self.spacingMargin;
            break;
    }
    self.videoPlayView.frame = frame;
    self.overlayViewController.view.frame = frame;
    
        CGFloat videoAspectRatio = [self.videoDetail.video.height floatValue] / [self.videoDetail.video.width floatValue];

        CGSize screenSize = [UIScreen mainScreen].bounds.size;
 
        CGFloat screenAspectRatio = screenSize.height > screenSize.width ? (screenSize.height / screenSize.width) : (screenSize.width / screenSize.height);

        if(videoAspectRatio >= screenAspectRatio){
            self.videoPlayView.contentMode = UIViewContentModeScaleAspectFill;
        }else{
//            if ([TTDeviceHelper isIPhoneXDevice]) {
//                self.videoPlayView.top = self.tt_safeAreaInsets.top;
//                CGFloat height = CGRectGetHeight(frame) - self.tt_safeAreaInsets.top;
//                self.videoPlayView.height = ceil(CGRectGetWidth(frame) * 16 / 9);
//                if(videoAspectRatio >= (16.0 / 9.0)){
//                    self.videoPlayView.contentMode = UIViewContentModeScaleAspectFill;
//                }else{
//                    self.videoPlayView.contentMode = UIViewContentModeScaleAspectFit;
//                }
//            }else{
                self.videoPlayView.contentMode = UIViewContentModeScaleAspectFit;
//            }
        }
        
//        if ([TTDeviceHelper isIPhoneXDevice]) {
//            if (videoAspectRatio > 1.7) {
//                self.videoPlayView.contentMode = UIViewContentModeScaleAspectFill;
//            } else {
//                self.videoPlayView.contentMode = UIViewContentModeScaleAspectFit;
//            }
//        } else {
//            if (videoAspectRatio > 1.6) {
//                self.videoPlayView.contentMode = UIViewContentModeScaleAspectFill;
//            } else {
//                self.videoPlayView.contentMode = UIViewContentModeScaleAspectFit;
//            }
//        }
}

- (void)playView:(AWEVideoPlayView *)view didStartPlayWithModel:(TTShortVideoModel *)model
{
    if (self.videoDidStartPlay) {
        self.videoDidStartPlay();
    }
}

- (void)playView:(AWEVideoPlayView *)view didStopPlayWithModel:(TTShortVideoModel *)model duration:(NSTimeInterval)duration
{
    //FIXME: duration 装成是 NSTimeInterval, 但单位是秒
    self.totalPlayTime += duration / 1000;
}

- (void)playView:(AWEVideoPlayView *)view didPlayNextLoopWithModel:(TTShortVideoModel *)model
{
    [self.overlayViewController.viewModel videoDidPlayOneLoop];
    NSString *duration = [NSString stringWithFormat:@"%.0f", self.totalPlayTime * 1000];
    [FHShortVideoTracerUtil videoOverWithModel:self.videoDetail eventIndex:self.selfIndex forStayTime:duration];
    if (self.videoDidPlayOneLoop) {
        self.videoDidPlayOneLoop();
    }
}

- (void)prepareForReuse
{
    self.totalPlayTime = 0;
    [self.videoPlayView stop];
}

- (void)setSpacingMargin:(CGFloat)spacingMargin
{
    _spacingMargin = spacingMargin;

    [self setNeedsLayout];
}

- (void)setCommonTrackingParameter:(NSDictionary *)commonTrackingParameter
{
    _commonTrackingParameter = commonTrackingParameter;

    self.videoPlayView.commonTrackingParameter = self.commonTrackingParameter;
}

- (void)updateWithModel:(FHFeedUGCCellModel *)videoDetail usingFirstFrameCover:(BOOL)usingFirstFrameCover
{
    self.videoDetail = videoDetail;
    self.usingFirstFrameCover = usingFirstFrameCover;
    
    [self.videoPlayView updateWithModel:videoDetail usingFirstFrameCover:usingFirstFrameCover];
}

- (void)cellWillDisplay
{
    [self.overlayViewController.viewModel cellWillDisplay];
}

@end
