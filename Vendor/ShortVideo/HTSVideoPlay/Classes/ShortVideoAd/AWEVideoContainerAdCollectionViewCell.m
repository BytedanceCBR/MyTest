//
//  AWEVideoContainerCollectionViewCell.m
//  Pods
//
//  Created by Zuyang Kou on 19/06/2017.
//
//

#import "AWEVideoContainerAdCollectionViewCell.h"

#import "AWEVideoDetailTracker.h"
#import "TSVShortVideoOriginalData.h"
#import "AWEVideoDetailScrollConfig.h"
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "AWEVideoDetailControlAdOverlayViewController.h"
#import "TTShortVideoModel+TTAdFactory.h"
#import "TTAShortVideoTracker.h"

@interface AWEVideoContainerAdCollectionViewCell () <AWEVideoPlayViewDelegate>

@property (nonatomic, strong) AWEVideoPlayView *videoPlayView;
@property (nonatomic, assign) BOOL usingFirstFrameCover;
@property (nonatomic, strong, readwrite) TTShortVideoModel *videoDetail;
@property (nonatomic, assign) BOOL hasShow;
@property (nonatomic, strong) TTAShortVideoTracker *videoTracker;

@end

@implementation AWEVideoContainerAdCollectionViewCell

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
    }
    
    return self;
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
    
    if ([TTDeviceHelper isIPhoneXDevice]) {
        self.videoPlayView.top = self.tt_safeAreaInsets.top;
        self.videoPlayView.height = ceil(CGRectGetWidth(frame) * 16 / 9);
    }
}

- (void)playView:(AWEVideoPlayView *)view didStartPlayWithModel:(TTShortVideoModel *)model
{
    if (self.videoDidStartPlay) {
        self.videoDidStartPlay();
    }
    
    if (!self.hasShow) {
        [self.videoDetail.rawAd trackDrawWithTag:@"draw_ad" label:@"show" extra:nil];
        self.hasShow = YES;
    }
    [self.videoTracker play];
}

- (void)playView:(AWEVideoPlayView *)view didPausePlayWithModel:(TTShortVideoModel *)model duration:(NSTimeInterval)duration
{
    [self.videoTracker pause];
}

- (void)playView:(AWEVideoPlayView *)view didResumePlayWithModel:(TTShortVideoModel *)model duration:(NSTimeInterval)duration
{
    [self.videoTracker resume];
}

- (void)playView:(AWEVideoPlayView *)view didStopPlayWithModel:(TTShortVideoModel *)model duration:(NSTimeInterval)duration
{
    [self.videoTracker stop];
}

- (void)playView:(AWEVideoPlayView *)view didPlayNextLoopWithModel:(TTShortVideoModel *)model
{
    [self.overlayViewController.viewModel videoDidPlayOneLoop];
    
    if (self.videoDidPlayOneLoop) {
        self.videoDidPlayOneLoop();
    }
    [self.videoTracker over];
    [self.videoTracker play];
}

- (void)prepareForReuse
{
    self.hasShow = NO;
    [self.videoPlayView stop];
    [self.videoTracker begin];
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
    self.videoTracker = [[TTAShortVideoTracker alloc] initWithModel:videoDetail];
}

- (void)cellWillDisplay
{
    [self.overlayViewController.viewModel cellWillDisplay];
    [self.videoTracker begin];
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.videoTracker begin];
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.videoTracker end];
}

@end
