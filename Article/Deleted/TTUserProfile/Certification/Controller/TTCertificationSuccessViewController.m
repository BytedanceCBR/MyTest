//
//  TTCertificationSuccessViewController.m
//  Article
//
//  Created by wangdi on 2017/5/22.
//
//

#import "TTCertificationSuccessViewController.h"
#import "TTCertificationOperationView.h"
#import "TTAsyncCornerImageView+VerifyIcon.h"
#import "SSThemed.h"
#import "TTAsyncCornerImageView.h"
#import <TTAccountBusiness.h>
#import "TTThemedAlertController.h"
#import "TTCertificationConst.h"
@interface TTCertificationSuccessBottomView : SSThemedView

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTAsyncCornerImageView *iconView;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *occupationalLabel;
@property (nonatomic, copy) NSString *occupationalText;
@property (nonatomic, copy) NSString *authType;
@property (nonatomic, strong) TTAlphaThemedButton *modifyCertificationBtn;
@end

@implementation TTCertificationSuccessBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
    titleLabel.textColorThemeKey = kColorText1;
    [self addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    TTAsyncCornerImageView *iconView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:50], [TTDeviceUIUtils tt_newPadding:50]) allowCorner:YES];
    iconView.cornerRadius = [TTDeviceUIUtils tt_newPadding:50] * 0.5;
    iconView.placeholderName = @"default_avatar";
    [iconView tt_setImageWithURLString:[TTAccountManager avatarURLString]];
    [iconView setupVerifyViewForLength:50 adaptationSizeBlock:^CGSize(CGSize standardSize) {
        return [TTVerifyIconHelper tt_newSize:standardSize];
    }];
    [self addSubview:iconView];
    self.iconView = iconView;
    
    SSThemedLabel *nameLabel = [[SSThemedLabel alloc] init];
    nameLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newPadding:18]];
    nameLabel.textColorThemeKey = kColorText1;
    nameLabel.text = [TTAccountManager userName];
    [self addSubview:nameLabel];
    self.nameLabel = nameLabel;
    
    SSThemedLabel *occupationalLabel = [[SSThemedLabel alloc] init];
    occupationalLabel.numberOfLines = 0;
    occupationalLabel.textColorThemeKey = kColorText3;
    occupationalLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:16]];
    [self addSubview:occupationalLabel];
    self.occupationalLabel = occupationalLabel;
    
    TTAlphaThemedButton *modifyCertificationBtn = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
    modifyCertificationBtn.imageName = @"certification_modify";
    modifyCertificationBtn.tintColorThemeKey = kColorText1;
    modifyCertificationBtn.titleEdgeInsets = UIEdgeInsetsMake(0, [TTDeviceUIUtils tt_newPadding:12], 0, 0);
    [modifyCertificationBtn setTitle:@"修改认证" forState:UIControlStateNormal];
    modifyCertificationBtn.titleColorThemeKey = kColorText1;
    modifyCertificationBtn.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:14]];
    [self addSubview:modifyCertificationBtn];
    self.modifyCertificationBtn = modifyCertificationBtn;
    
}

- (void)setOccupationalText:(NSString *)occupationalText
{
    _occupationalText = [occupationalText copy];
    self.occupationalLabel.text = occupationalText;
}

