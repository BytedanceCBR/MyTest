//
//  TTProfileHeaderVisitorView.m
//  Article
//
//  Created by liuzuopeng on 8/8/16.
//
//

#import "TTProfileHeaderVisitorView.h"
#import "TTProfileThemeConstants.h"
#import "SSMyUserModel.h"
#import "TTAlphaThemedButton.h"
#import <TTAccountBusiness.h>
#import "TTTabBarProvider.h"
#import "TTImageView.h"
#import "TTCountInfoResponseModel.h"
#import "SSActionManager.h"

@implementation TTProfileHeaderVisitorModel
+ (instancetype)visitorModelWithText:(NSString *)text number:(long long)number type:(NSUInteger)type {
    TTProfileHeaderVisitorModel *vModel = [TTProfileHeaderVisitorModel new];
    if (vModel) {
        vModel.visitorType = type;
        vModel.text   = text;
        vModel.number = number;
    }
    return vModel;
}

+ (NSArray<TTProfileHeaderVisitorModel *> *)modelsWithMoments:(long long)moments followings:(long long)followings followers:(long long)followers visitors:(long long)visitors {
    TTProfileHeaderVisitorModel *momentModel = [TTProfileHeaderVisitorModel visitorModelWithText:[TTAccountManager momentString] number:moments type:3];
    TTProfileHeaderVisitorModel *followingModel = [TTProfileHeaderVisitorModel visitorModelWithText:[TTAccountManager followingString] number:followings type:1];
    TTProfileHeaderVisitorModel *followerModel = [TTProfileHeaderVisitorModel visitorModelWithText:[TTAccountManager followerString] number:followers type:2];
//    TTProfileHeaderVisitorModel *visitorModel = [TTProfileHeaderVisitorModel visitorModelWithText:[TTAccountManager visitorString] number:visitors type:0];
    NSArray *models = [NSArray array];
    
    models = @[momentModel, followingModel, followerModel];
    
    return models;
}
@end


@interface TTVisitorButton : TTAlphaThemedButton
@property (nonatomic, strong) TTProfileHeaderVisitorModel *model;

@property (nonatomic, strong) SSThemedView  *containerView;
@property (nonatomic, strong) SSThemedLabel *textLabel;
@property (nonatomic, strong) SSThemedLabel *numberLabel;
@property (nonatomic, strong) TTImageView *imageUpAndDown;
@property (nonatomic, assign) BOOL expand;
@property (nonatomic, assign) BOOL showUpDownArrow;

- (void)updateImage;

+ (instancetype)buttonWithModel:(TTProfileHeaderVisitorModel *)model;
@end

@implementation TTVisitorButton
+ (instancetype)buttonWithModel:(TTProfileHeaderVisitorModel *)model {
    TTVisitorButton *aButton = [self buttonWithType:UIButtonTypeCustom];
    if (aButton) {
        aButton.enableHighlightAnim = YES;
        aButton.model = model;
        [aButton initSubviews];
    }
    return aButton;
}

- (instancetype)init {
    if ((self = [super init])) {
        _model = nil;
        [self initSubviews];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)initSubviews {
    self.containerView = [SSThemedView new];
    self.containerView.userInteractionEnabled = NO;
    [self addSubview:self.containerView];
    
    [self.containerView addSubview:self.numberLabel];
    [self.containerView addSubview:self.textLabel];
    [self.containerView addSubview:self.imageUpAndDown];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(updateImage)
                                                 name:@"kAppFansViewExpand"
                                               object:nil];
}

- (void)themeChanged:(NSNotification *)notification {
    self.numberLabel.alpha = [self alphaOfNumberLabel];
    
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        self.imageUpAndDown.alpha = 1.0;
    } else {
        self.imageUpAndDown.alpha = 0.5;
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if ([self.model.text isEqualToString:@"粉丝"] && self.showUpDownArrow) {
        self.imageUpAndDown.hidden = NO;
    } else {
        self.imageUpAndDown.hidden = YES;
    }
    
    if (![TTTabBarProvider isMineTabOnTabBar]) {
        self.containerView.width = self.width;
        self.containerView.height = self.numberLabel.height;
        
        CGFloat margin = (self.width - self.numberLabel.width - self.textLabel.width) / 2;
        self.numberLabel.top = 0;
        self.numberLabel.right = self.containerView.width - margin;
        
        self.textLabel.left = margin;
        self.textLabel.centerY = self.numberLabel.centerY;
        
        self.imageUpAndDown.left = self.numberLabel.right + 5;
        self.imageUpAndDown.centerY = self.numberLabel.centerY;
        
        self.containerView.center = CGPointMake(self.width/2, self.height/2);
    }
    else{
        
        self.containerView.width = self.width;
        
        self.numberLabel.top = 0;
        self.numberLabel.centerX = self.containerView.width / 2;
        CGFloat padding = [TTDeviceUIUtils tt_padding:3];
        self.textLabel.top = self.numberLabel.bottom + padding;
        self.textLabel.centerX = self.numberLabel.centerX;
        
        self.imageUpAndDown.left = self.textLabel.right + 5;
        self.imageUpAndDown.centerY = self.textLabel.centerY;
        
        self.containerView.height = self.numberLabel.height + padding + self.textLabel.height;
        
        self.containerView.center = CGPointMake(self.width/2, self.height/2);
    }
}

