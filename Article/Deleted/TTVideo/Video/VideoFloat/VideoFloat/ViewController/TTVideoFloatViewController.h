
#import "SSViewControllerBase.h"
#import "ExploreMovieView.h"
#import "TTDetailModel.h"
#import "TTDetailViewController.h"
#import "ArticleVideoPosterView.h"
#import "TTActivityShareManager.h"
#import "TTVideoFloatCell.h"
#import "TTVideoFloatProtocol.h"
#import "TTVideoDetailStayPageTracker.h"
#import "TTActionSheetController.h"
#import "TTVideoShareMovie.h"
#import "TTSharedViewTransition.h"

@protocol TTHittestTableViewDelegate <NSObject>

- (void)tt_hitTest:(CGPoint)point withEvent:(UIEvent * _Nullable)event;

@end
@interface TTHittestTableView : SSThemedTableView
@property (nonatomic, weak ,nullable) NSObject<TTHittestTableViewDelegate> *hit_delegate;
@end

#define kImmerseTime 3

@interface TTVideoFloatViewController : SSViewControllerBase<TTDetailViewController,TTSharedViewTransitionTo>
@property (nonatomic, strong, nullable ) TTDetailModel    *detailModel;
@property (nonatomic, strong, nullable ) TTVideoShareMovie *shareMovie;

//for category
@property (nonatomic, strong, nullable,readonly) TTActivityShareManager *activityActionManager;
@property (nonatomic, assign) BOOL canImmerse;
@property (nonatomic, assign) TTVideoFloatCellAction action;
@property (nonatomic, strong, nullable) NSTimer *immerseTimer;
@property (nonatomic, strong, nullable) Article *shareArticle;
@property (nonatomic, strong, nullable ,readonly) TTVideoFloatCell *toPlayCell;
@property (nonatomic, strong, nullable,readonly) TTVideoDetailStayPageTracker *tracker;
@property (nonatomic, strong, nullable,readonly) TTVideoDetailStayPageTracker *trackerPlayed;//正在播放的视频停留时间

//gesture
@property(nonatomic, strong,nullable) UIPanGestureRecognizer *panGestureRecognizer;
@property (nonatomic, assign) CGPoint firstVelocity;
@property(nonatomic ,assign) CGPoint initialTouchPosition;
@property(nonatomic ,assign) CGPoint preTouchPosition;
@property(nonatomic ,assign) CGRect selfViewOriginFrame;
@property(nonatomic ,strong,nullable,readonly) SSThemedView *containerView;
//详情页dislike及report字典
@property (nonatomic, strong, nullable) TTActionSheetController *actionSheetController;
@property (nonatomic, assign) BOOL playNextInterrupt;

+ (nullable NSMutableDictionary *)baseExtraWithArticle:( Article * _Nonnull )article;
- (void)tt_playButtonClicked;

//for impression
@property (nonatomic, assign) BOOL isViewAppear;
@property (nonatomic, assign) BOOL isFirstAppearAndShowing;
@property (nonatomic, strong ,nullable) NSIndexPath *currentIndexPath;
@property(nonatomic, strong,nonnull,readonly) TTHittestTableView *tableView;

- (void)immerseHalf;
- ( ExploreMovieView * _Nullable )movieView;
- ( ArticleVideoPosterView * _Nullable )movieShotView;
@end
