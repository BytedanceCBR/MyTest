//
//  TTVideoDetailViewController.h
//  Article
//
//  Created by 刘廷勇 on 16/3/31.
//
//

#import "SSViewControllerBase.h"
#import "TTDetailViewController.h"
#import "TTDetailModel.h"
#import "TTVideoShareMovie.h"

@class Article;
@class ExploreMovieView;
@class ExploreOrderedData;
@class TTAlphaThemedButton;
@class TTDetailNatantVideoADView;
@class ArticleVideoPosterView;
@class TTCommentViewController;
@class TTVideoDetailInteractModel;
@class TTVideoAlbumView;
@class ArticleInfoManager;
@class TTVideoDetailFloatCommentViewController;
@class TTVideoMovieBanner;
@class TTDetailNatantVideoPGCView;
@class TTDetailNatantVideoBanner;
@class TTVideoDetailPlayControl;

extern NSString * _Nonnull const TTVideoDetailViewControllerDeleteVideoArticle;


/*
 *  视频详情页来源
 */
typedef NS_ENUM(NSInteger, VideoDetailViewFromType)
{
    VideoDetailViewFromTypeCategory,    //列表页
    VideoDetailViewFromTypeRelated,     //详情页相关视频
    VideoDetailViewFromTypeSplash,      //开屏 广告
    VideoDetailViewFromTypeUnKnow
};

/*
 *  视频详情页展示状态
 */
typedef NS_ENUM(NSInteger, VideoDetailViewShowStatus)
{
    VideoDetailViewShowStatusVideo,     //显示视频区
    VideoDetailViewShowStatusComment    //显示评论区
};
@interface TTVideoDetailViewController : SSViewControllerBase <TTDetailViewController>
@property (nonatomic, strong, nullable ,readonly) UIView *movieView;//视频播放器
@property (nonatomic, strong ,readonly) TTVideoDetailPlayControl * _Nullable playControl;
@property (nonatomic, strong, nullable) ArticleInfoManager *infoManager;
@property (nonatomic, strong, nonnull ) TTDetailModel    *detailModel;
@property (nonatomic, strong, nullable) TTVideoShareMovie *shareMovie;
@property (nonatomic, assign) BOOL clickedBackBtn;
@property (nonatomic, assign) BOOL shouldPlayWhenBack;
@property (nonatomic, assign) BOOL isDownloadAppInIOS78;//78 下载app会调用当前viewController的viewDidDisappear
- (nullable ExploreOrderedData *)orderedData;

- (nullable Article *)article;

- (nullable NSString *)videoID;

#pragma for TTVideoDetailViewController+ExtendLink
@property (nonatomic, strong ,nullable) UIViewController *presentController;
@property (nonatomic, strong ,nullable) TTAlphaThemedButton *backButton;
@property (nonatomic, strong ,nullable) UIView *movieViewSuperView;
@property (nonatomic, assign) CGRect movieViewOriginFrame;
@property (nonatomic, strong ,nullable ,readonly) TTDetailNatantVideoADView *embededAD;

#pragma for
@property (nonatomic, strong, nullable) TTVideoDetailInteractModel *interactModel;
@property (nonatomic, strong, nullable, readonly) UIView                    *moviewViewContainer;
@property (nonatomic, strong, nullable, readwrite) TTDetailNatantVideoPGCView *topPGCView;
@property (nonatomic, strong, nullable, readonly) TTCommentViewController   *commentVC;
@property (nonatomic, assign, readonly) VideoDetailViewShowStatus           showStatus;
@property (nonatomic, strong, nullable, readonly) TTVideoAlbumView          *videoAlbum;
@property (nonatomic, strong, nullable, readonly) TTVideoMovieBanner        *movieBanner;
@property (nonatomic, assign, readonly) VideoDetailViewFromType             fromType;
//弹出的评论页详情页
@property (nonatomic, strong, nullable) TTVideoDetailFloatCommentViewController *floatCommentVC;
@property (nonatomic, assign) BOOL isChangingMovieSize;
- (void)backAction;
- (void)pauseMovieIfNeeded;
- (void)playMovieIfNeeded;
- ( ArticleVideoPosterView * _Nullable )movieShotView;

@end