- (void)setModel:(TTProfileHeaderVisitorModel *)model {
    if (!model || model == _model) return ;
    _model = model;
    
    if (![TTTabBarProvider isMineTabOnTabBar]) {
        if (isEmptyString(model.text)) {
            self.numberLabel.text = @"--";
            self.textLabel.text = nil;
        }
        else{
            NSString *numberString = [TTBusinessManager formatCommentCount:model.number];
            model.text ? self.textLabel.text = [NSString stringWithFormat:@"%@: ",model.text] : nil;
            self.numberLabel.text = numberString;
        }
    }
    else{
        if(isEmptyString(model.text)) {
            self.numberLabel.text = @"--";
        } else {
            NSString *numberString = [TTBusinessManager formatCommentCount:model.number];
            model.text ? self.textLabel.text = model.text : nil;
            self.numberLabel.text = numberString;
        }
    }
    
    if ([model.text isEqualToString:@"粉丝"] && self.showUpDownArrow) {
        self.imageUpAndDown.hidden = NO;
    } else {
        self.imageUpAndDown.hidden = YES;
    }
    
    [self.textLabel sizeToFit];
    [self.numberLabel sizeToFit];
    
    [self setNeedsLayout];
}

- (SSThemedLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [SSThemedLabel new];
        _textLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kTTProfileCareTextFontSize]];
        if (![TTTabBarProvider isMineTabOnTabBar]) {
            _textLabel.font = [UIFont systemFontOfSize:12];
        }
        _textLabel.textColorThemeKey = kTTProfileCareTextColorKey;
        _textLabel.alpha = 0.5;
        _textLabel.text = @"";
    }
    return _textLabel;
}

- (SSThemedLabel *)numberLabel {
    if (!_numberLabel) {
        _numberLabel = [SSThemedLabel new];
        _numberLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:kTTProfileCareNumberFontSize]];
        if (![TTTabBarProvider isMineTabOnTabBar]) {
            _numberLabel.font = [UIFont systemFontOfSize:14];
        }
        _numberLabel.textColorThemeKey = kTTProfileCareNumberColorKey;
        _numberLabel.alpha = 0.9;
        _numberLabel.text = @"";
    }
    return _numberLabel;
}

- (TTImageView *)imageUpAndDown {
    if (!_imageUpAndDown) {
        _imageUpAndDown = [[TTImageView alloc] initWithFrame:CGRectMake(88, 10, 8, 8)];
        _imageUpAndDown.enableNightCover = NO;
        _imageUpAndDown.image = [UIImage imageNamed:@"fans_page_up"];
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            _imageUpAndDown.alpha = 1.0;
        } else {
            _imageUpAndDown.alpha = 0.5;
        }
        _expand = NO;
    }
    return _imageUpAndDown;
}

- (void)updateImage
{
    if (_expand) {
        _imageUpAndDown.image = [UIImage imageNamed:@"fans_page_up"];
        _expand = NO;
    } else {
        _imageUpAndDown.image = [UIImage imageNamed:@"fans_page_down"];
        _expand = YES;
    }
}

