//
//  TTImagePreviewViewController.m
//  Article
//
//  Created by SongChai on 2017/4/9.
//
//

#import "TTImagePreviewViewController.h"
#import "TTImagePreviewTopBar.h"
#import "TTImagePreviewPhotoCell.h"
#import "TTImagePreviewVideoCell.h"
#import "TTImagePreviewVideoManager.h"
#import "TTIndicatorView.h"
#import "TTImagePreviewBottomView.h"
#import "TTImagePickerTrackManager.h"
#import "TTImagePickerDefineHead.h"
#import "TTImagePickerManager.h"
#import "UIViewAdditions.h"
#import "TTBaseMacro.h"
#import "TTImagePickerAlert.h"

typedef NS_ENUM(NSInteger, TTImagePreviewMoveDirection) {
    TTImagePreviewMoveDirectionNone, //未知
    TTImagePreviewMoveDirectionVerticalTop, //向上
    TTImagePreviewMoveDirectionVerticalBottom //向下
};




@interface TTImagePreviewViewController ()<UICollectionViewDataSource,UICollectionViewDelegate,UIScrollViewDelegate,TTImagePreviewTopBarDelegate, UIGestureRecognizerDelegate> {
    NSUInteger _currentIndex;
    NSMutableArray<TTAssetModel*> *_selectModels;
    NSArray<TTAssetModel*>* _allModels;
    
    BOOL _hideNavBarAndBottomBar;
    
    //以下为present默认值
    BOOL _statusBarHidden;
    BOOL _naviBarHidden;
    
    UIPanGestureRecognizer* _panGesture;
    BOOL _onPaning;
    CGPoint _initGesturePoint;
    CGRect _initFrame;
    UIView* _imgView;
}

@property (nonatomic, strong) UICollectionView* collectionView;
@property (nonatomic, strong) TTImagePreviewBottomView * bottomView;
@property (nonatomic, strong) TTImagePreviewTopBar* topView;

//下面是准备的拖动手势动画
@property (nonatomic, strong) UIPanGestureRecognizer * panGestureRecognizer;
//手势识别方向
@property (nonatomic, assign) TTImagePreviewMoveDirection direction;
//进入的设备方向，如果与点击退出不同，则使用渐隐动画
@property (nonatomic, assign) UIInterfaceOrientation enterOrientation;

@property(nonatomic, strong) TTImagePreviewVideoManager* videoManager;

@property(nonatomic, assign) TTImagePreviewType previewType;

@property(nonatomic, assign)  BOOL firstDisplay;

@end

@implementation TTImagePreviewViewController
@synthesize currentIndex = _currentIndex;
@synthesize selectModels = _selectModels;
@synthesize allModels = _allModels;
@synthesize animatedImageView = _imgView;

- (void)dealloc{
    if (_videoManager) {
        [_videoManager destory];
    }
}

- (void)loadView
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.view = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
}

- (instancetype)initWithModes:(NSArray<TTAssetModel *> *)models delegate:(id<TTImagePreviewViewControllerDelegate>) delegate {
    if (self = [super init]) {
        _allModels = models;
        _delegate = delegate;
        _maxLimit = MIN(models.count, 9);
        self.statusBarAutoHidden = YES;
        self.hidesBottomBarWhenPushed = YES;
        self.firstDisplay = YES;
    }
    return self;
}

+ (instancetype)deletePreviewViewControllerWithModes:(NSArray<TTAssetModel *> *)models index:(NSInteger)index delegate:(id<TTImagePreviewViewControllerDelegate>)delegate {
    TTImagePreviewViewController* viewController = [[TTImagePreviewViewController alloc] initWithModes:models delegate:delegate];
    if (viewController) {
        viewController->_currentIndex = index;
        viewController.previewType = TTImagePreviewTypeDelete;
        [viewController setSelectModels:models];
    }
    return viewController;
}

