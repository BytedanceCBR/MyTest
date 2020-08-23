//
//  FHDetailNavBar.m
//  Pods
//
//  Created by 张静 on 2019/2/12.
//

#import "FHDetailNavBar.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "TTDeviceHelper.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import <FHHouseBase/UIImage+FIconFont.h>
#import <TTRoute.h>

@interface FHDetailNavBar ()

@property(nonatomic , strong) UIView *bgView;
@property(nonatomic , strong) UIButton *backBtn;
@property(nonatomic , strong) UIButton *collectBtn;
@property(nonatomic , strong) UIButton *shareBtn;
@property(nonatomic , strong) UIButton *messageBtn;
//@property(nonatomic , strong) UIImageView *messageDot;
@property(nonatomic, strong)UILabel *messageDotNumber;
@property(nonatomic , strong) UIView *gradientView;
@property(nonatomic , strong) UIView *bottomLine;
@property (nonatomic, strong) UIView *vouchView;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property(nonatomic , assign) CGFloat subAlpha;
@property(nonatomic , assign) NSInteger followStatus;

@property(nonatomic , strong) UIImage *collectBlackImage;
@property(nonatomic , strong) UIImage *collectWhiteImage;
@property(nonatomic , strong) UIImage *collectYellowImage;
@property(nonatomic , strong) UIImage *collectWhiteSolidImage;
@property(nonatomic , strong) UIImage *backBlackImage;
@property(nonatomic , strong) UIImage *backWhiteImage;
@property(nonatomic , strong) UIImage *shareBlackImage;
@property(nonatomic , strong) UIImage *shareWhiteImage;
@property(nonatomic , strong) UIImage *messageBlackImage;
@property(nonatomic , strong) UIImage *messageWhiteImage;

@end

@implementation FHDetailNavBar

- (instancetype)initWithType:(FHDetailNavBarType)type
{
    CGRect screenBounds = [UIScreen mainScreen].bounds;
    CGFloat navBarHeight = [TTDeviceHelper isIPhoneXDevice] ? 44 : 20;
    CGRect frame = CGRectMake(0, 0, screenBounds.size.width, navBarHeight + 44);
    _type = type;
    self = [self initWithFrame:frame];
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isForVouch = NO;
        [self setupUI];
    }
    return self;
}

- (void)setType:(FHDetailNavBarType)type
{
    _type = type;
    if (_type == FHDetailNavBarTypeDefault) {
        [_shareBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(40);
            make.bottom.mas_equalTo(self);
        }];
        [_collectBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.shareBtn.mas_left).mas_offset(-14);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(40);
            make.bottom.mas_equalTo(self);
        }];
        _shareBtn.hidden = NO;
    }else {
        [_collectBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(40);
            make.bottom.mas_equalTo(self);
        }];
        _shareBtn.hidden = YES;
    }
}

- (void)removeBottomLine
{
    _bottomLine.hidden = YES;
    [_bottomLine removeFromSuperview];
}

