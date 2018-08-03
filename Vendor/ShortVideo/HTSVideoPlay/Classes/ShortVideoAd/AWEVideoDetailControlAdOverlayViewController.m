//
//  AWEVideoDetailBottomControlOverlayViewController.m
//  Pods
//
//  Created by Zuyang Kou on 20/06/2017.
//
//

#import "AWEVideoDetailControlAdOverlayViewController.h"

#import "AWEVideoDetailManager.h"
#import "AWEVideoDetailTracker.h"
#import "AWEVideoPlayTrackerBridge.h"
#import "AWEVideoPlayTransitionBridge.h"
#import "AWEVideoDetailScrollConfig.h"
#import "AWEVideoShareModel.h"
#import "BTDResponder.h"
#import "EXTKeyPathCoding.h"
#import "EXTScope.h"
#import "HTSDeviceManager.h"
#import "HTSVideoPlayToast.h"
#import "MBProgressHUD.h"
#import "SSMotionRender.h"
#import "SSThemed.h"
#import "TSVDetailRouteHelper.h"
#import "TSVShortVideoOriginalData.h"
#import "TTAdCallManager.h"
#import "TTAdManagerProtocol.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTDeviceHelper.h"
#import "TTModuleBridge.h"
#import "TTRoute.h"
#import "TTServiceCenter.h"
#import "TTShortVideoModel+TTAdFactory.h"
#import "TTURLUtils.h"
#import "UIButton+TTAdditions.h"
#import "UIView+Yoga.h"
#import "UIViewAdditions.h"
#import <Lottie/Lottie.h>
#import <Masonry/Masonry.h>
#import <ReactiveObjC/ReactiveObjC.h>
#import <TTThemed/UIColor+TTThemeExtension.h>
#import <BDWebImage/SDWebImageAdapter.h>
#import <UIView+CustomTimingFunction.h>

@import AssetsLibrary;

CGFloat const bottomMargin = 24.0f;
CGFloat const leftMargin = 15.0f;
CGFloat const userInfoHeight = 40.f;

@interface AWEVideoDetailControlAdOverlayViewController ()<UIGestureRecognizerDelegate>

// Top controls
@property (nonatomic, strong) UIView *topBarView;
@property (nonatomic, strong) CAGradientLayer *topBarGradientLayer;
@property (nonatomic, strong) UIView *layoutContainerView;
@property (nonatomic, strong) UIButton *moreButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UILabel *topBarTitleLabel;

// Buttom controls
@property (nonatomic, strong) CAGradientLayer *bottomGradientLayer;
@property (nonatomic, strong) UIView *bottomContentView;
@property (nonatomic, strong) UIView *userInfoContainerView;
@property (nonatomic, strong) UIImageView *avatarImageView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *actionButton;
@property (nonatomic, strong) UIButton *detailButton;

@property (nonatomic, strong) UIPanGestureRecognizer *slideUpGesture;

@end

@implementation AWEVideoDetailControlAdOverlayViewController

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupTopBarViews];
    [self setupBottomBarViews];
    
    UIPanGestureRecognizer *slideUpGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleSlideUpGesture:)];
    slideUpGesture.delegate = self;
    [self.view addGestureRecognizer:slideUpGesture];
    self.slideUpGesture = slideUpGesture;
    
    UIView *doubleTapMaskView = [UIView new];
    doubleTapMaskView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:doubleTapMaskView];
    [doubleTapMaskView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topBarView.mas_bottom);
        make.bottom.mas_equalTo(self.userInfoContainerView.mas_top);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
    }];
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_onPlayerDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [doubleTapMaskView addGestureRecognizer:doubleTap];
    
    RAC(self, model) = RACObserve(self, viewModel.model);
    RAC(self, commonTrackingParameter) = RACObserve(self, viewModel.commonTrackingParameter);
}

