//
//  TTAdCanvasVC.m
//  Article
//
//  Created by yin on 2017/4/7.
//
//

#import "TTAdCanvasVC.h"

#import "SSAppStore.h"
#import "TTAdCanvasButtonCell.h"
#import "TTAdCanvasDefine.h"
#import "TTAdCanvasFullPicCell.h"
#import "TTAdCanvasImageCell.h"
//#import "TTAdCanvasLiveCell.h"
#import "TTAdCanvasLoopPicCell.h"
#import "TTAdCanvasManager.h"
#import "TTAdCanvasNavigationBar.h"
#import "TTAdCanvasTextCell.h"
#import "TTAdCanvasUtils.h"
#import "TTAdCanvasVideoCell.h"
#import "TTAlphaThemedButton.h"
#import "TTImageView.h"
#import "TTNavigationController.h"
#import "UIImage+MultiFormat.h"
#import "UIView+CustomTimingFunction.h"
#import <AVFoundation/AVFoundation.h>

@interface TTADCanvasItemHandler :NSObject

+ (NSString *)identifierForModel:(TTAdCanvasLayoutModel*)model;

@end

@implementation TTADCanvasItemHandler

+ (NSString *)identifierForModel:(TTAdCanvasLayoutModel*)model
{
    switch (model.itemType) {
        case TTAdCanvasItemType_Text:
            return NSStringFromClass([TTAdCanvasTextCell class]);
            break;
        case TTAdCanvasItemType_Image:
            return NSStringFromClass([TTAdCanvasImageCell class]);
            break;
        case TTAdCanvasItemType_LoopPic:
            return NSStringFromClass([TTAdCanvasLoopPicCell class]);
            break;
        case TTAdCanvasItemType_FullPic:
            return NSStringFromClass([TTAdCanvasFullPicCell class]);
            break;
        case TTAdCanvasItemType_Video:
            return NSStringFromClass([TTAdCanvasVideoCell class]);
            break;
//        case TTAdCanvasItemType_Live:
//            return NSStringFromClass([TTAdCanvasLiveCell class]);
//            break;
        case TTAdCanvasItemType_Button:
            return NSStringFromClass([TTAdCanvasButtonCell class]);
            break;
        default:
            break;
    }
    return NSStringFromClass([TTAdCanvasButtonCell class]);
}

@end


@interface TTAdCanvasVCDelegate : NSObject<UIScrollViewDelegate, TTAdCanvasBaseCellDelegate>

@property (nonatomic, strong) NSArray* dataArray;
@property (nonatomic, strong) NSArray* cellArray;
@property (nonatomic, assign) BOOL endPull;
@property (nonatomic, assign) TTAdCanvasScrollOrientation orientation;
@property (nonatomic, weak) TTAdCanvasFullPicCell* animateFullPicCell;
@property (nonatomic, weak) TTAdCanvasBaseCell* flagCell;
@property (nonatomic, assign) BOOL inAnimate;

- (instancetype)initWithCondition:(NSDictionary*)dict;

- (void)scrollViewItemStatusInEnter:(UIScrollView *)scrollView;

- (void)canvasCellPauseByEvent;

- (void)canvasCellResumeByEvent;

- (void)canvasCellBreakByEvent;

@end

@implementation TTAdCanvasVCDelegate

- (void)dealloc
{
    
}

- (instancetype)initWithCondition:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.dataArray = [dict valueForKey:@"dataArray"];
        self.cellArray = [dict valueForKey:@"cellArray"];
        [self setUpDelegates];
        self.endPull = NO;
        self.inAnimate = NO;
    }
    return self;
}

- (void)setUpDelegates
{
    [self.cellArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasBaseCell* canvasCell = obj;
        if (canvasCell && [canvasCell isKindOfClass:[TTAdCanvasBaseCell class]]) {
            canvasCell.delegate = self;
        }
    }];
}

#pragma mark --Video Play