- (void)setAuthType:(NSString *)authType
{
    if(isEmptyString(authType)) {
        authType = @"0";
    }
    _authType = authType;
    NSMutableDictionary *authDict = [NSMutableDictionary dictionary];
    [authDict setValue:authType forKey:@"auth_type"];
    [authDict setValue:@" " forKey:@"auth_info"];
    NSData *authData = [NSJSONSerialization dataWithJSONObject:authDict options:NSJSONWritingPrettyPrinted error:nil];
    NSString *authJson = [[NSString alloc] initWithData:authData encoding:NSUTF8StringEncoding];
    if([TTVerifyIconHelper isVerifiedOfVerifyInfo:authJson] && ![authType isEqualToString:KTTVerifyNoVVerifyType]) {
        [self.iconView showOrHideVerifyViewWithVerifyInfo:authJson decoratorInfo:nil sureQueryWithID:YES userID:nil];
    } else {
        [self.iconView showOrHideVerifyViewWithVerifyInfo:nil decoratorInfo:nil sureQueryWithID:YES userID:nil];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.left = [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.height = [TTDeviceUIUtils tt_newPadding:20];
    self.titleLabel.width = self.width - 2 * self.titleLabel.left;
    self.titleLabel.top = [TTDeviceUIUtils tt_newPadding:13.5];
    
    self.iconView.left = [TTDeviceUIUtils tt_newPadding:15];
    self.iconView.top = self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:15];
    self.nameLabel.left = self.iconView.right + [TTDeviceUIUtils tt_newPadding:12];
    self.nameLabel.top = self.iconView.top;
    self.nameLabel.width = self.width - self.nameLabel.left - [TTDeviceUIUtils tt_newPadding:15];
    self.nameLabel.height = [TTDeviceUIUtils tt_newPadding:25];
    
    if (!self.modifyCertificationBtn.hidden) {
        self.occupationalLabel.left = self.nameLabel.left;
        CGSize occupationalSize = [self.occupationalLabel.attributedText boundingRectWithSize:CGSizeMake(self.width - self.occupationalLabel.left - [TTDeviceUIUtils tt_newPadding:107], MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
        self.occupationalLabel.size = CGSizeMake(occupationalSize.width, 22);
        self.occupationalLabel.bottom = self.iconView.bottom;
        
        self.modifyCertificationBtn.height = [TTDeviceUIUtils tt_newPadding:20];
        CGSize modifyBtnTitleSize = [self.modifyCertificationBtn.currentTitle sizeWithAttributes:@{NSFontAttributeName : self.modifyCertificationBtn.titleLabel.font}];
        self.modifyCertificationBtn.width = self.modifyCertificationBtn.currentImage.size.width + self.modifyCertificationBtn.titleEdgeInsets.left + modifyBtnTitleSize.width;
        self.modifyCertificationBtn.centerY = self.occupationalLabel.centerY;
        self.modifyCertificationBtn.right = self.width - [TTDeviceUIUtils tt_newPadding:15];
    } else {
        self.occupationalLabel.left = self.nameLabel.left;
        self.occupationalLabel.size = CGSizeMake(self.nameLabel.width, [TTDeviceUIUtils tt_newPadding:22]);
        self.occupationalLabel.bottom = self.iconView.bottom;
    }
}

@end

@interface TTCertificationSuccessViewController ()<UIAlertViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) SSThemedView *topView;
@property (nonatomic, strong) SSThemedImageView *topIconView;
@property (nonatomic, strong) TTCertificationSuccessBottomView *bottomView;
@property (nonatomic, strong) SSThemedView *bottomBackgroundView;
@property (nonatomic, strong) SSThemedImageView *tipBackImageView;
@property (nonatomic, strong) SSThemedImageView *tipTriangleImageView;
@property (nonatomic, strong) SSThemedLabel *tipTitleLabel;
@property (nonatomic, strong) SSThemedImageView *tipIconImageView;
@property (nonatomic, strong) SSThemedTextView *tipContentTextView;
@property (nonatomic, strong) SSThemedLabel *topViewLabel;
@property (nonatomic, strong) TTCertificationOperationView *certificationGetVOperationView;
@property (nonatomic, strong) SSThemedButton *questionButton;
@property (nonatomic, strong) SSThemedScrollView *scrollView;
@end

@implementation TTCertificationSuccessViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"爱看认证";
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [self themeChanged:nil];
    [self setupSubview];
}

- (void)questionButtonClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCertificationPressQuestionsEntranceNotification object:nil];
}

- (void)themeChanged:(NSNotification*)notification {
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    if (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) {
        self.topIconView.alpha = 1;
        UIImage *image = [UIImage imageNamed:@"certification_tip_backimage_up"];
        _tipBackImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    }else {
        self.topIconView.alpha = 0.5f;
        UIImage *image = [UIImage imageNamed:@"certification_tip_backimage_up_night"];
        _tipBackImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
    }
    
    [self updateTipTextTextAttributes];
}

- (void)setupSubview
{
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.topView];
    [self.scrollView addSubview:self.bottomView];
    [self.scrollView addSubview:self.bottomBackgroundView];
    [self.bottomBackgroundView addSubview:self.tipBackImageView];
    [self.bottomBackgroundView addSubview:self.tipTriangleImageView];
    [self.tipBackImageView addSubview:self.tipIconImageView];
    [self.tipBackImageView addSubview:self.tipTitleLabel];
    [self.tipBackImageView addSubview:self.tipContentTextView];
    [self.scrollView addSubview:self.certificationGetVOperationView];
    [self.scrollView addSubview:self.questionButton];
    
    [self updateFrame];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self updateFrame];
}