- (CGFloat)alphaOfNumberLabel {
    return [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? 0.9 : 0.6;
}
@end



@interface TTProfileHeaderVisitorView ()
@property (nonatomic, strong, readwrite) NSArray<TTProfileHeaderVisitorModel *> *models;
@property (nonatomic, strong) NSMutableArray<TTVisitorButton *> *buttons;
@property (nonatomic, strong) NSMutableArray<SSThemedView *> *separators;
@end
@implementation TTProfileHeaderVisitorView
- (instancetype)initWithModels:(NSArray<TTProfileHeaderVisitorModel *> *)models {
    if ((self = [super initWithFrame:CGRectZero])) {
        _models = models;
        _separatorEnabled = YES;
        _separatorColorKey = kColorLine12;
        
        [self initSubviews];
    }
    return self;
}

- (void)dealloc {
    _didTapButtonCallback = nil;
    [_buttons enumerateObjectsUsingBlock:^(TTVisitorButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
         [obj removeTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
    }];
}

- (void)initSubviews {
    if ([_models count] <= 0) return;
    
    if (!_buttons) {
        _buttons = [NSMutableArray arrayWithCapacity:[_models count]];
    } else {
        [_buttons enumerateObjectsUsingBlock:^(TTVisitorButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
            [obj removeFromSuperview];
        }];
        [_buttons removeAllObjects];
    }
    if (!_separators) {
        _separators = [NSMutableArray arrayWithCapacity:[_models count]];
    } else {
        [_separators enumerateObjectsUsingBlock:^(SSThemedView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
        }];
        [_separators removeAllObjects];
    }
    
    NSUInteger count = [_models count];
    for (int i = 0; i < count; i++) {
        TTVisitorButton *aButton = [TTVisitorButton buttonWithModel:_models[i]];
        [aButton addTarget:self action:@selector(didSelectButton:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:aButton];
        
        [self.buttons addObject:aButton];
    }
    
    if (_separatorEnabled) {
        for (int i = 0; i < count - 1; i++) {
            SSThemedView *aView = [SSThemedView new];
            aView.backgroundColorThemeKey = _separatorColorKey;
            aView.alpha = 0.1;
            [self addSubview:aView];
            
            [self.separators addObject:aView];
        }
    } else {
        [_separators enumerateObjectsUsingBlock:^(SSThemedView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = YES;
        }];
    }
    
    [self relayoutIfNeeded];
}

- (void)relayoutIfNeeded {
    NSUInteger count = [_models count];
    CGFloat totalLineWidth = (_separatorEnabled ? [TTDeviceHelper ssOnePixel] * (count - 1): 0);
    CGFloat buttonWidth = (self.width - totalLineWidth) / count;
    CGFloat lineWidth   = _separatorEnabled ? [TTDeviceHelper ssOnePixel] : 0;
    if (_separatorEnabled) {
        [_separators enumerateObjectsUsingBlock:^(SSThemedView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.backgroundColorThemeKey = _separatorColorKey;
            obj.frame = CGRectMake((idx + 1) * buttonWidth + idx * lineWidth, 0, lineWidth, self.height);
        }];
    } else {
        [_separators enumerateObjectsUsingBlock:^(SSThemedView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            obj.hidden = YES;
        }];
    }
    
    BOOL showUpDownArrow = self.showUpDownArrow;
    [_buttons enumerateObjectsUsingBlock:^(TTVisitorButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.frame = CGRectMake(idx * (buttonWidth +lineWidth) , 0, buttonWidth, self.height);
        obj.showUpDownArrow = showUpDownArrow;
    }];
}

- (void)setShowUpDownArrow:(BOOL)showUpDownArrow
{
    _showUpDownArrow = showUpDownArrow;
    NSUInteger count = [_models count];
    for (int i = 0; i < count; ++i) {
        TTProfileHeaderVisitorModel *model = [_models objectAtIndex:i];
        TTVisitorButton *button = [_buttons objectAtIndex:i];
        if ([model.text isEqualToString:@"粉丝"] && _showUpDownArrow) {
            button.imageUpAndDown.hidden = NO;
        } else {
            button.imageUpAndDown.hidden = YES;
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self relayoutIfNeeded];
}

#pragma mark - events 

- (void)didSelectButton:(id)sender {
    if ([self.buttons containsObject:sender]) {
        if (self.didTapButtonCallback) {
            self.didTapButtonCallback(self, [self.buttons indexOfObject:sender]);
            TTVisitorButton *button = (TTVisitorButton *)sender;
            [button updateImage];
        }
    }
}

- (SSThemedButton *)buttonAtIndex:(NSUInteger)index {
    if (index >= [self.buttons count]) return nil;
    return [self.buttons objectAtIndex:index];
}

#pragma mark - reload

- (void)reloadModels:(NSArray<TTProfileHeaderVisitorModel *> *)models {
    if (!models) return;
    
    self.models = models;
}

- (void)reloadModel:(TTProfileHeaderVisitorModel *)model forIndex:(NSUInteger)index {
    NSAssert([_models count] == [_buttons count], @"The number of models is not equal to the number of buttons");
    
    if (index >= [_models count] || !model) return;
    
    self.buttons[index].model = model;
}

- (void)setModels:(NSArray<TTProfileHeaderVisitorModel *> *)models {
    NSAssert([_models count] == [_buttons count], @"The number of models is not equal to the number of buttons");
    
    if (!models || ([_models count] > 0 && [models count] <= 0))
        return;
    
    _models = models;
    
    [_buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self initSubviews];
}
@end



@interface TTAppInfoButton : SSThemedView

@property (nonatomic, strong) SSThemedLabel *infoLabel;
@property (nonatomic, strong) TTImageView  *iconView;
@property (nonatomic, strong) SSThemedLabel *appNameLabel;
@property (nonatomic, strong) TTFollowerDetailModel *followerDetail;
@property (nonatomic, assign) BOOL isLargeStyle;

@end

@implementation TTAppInfoButton

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.infoLabel];
        [self addSubview:self.iconView];
        [self addSubview:self.appNameLabel];

    }
    return self;
}

- (void)setFollowerDetail:(TTFollowerDetailModel *)followerDetail
{
    _infoLabel.text = followerDetail.fansCount;
    _appNameLabel.text = followerDetail.appName;
    [_iconView setImageWithURLString:followerDetail.iconURL];
    
    [self updateFrame];
}

- (void)updateFrame
{
    if (_isLargeStyle) {
        _infoLabel.frame = CGRectMake((self.width - 70) / 2.0, 13, 70, 21);
        _infoLabel.textAlignment = NSTextAlignmentCenter;
        _iconView.frame = CGRectMake(self.width / 2.0 - 22, 41, 14, 14);
        _appNameLabel.frame = CGRectMake(self.width / 2.0 - 4, 39, 29, 18);
        
    } else {
        _infoLabel.frame = CGRectMake((self.width + 21) / 2.0, 10, 70, 21);
        _infoLabel.textAlignment = NSTextAlignmentLeft;
        _iconView.frame = CGRectMake(self.width / 2.0 - 44.5, 14, 14, 14);
        _appNameLabel.frame = CGRectMake(self.width / 2.0 - 26.5, 12, 29, 18);
    }
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        self.backgroundColor = [UIColor colorWithHexString:@"#252525"];
    } else {
        self.backgroundColor = [UIColor colorWithHexString:@"#505050"];
    }
}

