//
//  TTVVideoDetailHeaderPosterViewController.h
//  Article
//
//  Created by pei yun on 2017/5/8.
//
//

#import <TTUIWidget/SSViewControllerBase.h>
#import "TTVVideoInformationSyncProtocol.h"
#import "TTVVideoDetailVCDefine.h"
#import "ArticleDetailHeader.h"
#import "TTDetailModel.h"
#import "TTVPlayVideo.h"
#import "TTVDetailPlayControl.h"

@interface TTVVideoDetailInteractModel : NSObject

@property (nonatomic, assign) CGFloat minMovieH;
@property (nonatomic, assign) CGFloat maxMovieH;
@property (nonatomic, assign) CGFloat curMovieH;
@property (nonatomic, assign) BOOL isDraggingMovieContainerView;
@property (nonatomic, assign) BOOL isDraggingCommentTableView;
@property (nonatomic, assign) CGFloat lastY;
@property (nonatomic, assign) CGFloat cLastY;
@property (nonatomic, assign) BOOL shouldSendCommentTrackLater;

@end

@class TTVideoShareMovie;
@class TTVideoDetailHeaderPosterView;
@class TTVContainerScrollView;
@class TTVVideoDetailInteractModel;
@class TTVideoDetailFloatCommentViewController;
@interface TTVVideoDetailHeaderPosterViewController : SSViewControllerBase <TTVVideoInformationSyncProtocol ,TTVDetailContext>

@property (nonatomic, strong) id<TTVArticleProtocol> videoInfo;
@property (nonatomic, strong) TTVWhiteBoard *whiteboard;
@property (nonatomic, assign) BOOL reloadVideoInfoFinished;
@property (nonatomic, strong) TTDetailModel *detailModel;
@property (nonatomic, assign) TTVVideoDetailViewFromType             fromType;
@property (nonatomic, strong) TTVContainerScrollView *ttvContainerScrollView;
@property (nonatomic, weak) id<TTVVideoDetailToolbarActionProtocol> toolbarActionDelegate;
@property (nonatomic, weak) id<TTVVideoDetailHomeToHeaderActionProtocol> homeActionDelegate;
@property (nonatomic, weak) id<TTVPlayerDoubleTap666Delegate> doubleTap666Delegate;

@property (nonatomic, strong, readonly) TTVideoDetailHeaderPosterView              *movieShotView;
@property (nonatomic, strong, readonly) TTVVideoDetailInteractModel *interactModel;
@property (nonatomic, strong, readonly) TTVideoShareMovie *shareMovie;
@property (nonatomic, strong) TTVDetailPlayControl *playControl;
@property (nonatomic, strong) TTVDetailStateStore *detailStateStore;

- (TTVPlayVideo *)movieView;
- (void)layoutMovieShotView;
- (CGRect)frameForMovieView;

- (void)playMovieIfNeeded;
- (void)pauseMovieIfNeeded;
- (void)_invalideMovieViewWithFinishedBlock:(TTVStopFinished)finishedBlock;

- (void)vdvi_commentTableViewDidScroll:(UIScrollView *)scrollView;
- (void)vdvi_commentTableViewDidEndDragging:(UIScrollView *)scrollView;
- (void)vdvi_trackWithLabel:(NSString *)label source:(NSString *)source groupId:(NSString *)groupId;
- (void)vdvi_changeMovieSizeWithStatus:(TTVVideoDetailViewShowStatus)status;

@end
