//
//  TTVideoPGCCell.m
//  Article
//
//  Created by 刘廷勇 on 15/11/5.
//
//

#import "TTVideoPGCBar.h"
//#import "UIButton+TTCache.h"
#import <SDWebImageManager.h>
#import "SSThemed.h"
#import "TTAlphaThemedButton.h"
#import "UIDevice+TTAdditions.h"
#import "TTRoute.h"
#import "ExploreMovieView.h"
#import <TTUserSettingsManager+FontSettings.h>
#import "UIImage+TTThemeExtension.h"
#import "TTThemeManager.h"
#import "TTStringHelper.h"

#define kPGCButtonTagOffset 1000
#define kPGCButtonWidth ([TTDeviceHelper isScreenWidthLarge320] ? 28.0 : 24.0)

@interface TTVideoPGCView : SSThemedView <UIScrollViewDelegate>

@property (nonatomic, strong) NSArray *pgcList;

@property (nonatomic, strong) SSThemedButton *leftView;
@property (nonatomic, strong) SSThemedLabel *leftLabel;
@property (nonatomic, strong) SSThemedButton *rightView;
@property (nonatomic, strong) SSThemedScrollView *pgcContainer;

@property (nonatomic, strong) SSThemedButton *middleButton;

@property (nonatomic, strong) SSThemedView *leftBorderLine;
@property (nonatomic, strong) SSThemedImageView *rightShadow;

@property (nonatomic, strong) NSString *openURL;

@property (nonatomic) CGFloat contentWidth;

@end

@implementation TTVideoPGCView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.backgroundColorThemeKey = kColorBackground4;

        [self addSubview:self.pgcContainer];
        [self addSubview:self.leftView];
        [self addSubview:self.rightView];
        
        [self.pgcContainer mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        CGFloat leftViewWidth = 44;
        
        [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.bottom.equalTo(self);
            make.width.mas_equalTo(leftViewWidth);
        }];
        
        [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(self);
        }];
        
        self.pgcContainer.contentInset = UIEdgeInsetsMake(0, leftViewWidth, 0, 37);
        
        [self updateShadowImage];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.pgcContainer.contentSize = CGSizeMake(self.contentWidth, kVideoPGCBarHeight);
}

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    [self updateShadowImage];
}

- (void)updateShadowImage
{
    UIImage *rightShadowImage = [UIImage themedImageNamed:@"shadow_subscribe_video"];
    self.rightShadow.image = [rightShadowImage resizableImageWithCapInsets:UIEdgeInsetsMake(5, 0, 5, 0)];
}

- (SSThemedButton *)leftView
{
    if (!_leftView) {
        _leftView = [[SSThemedButton alloc] init];
        _leftView.backgroundColorThemeKey = self.backgroundColorThemeKey;
        _leftView.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
        
        [_leftView addSubview:self.leftLabel];
        
        self.leftBorderLine = [[SSThemedView alloc] init];
        self.leftBorderLine.backgroundColorThemeKey = kColorLine1;
        [_leftView addSubview:self.leftBorderLine];
        
        [self.leftLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(_leftView);
        }];
        
        [self.leftBorderLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo([TTDeviceHelper ssOnePixel]);
            make.top.right.bottom.equalTo(_leftView);
        }];
        
        [_leftView addTarget:self action:@selector(didSelectCell) forControlEvents:UIControlEventTouchUpInside];
    }
    return _leftView;
}

- (SSThemedLabel *)leftLabel
{
    if (!_leftLabel) {
        _leftLabel = [[SSThemedLabel alloc] init];
        _leftLabel.font = [UIFont systemFontOfSize:12];
        _leftLabel.textColorThemeKey = kColorText5;
        _leftLabel.text = @"订阅";
    }
    return _leftLabel;
}

- (SSThemedScrollView *)pgcContainer
{
    if (!_pgcContainer) {
        _pgcContainer = [[SSThemedScrollView alloc] init];
        _pgcContainer.scrollsToTop = NO;
        _pgcContainer.backgroundColor = [UIColor clearColor];
        _pgcContainer.showsVerticalScrollIndicator = NO;
        _pgcContainer.showsHorizontalScrollIndicator = NO;
        _pgcContainer.alwaysBounceHorizontal = YES;
        _pgcContainer.directionalLockEnabled = YES;
        _pgcContainer.delegate = self;
    }
    return _pgcContainer;
}

