//
//  TTVDetailPlayControl.h
//  Article
//
//  Created by panxiang on 2017/7/7.
//
//

#import <Foundation/Foundation.h>
#import "TTVideoShareMovie.h"
#import "TTDetailModel.h"
#import "TTVDetailContext.h"
#import "TTVVideoDetailMovieBannerProtocol.h"
#import "TTVPlayerDoubleTap666Delegate.h"

@protocol TTVDetailPlayControlDelegate <NSObject>

@optional
- (void)ttv_playerOrientationState:(BOOL)isFullScreen;
- (CGRect)ttv_playerControlerMovieFrame;
- (void)ttv_playerControlerShowDetailButtonClicked;
- (BOOL)ttv_playerControlerShouldShowDetailButton;
- (CGRect)ttv_playerControlerMovieViewFrameAfterExitFullscreen;
- (void)ttv_playerControlerPreVideoDidPlay;
- (void)ttv_playerControlerShareButtonClicked;
- (void)ttv_playerControlerMoreButtonClicked:(BOOL )isFullScreen;
- (void)ttv_playerFinishTipShareButtonClicked;
- (void)ttv_playerFinishTipMoreButtonClicked;
- (void)ttv_playerFinishTipDirectShareActionWithActivityType:(NSString *)activityType;
- (void)ttv_playingShareViewDirectShareActionWithActivityType:(NSString *)activityType;

- (void)ttv_playerControllerFullScreenButtonClicked:(BOOL)isFull;
- (BOOL)ttv_shouldAllocTipAdNewCreator;

@end

@class TTVPlayVideo, TTVCommodityView;
@interface TTVDetailPlayControl : NSObject<TTVDetailContext>
@property (nonatomic, strong ,readonly) TTVPlayVideo *movieView;
@property (nonatomic, strong) TTVideoShareMovie *shareMovie;
@property (nonatomic, strong) TTVDetailStateStore *detailStateStore;
@property (nonatomic, weak) id <TTVDetailPlayControlDelegate> delegate;
@property (nonatomic, weak) id<TTVPlayerDoubleTap666Delegate> doubleTap666Delegate;
@property (nonatomic, weak) UIView<TTVVideoDetailMovieBannerProtocol> *movieBanner;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) CGRect movieFrame;
@property (nonatomic, assign) NSInteger enableTrackSDK;
@property (nonatomic, strong) id<TTVArticleProtocol> videoInfo;
@property (nonatomic, strong ,readonly) TTVCommodityView *commodityView;

- (void)viewDidLoad;
- (void)invalideMovieView;
- (void)invalideMovieViewWithFinishedBlock:(void (^)(void))finishedBlock;
- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewDidDisappear;
- (BOOL)shouldLayoutSubviews;
- (void)playButtonClicked;
- (float)watchPercent;
- (void)updateFrame;
- (BOOL)isMovieFullScreen;
- (void)showDetailButtonIfNeeded;
- (BOOL)isFirstPlayMovie;
- (void)pauseMovieIfNeeded;
- (void)playMovieIfNeeded;
- (void)playMovieIfNeededAndRebindToMovieShotView:(BOOL)rebindToMovieShotView;
- (void)setToolBarHidden:(BOOL)hidden;
- (void)addCommodity;
@end