+ (instancetype)selectPreviewViewControllerWithModes:(NSArray<TTAssetModel *> *)models selects:(NSMutableArray<TTAssetModel *> *)selectModels index:(NSInteger)index delegate:(id<TTImagePreviewViewControllerDelegate>)delegate {
    
    TTImagePreviewViewController* viewController = [[TTImagePreviewViewController alloc] initWithModes:[models copy] delegate:delegate];
    if (viewController) {
        viewController->_currentIndex = index;
        [viewController setSelectModels:selectModels];
    }
    return viewController;
}

+ (instancetype)selectPreviewViewControllerWithVideo:(TTAssetModel *)model
                                             delegate:(id<TTImagePreviewViewControllerDelegate>) delegate;
{
    if (!model) {
        return nil;
    }
    TTImagePreviewViewController* viewController = [[TTImagePreviewViewController alloc] initWithModes:@[model] delegate:delegate];
    viewController->_currentIndex = 0;
    
    viewController.previewType = TTImagePreviewTypeVideo;
    viewController.selectModels = [NSMutableArray arrayWithObject:model];
    return viewController;
}

- (void)setSelectModels:(NSArray<TTAssetModel *> *)selectModels {
    if (selectModels == nil || ![selectModels isKindOfClass:[NSArray class]]) {
        _selectModels = [NSMutableArray new];
    } else if (![selectModels isKindOfClass:[NSMutableArray class]]) {
        _selectModels = [NSMutableArray arrayWithArray:selectModels];
    } else {
        _selectModels = (NSMutableArray*) selectModels;
    }
}
- (void)setLoadingView:(TTImagePickerLoadingView *)loadingView
{
    if (_loadingView != loadingView) {
        [_loadingView removeViews];
        _loadingView = loadingView;
        if (_loadingView) {
            [self.view addSubview:_loadingView];
        }
    }
}

- (TTImagePreviewTopBar *)topView {
    if (_topView == nil) {
        _topView = [[TTImagePreviewTopBar alloc] initWithFrame:CGRectMake(0, 0, self.view.width, 99) withType:self.previewType];
        if ([TTDeviceHelper isIPhoneXDevice]) {
            _topView.height = 99 + TTSafeAreaInsetsTop;
        }
        _topView.selectedCount = (int)_selectModels.count;
        _topView.delegate = self;
    }
    return _topView;
}

//只有默认情况有bottomView
- (UIView *)bottomView {
    if (_bottomView == nil && self.previewType == TTImagePreviewTypeDefalut) {
        _bottomView = [[TTImagePreviewBottomView alloc] initWithFrame:CGRectMake(0, self.view.height - 99, self.view.width, 99)];
        if ([TTDeviceHelper isIPhoneXDevice]) {
            _bottomView.frame = CGRectMake(0, self.view.height - 99 - TTSafeAreaInsetsBottom, self.view.width, 99 +TTSafeAreaInsetsBottom);
        }
        WeakSelf;
        _bottomView.selectAction = ^{
            [wself selectAction];
        };
    }
    return _bottomView;
}


- (TTImagePreviewVideoManager *)videoManager {
    if (_videoManager == nil) {
        _videoManager = [[TTImagePreviewVideoManager alloc] init];
        _videoManager.videoPlayer.myVC = self;
    }
    return _videoManager;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.canComplete = YES;
    
    [self configCollectionView];
    
    [self.view addSubview:self.topView];
    if (self.bottomView) {
        [self.view addSubview:self.bottomView];
    }
    self.view.clipsToBounds = YES;
    self.view.backgroundColor = [UIColor blackColor];
    
    // 修复iOS7下，photoScrollView 子视图初始化位置不正确的问题
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]){
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureAction:)];
    [self.view addGestureRecognizer:_panGesture];
    
    if (_currentIndex) {
        [_collectionView setContentOffset:CGPointMake((self.view.width + 20) * _currentIndex, 0) animated:NO];
    }
}