- (SSThemedButton *)rightView
{
    if (!_rightView) {
        _rightView = [[SSThemedButton alloc] init];
        
        _rightView.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
        
        SSThemedView *rightBorder = [[SSThemedView alloc] init];
        rightBorder.userInteractionEnabled = NO;
        rightBorder.backgroundColorThemeKey = self.backgroundColorThemeKey;
        
        self.rightShadow = [[SSThemedImageView alloc] init];
        
        SSThemedImageView *imageView = [[SSThemedImageView alloc] init];
        imageView.imageName = @"arrow_theme_textpage";
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        
        [_rightView addSubview:rightBorder];
        [_rightView addSubview:self.rightShadow];
        [_rightView addSubview:imageView];
        
        [rightBorder mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.right.bottom.equalTo(_rightView);
            make.width.mas_equalTo(17);
        }];
        
        [self.rightShadow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(_rightView);
            make.right.equalTo(rightBorder.mas_left);
        }];
        
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_rightView);
            make.left.equalTo(_rightView);
            make.right.equalTo(self.rightShadow);
        }];
        
        [_rightView addTarget:self action:@selector(didSelectCell) forControlEvents:UIControlEventTouchUpInside];
    }
    return _rightView;
}

- (void)setPgcList:(NSArray *)pgcList
{
    if (_pgcList != pgcList) {
        _pgcList = pgcList;
        
        [self.pgcContainer.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
        
        self.middleButton = [[SSThemedButton alloc] init];
        self.middleButton.backgroundColorThemeKey = self.backgroundColorThemeKey;
        self.middleButton.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
        [self.middleButton addTarget:self action:@selector(didSelectCell) forControlEvents:UIControlEventTouchUpInside];
        [self.pgcContainer addSubview:self.middleButton];
        
        [self.middleButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        CGFloat buttonWidth = kPGCButtonWidth;
        CGFloat buttonInterim = 8;
        
        int index = 0;
        for (; index < [_pgcList count]; index++) {
            
            TTVideoPGC *pgc = _pgcList[index];
            
            TTAlphaThemedButton *button = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
            button.size = CGSizeMake(buttonWidth, buttonWidth);
            button.tag = kPGCButtonTagOffset + index;
            button.borderWidth = 2;
            button.borderColorThemeKey = kColorLine1;
            button.enableRounded = YES;
            button.enableNightMask = YES;
            [button addTarget:self action:@selector(pgcClicked:) forControlEvents:UIControlEventTouchUpInside];

            UIImage *placeholderImage = [UIImage imageWithSize:CGSizeMake(buttonWidth, buttonWidth) backgroundColor:[UIColor tt_themedColorForKey:kColorBackground2]];
            
            [button setImage:placeholderImage forState:UIControlStateNormal];
            [[SDWebImageManager sharedManager] loadImageWithURL:[NSURL URLWithString:pgc.avatarUrl] options:SDWebImageHighPriority progress:nil completed:^(UIImage * _Nullable image, NSData * _Nullable data, NSError * _Nullable error, SDImageCacheType cacheType, BOOL finished, NSURL * _Nullable imageURL) {
                if (!error && image) {
                    [button setImage:image forState:UIControlStateNormal];
                }
            }];
//            [button tt_setImageWithURL:[NSURL URLWithString:pgc.avatarUrl] forState:UIControlStateNormal placeholderImage:placeholderImage];
            
            [self.pgcContainer addSubview:button];
            
            CGFloat buttonLeft = (buttonWidth + buttonInterim) * index;
            [button mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.pgcContainer);
                make.width.height.mas_equalTo(buttonWidth);
                make.left.mas_equalTo(buttonLeft);
            }];
        }
        
        self.contentWidth = index * (buttonWidth + buttonInterim) - buttonInterim;
        self.pgcContainer.contentOffset = CGPointMake(-self.pgcContainer.contentInset.left, 0);
    }
}

- (void)pgcClicked:(UIButton *)sender
{
    NSInteger index = sender.tag - kPGCButtonTagOffset;

    if (index < [self.pgcList count]) {
        TTVideoPGC *pgc = self.pgcList[index];
        NSString *openPGCURL = pgc.openUrl;
        if (!isEmptyString(openPGCURL)) {
            BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
            NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
            openPGCURL = [openPGCURL stringByAppendingFormat:@"&tt_daymode=%d&tt_font=%@", isDayModel, fontSizeType];
            if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:openPGCURL]]) {
                [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openPGCURL]];
                
                [ExploreMovieView removeAllExploreMovieView];
                
                [TTTrackerWrapper event:@"video" label:@"feed_enter_pgc_hd" value:pgc.mediaID extValue:nil extValue2:nil];
            }
        }
    }
}