- (SSThemedLabel *)infoLabel
{
    if (!_infoLabel) {
        _infoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _infoLabel.text = @"";
        CGFloat fontSize = 15.0;
        if ([UIScreen mainScreen].bounds.size.width < 374) {
            fontSize = 13.0;
        }
        
        _infoLabel.textColorThemeKey = kColorText10;
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            _infoLabel.font = [UIFont fontWithName:@"PingFangSC-Medium" size:fontSize];
        } else {
            _infoLabel.font = [UIFont systemFontOfSize:fontSize];
        }
        
        if (_isLargeStyle) {
            _infoLabel.textAlignment = NSTextAlignmentCenter;
            _infoLabel.frame = CGRectMake((self.width - 70) / 2.0, 13, 70, 21);

        } else {
            _infoLabel.textAlignment = NSTextAlignmentLeft;
            _infoLabel.frame = CGRectMake((self.width + 21) / 2.0, 10, 70, 21);
        }
    }
    return _infoLabel;
}

- (TTImageView *)iconView
{
    if (!_iconView) {
        _iconView = [[TTImageView alloc] initWithFrame:CGRectZero];
        
        if (_isLargeStyle) {
            _iconView.frame = CGRectMake(self.width / 2.0 - 22, 41, 14, 14);
        } else {
            _iconView.frame = CGRectMake(self.width / 2.0 - 44.5, 14, 14, 14);
        }
        
        _iconView.layer.masksToBounds = YES;
        _iconView.layer.cornerRadius = 3.f;
    }
    return _iconView;
}