- (void)panGestureAction:(UIPanGestureRecognizer*)panGestureRecognizer {
    if (panGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self preparePanAnimated:panGestureRecognizer];
    } else if (panGestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if (_onPaning && _imgView) {
            [self changePanAnimated:panGestureRecognizer];
        }
    } else if(panGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        if (_onPaning && _imgView) {
            CGFloat curScale = _imgView.width/_initFrame.size.width;
            if (curScale > 0.9){
                [self resetPanAnimated];
            }
            else {
                [self dismissMySelf:YES];
            }
        }
    } else {
        [self resetPanAnimated];
    }
}

- (void) preparePanAnimated:(UIPanGestureRecognizer*) panGestureRecognizer {
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
    if ([cell isKindOfClass:[TTImagePreviewPhotoCell class]]) {
        TTImagePreviewPhotoView* photoView = ((TTImagePreviewPhotoCell*) cell).previewView;
        if (photoView.scrollView.zoomScale == 1) {
            _imgView = photoView.imageContainerView;
            
            if (!photoView.imageView || !photoView.imageView.image) {
                return;
            }
            float height = photoView.imageView.image.size.height/photoView.imageView.image.size.width  *KScreenWidth;
            if (height > KScreenHeight + 2) {
                return;
            }
            
            _initGesturePoint = [panGestureRecognizer locationInView:_imgView];
            if (CGRectContainsPoint(_imgView.bounds, _initGesturePoint)) {
                [_imgView removeFromSuperview];
                [self.view addSubview:_imgView];
                _imgView.center = CGPointMake(self.view.width/2, self.view.height/2);
                self.collectionView.hidden = YES;
                self.bottomView.hidden = YES;
                self.topView.hidden = YES;
                
                _onPaning = YES;
                _initFrame = _imgView.frame;
                
                
                [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                                        withAnimation:NO];
            } else {
                _imgView = nil;
                _onPaning = NO;
            }
        }
    } else if ([cell isKindOfClass:[TTImagePreviewVideoCell class]]) {
        [((TTImagePreviewVideoCell*) cell).videoView stop];
        _imgView = ((TTImagePreviewVideoCell*) cell).videoView;
      

        _initGesturePoint = [panGestureRecognizer locationInView:_imgView];
        [_imgView removeFromSuperview];
        [self.view addSubview:_imgView];
        _initFrame = _imgView.frame;
        
        
        _imgView.frame = [_imgView convertRect:_imgView.bounds toView:self.view];

//        _imgView.center = CGPointMake(self.view.width/2, self.view.height/2);
        self.collectionView.hidden = YES;
        self.bottomView.hidden = YES;
        self.topView.hidden = YES;
        
        _onPaning = YES;

        [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                                withAnimation:NO];
    }
}

- (void) resetPanAnimated {
    [[UIApplication sharedApplication] setStatusBarHidden:YES
                                            withAnimation:NO];
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
    if ([cell isKindOfClass:[TTImagePreviewPhotoCell class]]) {
        TTImagePreviewPhotoView* photoView = ((TTImagePreviewPhotoCell*) cell).previewView;
        if (_imgView == photoView.imageContainerView) {
            [_imgView removeFromSuperview];
            [photoView.scrollView addSubview:_imgView];
            
            self.collectionView.hidden = NO;
            [self refreshNaviBarAndBottomBarState];
//            self.view.backgroundColor = [UIColor blackColor];
            [UIView animateWithDuration:.35 animations:^{
                _imgView.frame = _initFrame;
                self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];

            } completion:^(BOOL finished) {
                _onPaning = NO;
                _imgView = nil;
            }];
        }
    } else if ([cell isKindOfClass:[TTImagePreviewVideoCell class]]) {
        TTImagePreviewVideoView* videoView = ((TTImagePreviewVideoCell*) cell).videoView;
        if (_imgView == videoView) {
            [_imgView removeFromSuperview];
            [cell addSubview:_imgView];
            self.collectionView.hidden = NO;
            _hideNavBarAndBottomBar = NO;
            [self refreshNaviBarAndBottomBarState];
            //            self.view.backgroundColor = [UIColor blackColor];
            
            [UIView animateWithDuration:.35 animations:^{
                _imgView.frame = _initFrame;
                self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:1];
            } completion:^(BOOL finished) {
                _onPaning = NO;
                _imgView = nil;
                [((TTImagePreviewVideoCell*) cell) willDisplay];
            }];
        }
    }
}

