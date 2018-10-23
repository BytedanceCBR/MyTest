//
//  AWEVideoContainerCollectionViewCell.m
//  Pods
//
//  Created by Zuyang Kou on 19/06/2017.
//
//

#import "AWEVideoContainerCollectionViewCell.h"
#import "AWEVideoDetailTracker.h"
#import "TSVShortVideoOriginalData.h"
#import "AWEVideoDetailScrollConfig.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "AWEVideoDetailControlOverlayViewController.h"
#import "TTSettingsManager.h"
#import "TSVVideoDetailControlOverlayUITypeConfig.h"
#import <AVFoundation/AVFoundation.h>

@interface AWEVideoContainerCollectionViewCell () <AWEVideoPlayViewDelegate>

@property (nonatomic, strong) AWEVideoPlayView *videoPlayView;
@property (nonatomic, assign) NSTimeInterval totalPlayTime;
@property (nonatomic, assign) BOOL usingFirstFrameCover;
@property (nonatomic, strong, readwrite) TTShortVideoModel *videoDetail;

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
    
    [AWEVideoDetailTracker trackEvent:@"rt_like"
                                model:self.videoDetail
                      commonParameter:self.commonTrackingParameter
                       extraParameter:@{
                                        @"user_id": self.videoDetail.author.userID,
                                        @"position": @"double_like",
                                        }];

    if ([self.overlayViewController isKindOfClass:[AWEVideoDetailControlOverlayViewController class]]) {
        [(AWEVideoDetailControlOverlayViewController *)self.overlayViewController digg];
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

    BOOL useEdgeToEdgeUI = [[[TTSettingsManager sharedManager] settingForKey:@"tt_huoshan_detail_edge_to_edge_adjustment"
                                                                defaultValue:@YES
                                                                      freeze:NO] boolValue];
    if (useEdgeToEdgeUI) {
        CGFloat videoAspectRatio;
        NSString *videoLocalPlayAddr = self.videoDetail.videoLocalPlayAddr;
        if (videoLocalPlayAddr.length > 0) {
            //获取视频尺寸
            AVURLAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:videoLocalPlayAddr]];
            NSArray *array = asset.tracks;
            CGSize videoSize = CGSizeZero;
            for (AVAssetTrack *track in array) {
                if ([track.mediaType isEqualToString:AVMediaTypeVideo]) {
                    videoSize = track.naturalSize;
                }
            }
            if (videoSize.width > 0 && videoSize.height > 0) {
                videoAspectRatio = videoSize.height / videoSize.width;
            } else {
                videoAspectRatio = 16 / 9;
            }
        } else {
            videoAspectRatio = self.videoDetail.video.height / self.videoDetail.video.width;
        }
        if ([TTDeviceHelper isIPhoneXDevice]) {
            if (videoAspectRatio > 1.7) {
                self.videoPlayView.contentMode = UIViewContentModeScaleAspectFill;
            } else {
                self.videoPlayView.contentMode = UIViewContentModeScaleAspectFit;
            }
        } else {
            if (videoAspectRatio > 1.6) {
                self.videoPlayView.contentMode = UIViewContentModeScaleAspectFill;
            } else {
                self.videoPlayView.contentMode = UIViewContentModeScaleAspectFit;
            }
        }
    } else {
        if ([TTDeviceHelper isIPhoneXDevice]) {
            self.videoPlayView.top = self.tt_safeAreaInsets.top;
            self.videoPlayView.height = ceil(CGRectGetWidth(frame) * 16 / 9);
        }
        self.videoPlayView.contentMode = UIViewContentModeScaleAspectFit;
    }
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

- (void)updateWithModel:(TTShortVideoModel *)videoDetail usingFirstFrameCover:(BOOL)usingFirstFrameCover
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