- (SSThemedLabel *)appNameLabel
{
    if (!_appNameLabel) {
        _appNameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _appNameLabel.text = @"";
        _appNameLabel.textColorThemeKey = kColorText10;
        if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
            _appNameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:13];
        } else {
            _appNameLabel.font = [UIFont systemFontOfSize:13];
        }
        _appNameLabel.textAlignment = NSTextAlignmentLeft;
        
        if (_isLargeStyle) {
            _appNameLabel.frame = CGRectMake(self.width / 2.0 - 4, 39, 29, 18);
        } else {
            _appNameLabel.frame = CGRectMake(self.width / 2.0 - 26.5, 12, 29, 18);
        }
    }
    return _appNameLabel;
}

@end


@interface TTProfileHeaderAppFansView ()

@property (nonatomic, strong) NSMutableArray *buttonsArray;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@end

@implementation TTProfileHeaderAppFansView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        _buttonsArray = [[NSMutableArray alloc] init];
        for (int i = 0; i < 5; i++) {
            TTAppInfoButton *button = [[TTAppInfoButton alloc] initWithFrame:CGRectZero];
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
                button.backgroundColor = [UIColor colorWithHexString:@"#252525"];
            } else {
                button.backgroundColor = [UIColor colorWithHexString:@"#505050"];
            }
            button.layer.masksToBounds = YES;
            button.layer.cornerRadius = 4.f;
            UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didTap:)];
            [button addGestureRecognizer:tapGestureRecognizer];
            [_buttonsArray addObject:button];
            [self addSubview:button];
        }
    }
    return self;
}

- (void)didTap:(UITapGestureRecognizer *)tapGestureRecognizer
{
    NSInteger index = [_buttonsArray indexOfObject:tapGestureRecognizer.view];
    TTFollowerDetailModel *followerDetail = [_appInfos objectAtIndex:index];
    NSURL *url = [NSURL URLWithString:followerDetail.openURL];
    NSString *appName = @"";
    if (followerDetail.appName && [followerDetail.appName isKindOfClass:[NSString class]] && followerDetail.appName.length > 0 && followerDetail.trackName.length > 0) {
        appName = followerDetail.trackName;
    }
    if ([[TTRoute sharedRoute] canOpenURL:url]) {
        [[TTRoute sharedRoute] openURLByPushViewController:url];
        [TTTrackerWrapper eventV3:@"followers_click" params:@{@"position":@"mine", @"app":@"news_article", @"action":@"list_show"}];
    } else {
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"kFollowersDetailInfoShowLaunchAppAlertKey"];
            BOOL show = NO;
            if (!dict || ![dict isKindOfClass:[NSDictionary class]] || !followerDetail.appName) {
                show = YES;
            }
            show = ![dict tt_boolValueForKey:followerDetail.appName];
            if (show) {
                TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:[NSString stringWithFormat:@"即将前往%@ APP 查看", followerDetail.appName]
                                                                                                  message:nil
                                                                                            preferredType:TTThemedAlertControllerTypeAlert];
                [alertController addActionWithTitle:@"取消"
                                         actionType:TTThemedAlertActionTypeCancel
                                        actionBlock:nil];
                [alertController addActionWithTitle:@"立刻前往"
                                         actionType:TTThemedAlertActionTypeNormal
                                        actionBlock:^{
                                            [[UIApplication sharedApplication] openURL:url];
                                            [TTTrackerWrapper eventV3:@"followers_click" params:@{@"position":@"mine", @"app":appName, @"action":@"app_launch"}];
                                        }];
                [alertController showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
                
                NSDictionary *dict = [[NSUserDefaults standardUserDefaults] objectForKey:@"kFollowersDetailInfoShowLaunchAppAlertKey"];
                NSMutableDictionary *newDic = [[NSMutableDictionary alloc] init];
                for(id key in dict) {
                    [newDic setValue:[dict objectForKey:key] forKey:key];
                }
                [newDic setValue:@(YES) forKey:followerDetail.appName];
                
                [[NSUserDefaults standardUserDefaults] setValue:newDic forKey:@"kFollowersDetailInfoShowLaunchAppAlertKey"];
                [[NSUserDefaults standardUserDefaults] synchronize];
            } else {
                [[UIApplication sharedApplication] openURL:url];
                [TTTrackerWrapper eventV3:@"followers_click" params:@{@"position":@"mine", @"app":appName, @"action":@"app_launch"}];
            }
        } else {
            TTThemedAlertController *alertController = [[TTThemedAlertController alloc] initWithTitle:[NSString stringWithFormat:@"即将前往App Store，下载%@APP 查看", followerDetail.appName]
                                                                                              message:nil
                                                                                        preferredType:TTThemedAlertControllerTypeAlert];
            [alertController addActionWithTitle:@"取消"
                                     actionType:TTThemedAlertActionTypeCancel
                                    actionBlock:nil];
            [alertController addActionWithTitle:@"立刻前往"
                                     actionType:TTThemedAlertActionTypeNormal
                                    actionBlock:^{
                                        [TTTrackerWrapper eventV3:@"followers_click" params:@{@"position":@"mine", @"app":appName, @"action":@"app_download"}];
                                        [[SSActionManager sharedManager] openDownloadURL:nil appleID:followerDetail.appID];
                                    }];
            [alertController showFrom:[TTUIResponderHelper topmostViewController] animated:YES];
        }
    }
}