- (UIView *)userInfoContainerView
{
    if (!_userInfoContainerView) {
        _userInfoContainerView = [[UIView alloc] init];
        _userInfoContainerView.backgroundColor = [UIColor clearColor];

        _avatarImageView = [[UIImageView alloc] init];
        _avatarImageView.backgroundColor = [UIColor whiteColor];
        _avatarImageView.clipsToBounds = YES;
        _avatarImageView.userInteractionEnabled = YES;
        [_userInfoContainerView addSubview:_avatarImageView];

        _nameLabel = [[UILabel alloc] init];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.numberOfLines = 1;
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.layer.shadowOffset = CGSizeZero;
        _nameLabel.font = [UIFont boldSystemFontOfSize:17.0];
        _nameLabel.layer.shadowColor = [UIColor colorWithWhite:0x66/255.0 alpha:0.9].CGColor;
    
        _nameLabel.layer.shadowRadius = 1.0;
        _nameLabel.layer.shadowOpacity = 1.0;
        _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _nameLabel.userInteractionEnabled = YES;
        [_userInfoContainerView addSubview:_nameLabel];
        _userInfoContainerView.translatesAutoresizingMaskIntoConstraints = NO;
        [_userInfoContainerView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleUserInfoClick:)]];
    }

    return _userInfoContainerView;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor colorWithHexString:@"0xF85959"]];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(handleActionClick:) forControlEvents:UIControlEventTouchUpInside];
        _actionButton = button;
    }
    return _actionButton;
}

- (UIButton *)detailButton {
    if (!_detailButton) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setBackgroundColor:[UIColor colorWithHexString:@"0xF85959"]];
        button.titleLabel.font = [UIFont systemFontOfSize:14];
        [button addTarget:self action:@selector(handleDetailClick:) forControlEvents:UIControlEventTouchUpInside];
        _detailButton = button;
    }
    return _detailButton;
}

- (void)setupTopBarViews
{
    self.topBarView = [[UIView alloc] init];
    self.topBarView.frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 64.0);
    self.topBarView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    [self.view addSubview:self.topBarView];

    self.topBarGradientLayer = [CAGradientLayer layer];
    self.topBarGradientLayer.locations = @[@0, @.046875, @.109375, @.296875, @.484375, @.671875, @1];
    self.topBarGradientLayer.colors = @[(__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.4].CGColor,
                                        (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.38].CGColor,
                                        (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.34].CGColor,
                                        (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.24].CGColor,
                                        (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.14].CGColor,
                                        (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.06].CGColor,
                                        (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0].CGColor];
    [self.view.layer addSublayer:self.topBarGradientLayer];

    _layoutContainerView = [[UIView alloc] init];
    _layoutContainerView.backgroundColor = [UIColor clearColor];
    [self.topBarView addSubview:_layoutContainerView];
    
    _closeButton = [[UIButton alloc] init];
    [_closeButton setImage:[UIImage imageNamed:@"hts_vp_close"] forState:UIControlStateNormal];
    [_closeButton setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 8, 0)];
    [_closeButton addTarget:self action:@selector(handleCloseClick:) forControlEvents:UIControlEventTouchUpInside];
    [_layoutContainerView addSubview:_closeButton];
    
    _topBarTitleLabel = [[UILabel alloc] init];
    _topBarTitleLabel.textAlignment = NSTextAlignmentCenter;
    _topBarTitleLabel.font = [UIFont systemFontOfSize:14];
    _topBarTitleLabel.textColor = [UIColor whiteColor];
     [_layoutContainerView addSubview:_topBarTitleLabel];

    _moreButton = [[UIButton alloc] init];
    [_moreButton setImage:[UIImage imageNamed:@"hts_vp_white_more_titlebar"] forState:UIControlStateNormal];
    [_moreButton setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 8, 0)];
    [_moreButton addTarget:self action:@selector(handleReportClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.topBarView addSubview:_moreButton];

    [_layoutContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topBarView);
        make.left.equalTo(self.topBarView).offset(12.0);
        make.height.equalTo(@48.0);
        make.right.equalTo(_moreButton.mas_left).offset(-8.0);
    }];

    [_closeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.equalTo(_layoutContainerView);
        make.height.equalTo(@48.0);
        make.width.equalTo(@30.0);
    }];

    [self.topBarTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@100);
        make.height.equalTo(@28);
        make.centerY.equalTo(self.closeButton.mas_centerY);
    }];

    [_moreButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(_closeButton);
        make.right.equalTo(self.view).offset(-12.0);
        make.height.equalTo(@50.0);
        make.width.equalTo(@30.0);
    }];
}

