//
//  AWEVideoDetailSecondUsePromptViewController.m
//  HTSVideoPlay
//
//  Created by 邱鑫玥 on 2017/8/23.
//

#import "AWEVideoDetailSecondUsePromptViewController.h"
#import "TTDeviceUIUtils.h"
#import "UIViewAdditions.h"
#import "UIImageView+WebCache.h"
#import "UIView+CustomTimingFunction.h"
#import "UIColor+TTThemeExtension.h"
#import "TTShortVideoModel.h"
#import "TTImageView.h"
#import "AWEVideoDetailFirstUsePromptViewController.h"
#import "AWEVideoDetailScrollConfig.h"

static AWEVideoDetailSecondUsePromptViewController *promptViewController;

@interface AWEVideoDetailSecondUsePromptViewController ()

@property (nonatomic, strong) TTShortVideoModel *detailModel;

@property (nonatomic, strong) UIView *animateView;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) TTImageView *coverImageView;

@property (nonatomic, assign) BOOL hasAnimated;
@property (nonatomic, assign) BOOL isDismissing;

@end

@implementation AWEVideoDetailSecondUsePromptViewController

#pragma mark -
+ (void)dismiss
{
    if (promptViewController) {
        [promptViewController hideWithCompletion:^{
            promptViewController = nil;
        }];
    }
}

+ (void)showSecondSwipePromptWithDataFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)dataFetchManager
                                     currentIndex:(NSInteger)index
                                 inViewController:(UIViewController *)containerViewController
{
    if (promptViewController) {
        return;
    }

    TTShortVideoModel *model = [dataFetchManager itemAtIndex:index + 1];
    
    promptViewController = [[self alloc] initWithDetailModel:model];
    
    [containerViewController addChildViewController:promptViewController];
    [containerViewController.view addSubview:promptViewController.view];
    promptViewController.view.frame = containerViewController.view.bounds;
    [promptViewController didMoveToParentViewController:containerViewController];
}

#pragma mark -

- (instancetype)initWithDetailModel:(TTShortVideoModel *)model
{
    if (self = [super init]) {
        self.detailModel = model;
    }
    
    return self;
}

#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.userInteractionEnabled = NO;
    self.isDismissing = NO;
    
    [self.view addSubview:self.animateView];
    [self.animateView addSubview:self.arrowImageView];
    [self.animateView addSubview:self.textLabel];
    [self.animateView addSubview:self.coverImageView];
    
    [self.coverImageView setImageWithModel:self.detailModel.detailCoverImageModel];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.animateView.width = [TTDeviceUIUtils tt_newPadding:236.f];
    self.animateView.height = [TTDeviceUIUtils tt_newPadding:68.f];
    self.animateView.centerY = self.view.height / 2;
    if (!self.hasAnimated) {
        self.animateView.left = self.view.width;
    } else {
        self.animateView.right = self.view.width;
    }
    
    UIBezierPath *cornerPath = [UIBezierPath bezierPathWithRoundedRect:self.animateView.bounds byRoundingCorners:UIRectCornerTopLeft|UIRectCornerBottomLeft cornerRadii:CGSizeMake(self.animateView.height / 2, self.animateView.height / 2)];
    CAShapeLayer *maskLayer= [[CAShapeLayer alloc] init];
    maskLayer.frame = self.animateView.bounds;
    maskLayer.path = cornerPath.CGPath;
    self.animateView.layer.mask = maskLayer;
    
    CGFloat centerY = self.animateView.height / 2;
    self.coverImageView.width = [TTDeviceUIUtils tt_newPadding:46.f];
    self.coverImageView.height = [TTDeviceUIUtils tt_newPadding:58.f];
    self.coverImageView.centerY = centerY;
    self.coverImageView.right = self.animateView.width - [TTDeviceUIUtils tt_newPadding:5.f];
    
    [self.textLabel sizeToFit];
    self.textLabel.centerY = centerY;
    self.textLabel.right = self.coverImageView.left - [TTDeviceUIUtils tt_newPadding:10.f];
    
    self.arrowImageView.width = [TTDeviceUIUtils tt_newPadding:31.f];
    self.arrowImageView.height = [TTDeviceUIUtils tt_newPadding:22.f];
    self.arrowImageView.centerY = centerY;
    self.arrowImageView.right = self.textLabel.left - [TTDeviceUIUtils tt_newPadding:6.f];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.hasAnimated) {
        self.hasAnimated = YES;

        [UIView animateWithDuration:0.6 customTimingFunction:CustomTimingFunctionExpoOut animation:^{
            self.animateView.right = self.view.width;
        } completion:^(BOOL finished) {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[self class] dismiss];
            });
        }];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [[self class] dismiss];
}

#pragma mark -
- (UIView *)animateView
{
    if (!_animateView) {
        _animateView = [[UIView alloc] init];
        _animateView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.6];
    }
    
    return _animateView;
}

- (UIImageView *)arrowImageView
{
    if (!_arrowImageView) {
        _arrowImageView = [[UIImageView alloc] init];
        _arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
        _arrowImageView.clipsToBounds = YES;
        _arrowImageView.image = [UIImage imageNamed:@"shortvideo_detail_right_arrow"];
    }
    return _arrowImageView;
}

- (UILabel *)textLabel
{
    if (!_textLabel) {
        _textLabel = [[UILabel alloc] init];
        _textLabel.textColor = [UIColor whiteColor];
        _textLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:17.f]];
        _textLabel.text = @"左滑查看下一个";
    }
    return _textLabel;
}

- (TTImageView *)coverImageView
{
    if (!_coverImageView) {
        _coverImageView = [[TTImageView alloc] init];
        _coverImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _coverImageView.backgroundColor = [UIColor colorWithHexString:@"1b1b1b"];
        _coverImageView.enableNightCover = NO;
        _coverImageView.clipsToBounds = YES;
    }
    return _coverImageView;
}

- (void)hideWithCompletion:(void (^)(void))completionBlock
{
    if (self.isDismissing) {
        return;
    }

    self.isDismissing = YES;
    [UIView animateWithDuration:0.15 animations:^{
        self.animateView.alpha = 0;
    } completion:^(BOOL finished) {
        [self willMoveToParentViewController:nil];
        [self.view removeFromSuperview];
        [self removeFromParentViewController];
        self.isDismissing = NO;
        
        if (completionBlock) {
            completionBlock();
        }
    }];
}

@end