- (void)themeChanged:(NSNotification*)notification
{
    [super themeChanged:notification];
    
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
        UIColor *firstColor = [UIColor colorWithHexString:@"0x161616"];
        UIColor *secondColor = [UIColor colorWithHexString:@"0x181818"];
        NSArray *colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
        NSArray *locations = @[@(0.0), @(1.0)];
        _gradientLayer.colors = colors;
        _gradientLayer.locations = locations;
    } else {
        UIColor *firstColor = [UIColor colorWithHexString:@"0x3c3c3c"];
        UIColor *secondColor = [UIColor colorWithHexString:@"0x3e3e3e"];
        NSArray *colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
        NSArray *locations = @[@(0.0), @(1.0)];
        _gradientLayer.colors = colors;
        _gradientLayer.locations = locations;
    }
}

- (void)setAppInfos:(NSMutableArray *)appInfos
{
    _appInfos = appInfos;
    NSInteger count = [appInfos count];
    CGFloat width = ([UIScreen mainScreen].bounds.size.width - (count - 1) * 8 - 30) / count;
    CGFloat layerHeight = 0;
    if (appInfos.count > 2) {
        layerHeight = 85;
    } else if (appInfos.count == 2) {
        layerHeight = 56;
    } else {
        layerHeight = 0;
    }
    
    if (!_gradientLayer && appInfos.count > 1) {
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
            UIColor *firstColor = [UIColor colorWithHexString:@"0x161616"];
            UIColor *secondColor = [UIColor colorWithHexString:@"0x181818"];
            NSArray *colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
            NSArray *locations = @[@(0.0), @(1.0)];
            _gradientLayer = [CAGradientLayer layer];
            _gradientLayer.colors = colors;
            _gradientLayer.locations = locations;
            _gradientLayer.frame = CGRectMake(0, 0, self.width, layerHeight);
            [self.layer addSublayer:_gradientLayer];
            
        } else {
            UIColor *firstColor = [UIColor colorWithHexString:@"0x3c3c3c"];
            UIColor *secondColor = [UIColor colorWithHexString:@"0x3e3e3e"];
            NSArray *colors = @[(id)firstColor.CGColor, (id)secondColor.CGColor];
            NSArray *locations = @[@(0.0), @(1.0)];
            _gradientLayer = [CAGradientLayer layer];
            _gradientLayer.colors = colors;
            _gradientLayer.locations = locations;
            _gradientLayer.frame = CGRectMake(0, 0, self.width, layerHeight);
            [self.layer addSublayer:_gradientLayer];
        }
    } else {
        if (appInfos.count > 1) {
            if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeNight) {
                _gradientLayer.frame = CGRectMake(0, 0, self.width, layerHeight);
            } else {
                _gradientLayer.frame = CGRectMake(0, 0, self.width, layerHeight);
            }
        }
    }
    
    for (TTAppInfoButton *button in self.buttonsArray) {
        button.frame = CGRectZero;
        [self bringSubviewToFront:button];
    }
    
    if (appInfos.count > 2) {
        for (int i = 0; i < count; i++) {
            TTAppInfoButton *button = [self.buttonsArray objectAtIndex:i];
            button.frame = CGRectMake(15 + i * width + i * 8, 5, width, 70);
            button.isLargeStyle = YES;
            button.followerDetail = [appInfos objectAtIndex:i];
        }
    } else if (appInfos.count == 2) {
        for (int i = 0; i < count; i++) {
            TTAppInfoButton *button = [self.buttonsArray objectAtIndex:i];
            button.frame = CGRectMake(15 + i * width + i * 8, 5, width, 41);
            button.isLargeStyle = NO;
            button.followerDetail = [appInfos objectAtIndex:i];
        }
    } else {
    }
}

@end
