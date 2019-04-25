//
//  TTVideoDetailPlayControl.h
//  Article
//
//  Created by panxiang on 2017/6/6.
//
//

#import <Foundation/Foundation.h>
#import "TTVideoShareMovie.h"
#import "TTDetailModel.h"
#import "TTVideoDetailViewController.h"

@class TTVideoMovieBanner;
@protocol TTVideoDetailPlayControlDelegate <NSObject>

@optional
- (CGRect)ttv_playerControlerMovieFrame;
- (void)ttv_playerControlerShowDetailButtonClicked;
- (BOOL)ttv_playerControlerShouldShowDetailButton;
- (CGRect)ttv_playerControlerMovieViewFrameAfterExitFullscreen;
- (void)ttv_shareButtonOnMovieFinishViewClicked;
- (void)ttv_playerControlerPreVideoDidPlay;
- (void)ttv_moreButtonOnMovieTopViewClicked;
- (void)ttv_shareButtonOnMovieTopViewClicked;
- (void)ttv_playerShareActionClickedWithActivityType:(NSString *)activityType;
- (void)ttv_playerReplayButtonClicked;
@end

@interface TTVideoDetailPlayControl : NSObject
@property (nonatomic, strong) TTVideoShareMovie *shareMovie;
@property (nonatomic, weak) id <TTVideoDetailPlayControlDelegate> delegate;
@property (nonatomic, assign) BOOL forbidLayout;
@property (nonatomic, assign) CGRect movieFrame;
@property (nonatomic, assign) BOOL isChangingMovieSize;
@property (nonatomic, assign) BOOL forbidFullScreenWhenPresentAd;
@property (nonatomic, weak) TTDetailModel *detailModel;
@property (nonatomic, weak) TTVideoMovieBanner *movieBanner;
@property (nonatomic, weak) UIViewController *viewController;
@property (nonatomic, assign) VideoDetailViewFromType fromType;
- (void)releatedVideoCliced;
- (void)viewDidLoad;
- (void)invalideMovieView;
- (void)viewWillAppear;
- (void)viewDidAppear;
- (void)viewWillDisappear;
- (void)viewDidDisappear;
- (BOOL)shouldLayoutSubviews;
- (void)layoutSubViews;
- (void)playButtonClicked;
- (float)watchPercent;
- (void)updateFrame;
- (BOOL)isMovieFullScreen;
- (void)showDetailButtonIfNeeded;
- (BOOL)isFirstPlayMovie;
- (void)pauseMovieIfNeeded;
- (void)playMovieIfNeededAndRebindToMovieShotView:(BOOL)rebindToMovieShotView;
- (void)playMovieIfNeeded;
- (void)setToolBarHidden:(BOOL)hidden;
- (void)addCommodity;
@end