- (void)setupBottomBarViews {
    //height 140
    _bottomGradientLayer = [CAGradientLayer layer];
    _bottomGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                    (__bridge id)[[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor];
    [self.view.layer addSublayer:_bottomGradientLayer];
    
    self.bottomContentView = ({
                              UIView *contentView = [UIView new];
                              contentView;
    });
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.numberOfLines = 2;
    self.titleLabel.layer.shadowOffset = CGSizeZero;
    self.titleLabel.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.6].CGColor;
    self.titleLabel.layer.shadowRadius = 1.0;
    self.titleLabel.layer.shadowOpacity = 1.0;
    self.titleLabel.layer.shouldRasterize = YES;
    self.titleLabel.userInteractionEnabled = YES;
    
    [_titleLabel addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTitleClick:)]];
    
    // 新样式
    [self.bottomContentView addSubview:self.userInfoContainerView];
    [self.bottomContentView addSubview:self.actionButton];
    [self.bottomContentView addSubview:self.detailButton];
    [self.bottomContentView addSubview:self.titleLabel];
    [self.view addSubview:self.bottomContentView];
    
    
    const CGFloat avatarSize = userInfoHeight;
    [_avatarImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.userInfoContainerView);
        make.left.equalTo(_userInfoContainerView);
        make.width.height.equalTo(@(avatarSize));
    }];
    _avatarImageView.layer.cornerRadius = avatarSize / 2.0;
    
    [_nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.userInfoContainerView);
        make.left.equalTo(_avatarImageView.mas_right).offset(8.0);
        make.right.equalTo(_userInfoContainerView);
        make.height.equalTo(@24.0);
    }];

    [self.bottomContentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
}

- (void)updateViewConstraints {
    [self updateViewConstraintsForSafeAreaIfNeeded];
    [super updateViewConstraints];
}

- (UIEdgeInsets)viewSafeAreaInsets
{
    //FIXME: 这个 view 的 safeAreaInsets 经常不对，会是0，所以取了 superview 的。推测可能跟这个 view 有对应的 VC 有关
    return self.view.superview.tt_safeAreaInsets;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    self.topBarGradientLayer.frame = self.topBarView.frame;
   
    self.bottomGradientLayer.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - 140, CGRectGetWidth(self.view.bounds), 140);
    [self updateViewFrameForSafeAreaIfNeeded];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setModel:(TTShortVideoModel *)model {
    _model = model;
    if (model == nil) {
        return;
    }
    TTAdShortVideoModel *adModel = model.rawAd;
    
    self.topBarTitleLabel.attributedText = [self makeCommonAttributeText:model.labelForDetail];
    NSURL *url = [NSURL URLWithString:self.model.author.avatarURL ?: @""];
    [self.avatarImageView sda_setImageWithURL:url placeholderImage:self.avatarImageView.image?:[UIImage imageNamed:@"hts_vp_head_icon"] completed:nil];
    self.nameLabel.text = self.model.author.name;
   
    NSMutableAttributedString *attributeText = nil;
    NSMutableDictionary *attribute = @{}.mutableCopy;
    attribute[NSFontAttributeName] = [UIFont systemFontOfSize:14.0f];
    attribute[NSForegroundColorAttributeName] = [UIColor whiteColor];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle.alignment = NSTextAlignmentLeft;
    if (model.title != nil) {
        attributeText = [[NSMutableAttributedString alloc] initWithString:model.title];
    }
    if (adModel.button_style > 1) { //2  two button
        paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
        attribute[NSParagraphStyleAttributeName] = paragraphStyle;
        [attributeText addAttributes:attribute range:NSMakeRange(0, attributeText.length)];
        self.titleLabel.attributedText = attributeText;
        
        if ([adModel.type isEqualToString:@"web"]) {
            [self style2ContentView:adModel];
        } else {
            [self style3ContentView:adModel];
        }
    } else {
        if ([adModel.type isEqualToString:@"web"]) {
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingTail;
            attribute[NSParagraphStyleAttributeName] = paragraphStyle;
            [attributeText addAttributes:attribute range:NSMakeRange(0, attributeText.length)];
            self.titleLabel.attributedText = attributeText;
        } else {
            CGFloat maxContentWidth = CGRectGetWidth(self.view.bounds) - 2 * leftMargin;
            CGSize contentSize = [attributeText boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX) options:0 context:nil].size;
            NSString *attachText = @"了解更多";
            
            if (contentSize.width <= maxContentWidth && contentSize.width + 100 >= maxContentWidth) {
                attachText = @"\n了解更多";
            } else {
                attachText = @" 了解更多";
            }
    
            [attributeText appendAttributedString:[[NSAttributedString alloc] initWithString:attachText]];
            NSTextAttachment *attach = [[NSTextAttachment alloc] init];
            attach.image = [UIImage imageNamed:@"ad_draw_web"];
            attach.bounds = CGRectMake(0, -2, 11, 14);
            NSAttributedString *imageAttribute = [NSAttributedString attributedStringWithAttachment:attach];
            [attributeText appendAttributedString:imageAttribute];
            
            paragraphStyle.lineBreakMode = NSLineBreakByTruncatingMiddle;
            attribute[NSParagraphStyleAttributeName] = paragraphStyle;
            [attributeText addAttributes:attribute range:NSMakeRange(0, attributeText.length)];
            self.titleLabel.attributedText = attributeText;
        }
        [self style1ContentView:adModel];
    }
    [self.view setNeedsUpdateConstraints];
}