- (void)configureVouchStyle {
    self.isForVouch = YES;
    if (!_gradientLayer) {
        UIColor *leftColor = [UIColor colorWithHexString:@"#ff9629"];
        UIColor *rightColor = [UIColor themeOrange1];
        NSArray *gradientColors = [NSArray arrayWithObjects:(id)(leftColor.CGColor), (id)(rightColor.CGColor), nil];
        CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
        gradientLayer.colors = gradientColors;
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        
        gradientLayer.frame = self.bounds;
        //        gradientlayer.cornerRadius = 4.0;
        [self.bgView.layer insertSublayer:gradientLayer atIndex:0];
        _gradientLayer = gradientLayer;
    }
    if (!_vouchView) {
        self.vouchView = [[UIView alloc] init];
        [self.bgView addSubview:self.vouchView];
        
        UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToJump)];
        [self.vouchView addGestureRecognizer:singleTap];
        
        UIImageView *vouchIconImageView = [[UIImageView alloc] init];
        vouchIconImageView.image = [UIImage imageNamed:@"detail_header_top_icon"];
        [self.vouchView addSubview:vouchIconImageView];
        [vouchIconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(24, 24));
            make.left.mas_equalTo(0);
            make.top.bottom.mas_equalTo(0);
        }];
        
        UILabel *vouchLabel = [[UILabel alloc] init];
        vouchLabel.text = @"企业担保";
        vouchLabel.textColor = [UIColor themeWhite];
        vouchLabel.font = [UIFont themeFontSemibold:16];
        [self.vouchView addSubview:vouchLabel];
        [vouchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(vouchIconImageView.mas_right).mas_offset(4);
            make.top.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        [self.vouchView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.mas_equalTo(self.backBtn);
            make.left.mas_equalTo(self.backBtn.mas_right).mas_offset(15);
        }];
    }
    self.vouchView.hidden = YES;
    self.gradientLayer.hidden = YES;
}

- (void)setupUI
{
    _bgView = [[UIView alloc]initWithFrame:self.bounds];
    _bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:0];
    [self addSubview:_bgView];
    
    _bottomLine = [[UIView alloc]init];
    _bottomLine.backgroundColor = [UIColor themeGray6];
    [_bgView addSubview:_bottomLine];
    _bottomLine.hidden = YES;
    
    _gradientView = [[UIView alloc]initWithFrame:self.bounds];
    [self addSubview:_gradientView];
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    gradientLayer.frame = _gradientView.bounds;
    gradientLayer.colors = @[(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0.3].CGColor,(__bridge id)[UIColor colorWithRed:0 green:0 blue:0 alpha:0].CGColor];
    gradientLayer.startPoint = CGPointMake(0, 0);
    gradientLayer.endPoint = CGPointMake(0, 1);
    [_gradientView.layer addSublayer:gradientLayer];
    
    _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_backBtn setImage:self.backWhiteImage forState:UIControlStateNormal];
    [_backBtn setImage:self.backWhiteImage forState:UIControlStateHighlighted];
    [_backBtn addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_backBtn];
    
    _collectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_collectBtn setImage:self.collectWhiteImage forState:UIControlStateNormal];
    [_collectBtn setImage:self.collectWhiteImage forState:UIControlStateHighlighted];
    //    [_collectBtn addTarget:self action:@selector(collectAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_collectBtn];
    @weakify(self);
    [[[[_collectBtn rac_signalForControlEvents:UIControlEventTouchUpInside]takeUntil:self.rac_willDeallocSignal] throttle:0.3]subscribeNext:^(__kindof UIControl * _Nullable x) {
        @strongify(self);
        [self collectAction:x];
    }];
    
    UIImage *img;
    _messageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    img =  ICON_FONT_IMG(24, @"\U0000e691", [UIColor whiteColor]);//detail_message_white
    [_messageBtn setImage:img forState:UIControlStateNormal];
    [_messageBtn setImage:img forState:UIControlStateHighlighted];
    [_messageBtn addTarget:self action:@selector(messageAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_messageBtn];
    
    _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    img = ICON_FONT_IMG(24, @"\U0000e692", [UIColor whiteColor]);//detail_share_white
    [_shareBtn setImage:img forState:UIControlStateNormal];
    [_shareBtn setImage:img forState:UIControlStateHighlighted];
    [_shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_shareBtn];
    
    
    _messageDotNumber = [[UILabel alloc]init];
    _messageDotNumber.font = [UIFont themeFontSemibold:10];
    _messageDotNumber.backgroundColor = [UIColor themeOrange1];
    _messageDotNumber.textColor = [UIColor whiteColor];
    _messageDotNumber.textAlignment = NSTextAlignmentCenter;
    _messageDotNumber.layer.cornerRadius = 8;
    _messageDotNumber.layer.masksToBounds = YES;
    _messageDotNumber.hidden = YES;
    //    _messageDot = [[UIImageView alloc] init];
    //    _messageDot.hidden = YES;
    //    [_messageDot setImage:[UIImage imageNamed:@"detail_message_dot"]];
    [self addSubview:_messageDotNumber];
    
    [_backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.height.mas_equalTo(44);
        make.width.mas_equalTo(40);
        make.bottom.mas_equalTo(self);
    }];
    
    if (_type == FHDetailNavBarTypeDefault) {
        [self addSubview:self.shareBtn];
        [_shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(40);
            make.bottom.mas_equalTo(self);
        }];
        [_messageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.shareBtn.mas_left).mas_offset(-12);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(40);
            make.bottom.mas_equalTo(self);
        }];
        [_collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.messageBtn.mas_left).mas_offset(-12);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(40);
            make.bottom.mas_equalTo(self);
        }];
        [_messageDotNumber mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.messageBtn.mas_centerX).offset(2);
            make.height.mas_equalTo(16);
            make.width.mas_equalTo(16);
            make.top.mas_equalTo(self.messageBtn).offset(6);
        }];
        //        [_messageDot mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.right.mas_equalTo(self.messageBtn).offset(-5);
        //            make.height.mas_equalTo(10);
        //            make.width.mas_equalTo(10);
        //            make.top.mas_equalTo(self.messageBtn).offset(10);
        //        }];
    }else {
        [_messageBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(-12);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(40);
            make.bottom.mas_equalTo(self);
        }];
        [_collectBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self.messageBtn.mas_left).mas_offset(-12);
            make.height.mas_equalTo(44);
            make.width.mas_equalTo(40);
            make.bottom.mas_equalTo(self);
        }];
        [_messageDotNumber mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.messageBtn.mas_centerX).offset(2);
            make.height.mas_equalTo(16);
            make.width.mas_equalTo(16);
            make.top.mas_equalTo(self.messageBtn).offset(6);
        }];
        //        [_messageDot mas_makeConstraints:^(MASConstraintMaker *make) {
        //            make.right.mas_equalTo(self.messageBtn).offset(-5);
        //            make.height.mas_equalTo(10);
        //            make.width.mas_equalTo(10);
        //            make.top.mas_equalTo(self.messageBtn).offset(10);
        //        }];
    }
    
    [_bottomLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.mas_equalTo(0);
        make.height.mas_equalTo(0.5);
    }];
}