- (void)canvasCellVideoPlay:(TTAdCanvasBaseCell *)cell
{
    [self.cellArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasBaseCell* canvasCell = obj;
        if (canvasCell && [canvasCell isKindOfClass:[TTAdCanvasBaseCell class]]) {
            if (canvasCell != cell) {
                [canvasCell cellMediaPlay:cell];
            }
        }
    }];
}

- (void)canvasCellLivePlay:(TTAdCanvasBaseCell *)cell
{
    [self.cellArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasBaseCell* canvasCell = obj;
        if (canvasCell && [canvasCell isKindOfClass:[TTAdCanvasBaseCell class]]) {
            if (canvasCell != cell) {
                [canvasCell cellMediaPlay:cell];
            }
        }
    }];
}

#pragma mark -- Item Interupt

- (void)canvasCellPauseByEvent
{
    [self.cellArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasBaseCell* canvasCell = obj;
        if (canvasCell && [canvasCell isKindOfClass:[TTAdCanvasBaseCell class]]) {
            [canvasCell cellPauseByEvent];
        }
    }];
}

- (void)canvasCellResumeByEvent
{
    [self.cellArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasBaseCell* canvasCell = obj;
        if (canvasCell && [canvasCell isKindOfClass:[TTAdCanvasBaseCell class]]) {
            [canvasCell cellResumeByEvent];
        }
    }];
}


- (void)canvasCellBreakByEvent
{
    [self.cellArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasBaseCell* canvasCell = obj;
        if (canvasCell && [canvasCell isKindOfClass:[TTAdCanvasBaseCell class]]) {
            [canvasCell cellBreakByEvent];
        }
    }];
}

#pragma mark -- Item life_cycle

static CGFloat last_offset = 0;

- (void)checkOrientation:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.y > last_offset) {
        self.orientation = TTAdCanvasScrollOrientation_Up;
    }
    else if (scrollView.contentOffset.y < last_offset)
    {
        self.orientation = TTAdCanvasScrollOrientation_Down;
    }
    
    [self scrollViewItemStatus:scrollView];
    
    last_offset = scrollView.contentOffset.y;
}


- (void)scrollViewItemStatus:(UIScrollView *)scrollView
{
    [self.cellArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasBaseCell* canvasCell = obj;
        if (canvasCell && [canvasCell isKindOfClass:[TTAdCanvasBaseCell class]]) {
            [canvasCell scrollView:scrollView lastOffset:last_offset itemInCritical:canvasCell orientation:self.orientation itemIndex:idx];
        }
    }];
}

- (void)scrollViewItemStatusInEnter:(UIScrollView *)scrollView
{
    [self.cellArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasBaseCell* canvasCell = obj;
        if (canvasCell && [canvasCell isKindOfClass:[TTAdCanvasBaseCell class]]) {
            [canvasCell scrollView:scrollView item:canvasCell itemIndex:idx];
        }
    }];
}

#pragma mark --吸顶效果

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    [self.cellArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasBaseCell* canvasCell = obj;
        if (canvasCell && [canvasCell isKindOfClass:[TTAdCanvasFullPicCell class]]) {
            //判断可吸顶条件:全景图停留地方位于 屏幕顶部以上一个cell之内 或者  底部一下一个cell之内
            if (((*targetContentOffset).y > canvasCell.top && (*targetContentOffset).y < canvasCell.bottom)||((*targetContentOffset).y + scrollView.height > canvasCell.top && (*targetContentOffset).y + scrollView.height < canvasCell.bottom)) {
                self.animateFullPicCell = (TTAdCanvasFullPicCell *)canvasCell;
                return ;
            }
        }
    }];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    self.endPull = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    self.endPull = YES;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self checkOrientation:scrollView];
    if (self.endPull == YES) {
        if (self.inAnimate == NO) {
            [self scrollViewAnimateToFullPic:scrollView];
        }
    }
}