- (void)didSelectCell
{
    NSString *openPGCURL = self.openURL;
    if (!isEmptyString(openPGCURL)) {
        BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
        NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
        openPGCURL = [openPGCURL stringByAppendingFormat:@"&tt_daymode=%d&tt_font=%@", isDayModel, fontSizeType];
        if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:openPGCURL]]) {
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openPGCURL]];
            
            [ExploreMovieView removeAllExploreMovieView];
            
            wrapperTrackEvent(@"video", @"feed_enter_pgc_list_hd");
        }
    }
}

#pragma mark -
#pragma mark ScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView.contentOffset.x > -scrollView.contentInset.left) {
        self.leftBorderLine.hidden = NO;
    } else {
        self.leftBorderLine.hidden = YES;
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    wrapperTrackEvent(@"video", @"feed_pgc_list_slide");
}

@end


@interface TTVideoNoPGCView : SSThemedButton

@property (nonatomic, copy)   NSString *desc;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) SSThemedLabel *title;

@end

@implementation TTVideoNoPGCView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
        self.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
        [self addSubview:self.containerView];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

- (void)setDesc:(NSString *)desc
{
    if (_desc != desc) {
        _desc = desc;
        self.title.text = desc;
    }
}

- (UIView *)containerView
{
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        
        SSThemedImageView *leftImageView = [[SSThemedImageView alloc] init];
        leftImageView.imageName = @"add_subscribe_video";
        
        [_containerView addSubview:leftImageView];
        [_containerView addSubview:self.title];
        
        [leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.centerY.equalTo(_containerView);
        }];
        
        [self.title mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(_containerView);
            make.left.equalTo(leftImageView.mas_right).offset(4);
            make.right.equalTo(_containerView);
        }];
    }
    return _containerView;
}

- (SSThemedLabel *)title
{
    if (!_title) {
        _title = [[SSThemedLabel alloc] init];
        CGFloat fontSize = 13;
        
        UIDevice *device = [UIDevice currentDevice];
        NSInteger platform = [device platformType];
        if (platform >= UIDevice6iPhone || platform == UIDeviceUnknown) {
            fontSize = 14;
        }
        _title.font = [UIFont systemFontOfSize:fontSize];
        _title.textColorThemeKey = kColorText1;
    }
    return _title;
}

@end


@interface TTVideoPGCBar ()

@property (nonatomic, strong) UIView *pgcView;

@end

@implementation TTVideoPGCBar

- (void)setViewModel:(TTVideoPGCViewModel *)viewModel
{
    if (_viewModel != viewModel) {
        _viewModel = viewModel;
        
        [self.pgcView removeFromSuperview];
        
        if ([_viewModel.pgcList count] > 0) {
            TTVideoPGCView *pgcView = [[TTVideoPGCView alloc] init];
            pgcView.pgcList = viewModel.pgcList;
            pgcView.openURL = viewModel.openUrl;
            self.pgcView = pgcView;
        } else {
            TTVideoNoPGCView *noPGCView = [[TTVideoNoPGCView alloc] init];
            noPGCView.desc = viewModel.defaultDesc ?: @"视频订阅";
            [noPGCView addTarget:self action:@selector(clickCell:) forControlEvents:UIControlEventTouchUpInside];
            self.pgcView = noPGCView;
        }
        
        [self addSubview:self.pgcView];
        [self.pgcView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
}

- (void)clickCell:(id)sender
{
    NSString *openPGCURL = self.viewModel.openUrl;
    if (!isEmptyString(openPGCURL)) {
        BOOL isDayModel = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay;
        NSString *fontSizeType = [TTUserSettingsManager settedFontShortString];
        openPGCURL = [openPGCURL stringByAppendingFormat:@"&tt_daymode=%d&tt_font=%@", isDayModel, fontSizeType];
        if ([[TTRoute sharedRoute] canOpenURL:[TTStringHelper URLWithURLString:openPGCURL]]) {
            [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:openPGCURL]];
            
            [ExploreMovieView removeAllExploreMovieView];
            
            wrapperTrackEvent(@"video", @"feed_enter_pgc_null_hd");
        }
    }
}

@end