- (void)refreshAlpha:(CGFloat)alpha
{
    _bgView.backgroundColor = [UIColor colorWithWhite:1 alpha:alpha];
    _subAlpha = alpha;
    if (alpha > 0) {
        _gradientView.alpha = 0;
        if (self.isForVouch) {
            [_backBtn setImage:self.backWhiteImage forState:UIControlStateNormal];
            [_backBtn setImage:self.backWhiteImage forState:UIControlStateHighlighted];
            [_shareBtn setImage:self.shareWhiteImage forState:UIControlStateNormal];
            [_shareBtn setImage:self.shareWhiteImage forState:UIControlStateHighlighted];
            [_messageBtn setImage:self.messageWhiteImage forState:UIControlStateNormal];
            [_messageBtn setImage:self.messageWhiteImage forState:UIControlStateHighlighted];
            UIImage *image = self.followStatus ? self.collectWhiteSolidImage : self.collectWhiteImage;
            [_collectBtn setImage:image forState:UIControlStateNormal];
            [_collectBtn setImage:image forState:UIControlStateHighlighted];
            
            self.vouchView.hidden = NO;
            self.gradientLayer.hidden = NO;
            self.messageDotNumber.backgroundColor = [UIColor whiteColor];
            self.messageDotNumber.textColor = [UIColor themeOrange1];

        } else {
            [_backBtn setImage:self.backBlackImage forState:UIControlStateNormal];
            [_backBtn setImage:self.backBlackImage forState:UIControlStateHighlighted];
            UIImage *image = self.followStatus ? self.collectYellowImage : self.collectBlackImage;
            [_collectBtn setImage:image forState:UIControlStateNormal];
            [_collectBtn setImage:image forState:UIControlStateHighlighted];
            [_shareBtn setImage:self.shareBlackImage forState:UIControlStateNormal];
            [_shareBtn setImage:self.shareBlackImage forState:UIControlStateHighlighted];
            [_messageBtn setImage:self.messageBlackImage forState:UIControlStateNormal];
            [_messageBtn setImage:self.messageBlackImage forState:UIControlStateHighlighted];
            self.messageDotNumber.backgroundColor = [UIColor themeOrange1];
            self.messageDotNumber.textColor = [UIColor whiteColor];
        }
        
    }else {
        _gradientView.alpha = 1;
        UIImage *image = self.followStatus ? self.collectYellowImage : self.collectWhiteImage;
        [_backBtn setImage:self.backWhiteImage forState:UIControlStateNormal];
        [_backBtn setImage:self.backWhiteImage forState:UIControlStateHighlighted];
        [_collectBtn setImage:image forState:UIControlStateNormal];
        [_collectBtn setImage:image forState:UIControlStateHighlighted];
        [_shareBtn setImage:self.shareWhiteImage forState:UIControlStateNormal];
        [_shareBtn setImage:self.shareWhiteImage forState:UIControlStateHighlighted];
        [_messageBtn setImage:self.messageWhiteImage forState:UIControlStateNormal];
        [_messageBtn setImage:self.messageWhiteImage forState:UIControlStateHighlighted];
        self.messageDotNumber.backgroundColor = [UIColor themeOrange1];
        self.messageDotNumber.textColor = [UIColor whiteColor];
        if (self.isForVouch) {
            self.vouchView.hidden = YES;
            self.gradientLayer.hidden = YES;
        }
    }
    if (alpha >= 1) {
        if (self.isForVouch) {
            _bottomLine.hidden = YES;
        } else {
            _bottomLine.hidden = NO;
        }
    }else {
        _bottomLine.hidden = YES;
    }
}