- (void)scrollViewAnimateToFullPic:(UIScrollView *)scrollView
{
    if (self.animateFullPicCell)
    {
        if (scrollView.contentOffset.y <= self.animateFullPicCell.top+20 && scrollView.contentOffset.y >= self.animateFullPicCell.top-20) {
            scrollView.userInteractionEnabled = NO;
            self.inAnimate = YES;
            
            WeakSelf;
            [UIView animateWithDuration:0.25 customTimingFunction:CustomTimingFunctionDefault animation:^{
                StrongSelf;
                [scrollView setContentOffset: CGPointMake(self.animateFullPicCell.left, self.animateFullPicCell.top) animated:NO];
                
                [self.animateFullPicCell cellAnimateToTop];
                self.inAnimate = NO;
                self.animateFullPicCell = nil;
                scrollView.userInteractionEnabled = YES;
            }];
        }
    }
}

@end


@interface TTAdCanvasVC ()

@property (nonatomic, strong) TTAdCanvasNavigationBar* naviView;
@property (nonatomic, strong) NSDictionary* baseCondition;

@property (nonatomic, strong) UIView* screenShotView;

@property (nonatomic, strong) UIScrollView* scrollView;
@property (nonatomic, strong) TTAdCanvasVCDelegate* canvasDelegate;

@property (nonatomic, strong) NSMutableArray* cellArray;
@property (nonatomic, strong) TTAdCanvasJsonLayoutModel* jsonLayoutModel;

@property (nonatomic, assign) BOOL hasLayout;
@property (nonatomic, assign) BOOL customAnimation;
@property (nonatomic, assign) UIEdgeInsets safeEdgeInsets;

@end

@implementation TTAdCanvasVC

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    self = [super initWithRouteParamObj:paramObj];
    if (self) {
        self.hasLayout = NO;
        self.baseCondition = paramObj.allParams;
        [self buildup];
    }
    return self;
}

- (instancetype)initWithViewModel:(TTAdCanvasViewModel *)viewModl {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.viewModel = viewModl;
        [self buildup];
    }
    return self;
}

- (void)buildup {
    self.hidesBottomBarWhenPushed = YES;
    if (@available(iOS 11.0, *)) {
        self.safeEdgeInsets = [UIApplication sharedApplication].keyWindow.safeAreaInsets;
    } else {
        self.safeEdgeInsets = UIEdgeInsetsZero;
    }
}

- (void)dealloc
{
    [self.tracker wap_staypage];
    [self.tracker trackLeave];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setCommons];
    [self createCustormNavigationBar];
    if (self.customAnimation) {
        [self setShotScreen];
        [self showStartAnimation];
    } else {
        [self commitShowRNViewAnimation];
    }
    [self reloadState:self.viewModel];
    [self.tracker wap_load];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.canvasDelegate) {
        [self.canvasDelegate canvasCellResumeByEvent];
    }
    [self.tracker wap_loadfinish];
    [self.tracker native_page];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:NO
                                            withAnimation:UIStatusBarAnimationNone];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.canvasDelegate) {
        [self.canvasDelegate canvasCellPauseByEvent];
    }
    
    [self removeNotification];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryAmbient error:nil];
        [[AVAudioSession sharedInstance] setActive:NO error:nil];
    });
}

