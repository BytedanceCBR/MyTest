//
//  TTDiggScoreFeedBackView.m
//  Article
//
//  Created by Zichao Xu on 2017/10/16.
//

#import "TTDiggScoreFeedBackView.h"

#import "SSThemed.h"
#import "TTAlphaThemedButton.h"
#import "UIButton+TTAdditions.h"
#import "TTDeviceUIUtils.h"
#import "UIViewAdditions.h"
#import "TTTracker.h"
#import "TTThemeManager.h"


@interface TTScoreGuideViewController : UIViewController


//具体的UI
@property (nonatomic,strong) SSThemedView *backView;
@property (nonatomic,strong) TTAlphaThemedButton *closeBtn;
@property (nonatomic,strong) TTAlphaThemedButton *upBtn;
@property (nonatomic,strong) TTAlphaThemedButton *downBtn;
@property (nonatomic,strong) SSThemedView *wrapperView;
@property (nonatomic,strong) SSThemedLabel *titleLabel;
@property (nonatomic,strong) SSThemedLabel *tipLabel;
@property (nonatomic,strong) SSThemedImageView *goodImageView;
@property (nonatomic,strong) SSThemedLabel *goodLabel;
@property (nonatomic,strong) SSThemedImageView *badImageView;
@property (nonatomic,strong) SSThemedLabel *badLabel;

//方法
- (void)refreshActionDiggBlock:(dispatch_block_t)upBlock
                     downBlock:(dispatch_block_t)downBlock
                   cancelBlock:(dispatch_block_t)cancelBlock;


@end

@implementation TTScoreGuideViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setUpGuideView];
    [self layoutGuideView];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    [self layoutGuideView];
}

#pragma mark -- 辅助函数
- (void)setUpGuideView
{
    self.backView = [[SSThemedView alloc] initWithFrame:self.view.bounds];
    self.backView.backgroundColor = [UIColor blackColor];
    self.backView.alpha = 0.3;
    [self.view addSubview:self.backView];
    
    self.wrapperView = [[SSThemedView alloc] init];
    self.wrapperView.backgroundColorThemeKey = kColorBackground4;
    self.wrapperView.clipsToBounds = YES;
    [self.view addSubview:self.wrapperView];
    
    self.closeBtn = [[TTAlphaThemedButton alloc] init];
    self.closeBtn.backgroundColorThemeKey = kColorBackground4;
    self.closeBtn.imageName = @"popup_newclose";
    [self.wrapperView addSubview:self.closeBtn];
    
    self.titleLabel = [[SSThemedLabel alloc] init];
    self.titleLabel.font = [UIFont systemFontOfSize:[self fontSize]];
    self.titleLabel.textColorThemeKey = kColorText1;
    self.titleLabel.text = @"喜欢“好多房”吗?";
    [self.wrapperView addSubview:self.titleLabel];
    
    self.tipLabel = [[SSThemedLabel alloc] init];
    self.tipLabel.font = [UIFont systemFontOfSize:[self fontSize]];
    self.tipLabel.textColorThemeKey = kColorText1;
    self.tipLabel.text = @"您的评价对我们非常重要";
    [self.wrapperView addSubview:self.tipLabel];
    
    self.upBtn = [[TTAlphaThemedButton alloc] init];
    self.upBtn.backgroundColorThemeKey = kColorBackground4;
    [self.wrapperView addSubview:self.upBtn];
    
    self.goodImageView = [[SSThemedImageView alloc] init];
    self.goodImageView.imageName = @"guideScoreGood";
    [self.upBtn addSubview:self.goodImageView];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        self.goodImageView.alpha = 0.5;
    }
    
    self.goodLabel = [[SSThemedLabel alloc] init];
    self.goodLabel.font = [UIFont systemFontOfSize:[self fontSize]];
    self.goodLabel.textColorThemeKey = kColorText1;
    self.goodLabel.text = @"五星好评";
    [self.upBtn addSubview:self.goodLabel];
    
    self.downBtn = [[TTAlphaThemedButton alloc] init];
    self.downBtn.backgroundColorThemeKey = kColorBackground4;
    [self.wrapperView addSubview:self.downBtn];
    
    self.badImageView = [[SSThemedImageView alloc] init];
    self.badImageView.imageName = @"guideScoreBad";
    [self.downBtn addSubview:self.badImageView];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        self.badImageView.alpha = 0.5;
    }

    self.badLabel = [[SSThemedLabel alloc] init];
    self.badLabel.font = [UIFont systemFontOfSize:[self fontSize]];
    self.badLabel.textColorThemeKey = kColorText1;
    self.badLabel.text = @"我要吐槽";
    [self.downBtn addSubview:self.badLabel];
    
}