- (void)setFollowStatus:(NSInteger)followStatus
{
    _followStatus = followStatus;
    if (self.subAlpha > 0) {
        UIImage *image = self.collectBlackImage;
        image = followStatus != 0 ? self.collectYellowImage : image;
        if (self.isForVouch) {
            image = followStatus != 0 ? self.collectWhiteSolidImage : self.collectWhiteImage;
        }
        [_collectBtn setImage:image forState:UIControlStateNormal];
        [_collectBtn setImage:image forState:UIControlStateHighlighted];
    }else {
        UIImage *image = self.collectWhiteImage;
        image = followStatus != 0 ? self.collectYellowImage : image;
        [_collectBtn setImage:image forState:UIControlStateNormal];
        [_collectBtn setImage:image forState:UIControlStateHighlighted];
    }
}

- (void)showRightItems:(BOOL)showItem
{
    self.shareBtn.hidden = !showItem;
    self.collectBtn.hidden = !showItem;
    self.messageBtn.hidden = !showItem;
    //    if (!showItem) {
    //        self.messageDot.hidden = !showItem;
    //    }
}

- (void)backAction:(UIButton *)sender
{
    if (self.backActionBlock) {
        self.backActionBlock();
    }
}

- (void)collectAction:(UIButton *)sender
{
    if (self.collectActionBlock) {
        self.collectActionBlock(self.followStatus);
    }
}

- (void)messageAction:(UIButton *)sender
{
    if (self.messageActionBlock) {
        self.messageActionBlock();
    }
}

- (void)shareAction:(UIButton *)sender
{
    if (self.shareActionBlock) {
        self.shareActionBlock();
    }
}