- (void)createCustormNavigationBar {
    self.ttHideNavigationBar = YES;
    
    self.naviView = [[TTAdCanvasNavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, kNavigationBarHeight)];
    [self.view addSubview:self.naviView];
    
    self.naviView.leftButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    self.naviView.leftButton.enableNightMask = NO;
    self.naviView.leftButton.imageName = @"photo_detail_titlebar_close";
    [self.naviView.leftButton addTarget:self action:@selector(closeButtonTouched:) forControlEvents:UIControlEventTouchUpInside];
    
    self.naviView.rightButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    self.naviView.rightButton.enableNightMask = NO;
    self.naviView.rightButton.imageName = @"new_morewhite_titlebar";
    self.naviView.rightButton.enableNightMask = NO;
    [self.naviView.rightButton addTarget:self action:@selector(shareTouched:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)createScrollView {
    [self.scrollView removeFromSuperview];
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:[self contentArea]];
    self.scrollView.showsVerticalScrollIndicator = NO;
    [self.view addSubview:self.scrollView];
    
    if (self.viewModel.rootViewColor != nil) {
        self.scrollView.backgroundColor = self.viewModel.rootViewColor;
    }
    
    self.cellArray = [NSMutableArray arrayWithCapacity:self.jsonLayoutModel.components.count];
    UIColor *color = self.viewModel.rootViewColor;
    
    [self.jsonLayoutModel.components enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasLayoutModel* model = (TTAdCanvasLayoutModel*)obj;
        if (model) {
            NSString* className  = [TTADCanvasItemHandler identifierForModel:model];
            TTAdCanvasBaseCell* cell = [[NSClassFromString(className) alloc] initWithWidth:self.view.width];
            if (cell && [cell isKindOfClass:[TTAdCanvasBaseCell class]]) {
                CGFloat cellHeight = ceilf([NSClassFromString(className) heightForModel:model inWidth:self.view.width]);
                cell.cellHeight = cellHeight;
                [cell refreshWithModel:model];
                [self.cellArray addObject:cell];
                [self.scrollView addSubview:cell];
                if (self.viewModel.rootViewColor != nil) {
                    cell.backgroundColor = color;
                    [cell setBackLabelColor:color];
                }
            }
        }
    }];
    
    self.scrollView.hidden = YES;
    NSMutableDictionary* condition = [NSMutableDictionary dictionary];
    [condition setValue:self.jsonLayoutModel.components forKey:@"dataArray"];
    
    [condition setValue:self.cellArray forKey:@"cellArray"];
    
    self.canvasDelegate =  [[TTAdCanvasVCDelegate alloc] initWithCondition:condition];
    
    self.scrollView.delegate = self.canvasDelegate;
}

- (void)reloadState:(TTAdCanvasViewModel *)viewModel {
    if (viewModel == nil) return;
    NSDictionary *layoutInfo = viewModel.layoutInfo;
    self.jsonLayoutModel = [[TTAdCanvasManager sharedManager] parseJsonLayout:layoutInfo];
    if (viewModel.createFeedData) {
        TTAdCanvasLayoutModel *component = [[TTAdCanvasLayoutModel alloc] initWithDictionary:viewModel.createFeedData[@"data"] error:nil];
        if (component && self.jsonLayoutModel.components != nil) {
            NSMutableArray *componets = [[NSMutableArray alloc] initWithArray:self.jsonLayoutModel.components];
            [componets insertObject:component atIndex:0];
            self.jsonLayoutModel.components = componets.copy;
        }
    }
    [self createScrollView];
    [self.view bringSubviewToFront:self.naviView];
    self.scrollView.hidden = NO;
}

- (void)setCommons {
    self.ttHideNavigationBar = YES;
    [self addNotification];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
}

- (void)setShotScreen
{
    UITabBarController *tabBarController = (UITabBarController *)[UIApplication sharedApplication].keyWindow.rootViewController;
    if (tabBarController&&[tabBarController isKindOfClass:[UITabBarController class]]) {
        self.screenShotView = [tabBarController.view snapshotViewAfterScreenUpdates:NO];
        [self.view  addSubview:self.screenShotView];
        [self.view sendSubviewToBack:self.screenShotView];
    }
}