- (void)changePanAnimated:(UIPanGestureRecognizer*) panGestureRecognizer {
    
    self.bottomView.hidden = YES;
    self.topView.hidden = YES;
    
    CGPoint point = [panGestureRecognizer translationInView:self.view];
    
    CGFloat length = point.y*point.y + point.x*point.x;
    CGFloat max = self.view.width*self.view.width;
    CGFloat scale = (max - length)/max;
    
    scale = MAX(scale, 0.3);
    
    CGFloat width = _initFrame.size.width * scale;
    CGFloat height = _initFrame.size.height * scale;
    
    CGFloat x = (_initFrame.size.width - width) * _initGesturePoint.x/_initFrame.size.width + point.x + _initFrame.origin.x;
    CGFloat y = (_initFrame.size.height - height) * _initGesturePoint.y/_initFrame.size.height + point.y + _initFrame.origin.y;
    
    _imgView.frame = CGRectMake(x, y, width, height);
    
    self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:scale];
}


- (BOOL)prefersStatusBarHidden {
    return YES;
}


- (void)presentOn:(UIViewController *)parentViewController {
    _naviBarHidden = self.navigationController.navigationBarHidden;
    if ([UIDevice currentDevice].systemVersion.doubleValue < 8.f) {
        if (self.navigationController.navigationBar == nil) {
            _naviBarHidden = YES;
        } else {
            _naviBarHidden = self.navigationController.navigationBar.hidden;
        }
    }
    _statusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    _enterOrientation = [[UIApplication sharedApplication] statusBarOrientation];
    UIViewController *rootViewController = parentViewController;
    
    if (rootViewController == nil) {
        UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (rootViewController.presentedViewController) {
            rootViewController = rootViewController.presentedViewController;
        }
    }
   
    [rootViewController addChildViewController:self];
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    if (self.previewType == TTImagePreviewTypeDelete) {
        TTImagePickerTrack(TTImagePickerTrackKeyPreviewPostEnter, nil);
    }
    UIView *containerView = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
    containerView.backgroundColor = [UIColor clearColor];
    [rootViewController.view addSubview:containerView];
    [rootViewController.view addSubview:self.view];

    
    //从原图处扩展动画
    if (self.tapView && self.tapView.image && self.allModels && self.allModels.count > _currentIndex) {
        
        UIView *maskView = [[UIView alloc]initWithFrame:self.tapView.frame];
        maskView.backgroundColor = [UIColor whiteColor];
        [self.tapView.superview addSubview:maskView];
        
        
        self.view.hidden = YES;
        CGRect frame = [self.tapView convertRect:self.tapView.bounds toView:rootViewController.view];
        
        __block CGFloat imgHeight = 0;
        if (self.tapView.image.size.width) {
            imgHeight = (self.tapView.image.size.height/self.tapView.image.size.width)* self.view.width;
        }
        
        UIImageView *image = [[UIImageView alloc]initWithFrame:frame];
        image.contentMode = UIViewContentModeScaleAspectFill;
        image.clipsToBounds = YES;
        image.image = self.tapView.image;
        [rootViewController.view addSubview:image];
        
        TTAssetModel *model = self.allModels[_currentIndex];
        
        if (model.cacheImage) {
            image.image = model.cacheImage;
            if (model.cacheImage.size.width) {
                imgHeight = (model.cacheImage.size.height/model.cacheImage.size.width )* self.view.width;
            }
        }else{
            if (model.type != TTAssetModelMediaTypePhotoGif) {
                
                [[TTImagePickerManager manager] getPhotoWithAsset:model.asset photoWidth:TTImagePickerImageWidthDefault completion:^(UIImage *photo, NSDictionary *info, BOOL isDegraded) {
                    image.image = photo;
                    if (photo.size.width) {
                        imgHeight = (photo.size.height/photo.size.width )* self.view.width;
                    }
                } progressHandler:nil isIcloudEabled:NO isSingleTask:NO];
                
            }
        }
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:NO];
        
        [UIView animateWithDuration:.2f animations:^{
            image.frame = CGRectMake(0, (self.view.height - imgHeight)/2.0, self.view.width, imgHeight);

            containerView.backgroundColor = [UIColor blackColor];

        } completion:^(BOOL finished) {
         
            [image removeFromSuperview];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            self.view.hidden = NO;
            [containerView removeFromSuperview];

            [maskView removeFromSuperview];

            [self refreshNaviBarAndBottomBarState];
            if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePreviewViewControllerScrollChange:index:)]) {
                [self.delegate ttImagePreviewViewControllerScrollChange:self index:_currentIndex];
            }
            
