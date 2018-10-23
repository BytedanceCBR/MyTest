//
//  TTAdFullScreenVideoViewController.m
//  Article
//
//  Created by matrixzk on 21/07/2017.
//
//

#import "TTAdFullScreenVideoViewController.h"

#import "TTRoute.h"
#import "TTImagePreviewAnimateManager.h"
#import "UIViewController+NavigationBarStyle.h"
#import "UIViewController+TabBarSnapShot.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Article.h"
#import "TTAdFullScreenVideoPlayerView.h"
#import "UIImageView+WebCache.h"
#import "TTAdFullScreenVideoViewModel.h"
#import <BDWebImage/SDWebImageAdapter.h>
#import "TTArticlePicView.h"

@interface TTAdFullScreenVideoViewController () <TTRouteInitializeProtocol, TTPreviewPanBackDelegate>

@property (nonatomic, strong) TTImagePreviewAnimateManager *previewAnimateManager;
@property (nonatomic, strong) SSThemedView *blackMaskView;
@property (nonatomic, strong) UIView *popToView;
@property (nonatomic, strong) UIView *bottomTabbarView;
@property (nonatomic, assign) CGRect picViewFrame;
@property (nonatomic, assign) TTArticlePicViewStyle picViewStyle;
@property (nonatomic, weak)   UIView *targetView;
@property (nonatomic, strong) UIImageView *backCoverImageView;

@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) UIView *topNavigationView;
@property (nonatomic, strong) TTAdFullScreenVideoPlayerView *videoPlayerView;
@property (nonatomic, strong) UIView *bottomView;
@property (nonatomic, strong) TTAdFullScreenVideoViewModel *viewModel;

@property (nonatomic, assign) BOOL viewHadAppeared;

@end


@implementation TTAdFullScreenVideoViewController

//- (void)dealloc
//{
//    NSLog(@">>>>> Deallco: TTAdFullScreenVideoViewController.");
//}

- (instancetype)initWithRouteParamObj:(nullable TTRouteParamObj *)paramObj
{
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        
        _orderedData = [paramObj.allParams tt_objectForKey:@"ordered_data"];
        _picViewFrame = CGRectFromString([paramObj.allParams tt_stringValueForKey:@"picViewFrame"]);
        _targetView   = [paramObj.allParams valueForKey:@"targetView"];
        
        self.ttHideNavigationBar = YES;
        
        _viewModel = [[TTAdFullScreenVideoViewModel alloc] initWithParamObj:paramObj hostVC:self];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.modeChangeActionType = ModeChangeActionTypeNone;
    
    self.previewAnimateManager = [TTImagePreviewAnimateManager new];
    self.previewAnimateManager.panDelegate = self;
    [self.previewAnimateManager registeredPanBackWithGestureView:self.view];
    
    self.videoPlayerView = [[TTAdFullScreenVideoPlayerView alloc] initWithFrame:self.view.bounds];
    self.videoPlayerView.eventTracker = self.viewModel;
    self.videoPlayerView.shouldRepeat = YES;
    TTAdFullScreenVideoModel *videoModel = [TTAdFullScreenVideoModel new];
    videoModel.videoId = [self.orderedData.article.videoDetailInfo tt_stringValueForKey:@"video_id"];
    videoModel.coverURL = [[self.orderedData.raw_ad_data tt_dictionaryValueForKey:@"detail_video_large_image"] tt_stringValueForKey:@"url"];
    if (isEmptyString(videoModel.coverURL)) {
        videoModel.coverURL = [[self.orderedData.article.videoDetailInfo tt_dictionaryValueForKey:@"detail_video_large_image"] tt_stringValueForKey:@"url"];
    }
    [self.videoPlayerView playVideoWithModel:videoModel];
    [self.view addSubview:self.videoPlayerView];
    
    
    // Top view
    WeakSelf;
    UIView *topView = [self.viewModel buildTopViewWithBackButtonPressedBlock:^{
        StrongSelf;
        //[self.videoPlayerView stopVideo];
        if (CGRectEqualToRect(self.picViewFrame, CGRectZero)) {
            [self.navigationController popViewControllerAnimated:YES];
        } else {
            [self.previewAnimateManager dismissWithoutGesture];
        }
    }];
    [self.view addSubview:topView];
    self.topNavigationView = topView;
    
    
    // Bottom view
    UIView *bottomView = [self.viewModel buildBottomView];
    [self.view addSubview:bottomView];
    self.bottomView = bottomView;
    
    // Show
    self.view.alpha = 0;
    [UIView animateWithDuration:0.3 animations:^{
        self.view.alpha = 1;
    }];
    
    [self.viewModel eventTrackWithLabel:@"detail_show"];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    UIEdgeInsets safeEdgeInsets = UIEdgeInsetsZero;
    if (@available(iOS 11.0, *)) {
        safeEdgeInsets = self.view.safeAreaInsets;
    }
    CGFloat width = self.view.width - safeEdgeInsets.left - safeEdgeInsets.right;
    self.topNavigationView.frame = CGRectMake(safeEdgeInsets.left, safeEdgeInsets.top, width, CGRectGetHeight(self.topNavigationView.bounds));
    self.videoPlayerView.frame = CGRectMake(safeEdgeInsets.left, safeEdgeInsets.top, width, self.view.height - safeEdgeInsets.top);
    
    CGFloat bottomViewContentHeight = [self.viewModel heightOfBottomViewWith:width];
    CGFloat bottomViewY = self.view.height - bottomViewContentHeight - safeEdgeInsets.bottom;
    self.bottomView.frame = CGRectMake(safeEdgeInsets.left, bottomViewY, width, bottomViewContentHeight + safeEdgeInsets.bottom);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
    
    if (self.viewHadAppeared) {
        [self.videoPlayerView playVideo];
        [self.videoPlayerView videoPlayDidResume];
    } else {
        self.viewHadAppeared = YES;
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];
    
    [self.videoPlayerView pauseVideo];
    [self.videoPlayerView videoPlayDidInterrupted];
}