- (void)displayMessageDot:(NSInteger)dotNumber{
    if (dotNumber >0) {
        //        self.messageDotNumber.hidden = YES;
        self.messageDotNumber.text = dotNumber >99?@"99+":[NSString stringWithFormat:@"%ld",dotNumber];
        if (dotNumber>9) {
            [_messageDotNumber mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(dotNumber>99?29:22);
            }];
        }
    }else {
        //        self.messageDotNumber.hidden = YES;
    }
}

- (UIButton *)shareBtn
{
    if (!_shareBtn) {
        _shareBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_shareBtn setImage:self.shareWhiteImage forState:UIControlStateNormal];
        [_shareBtn setImage:self.shareWhiteImage forState:UIControlStateHighlighted];
        [_shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}

- (UIImage *)collectBlackImage
{
    if (!_collectBlackImage) {
        _collectBlackImage =  ICON_FONT_IMG(24, @"\U0000e696", nil); //@"detail_collect_black"
    }
    return _collectBlackImage;
}
- (UIImage *)collectWhiteImage
{
    if (!_collectWhiteImage) {
        _collectWhiteImage =  ICON_FONT_IMG(24, @"\U0000e696", [UIColor whiteColor]);//@"detail_collect_white"
    }
    return _collectWhiteImage;
}
- (UIImage *)collectYellowImage
{
    if (!_collectYellowImage) {
        _collectYellowImage = ICON_FONT_IMG(24, @"\U0000e6b2", [UIColor colorWithHexStr:@"#ff9629"]);// @"detail_collect_yellow"
    }
    return _collectYellowImage;
}

- (UIImage *)collectWhiteSolidImage {
    if (!_collectWhiteSolidImage) {
        _collectWhiteSolidImage = ICON_FONT_IMG(24, @"\U0000e6b2", [UIColor whiteColor]);
    }
    return _collectWhiteSolidImage;
}

- (UIImage *)backBlackImage
{
    if (!_backBlackImage) {
        _backBlackImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor themeGray1]); // detail_back_black
    }
    return _backBlackImage;
}
- (UIImage *)backWhiteImage
{
    if (!_backWhiteImage) {
        _backWhiteImage = ICON_FONT_IMG(24, @"\U0000e68a", [UIColor whiteColor]); //detail_back_white
    }
    return _backWhiteImage;
}
- (UIImage *)shareBlackImage
{
    if (!_shareBlackImage) {
        _shareBlackImage = ICON_FONT_IMG(24, @"\U0000e692", nil); // detail_share_black
    }
    return _shareBlackImage;
}
- (UIImage *)shareWhiteImage
{
    if (!_shareWhiteImage) {
        _shareWhiteImage = ICON_FONT_IMG(24, @"\U0000e692", [UIColor whiteColor]); //detail_share_white
    }
    return _shareWhiteImage;
}
- (UIImage *)messageBlackImage
{
    if (!_messageBlackImage) {
        //e691
        _messageBlackImage = ICON_FONT_IMG(24, @"\U0000e691", nil); //detail_message_black
    }
    return _messageBlackImage;
}
- (UIImage *)messageWhiteImage
{
    if (!_messageWhiteImage) {
        _messageWhiteImage =  ICON_FONT_IMG(24, @"\U0000e691", [UIColor whiteColor]); //detail_message_white
    }
    return _messageWhiteImage;
}

- (void)showMessageNumber {
    if (self.messageDotNumber.text.length>0) {
        self.messageDotNumber.hidden = NO;
    }
}

- (void)goToJump {
    NSString *url = @"sslocal://enterprise_guarantee?channel=lynx_enterprise_guarantee";
    if(self.pageType.length > 0){
        url = [url stringByAppendingFormat:@"&enter_from=%@",self.pageType];
    }
    if(url.length > 0){
        NSURL *openUrl = [NSURL URLWithString:url];
        [[TTRoute sharedRoute] openURLByPushViewController:openUrl userInfo:nil];
    }
}

@end