//            self.bottomView.backImg.alpha = 0;
//            self.topView.backImg.alpha = 0;
//            [UIView animateWithDuration:.2 animations:^{
//                self.bottomView.backImg.alpha = 1;
//                self.topView.backImg.alpha = 1;
//            }];
    
            
        }];
        
    }
    //上推动画
    else{
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES
                                                withAnimation:NO];
        self.view.top = rootViewController.view.height;
        [UIView animateWithDuration:.3f animations:^{
            self.view.top = 0;
            containerView.backgroundColor = [UIColor blackColor];
        } completion:^(BOOL finished) {
            [containerView removeFromSuperview];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            
            [self refreshNaviBarAndBottomBarState];
            if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePreviewViewControllerScrollChange:index:)]) {
                [self.delegate ttImagePreviewViewControllerScrollChange:self index:_currentIndex];
            }
            
        }];
    }
 
}

//此处动画交给外部来做，仅仅做干掉操作而已
- (void)dismiss:(BOOL)animated  isGestureAnimate:(BOOL)isGestureAnimate{
    
    //取消掉正在进行的Icloud预览任务
    //[[TTImagePickerManager manager].icloudDownloader cancelSingleIcloud];
    if (!animated) {
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        return;
    }
    if (isGestureAnimate) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:.2 animations:^{
            self.view.backgroundColor = [UIColor clearColor];
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];
    }else{
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [UIView animateWithDuration:.15 animations:^{
            self.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        }];

    }

}



- (void) configCollectionView {
    
    float gap = self.previewType == TTImagePreviewTypeVideo? 0 : 20;
    float x = self.previewType == TTImagePreviewTypeVideo? 0 : -10;

    UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    layout.itemSize = CGSizeMake(self.view.width + gap, self.view.height);
    layout.minimumInteritemSpacing = 0;
    layout.minimumLineSpacing = 0;
    
    _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(x, 0, self.view.width + gap, self.view.height) collectionViewLayout:layout];
    _collectionView.backgroundColor = [UIColor blackColor];
    _collectionView.dataSource = self;
    _collectionView.delegate = self;
    _collectionView.pagingEnabled = YES;
    _collectionView.scrollsToTop = NO;
    _collectionView.showsHorizontalScrollIndicator = NO;
    _collectionView.contentOffset = CGPointMake(0, 0);
    _collectionView.contentSize = CGSizeMake(self.allModels.count * (self.view.width + gap), 0);
    _collectionView.alwaysBounceHorizontal = YES;
    [self.view addSubview:_collectionView];
    [_collectionView registerClass:[TTImagePreviewPhotoCell class] forCellWithReuseIdentifier:@"TTImagePreviewPhotoCell"];
    [_collectionView registerClass:[TTImagePreviewVideoCell class] forCellWithReuseIdentifier:@"TTImagePreviewVideoCell"];
}