#pragma mark - Back transition

- (void)addPreviousVCToNaviView
{
    NSArray *VCs = [[self.navigationController.viewControllers reverseObjectEnumerator] allObjects];
    if (VCs.count > 1){
        UIViewController *VC = [VCs objectAtIndex:1];
        _popToView = VC.view;
        _popToView.frame = self.navigationController.view.bounds;
        [self.navigationController.view addSubview:_popToView];
        if ([VCs count] == 2) {
            _bottomTabbarView = [UIViewController tabBarSnapShotView];
        }
        [self.navigationController.view addSubview:_bottomTabbarView];
        [self.navigationController.view addSubview:_blackMaskView];
    }
}

- (void)removePreviousVCFromNaviView
{
    [_popToView removeFromSuperview];
    [_blackMaskView removeFromSuperview];
    [_bottomTabbarView removeFromSuperview];
}

- (SSThemedView *)blackMaskView
{
    if (!_blackMaskView) {
        _blackMaskView = [[SSThemedView alloc] initWithFrame:self.view.frame];
        _blackMaskView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _blackMaskView.backgroundColor = [UIColor colorWithHexString:@"#000000"];
    }
    return _blackMaskView;
}


#pragma mark - TTPreviewPanBackDelegate

- (void)ttPreviewPanBackStateChange:(TTPreviewAnimateState)currentState scale:(float)scale
{
    switch (currentState) {
        case TTPreviewAnimateStateWillBegin:
        {
            [[UIApplication sharedApplication] setStatusBarHidden:NO
                                                    withAnimation:UIStatusBarAnimationNone];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            self.backCoverImageView = [UIImageView new];
            [self.backCoverImageView sda_setImageWithURL:[NSURL URLWithString:[_orderedData.article.largeImageDict tt_stringValueForKey:@"url"]]];
            [self removePreviousVCFromNaviView];
            [self addPreviousVCToNaviView];
            [self.videoPlayerView pauseVideo];
        } break;
            
        case TTPreviewAnimateStateChange:
        {
            self.blackMaskView.alpha = MAX(0, (scale * 14 - 13 - self.previewAnimateManager.minScale) / (1 - self.previewAnimateManager.minScale));
        } break;
            
        case TTPreviewAnimateStateDidFinish:
        {
            [self removePreviousVCFromNaviView];
            // [self.videoPlayerView stopVideo];
            [self.navigationController popViewControllerAnimated:NO];
        } break;
            
        case TTPreviewAnimateStateDidCancel:
        {
            [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                    withAnimation:UIStatusBarAnimationNone];
            [self removePreviousVCFromNaviView];
            [self.videoPlayerView playVideo];
        } break;
            
        default:
            break;
    }
}

- (UIView *)ttPreviewPanBackGetOriginView
{
    return self.videoPlayerView;
}

- (BOOL)ttPreviewPanGestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer;
{
    return !CGRectEqualToRect(self.picViewFrame, CGRectZero);
}

- (void)ttPreviewPanBackFinishAnimationCompletion
{
    self.blackMaskView.alpha = 0;
}

- (void)ttPreviewPanBackCancelAnimationCompletion
{
    self.blackMaskView.alpha = 1;
}

- (UIView *)ttPreviewPanBackGetBackMaskView
{
    return self.targetView;
}

- (CGRect)ttPreviewPanBackTargetViewFrame
{
    return self.picViewFrame;
}

- (UIImage *)ttPreviewPanBackImageForSwitch
{
    return self.backCoverImageView.image;
}


@end