- (void)updateFrame {
    if(self.certificationGetVOperationView.bottom + [TTDeviceUIUtils tt_newPadding:20] + self.questionButton.height + [TTDeviceUIUtils tt_newPadding:10] > self.scrollView.height) {
        self.questionButton.top = self.certificationGetVOperationView.bottom + [TTDeviceUIUtils tt_newPadding:20];
        self.scrollView.contentSize = CGSizeMake(0, self.questionButton.bottom + [TTDeviceUIUtils tt_newPadding:10]);
    } else {
        self.scrollView.contentSize = CGSizeMake(0, self.scrollView.height);
        self.questionButton.bottom = self.scrollView.height - [TTDeviceUIUtils tt_newPadding:10];
    }
    self.bottomBackgroundView.height = self.scrollView.contentSize.height;
}

- (void)setIsCertificationV:(BOOL)isCertificationV {
    if (_isCertificationV != isCertificationV) {
        _isCertificationV = isCertificationV;
        self.topIconView.imageName = self.isCertificationV ? @"v_Information_passing" : @"Information_passing";
    }
}

- (SSThemedView *)topView
{
    if(!_topView) {
        CGFloat top = 0;
        _topView = [[SSThemedView alloc] init];
        _topView.backgroundColorThemeKey = kColorBackground4;
        _topView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _topView.frame = CGRectMake(0, top, self.view.width, [TTDeviceUIUtils tt_newPadding:169]);
        SSThemedImageView *topIconView = [[SSThemedImageView alloc] init];
        topIconView.imageName = self.isCertificationV ? @"v_Information_passing" : @"Information_passing";
        [_topView addSubview:topIconView];
        if (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) {
            topIconView.alpha = 1;
        }else {
            topIconView.alpha = 0.5f;
        }
        topIconView.width = [TTDeviceUIUtils tt_newPadding:179];
        topIconView.height = [TTDeviceUIUtils tt_newPadding:77];
        topIconView.centerX = self.view.width * 0.5;
        topIconView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        topIconView.top = [TTDeviceUIUtils tt_newPadding:37];
        self.topIconView = topIconView;
        
        SSThemedLabel *topViewLabel = [[SSThemedLabel alloc] init];
        topViewLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        topViewLabel.textColorThemeKey = kColorText1;
        topViewLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
        topViewLabel.textAlignment = NSTextAlignmentCenter;
        topViewLabel.left = 0;
        topViewLabel.top = topIconView.bottom + [TTDeviceUIUtils tt_newPadding:10];
        topViewLabel.width = self.view.width;
        topViewLabel.height = [TTDeviceUIUtils tt_newPadding:22.5];
        self.topViewLabel = topViewLabel;
        [_topView addSubview:topViewLabel];
    }
    return _topView;
}