#pragma -- mark action
- (void)onClickSubmit {
    //任务未完成
    if (!self.canComplete) {
        if (self.loadingView.isFailed) {
            [TTImagePickerAlert showWithTitle:@"iCloud同步失败"];
        }else{
            [TTImagePickerAlert showWithTitle:@"iCloud同步中"];
        }
        return;
    }
    
    if (self.previewType == TTImagePreviewTypeDefalut) {
        TTImagePickerTrack(TTImagePickerTrackKeyPreviewFinished, nil);
    }else if(self.previewType == TTImagePreviewTypeVideo){
        TTImagePickerTrack(TTImagePickerTrackKeyVideoPreviewFinish, nil);
    }
    
    if (_selectModels.count == 0) {
        [self addSelectModel:[self.allModels objectAtIndex:_currentIndex]];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePreviewViewControllerSelectDidFinish:)]) {
        [self.delegate ttImagePreviewViewControllerSelectDidFinish:self];
    }
    BOOL statusBarHidden = _statusBarHidden;
    if (!self.isStatusBarAutoHidden) {
        statusBarHidden = self.lastHidden;
    }
    [[UIApplication sharedApplication] setStatusBarHidden:statusBarHidden
                                            withAnimation:NO];
}

#pragma -- mark TTImagePreviewTopBarDelegate
- (void)ttImagePreviewTopBarOnButtonClick:(TTImagePreviewTopBarButtonTag)tag {
    switch (tag) {
        case TTImagePreviewTopBarButtonTagClose:
            [self dismissMySelf:NO];
            break;
            
        case TTImagePreviewTopBarButtonTagDelete:
        {
            NSUInteger deleteIndex = _currentIndex;
            if (_currentIndex == self.allModels.count - 1) {
                if (_currentIndex >= 1) {
                    _currentIndex --;
                }
            }
            TTImagePickerTrack(TTImagePickerTrackKeyPreviewPostDelete, nil);
            [self removeSelectModelIndex:deleteIndex];
            _allModels = self.selectModels;
            if (self.allModels.count == 0) {
                [self dismissMySelf:NO];
                return;
            } else {
                [self.collectionView reloadData];
            }
            
            [self refreshNaviBarAndBottomBarState];

        }
            break;
            
        case TTImagePreviewTopBarButtonTagComplete:
        {
            [self onClickSubmit];
        }
            break;
        default:
            break;
    }
}

- (void)selectAction
{
    TTAssetModel* model = [self.allModels objectAtIndex:_currentIndex];
    if ([_selectModels containsObject:model]) {
        [self removeSelectModel:model];
        self.bottomView.selected = NO;
    } else {
        if (_maxLimit == self.selectModels.count) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:[NSString stringWithFormat:@"最多只能选中%ld张图片", _maxLimit] indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        } else {
            [self addSelectModel:model];
            self.bottomView.selected = YES;
        }
    }

}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offSetWidth = scrollView.contentOffset.x;
    offSetWidth = offSetWidth +  ((self.view.width + 20) * 0.5);
    
    NSInteger currentIndex = offSetWidth / (self.view.width + 20);
    
    
    if ((currentIndex < self.allModels.count && _currentIndex != currentIndex)) {
        _currentIndex = currentIndex;
        [self refreshNaviBarAndBottomBarState];
        if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePreviewViewControllerScrollChange:index:)]) {
            [self.delegate ttImagePreviewViewControllerScrollChange:self index:_currentIndex];
        }
    }
    
    if (!scrollView.isDecelerating && !scrollView.isTracking && !scrollView.isDragging) {
        UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
        if ([cell isKindOfClass:[TTImagePreviewBaseCell class]]) {
            [((TTImagePreviewBaseCell*) cell) didDisplay];
        }
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {

    if (self.previewType == TTImagePreviewTypeDefalut || self.previewType == TTImagePreviewTypeDelete) {
        TTImagePickerTrack(TTImagePickerTrackKeyPreviewFlip, nil);
    }
    if (!scrollView.isTracking) {
        UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
        if ([cell isKindOfClass:[TTImagePreviewBaseCell class]]) {
            [((TTImagePreviewBaseCell*) cell) didDisplay];
        }
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    if (!scrollView.isTracking) {
        UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:_currentIndex inSection:0]];
        if ([cell isKindOfClass:[TTImagePreviewBaseCell class]]) {
            [((TTImagePreviewBaseCell*) cell) didDisplay];
        }
    }
}

