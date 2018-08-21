//
//  TTXiguaLiveView.m
//  Article
//
//  Created by lishuangyang on 2017/12/14.
//
#import "TTBusinessManager.h"
#import "TTXiguaLiveProfileView.h"
#import "TTXiguaLiveManager.h"
#import "TTUIResponderHelper.h"
#import "TTDeviceUIUtils.h"
#import "TTIndicatorView.h"
#import "TTXiguaLiveLivingAnimationView.h"

static inline CGFloat logoImageLeftPadding() {
    return [TTDeviceUIUtils tt_newPadding:16];
}

static inline CGFloat titleTopPadding() {
    return [TTDeviceUIUtils tt_newPadding:37];
}

static inline CGFloat watchCountTitlePadding() {
    return [TTDeviceUIUtils tt_newPadding:4];
}

static inline CGFloat broadCastViewWatchPadding() {
    return [TTDeviceUIUtils tt_newPadding:15];
}


@interface TTXiguaLiveProfileModel ()

@end

@implementation TTXiguaLiveProfileModel

- (FRImageInfoModel *)largeImageModel{
    if ([self.largeImage count] == 0 || ![self.largeImage isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    return [[FRImageInfoModel alloc] initWithDictionary:self.largeImage];
}

@end


@interface TTXiguaLiveProfileView ()

@property (nonatomic, strong) TTXiguaLiveLivingAnimationView *liveAnimationView;
@property (nonatomic, strong) SSThemedView *maskView;
@property (nonatomic, strong) TTImageView  *logoImgView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *watchNumLabel;
@property (nonatomic, strong) UIButton *liveButton;
@property (nonatomic, strong) SSThemedView *bottomLine;

@end

@implementation TTXiguaLiveProfileView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self themeChanged:nil];
    }
    return self;
}

- (void)setupSubView
{
    if (!_logoImgView){
        CGFloat imgWidth = CGRectGetWidth(self.bounds) - logoImageLeftPadding()*2;
        CGRect imageViewRec = CGRectMake(logoImageLeftPadding(), 0, imgWidth, ceil(imgWidth/2.1));
        TTImageView *imageView = [[TTImageView alloc] initWithFrame:imageViewRec];
        imageView.enableNightCover = YES;
        imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        imageView.clipsToBounds = YES;
        imageView.backgroundColorThemeKey = kColorBackground3;
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [self addSubview:imageView];
        _logoImgView = imageView;
        _maskView = [[SSThemedView alloc] initWithFrame:imageViewRec];
        _maskView.backgroundColor = [UIColor colorWithRed:0.f green:0.f blue:0.f alpha:0.3];
        [self addSubview:_maskView];
    }
    [self.logoImgView setImageWithURLString:[self.liveModel largeImageModel].url];

    
    if (!_bottomLine){
        SSThemedView *bottomLine = [[SSThemedView alloc] init];
        bottomLine.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        bottomLine.backgroundColorThemeKey = kColorLine1;
        [self addSubview:bottomLine];
        _bottomLine = bottomLine;
        [self addSubview:bottomLine];
    }

    if (!_titleLabel) {
        SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
        [self addSubview:titleLabel];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.numberOfLines = 2;
        titleLabel.font = [UIFont systemFontOfSize:19];
        titleLabel.textColorThemeKey =kColorText12;
        _titleLabel = titleLabel;
    }
    [self.titleLabel setText:self.liveModel.title];
    [self.titleLabel sizeToFit];
    
    if (!_watchNumLabel) {
        SSThemedLabel *watchCountLabel = [[SSThemedLabel alloc] init];
        watchCountLabel.font = [UIFont systemFontOfSize:11];
        watchCountLabel.textColorThemeKey =kColorText12;
        watchCountLabel.alpha = 0.7;
        [self addSubview:watchCountLabel];
        _watchNumLabel = watchCountLabel;
    }
    [self.watchNumLabel setText:[NSString stringWithFormat:@"%@人观看",[TTBusinessManager formatCommentCount:self.liveModel.watchCount.longLongValue]]];
    [self.watchNumLabel sizeToFit];

    if (!_liveAnimationView) {
        _liveAnimationView = [[TTXiguaLiveLivingAnimationView alloc] initWithStyle:TTXiguaLiveLivingAnimationViewStyleMiddleAndLine];
        [self addSubview:self.liveAnimationView];
    }else{
        [self.liveAnimationView beginAnimation];
    }

    if (!_liveButton) {
        SSThemedButton *liveButton = [[SSThemedButton alloc] initWithFrame:self.bounds];
        [liveButton addTarget:self action:@selector(liveButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:liveButton];
        _liveButton = liveButton;
    }
}

- (void)liveButtonClicked:(SSThemedButton *)btn{
    //如果已经在同一个直播间，直接提示
    if ([[TTXiguaLiveManager sharedManager] isAlreadyInThisRoom:self.liveModel.roomID userID:self.liveModel.userID]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage
                                  indicatorText:NSLocalizedString(@"您已经在该直播间内", nil)
                                 indicatorImage:nil
                                    autoDismiss:YES
                                 dismissHandler:nil];
        return;
    }
    UINavigationController *correctVC = [TTUIResponderHelper topNavigationControllerFor:self];
    UIViewController *audienceVC = [[TTXiguaLiveManager sharedManager] audienceRoomWithUserID:self.liveModel.userID extraInfo:self.extraDic];
    [correctVC pushViewController:audienceVC animated:YES];
}

- (void)setLiveModel:(id<TTXiguaLiveViewModelProtocol>)liveModel
{
    _liveModel = liveModel;
    [self setupSubView];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat imgWidth = CGRectGetWidth(self.bounds) - logoImageLeftPadding()*2;
    CGRect imageViewRec = CGRectMake(logoImageLeftPadding(), 0, imgWidth, ceil(imgWidth/2.1));
    ;
    self.logoImgView.frame = imageViewRec;
    self.bottomLine.left = 0;
    self.bottomLine.width = self.width;
    self.bottomLine.height = [TTDeviceHelper ssOnePixel];
    self.bottomLine.top = self.height - self.bottomLine.height;
    self.titleLabel.width = self.width - 2 * logoImageLeftPadding();
    self.titleLabel.centerX = self.width / 2;
    self.titleLabel.top = titleTopPadding();
    self.watchNumLabel.centerX = self.titleLabel.centerX;
    self.watchNumLabel.top = self.titleLabel.bottom + watchCountTitlePadding();
    self.liveAnimationView.centerX = self.width / 2;
    self.liveAnimationView.top = self.watchNumLabel.bottom + broadCastViewWatchPadding();
    self.liveButton.frame = self.bounds;
    
}

- (void)themeChanged:(NSNotification *)notification{
    [super themeChanged:notification];
    self.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText12];
    self.watchNumLabel.textColor = [UIColor tt_themedColorForKey:kColorText12];
}

- (NSDictionary *)extraDic{
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.liveModel.categoryName forKey:@"category_name"];
    [dic setValue:@"click_pgc" forKey:@"enter_from"];
    return dic;
}

@end