- (SSThemedView *)bottomBackgroundView {
    if (!_bottomBackgroundView) {
        _bottomBackgroundView = [[SSThemedView alloc] init];
        _bottomBackgroundView.backgroundColorThemeKey = kColorBackground4;
        _bottomBackgroundView.top = self.bottomView.bottom;
        _bottomBackgroundView.width = self.view.width;
        _bottomBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _bottomBackgroundView;
}

- (SSThemedScrollView *)scrollView
{
    if(!_scrollView) {
        _scrollView = [[SSThemedScrollView alloc] init];
        _scrollView.backgroundColorThemeKey = kColorBackground3;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.left = 0;
        _scrollView.delegate = self;
        _scrollView.top = TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height;
        _scrollView.width = self.view.width;
        _scrollView.height = self.view.height - _scrollView.top - [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
//        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
//        [_scrollView addGestureRecognizer:tap];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _scrollView;
}

- (TTCertificationSuccessBottomView *)bottomView
{
    if(!_bottomView) {
        _bottomView = [[TTCertificationSuccessBottomView alloc] init];
        _bottomView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _bottomView.left = 0;
        _bottomView.top = self.topView.bottom + [TTDeviceUIUtils tt_newPadding:6];
        _bottomView.width = self.view.width;
        _bottomView.height = [TTDeviceUIUtils tt_newPadding:118];
        [_bottomView.modifyCertificationBtn addTarget:self action:@selector(modifyOperationViewClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _bottomView;
}

- (UIImage *)resizableImageWithCapInsets:(UIEdgeInsets)capInsets resizingMode:(UIImageResizingMode)resizingMode {
    return nil;
}

- (SSThemedImageView *)tipBackImageView {
    if (!_tipBackImageView) {
        _tipBackImageView = [[SSThemedImageView alloc] init];
        UIImage *image;
        if (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) {
            image = [UIImage imageNamed:@"certification_tip_backimage_up"];
        } else {
            image = [UIImage imageNamed:@"certification_tip_backimage_up_night"];
        }
        _tipBackImageView.image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 5)];
        _tipBackImageView.top = [TTDeviceUIUtils tt_newPadding:10];
        _tipBackImageView.left = [TTDeviceUIUtils tt_newPadding:15];
        _tipBackImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _tipBackImageView.width = self.view.width - 2 * [TTDeviceUIUtils tt_newPadding:15];
        _tipBackImageView.height = [TTDeviceUIUtils tt_newPadding:98];
        _tipBackImageView.hidden = YES;
    }
    return _tipBackImageView;
}

- (SSThemedLabel *)tipTitleLabel {
    if (!_tipTitleLabel) {
        _tipTitleLabel = [[SSThemedLabel alloc] init];
        _tipTitleLabel.textColorThemeKey = kColorText1;
        _tipTitleLabel.left = self.tipIconImageView.right + [TTDeviceUIUtils tt_newPadding:18];
        _tipTitleLabel.top = [TTDeviceUIUtils tt_newPadding:10];
        _tipTitleLabel.backgroundColor = [UIColor clearColor];
        _tipTitleLabel.width = self.tipBackImageView.width - [TTDeviceUIUtils tt_newPadding:121];
        _tipTitleLabel.height = [TTDeviceUIUtils tt_newPadding:20];
        _tipTitleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        _tipTitleLabel.text = @"提示：";
    }
    return _tipTitleLabel;
}

- (SSThemedImageView *)tipTriangleImageView {
    if (!_tipTriangleImageView) {
        _tipTriangleImageView = [[SSThemedImageView alloc] init];
        _tipTriangleImageView.imageName = @"certification_tip_backimage_down";
        _tipTriangleImageView.height = [TTDeviceUIUtils tt_newPadding:10];
        _tipTriangleImageView.width = [TTDeviceUIUtils tt_newPadding:19];
        _tipTriangleImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        _tipTriangleImageView.top = self.tipBackImageView.bottom - [TTDeviceUIUtils tt_newPadding:2];
        _tipTriangleImageView.centerX = self.view.width / 2;
        _tipTriangleImageView.hidden = YES;
    }
    return _tipTriangleImageView;
}

- (SSThemedImageView *)tipIconImageView {
    if (!_tipIconImageView) {
        _tipIconImageView = [[SSThemedImageView alloc] init];
        _tipIconImageView.height = [TTDeviceUIUtils tt_newPadding:31];
        _tipIconImageView.width = [TTDeviceUIUtils tt_newPadding:24];
        _tipIconImageView.left = [TTDeviceUIUtils tt_newPadding:20];
        _tipIconImageView.top = [TTDeviceUIUtils tt_newPadding:33];
        _tipIconImageView.imageName = @"authentication_prompt_icon";
    }
    return _tipIconImageView;
}

- (SSThemedTextView *)tipContentTextView {
    if (!_tipContentTextView) {
        _tipContentTextView = [[SSThemedTextView alloc] init];
        _tipContentTextView.backgroundColor = [UIColor clearColor];
        _tipContentTextView.textContainerInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tipContentTextView.textContainer.lineFragmentPadding = 0;
        _tipContentTextView.left = self.tipTitleLabel.left;
        _tipContentTextView.width = self.tipBackImageView.width - [TTDeviceUIUtils tt_newPadding:80];
        _tipContentTextView.top = self.tipTitleLabel.bottom + [TTDeviceUIUtils tt_newPadding:4];
        _tipContentTextView.height = self.tipBackImageView.height - self.tipTitleLabel.bottom - [TTDeviceUIUtils tt_newPadding:14];
        
    }
    return _tipContentTextView;
}

- (SSThemedButton *)questionButton {
    if (!_questionButton) {
        _questionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _questionButton.width = [TTDeviceUIUtils tt_newPadding:70];
        _questionButton.height = [TTDeviceUIUtils tt_newPadding:20];
        _questionButton.centerX = self.view.centerX;
        _questionButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _questionButton.bottom = self.scrollView.bottom - [TTDeviceUIUtils tt_newPadding:10];
        _questionButton.hitTestEdgeInsets = UIEdgeInsetsMake(-8, -8, -8, -8);
        [_questionButton setTitle:@"常见问题" forState:UIControlStateNormal];
        _questionButton.titleColorThemeKey = kColorText6;
        _questionButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        [_questionButton addTarget:self action:@selector(questionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _questionButton;
}

- (TTCertificationOperationView *)certificationGetVOperationView
{
    if(!_certificationGetVOperationView) {
        _certificationGetVOperationView = [[TTCertificationOperationView alloc] init];
        _certificationGetVOperationView.style = TTCertificationOperationViewStyleRed;
        _certificationGetVOperationView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_certificationGetVOperationView setTitle:@"申请加V" forState:UIControlStateNormal];
        _certificationGetVOperationView.left = [TTDeviceUIUtils tt_newPadding:15];
        _certificationGetVOperationView.width = self.view.width - 2 * _certificationGetVOperationView.left;
        _certificationGetVOperationView.height = [TTDeviceUIUtils tt_newPadding:44];
        _certificationGetVOperationView.top = self.bottomView.bottom + self.tipBackImageView.height + self.tipTriangleImageView.height + [TTDeviceUIUtils tt_newPadding:18];
        [_certificationGetVOperationView addTarget:self action:@selector(certificationGetViewClick) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _certificationGetVOperationView;
}

- (void)setOccupationalText:(NSString *)occupationalText
{
    _occupationalText = [occupationalText copy];
    self.bottomView.occupationalText = occupationalText;
}

- (void)setCertificationText:(NSString *)certificationText
{
    _certificationText = [certificationText copy];
    self.topViewLabel.text = certificationText;
}

- (void)setCertificationResultText:(NSString *)certificationResultText
{
    _certificationResultText = [certificationResultText copy];
    self.bottomView.titleLabel.text = _certificationResultText;
}

- (void)setCertificationTipText:(NSString *)certificationTipText {
    _certificationTipText = [certificationTipText copy];
    if (!isEmptyString(_certificationTipText)) {
        [self updateTipTextTextAttributes];
        self.tipBackImageView.hidden = NO;
        self.tipTriangleImageView.hidden = NO;
        self.certificationGetVOperationView.style = TTCertificationOperationViewStyleLightRed;
        self.certificationGetVOperationView.enabled = NO;
    } else {
        self.tipContentTextView.text = _certificationTipText;
        self.tipBackImageView.hidden = YES;
        self.tipTriangleImageView.hidden = YES;
        self.certificationGetVOperationView.style = TTCertificationOperationViewStyleRed;
        self.certificationGetVOperationView.enabled = YES;
    }
}

- (void)updateTipTextTextAttributes {
    if (isEmptyString(_certificationText)) {
        return;
    }
    
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.lineSpacing = 4;// 字体的行间距
    NSDictionary *attributes = @{
                                 NSForegroundColorAttributeName:[UIColor tt_themedColorForKey:kColorText1],
                                 NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]],
                                 NSParagraphStyleAttributeName:paragraphStyle
                                 };
    self.tipContentTextView.attributedText = [[NSAttributedString alloc] initWithString:_certificationTipText attributes:attributes];
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) {
        CGSize contentSize = self.tipContentTextView.contentSize;
        self.tipContentTextView.top = self.tipTitleLabel.bottom + [TTDeviceUIUtils tt_newPadding:4];
        self.tipContentTextView.height = contentSize.height;
    } else {
        self.tipContentTextView.top = self.tipTitleLabel.bottom + [TTDeviceUIUtils tt_newPadding:4];
        self.tipContentTextView.height = self.tipBackImageView.height - self.tipTitleLabel.bottom - [TTDeviceUIUtils tt_newPadding:14];
    }
}

- (void)setAuthType:(NSString *)authType
{
    if(isEmptyString(authType)) {
        authType = @"0";
    }
    _authType = authType;
    self.bottomView.authType = authType;
    if (![authType isEqualToString:KTTVerifyNoVVerifyType]) {
        [self.certificationGetVOperationView setTitle:@"修改认证" forState:UIControlStateNormal];
        self.bottomView.modifyCertificationBtn.hidden = YES;
        self.bottomView.occupationalLabel.size = CGSizeMake(self.bottomView.nameLabel.width, [TTDeviceUIUtils tt_newPadding:22]);
    } else {
        [self.certificationGetVOperationView setTitle:@"申请加V" forState:UIControlStateNormal];
    }
}

- (void)modifyOperationViewClick
{
    [TTTrackerWrapper eventV3:@"certificate_modify" params:nil];
    if(self.operationViewClick) {
        self.operationViewClick(YES);
    }
}

- (void)certificationGetViewClick
{
    if ([self.authType isEqualToString:KTTVerifyNoVVerifyType]) {
        [TTTrackerWrapper eventV3:@"certificate_v_apply" params:nil];
        if(self.certificationGetVClick) {
            self.certificationGetVClick();
        }
    } else {
        [TTTrackerWrapper eventV3:@"certificate_modify" params:nil];
        if(self.operationViewClick) {
            self.operationViewClick(YES);
        }
    }
}

@end