- (NSAttributedString *)makeCommonAttributeText:(NSString *)text {
    if (text == nil) {
        return nil;
    }
    NSMutableDictionary *attribute = @{}.mutableCopy;
    attribute[NSFontAttributeName] = [UIFont systemFontOfSize:14.0f];
    attribute[NSForegroundColorAttributeName] = [UIColor whiteColor];
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle defaultParagraphStyle].mutableCopy;
    paragraphStyle.alignment = NSTextAlignmentCenter;
    attribute[NSParagraphStyleAttributeName] = paragraphStyle;
    NSAttributedString *attributeText = [[NSAttributedString alloc] initWithString:text attributes:attribute];
    return attributeText;
}

- (void)style1ContentView:(TTAdShortVideoModel *)adModel {
    [self.actionButton setTitle:[adModel actionButtonText] forState:UIControlStateNormal];
    
    CGFloat actionButtonWidth = 85;
    
    if ([adModel.type isEqualToString:@"web"]) {
        actionButtonWidth = 72;
        self.actionButton.frame = CGRectMake(0, 0, actionButtonWidth, 28);
        [self.actionButton setImage:nil forState:UIControlStateNormal];
    } else {
        self.actionButton.frame = CGRectMake(0, 0, actionButtonWidth, 28);
        [self.actionButton layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:2];
        [self.actionButton setImage:[UIImage imageNamed:[adModel actionButtonIcon]] forState:UIControlStateNormal];
    }
    self.actionButton.layer.cornerRadius = 4.0f;
    self.detailButton.hidden = YES;
    
    [self.userInfoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftMargin);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(userInfoHeight);
    }];
    
    [self.actionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.userInfoContainerView.mas_right).mas_offset(@8);
        make.right.mas_lessThanOrEqualTo(@(-leftMargin));
        make.centerY.mas_equalTo(self.userInfoContainerView.mas_centerY);
        make.width.mas_equalTo(actionButtonWidth);
        make.height.mas_equalTo(28);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftMargin);
        make.right.mas_equalTo(-leftMargin);
        make.top.mas_equalTo(self.userInfoContainerView.mas_bottom).mas_offset(@8);
        make.bottom.mas_equalTo(-20);
    }];
    [self.bottomContentView setNeedsUpdateConstraints];
    [self.bottomContentView setNeedsLayout];
}

- (void)style2ContentView:(TTAdShortVideoModel *)adModel {
    [self.actionButton setAttributedTitle:[self makeCommonAttributeText:[adModel actionButtonText]] forState:UIControlStateNormal];
    [self.actionButton setImage:nil forState:UIControlStateNormal];
    self.actionButton.layer.cornerRadius = 4.0f;
    self.detailButton.hidden = YES;
    
    [self.userInfoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(leftMargin);
        make.right.mas_lessThanOrEqualTo(-leftMargin);
        make.height.mas_equalTo(userInfoHeight);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftMargin);
        make.right.mas_equalTo(self.actionButton.mas_left).mas_offset(@-44);
        make.top.mas_equalTo(self.userInfoContainerView.mas_bottom).mas_offset(@8);
        make.bottom.mas_offset(@-20);
    }];
    
    [self.actionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(@(-leftMargin));
        make.bottom.mas_equalTo(self.titleLabel.mas_bottom);
        make.width.mas_equalTo(92);
        make.height.mas_equalTo(32);
    }];
    
    [self.bottomContentView setNeedsUpdateConstraints];
    [self.bottomContentView setNeedsLayout];
}