#pragma mark - UICollectionViewDataSource && Delegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.allModels.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTAssetModel* model = _allModels[indexPath.row];
    TTImagePreviewBaseCell* cell;
    if (model.type == TTAssetModelMediaTypeVideo) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTImagePreviewVideoCell" forIndexPath:indexPath];
        cell.model = model;
        ((TTImagePreviewVideoCell*)cell).videoManager = self.videoManager;
    } else {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"TTImagePreviewPhotoCell" forIndexPath:indexPath];
        cell.myVC = self;
        cell.model = model;
    }
    cell.indexPath = indexPath;
    if (!cell.singleTapGestureBlock) {
        WeakSelf;
        cell.singleTapGestureBlock = ^(TTImagePreviewBaseCell* baseCell){
            StrongSelf;
            [self onSingleTapCell:baseCell.model indexPath:baseCell.indexPath];
        };
    }
    
    if ([UIDevice currentDevice].systemVersion.doubleValue < 8.f) {
        if ([cell isKindOfClass:[TTImagePreviewBaseCell class]]) {
            [(TTImagePreviewBaseCell *)cell willDisplay];
        }
    }
    
    if (self.firstDisplay && _currentIndex == indexPath.row) {
        [cell didDisplay];
        self.firstDisplay = NO;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell isKindOfClass:[TTImagePreviewBaseCell class]]) {
        [(TTImagePreviewBaseCell *)cell willDisplay];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
}

#pragma -- mark private
- (void)refreshNaviBarAndBottomBarState {
    self.bottomView.hidden = _hideNavBarAndBottomBar;
    self.topView.hidden = _hideNavBarAndBottomBar;
    [self.topView setTitle:[NSString stringWithFormat:@"%ld/%ld", _currentIndex + 1, self.allModels.count]];
    self.bottomView.selected = [self.selectModels containsObject:[self.allModels objectAtIndex:_currentIndex]];
}

- (void)onSingleTapCell:(TTAssetModel*) model indexPath:(NSIndexPath*) path {
    _hideNavBarAndBottomBar = !_hideNavBarAndBottomBar;
    [self refreshNaviBarAndBottomBarState];
}

- (void)dismissMySelf:(BOOL)isGestureAnimate {
    [[UIApplication sharedApplication] setStatusBarHidden:_statusBarHidden
                                            withAnimation:NO];
    [self.navigationController setNavigationBarHidden:_naviBarHidden];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePreviewViewControllerDidDismiss:)] ) {
        
        [self.delegate ttImagePreviewViewControllerDidDismiss:self];
        if (isGestureAnimate) {
            [self dismiss:YES isGestureAnimate:YES];
        }else{
            [self dismiss:YES isGestureAnimate:NO];
        }
    } else {
        [self dismiss:YES isGestureAnimate:isGestureAnimate];
    }
}

- (void)addSelectModel:(TTAssetModel *)object {
    
    [self.selectModels addObject:object];
    [self changeSelectModels];
}

- (void)removeSelectModel:(TTAssetModel*) object {
    [self.selectModels removeObject:object];
    [self changeSelectModels];
}

- (void)removeSelectModelIndex:(NSUInteger) index {
    [self.selectModels removeObjectAtIndex:index];
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePreviewViewControllerSelectChange:index:)]) {
        [self.delegate ttImagePreviewViewControllerSelectChange:self index:index];
    }
    if (self.selectModels.count >= 1) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePreviewViewControllerScrollChange:index:)]) {
            [self.delegate ttImagePreviewViewControllerScrollChange:self index:_currentIndex];
        }
    }
}

- (void)changeSelectModels {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePreviewViewControllerSelectChange:index:)]) {
        [self.delegate ttImagePreviewViewControllerSelectChange:self index:_currentIndex];
    }
}

#pragma mark -- Rotate
- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

@end
