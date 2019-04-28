//
//  FHDetailFullScreenVideoVC.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/24.
//

#import "FHDetailFullScreenVideoVC.h"

@interface FHDetailFullScreenVideoVC ()

@property(nonatomic, copy) dispatch_block_t dismissBlock;
@property(nonatomic, strong) UIView *containerView;
@property (nonatomic, assign)   CGRect       beginFrame;

@end

@implementation FHDetailFullScreenVideoVC

- (void)dealloc
{
    @try {
        [self removeObserver:self forKeyPath:@"self.view.frame"];
    }
    @catch (NSException *exception) {
        
    }
    @finally {
        
    }
}

#pragma mark - View Life Cycle
- (void)loadView
{
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    self.view = [[UIView alloc] initWithFrame:rootViewController.view.bounds];
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self addObserver:self forKeyPath:@"self.view.frame" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"self.view.frame"]) {
        [self refreshUI];
    }
}

- (void)refreshUI
{ }

- (instancetype)init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor clearColor];
    _containerView = [[UIView alloc] initWithFrame:self.view.frame];
    _containerView.backgroundColor = [UIColor blackColor];
    [self.view addSubview:_containerView];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)presentVideoViewWithDismissBlock:(dispatch_block_t)block
{
    self.dismissBlock = block;
    
    UIViewController *rootViewController = [UIApplication sharedApplication].keyWindow.rootViewController;
    while (rootViewController.presentedViewController) {
        rootViewController = rootViewController.presentedViewController;
    }
    [rootViewController addChildViewController:self];
    
    self.view.backgroundColor = [UIColor clearColor];
    self.beginFrame = self.videoView.vedioView.frame;
    CGFloat fw = self.beginFrame.size.width;
    CGFloat fh = self.beginFrame.size.height;
    CGFloat winW = [UIScreen mainScreen].bounds.size.width;
    CGFloat winH = [UIScreen mainScreen].bounds.size.height;
    CGFloat rate = 1.0;
    if (fw > 0 && fh > 0) {
        CGFloat wRate = winW / fh;
        CGFloat hRate = winH / fw;
        rate = wRate < hRate ? wRate : hRate; // 放大比率
    }
    UIView * largeImageView = self.videoView.vedioView; // 视频view
    CGFloat rotateW = fw * rate;
    CGFloat rotateH = fh * rate;
    largeImageView.frame = self.beginFrame;
    self.containerView.backgroundColor = [UIColor clearColor];
   
    [self.containerView addSubview:largeImageView];
    [rootViewController.view addSubview:self.view];
    CGAffineTransform transform = CGAffineTransformMakeRotation(M_PI_2);
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35f
                          delay:0.0 options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         largeImageView.frame = CGRectMake(self.beginFrame.origin.x - (rotateW - fw) / 2, self.beginFrame.origin.y - (rotateH - fh) / 2, rotateW, rotateH);
                         largeImageView.transform = transform;
                         weakSelf.containerView.backgroundColor = [UIColor blackColor];
                     } completion:^(BOOL finished) {
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
}

- (void)dismissVC {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:0.35f
                          delay:0.0 options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         weakSelf.videoView.vedioView.transform = CGAffineTransformIdentity;
                         weakSelf.videoView.vedioView.frame = weakSelf.beginFrame;
                     } completion:^(BOOL finished) {
                         weakSelf.containerView.backgroundColor = [UIColor clearColor];
                         [weakSelf.videoView addSubview:weakSelf.videoView.vedioView];
                         if (weakSelf.dismissBlock) {
                             weakSelf.dismissBlock();
                         }
                         [weakSelf.view removeFromSuperview];
                         [weakSelf removeFromParentViewController];
                         [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                     }];
}

@end