- (void)layoutGuideView
{
    self.backView.left = 0;
    self.backView.top = 0;
    self.backView.width = self.view.width;
    self.backView.height = self.view.height;

    self.wrapperView.width = [TTDeviceUIUtils tt_padding:270];
    self.wrapperView.height = [TTDeviceUIUtils tt_padding:220];
    self.wrapperView.layer.cornerRadius = [TTDeviceUIUtils tt_padding:12];
    self.wrapperView.centerY = self.view.height/2;
    self.wrapperView.centerX = self.view.width/2;
    
    self.closeBtn.width = [TTDeviceUIUtils tt_padding:24];
    self.closeBtn.height = [TTDeviceUIUtils tt_padding:24];
    self.closeBtn.right = self.wrapperView.width - [TTDeviceUIUtils tt_padding:8];
    self.closeBtn.top =  [TTDeviceUIUtils tt_padding:8];
    self.closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-12, -12, -12, -12);
    
    [self.titleLabel sizeToFit];
    self.titleLabel.height = [self fontSize];
    self.titleLabel.centerX = self.wrapperView.width/2;
    self.titleLabel.top = [TTDeviceUIUtils tt_padding:30];
    
    [self.tipLabel sizeToFit];
    self.tipLabel.height = [self fontSize];
    self.tipLabel.centerX = self.wrapperView.width/2;
    self.tipLabel.top = self.titleLabel.bottom + [TTDeviceUIUtils tt_padding:8];
    
    CGFloat btnTop = self.tipLabel.bottom + [TTDeviceUIUtils tt_padding:25];

    
    self.upBtn.width = self.wrapperView.width/2;
    self.upBtn.height = self.wrapperView.height - btnTop;
    self.upBtn.right = self.wrapperView.width;
    self.upBtn.top =  btnTop;
    
    self.goodImageView.width = [TTDeviceUIUtils tt_padding:64];
    self.goodImageView.height = [TTDeviceUIUtils tt_padding:64];
    self.goodImageView.layer.cornerRadius = self.goodImageView.width/2;
    self.goodImageView.centerX = self.upBtn.width/2;
    self.goodImageView.top = 0;
    
    [self.goodLabel sizeToFit];
    self.goodLabel.height = [self fontSize];
    self.goodLabel.centerX = self.upBtn.width/2;
    self.goodLabel.top =  self.goodImageView.bottom + [TTDeviceUIUtils tt_padding:10];
    
    self.downBtn.width = self.wrapperView.width/2;
    self.downBtn.height = self.wrapperView.height - btnTop;
    self.downBtn.left = 0;
    self.downBtn.top =  btnTop;
    
    self.badImageView.width = [TTDeviceUIUtils tt_padding:64];
    self.badImageView.height = [TTDeviceUIUtils tt_padding:64];
    self.badImageView.layer.cornerRadius = self.badImageView.width/2;
    self.badImageView.centerX = self.downBtn.width/2;
    self.badImageView.top = 0;
    
    [self.badLabel sizeToFit];
    self.badLabel.height = [self fontSize];
    self.badLabel.centerX = self.downBtn.width/2;
    self.badLabel.top =  self.badImageView.bottom + [TTDeviceUIUtils tt_padding:10];
    
}
- (void)refreshActionDiggBlock:(dispatch_block_t)upBlock
                     downBlock:(dispatch_block_t)downBlock
                     cancelBlock:(dispatch_block_t)cancelBlock
{
    if (upBlock && self.upBtn) {
        [self.upBtn addTarget:self withActionBlock:upBlock forControlEvent:UIControlEventTouchUpInside];
    }
    
    if (downBlock && self.downBtn) {
        [self.downBtn addTarget:self withActionBlock:downBlock forControlEvent:UIControlEventTouchUpInside];
    }
    
    if (cancelBlock && self.closeBtn) {
        [self.closeBtn addTarget:self withActionBlock:cancelBlock forControlEvent:UIControlEventTouchUpInside];
    }
}