- (void)style3ContentView:(TTAdShortVideoModel *)adModel {
    [self.actionButton setTitle:[adModel actionButtonText] forState:UIControlStateNormal];
    [self.actionButton setImage:[UIImage imageNamed:[adModel actionButtonIcon]] forState:UIControlStateNormal];
    self.actionButton.layer.cornerRadius = 4.0f;
    
    if ([adModel.type isEqualToString:@"web"]) {
       [self.actionButton setImage:nil forState:UIControlStateNormal];
        self.detailButton.hidden = YES;
    } else {
        [self.actionButton layoutButtonWithEdgeInsetsStyle:TTButtonEdgeInsetsStyleImageLeft imageTitlespace:2];
        self.detailButton.hidden = NO;
    }
    
    [self.detailButton setAttributedTitle:[self makeCommonAttributeText:NSLocalizedString(@"查看详情", @"查看详情")]  forState:UIControlStateNormal];
    BOOL isVertical = [self.model.shortVideoOriginalData.originalDict[@"raw_data"][@"video"][@"vertical"] boolValue];
    if (isVertical) {
        UIColor *color = [UIColor colorWithWhite:0 alpha:0.6];
        [self.detailButton setBackgroundColor:color];
    } else {
        [self.detailButton setBackgroundColor:[UIColor colorWithHexString:@"0x1D1D1D"]];
    }

    self.detailButton.layer.cornerRadius = 4.0f;
    
    [self.userInfoContainerView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftMargin);
        make.right.mas_lessThanOrEqualTo(-leftMargin);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(userInfoHeight);
    }];
    
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftMargin);
        make.right.mas_lessThanOrEqualTo(-leftMargin);
        make.top.mas_equalTo(self.userInfoContainerView.mas_bottom).mas_offset(@8);
        make.bottom.mas_offset(@(-(20+32+12)));
    }];
    
    [self.detailButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(leftMargin);
        make.bottom.mas_equalTo(-20);
        make.height.mas_equalTo(32);
    }];
    
    [self.actionButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.detailButton.mas_right).mas_offset(@12);
        make.right.mas_equalTo(-leftMargin);
        make.bottom.mas_equalTo(-20);
        make.height.mas_equalTo(32);
        make.width.mas_equalTo(self.detailButton.mas_width);
    }];
    [self.bottomContentView setNeedsUpdateConstraints];
    [self.bottomContentView setNeedsLayout];
}

#pragma mark - Action

- (BOOL)alertIfNotValid
{
    if (self.model.isDelete) {
        [HTSVideoPlayToast show:@"视频已被删除"];
        return YES;
    }
    return !self.model;
}

- (void)digg
{
    CGFloat viewWidth = 300;
    NSString *animationPath = [[NSBundle mainBundle] pathForResource:@"like" ofType:@"json" inDirectory:@"HTSVideoPlay.bundle"];
    LOTAnimationView *animationView = [LOTAnimationView animationWithFilePath:animationPath];
    animationView.contentMode = UIViewContentModeScaleAspectFit;
    animationView.bounds = CGRectMake(0, 0, viewWidth, CGRectGetHeight(self.view.frame));
    animationView.center = self.view.center;
    [self.view addSubview:animationView];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [animationView playWithCompletion:^(BOOL animationFinished) {
        [animationView removeFromSuperview];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }];

    if ([self alertIfNotValid]) {
        return;
    }

    if (!self.model.userDigg) {
        //point:视频点赞
    }
}

- (void)cancelDigg
{
    if ([self alertIfNotValid]) {
        return;
    }

    if (self.model.userDigg) {
        [self doSafeCancelDigg];
    }
}