#pragma mark -- 布局显示相关
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    UIEdgeInsets safeEdgeInsets = self.safeEdgeInsets;
    const CGFloat contentWidth = self.view.width - safeEdgeInsets.left - safeEdgeInsets.right;
    self.scrollView.frame = [self contentArea];
    __block CGFloat scrollHeight = 0;
    
    [self.cellArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTAdCanvasBaseCell* cell = (TTAdCanvasBaseCell*)obj;
        
        cell.frame = CGRectMake(0, scrollHeight, self.scrollView.width, cell.cellHeight);
        scrollHeight = scrollHeight + cell.cellHeight;
    }];
    self.scrollView.contentSize = CGSizeMake(contentWidth, scrollHeight);
    if (self.hasLayout == NO) {
        [self.canvasDelegate scrollViewItemStatusInEnter:self.scrollView];
        self.hasLayout = YES;
    }
    self.naviView.frame = CGRectMake(safeEdgeInsets.left, safeEdgeInsets.top, contentWidth, kNavigationBarHeight);
    [self.view bringSubviewToFront:self.naviView];
}

- (CGRect)contentArea {
    UIEdgeInsets safeEdgeInset = self.safeEdgeInsets;
    const CGFloat width = self.view.width - safeEdgeInset.left - safeEdgeInset.right;
    const CGFloat height = self.view.height - safeEdgeInset.top;
    const CGRect contentArea = CGRectMake(safeEdgeInset.left, safeEdgeInset.top, width, height);
    return contentArea;
}

#pragma mark -- ButtonTouch

- (void)shareTouched:(UIButton*)button
{
    [[TTAdCanvasManager sharedManager] canvasShare];
}

- (void)closeButtonTouched:(UIButton*)button
{
    [self.canvasDelegate canvasCellBreakByEvent];
    [self showEndAnimation];
}

#pragma mark -- Animation

- (void)showStartAnimation
{
    CGRect sourceFrame = self.viewModel.soureImageFrame;
    TTImageInfosModel* sourceImageModel = self.viewModel.sourceImageModel;

    TTImageInfosModel *toImageModel = self.viewModel.canvasImageModel;
    CGRect toFrame = CGRectZero;
    
    if (self.viewModel.animationStyle == TTAdCanvasOpenAnimationScale) {
        toFrame = [self contentArea];
        [self startAnimationScale:sourceFrame sourceImageModel:sourceImageModel toFrame:toFrame toImageModel:toImageModel];
    } else {
        if (toImageModel.width > FLT_EPSILON) {
             CGFloat height = ceilf(toImageModel.height * (self.view.width/toImageModel.width));
             toFrame = CGRectMake(self.safeEdgeInsets.left, self.safeEdgeInsets.top, ceilf(self.view.width), ceilf(height));
        }
        [self startAnimationMoveUp:sourceFrame sourceImageModel:sourceImageModel toFrame:toFrame toImageModel:toImageModel];
    }
}

- (void)startAnimationMoveUp:(CGRect)sourceFrame sourceImageModel:(TTImageInfosModel*)souceImageModel toFrame:(CGRect)toFrame toImageModel:(TTImageInfosModel*)toImageInfoModel
{
    __block TTImageView* toImageView = [[TTImageView alloc] initWithFrame:sourceFrame];
    toImageView.tag = toImageViewTag;
    toImageView.imageContentMode = TTImageViewContentModeScaleAspectFit;
    [toImageView setImageWithModel:toImageInfoModel];
    [self.view addSubview:toImageView];
    
    __block TTImageView* sourceImageView = [[TTImageView alloc] initWithFrame:sourceFrame];
    sourceImageView.tag = sourceImageViewTag;
    sourceImageView.imageContentMode = TTImageViewContentModeScaleAspectFit;
    [sourceImageView setImageWithModel:souceImageModel];
    [self.view addSubview:sourceImageView];
    [self.view bringSubviewToFront:self.naviView];
    
    WeakSelf;
    [UIView animateWithDuration:startAnimationDuration customTimingFunction:CustomTimingFunctionExpoOut animation:^{
        StrongSelf;
        sourceImageView.frame = toFrame;
        sourceImageView.alpha = 0;
        toImageView.frame = toFrame;
        toImageView.alpha = 1;
        self.screenShotView.alpha = 0;
    } completion:^(BOOL finished) {
        StrongSelf;
        [self commitShowRNViewAnimation];
    }];
}