- (float)fontSize
{
    return [TTDeviceUIUtils tt_fontSize:15];
}

@end

@interface TTDiggScoreFeedBackView()

@property (nonatomic,assign) BOOL isShowing;
@property (nonatomic,strong) UIWindow *backWindow;
@property (nonatomic,strong) UIWindow *originWindow;
@property (nonatomic,strong) TTScoreGuideViewController *rootVC;

//统计
@property (nonatomic,copy) NSDictionary *trackerInfo;


@end

@implementation TTDiggScoreFeedBackView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.rootVC = [[TTScoreGuideViewController alloc] init];
    }
    return self;
}

#pragma mark -- public

- (void)show
{
    if (self.isShowing) {
        return;
    }
    self.isShowing = YES;
    
    self.originWindow = [UIApplication sharedApplication].keyWindow;
    
    if (!self.rootVC) {
        self.rootVC = [[TTScoreGuideViewController alloc] init];
    }
    
    if (!self.backWindow) {
        self.backWindow = [[UIWindow alloc] init];
        self.backWindow.frame = [UIApplication sharedApplication].keyWindow.bounds;
        self.backWindow.windowLevel = UIWindowLevelAlert;
        self.backWindow.hidden = YES;
        [self.backWindow setBackgroundColor:[UIColor clearColor]];
        self.backWindow.rootViewController = self.rootVC;
    }
    
    [self.backWindow makeKeyAndVisible];
    
    self.rootVC.view.alpha = 0;
    [UIView animateKeyframesWithDuration:0.3 delay:0 options:UIViewKeyframeAnimationOptionCalculationModeLinear animations:^{
        self.rootVC.view.alpha = 1;
    } completion:nil];
    
    [TTTracker eventV3:@"evaluate_pop_show" params:self.trackerInfo];
}


- (void)dismissFinished:(dispatch_block_t)block
{
    self.rootVC.view.hidden = YES;
    [self.rootVC.view removeFromSuperview];
    self.rootVC = nil;
    self.backWindow.windowLevel = UIWindowLevelNormal;
    self.backWindow.hidden = YES;
    self.backWindow = nil;
    
    [self.originWindow makeKeyAndVisible];
    
    self.isShowing = NO;
    
    if (block) {
        block();
    }
}

- (void)refreshActionDiggBlock:(dispatch_block_t)upBlock
                     downBlock:(dispatch_block_t)downBlock
                   cancelBlock:(dispatch_block_t)cancelBlock
{
    dispatch_block_t up = ^{
        if (upBlock) {
            upBlock();
        }
        [TTTracker eventV3:@"evaluate_pop_good" params:self.trackerInfo];
    };
    
    dispatch_block_t down = ^{
        if (downBlock) {
            downBlock();
        }
        [TTTracker eventV3:@"evaluate_pop_bad" params:self.trackerInfo];
    };
    
    dispatch_block_t cancel = ^{
        if (cancelBlock) {
            cancelBlock();
        }
        [TTTracker eventV3:@"evaluate_pop_close" params:self.trackerInfo];
    };
    
    [self.rootVC refreshActionDiggBlock:up downBlock:down cancelBlock:cancel];
}

- (void)setTrackDic:(NSDictionary *)trackDic
{
    self.trackerInfo = trackDic;
}

@end