- (void)doSafeCancelDigg
{
    self.model.diggCount -= 1;
    self.model.userDigg = NO;
    [self.model save];

    @weakify(self);
    [AWEVideoDetailManager cancelDiggVideoItemWithID:self.model.groupID completion:^(BOOL succeed){
        @strongify(self);
        // 将点赞信息同步到列表页
        //TODO: 应该跟列表页用同样的 model，用数据做同步
        NSMutableDictionary *userInfo = @{}.mutableCopy;
        userInfo[@"ugc_video_id"] = self.model.itemID;
        userInfo[@"digg_count"] =  @(self.model.diggCount);
        userInfo[@"user_digg"] = @(self.model.userDigg);
        [[NSNotificationCenter defaultCenter] postNotificationName:@"TSVShortVideoDiggCountSyncNotification"
                                                            object:self
                                                          userInfo:userInfo];
        
    }];
}

- (void)_onInputButtonClicked:(UIButton *)sender
{
    if (!self.model) {
        return;
    }
    [self.viewModel clickWriteCommentButton];
}

- (void)_onCommentButtonClicked:(UIButton *)sender
{
    [self.viewModel clickCommentButton];
}

- (void)_onShareButtonClicked:(UIButton *)sender
{
    [self.viewModel clickShareButton];
}

#pragma mark - Actions

- (void)handleUserInfoClick:(id)sender {
    TTAdShortVideoModel *adModel = self.model.rawAd;
    if (adModel == nil) {
        return;
    }
    [adModel trackDrawWithTag:@"draw_ad" label:@"click" extra:nil];
    [adModel sendTrackURLs:adModel.click_track_url_list];
    [adModel trackDrawWithTag:@"draw_ad" label:@"click_source" extra:nil];
    [self pushDetail:adModel];
}

- (void)handleTitleClick:(id)sender {
    TTAdShortVideoModel *adModel = self.model.rawAd;
    if (adModel == nil) {
        return;
    }
    [adModel trackDrawWithTag:@"draw_ad" label:@"click" extra:nil];
    [adModel sendTrackURLs:adModel.click_track_url_list];
    [adModel trackDrawWithTag:@"draw_ad" label:@"click_title" extra:nil];
    [self pushDetail:adModel];
}

- (void)handleDetailClick:(id)sender {
    TTAdShortVideoModel *adModel = self.model.rawAd;
    if (adModel == nil) {
        return;
    }
    [adModel trackDrawWithTag:@"draw_ad" label:@"click" extra:nil];
    [adModel sendTrackURLs:adModel.click_track_url_list];
    [adModel trackDrawWithTag:@"draw_ad" label:@"ad_click" extra:nil];
    [self pushDetail:adModel];
}

- (void)handleSlideUpGesture:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateRecognized) {
        TTAdShortVideoModel *adModel = self.model.rawAd;
        [adModel trackDrawWithTag:@"draw_ad" label:@"click" extra:nil];
        [adModel sendTrackURLs:adModel.click_track_url_list];
        [adModel trackDrawWithTag:@"draw_ad" label:@"click_expansion" extra:nil];
        AWEVideoDetailScrollDirection direction = [AWEVideoDetailScrollConfig direction];
        if (direction == AWEVideoDetailScrollDirectionVertical) {
            [self pushDetail:adModel];
        } else {
            [self presentDetail:adModel];
        }
    }
}

- (void)handleActionClick:(id)sender {
    NSParameterAssert(self.model.rawAd != nil);
    TTAdShortVideoModel *adModel = self.model.rawAd;
    if (adModel == nil) {
        return;
    }
    NSParameterAssert(adModel.type != nil);
    
    [adModel trackDrawWithTag:@"draw_ad" label:@"click" extra:nil];
    [adModel sendTrackURLs:adModel.click_track_url_list];
    NSDictionary *labelMapper = @{
                                  @"web"        : @"ad_click",
                                  @"app"        : @"click_start",
                                  @"action"     : @"click_call",
                                  @"form"       : @"click_button",
                                  @"counsel"    : @"click_counsel",
                                  @"discount"   : @"click_discount"
                                  };
    if (adModel.type && labelMapper[adModel.type]) {
        [adModel trackDrawWithTag:@"draw_ad" label:labelMapper[adModel.type] extra:nil];
    }
    
    if ([adModel.type isEqualToString:@"web"] ||
        [adModel.type isEqualToString:@"app"]) {
        [self pushDetail:adModel];
    } else if ([adModel.type isEqualToString:@"action"]) {
        NSString *phoneNumber = adModel.phoneNumber;
        [TTAdCallManager callWithNumber:phoneNumber];
    } else if ([adModel.type isEqualToString:@"counsel"]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setValue:adModel.form_url forKey:@"url"];
        [params setValue:adModel.web_title forKey:@"title"];
        [params setValue:adModel.ad_id forKey:@"ad_id"];
        [params setValue:adModel.log_extra2 forKey:@"log_extra"];
        NSURL *schema = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:params];
        if ([[TTRoute sharedRoute] canOpenURL:schema]) {
            [TSVDetailRouteHelper openURLByPushViewController:schema];
        }
    } else if ([adModel.type isEqualToString:@"form"]) {
        [self showForm:adModel];
    } else {
        NSAssert(NO, @"不支持");
    }
}