- (void)startAnimationScale:(CGRect)sourceFrame sourceImageModel:(TTImageInfosModel*)souceImageModel toFrame:(CGRect)toFrame toImageModel:(TTImageInfosModel *)toImageInfoModel
{
    __block TTImageView* toImageView = [[TTImageView alloc] initWithFrame:sourceFrame];
    toImageView.tag = toImageViewTag;
    toImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
    [toImageView setImageWithModel:toImageInfoModel];
    [self.view addSubview:toImageView];
    
    __block TTImageView* sourceImageView = [[TTImageView alloc] initWithFrame:sourceFrame];
    sourceImageView.tag = sourceImageViewTag;
    sourceImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
    [self.view addSubview:sourceImageView];
    [sourceImageView setImageWithModel:souceImageModel];
    
    [self.view bringSubviewToFront:self.naviView];
    
    WeakSelf;
    [UIView animateWithDuration:startAnimationDuration customTimingFunction:CustomTimingFunctionExpoOut animation:^{
        StrongSelf;
        sourceImageView.frame = toFrame;
        sourceImageView.alpha = 0;
        toImageView.frame = toFrame;
        toImageView.alpha = 1;
        self.screenShotView.alpha = 0;
    } completion:^(BOOL finished) {
        StrongSelf;
        [self commitShowRNViewAnimation];
    }];
}

- (void)commitShowRNViewAnimation
{
    UIView* sourceImageView = [self.view viewWithTag:sourceImageViewTag];
    UIView* toImageView = [self.view viewWithTag:toImageViewTag];
    if (self.scrollView) {
        self.scrollView.hidden = NO;
        self.scrollView.alpha = 0;
        self.scrollView.frame = [self contentArea];
        WeakSelf;
        [UIView animateWithDuration:startAnimationDuration customTimingFunction:CustomTimingFunctionExpoOut animation:^{
            StrongSelf;
            self.scrollView.alpha = 1;
            self.scrollView.frame = [self contentArea];
        } completion:^(BOOL finished) {
            [sourceImageView removeFromSuperview];
            [toImageView removeFromSuperview];
        }];
    }
}

//一定要关闭视图
- (void)showEndAnimation {
    if ([self.delegate respondsToSelector:@selector(canvasVCShowEndAnimation:sourceImageModel:toFrame:toImageModel:complete:)]) {
        CGRect toFrame = self.viewModel.soureImageFrame;
        TTImageInfosModel *toImageModel = self.viewModel.sourceImageModel;
        
        CGRect sourceFrame = CGRectZero;
        if (self.viewModel.canvasImageModel != nil) {
            sourceFrame = CGRectMake(self.safeEdgeInsets.left, self.safeEdgeInsets.top, self.view.width, self.view.height);
        }
        [self.delegate canvasVCShowEndAnimation:sourceFrame sourceImageModel:self.viewModel.canvasImageModel toFrame:toFrame toImageModel:toImageModel complete:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

#pragma mark -- Track

#pragma mark -- Notification

- (void)addNotification
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidAppear:) name:SKStoreProductViewDidAppearKey object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(skStoreViewDidDisappear:) name:SKStoreProductViewDidDisappearKey object:nil];
}

- (void)removeNotification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)didEnterBackground:(NSNotification*)noti
{
    if (self.canvasDelegate) {
        [self.canvasDelegate canvasCellPauseByEvent];
    }
}

- (void)didBecomeActive:(NSNotification*)noti
{
    if (self.canvasDelegate) {
        [self.canvasDelegate canvasCellResumeByEvent];
    }
}

- (void)skStoreViewDidAppear:(NSNotification*)noti
{
    if (self.canvasDelegate) {
        [self.canvasDelegate canvasCellPauseByEvent];
    }
}

- (void)skStoreViewDidDisappear:(NSNotification*)noti
{
    if (self.canvasDelegate) {
        [self.canvasDelegate canvasCellResumeByEvent];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