- (void)presentDetail:(TTAdShortVideoModel *)adModel {
    NSParameterAssert(adModel != nil);
    if ([adModel.type isEqualToString:@"app"]) {
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        BOOL canOpenApp = [[adManagerInstance class] app_downloadAppWithModel:adModel];
        if (canOpenApp) {
        }
    } else {
        if (isEmptyString(adModel.web_url) && isEmptyString(adModel.open_url)) {
            return;
        }
        NSURL *openURL = [NSURL URLWithString:adModel.open_url];
        if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:adModel.log_extra2 forKey:@"log_extra"];
            [params setValue:adModel.ad_id forKey:@"ad_id"];
            [params setValue:@"close" forKey:@"back_button_icon"];
            [[TTRoute sharedRoute] openURLByPresentViewController:openURL userInfo:TTRouteUserInfoWithDict(params)];
        } else {
            NSMutableDictionary *applinkTrackDic = [NSMutableDictionary dictionary];
            [applinkTrackDic setValue:adModel.log_extra2 forKey:@"log_extra"];
            //尝试唤起外部app @by zengruihuan
            id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
            BOOL canOpenApp = [[adManagerInstance class] applink_dealWithWebURL:adModel.web_url openURL:adModel.open_url sourceTag:@"draw_ad" value:adModel.ad_id extraDic:applinkTrackDic];
            if (!canOpenApp) {
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setValue:adModel.web_url forKey:@"url"];
                [params setValue:adModel.web_title forKey:@"title"];
                [params setValue:adModel.ad_id forKey:@"ad_id"];
                [params setValue:adModel.log_extra2 forKey:@"log_extra"];
                [params setValue:@"close" forKey:@"back_button_icon"];
                NSURL *schema = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:params];
                if ([[TTRoute sharedRoute] canOpenURL:schema]) {
                    [[TTRoute sharedRoute] openURLByPresentViewController:schema userInfo:nil];
                }
            }
        }
    }
}

- (void)pushDetail:(TTAdShortVideoModel *)adModel {
    NSParameterAssert(adModel != nil);
    if ([adModel.type isEqualToString:@"app"]) {
        id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
        BOOL canOpenApp = [[adManagerInstance class] app_downloadAppWithModel:adModel];
        if (canOpenApp) {
        }
    } else {
        if (isEmptyString(adModel.web_url) && isEmptyString(adModel.open_url)) {
            return;
        }
        NSURL *openURL = [NSURL URLWithString:adModel.open_url];
        if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:adModel.log_extra2 forKey:@"log_extra"];
            [params setValue:adModel.ad_id forKey:@"ad_id"];
            [TSVDetailRouteHelper openURLByPushViewController:openURL userInfo:TTRouteUserInfoWithDict(params)];
        } else {
            NSMutableDictionary *applinkTrackDic = [NSMutableDictionary dictionary];
            [applinkTrackDic setValue:adModel.log_extra2 forKey:@"log_extra"];
            //尝试唤起外部app @by zengruihuan
            id<TTAdManagerProtocol> adManagerInstance = [[TTServiceCenter sharedInstance] getServiceByProtocol:@protocol(TTAdManagerProtocol)];
            BOOL canOpenApp = [[adManagerInstance class] applink_dealWithWebURL:adModel.web_url openURL:adModel.open_url sourceTag:@"draw_ad" value:adModel.ad_id extraDic:applinkTrackDic];
            if (!canOpenApp) {
                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                [params setValue:adModel.web_url forKey:@"url"];
                [params setValue:adModel.web_title forKey:@"title"];
                [params setValue:adModel.ad_id forKey:@"ad_id"];
                [params setValue:adModel.log_extra2 forKey:@"log_extra"];
                NSURL *schema = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:params];
                if ([[TTRoute sharedRoute] canOpenURL:schema]) {
                    [TSVDetailRouteHelper openURLByPushViewController:schema];
                }
            }
        }
    }
}

#pragma mark - action
- (void)showForm:(TTAdShortVideoModel *)adModel
{
    NSMutableDictionary *params = @{}.mutableCopy;
    [params setValue:adModel.ad_id forKey:@"ad_id"];
    [params setValue:adModel.log_extra2 forKey:@"log_extra"];
    [params setValue:adModel.form_url forKey:@"form_url"];
    [params setValue:adModel.form_width forKey:@"form_width"];
    [params setValue:adModel.form_height forKey:@"form_height"];
    [params setValue:adModel.use_size_validation forKey:@"use_size_validation"];
    void (^completeBlock)(NSUInteger) = ^void(NSUInteger state) {
        if (state == 2 || state == 1) {
            [adModel trackDrawWithTag:@"draw_ad" label:@"click_cancel" extra:nil];
        } else if (state == 3) {
            [adModel trackDrawWithTag:@"draw_ad" label:@"load_fail" extra:nil];
        }
    };
    [params setValue:completeBlock forKey:@"completeBlock"];
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"TTAd_action_form" object:adModel withParams:params complete:nil];
}

- (void)handleReportClick:(id)sender
{
  [self.viewModel clickMoreButton];
}

- (void)handleCloseClick:(id)sender
{
    [self.viewModel clickCloseButton];
}

- (void)_onPlayerDoubleTap:(UITapGestureRecognizer *)recognizer
{
    if (!self.model) {
        return;
    }
    NSMutableDictionary *paramters = @{}.mutableCopy;
    paramters[@"user_id"] = self.model.author.userID;
    paramters[@"position"] = @"double_like";
    [AWEVideoDetailTracker trackEvent:@"rt_like"
                                model:self.model
                      commonParameter:self.commonTrackingParameter
                       extraParameter:paramters];
    
    [self digg];
}

#pragma Gesture -

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer {
    AWEVideoDetailScrollDirection direction = [AWEVideoDetailScrollConfig direction];
    if (direction == AWEVideoDetailScrollDirectionVertical) {
        CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
        if (velocity.x < 0 && (fabs(velocity.x) > fabs(velocity.y))) {
            return YES;
        }
    } else {
        CGPoint velocity = [gestureRecognizer velocityInView:gestureRecognizer.view];
        if (velocity.y < 0 && (fabs(velocity.y) > fabs(velocity.x))) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - iPhone X 适配

- (void)updateViewFrameForSafeAreaIfNeeded
{
    if ([TTDeviceHelper isIPhoneXDevice]) {
        CGFloat safeAreaTop = self.viewSafeAreaInsets.top;
        
        self.topBarView.top = safeAreaTop;
        self.topBarGradientLayer.frame = CGRectMake(0, 0, self.view.bounds.size.width, 120);
        self.bottomGradientLayer.frame = CGRectMake(0, self.view.bounds.size.height - 220, CGRectGetWidth(self.view.bounds), 220);
    }
}

- (void)updateViewConstraintsForSafeAreaIfNeeded
{
     if ([TTDeviceHelper isIPhoneXDevice]) {
         CGFloat safeAreaTop = self.viewSafeAreaInsets.top;
         CGFloat playerViewHeight = ceil((self.view.superview.width) * 16 / 9);
         
         CGFloat bottomPadding = self.view.superview.height - safeAreaTop - playerViewHeight;
         // FIXME: 这个地方有时候 self.view.frame 是 CGRectZero，又因为这个 view 跟父 view 一样大，所以用了 superview 的 frame
         [self.bottomContentView mas_remakeConstraints:^(MASConstraintMaker *make) {
             make.left.equalTo(@0);
             make.right.equalTo(@0);
             make.bottom.equalTo(@(-bottomPadding));
         }];
     }
}

@end
