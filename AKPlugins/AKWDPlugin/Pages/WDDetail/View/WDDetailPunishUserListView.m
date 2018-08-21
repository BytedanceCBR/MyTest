//
//  WDDetailPunishUserListView.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/11/28.
//

#import "WDDetailPunishUserListView.h"
#import "UIViewAdditions.h"
#import "WDApiModel.h"
#import "TTImageView.h"
#import <TTThemed/TTThemeManager.h>
#import <TTRoute/TTRoute.h>

@interface WDDetailPunishUserListView ()

@property (nonatomic, strong) WDPostAnswerTipsStructModel *tipsModel;

@property (nonatomic, strong) TTImageView *iconImageView;

@property (nonatomic, strong) SSThemedImageView *fakeImageView;

@end

@implementation WDDetailPunishUserListView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubviews];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame tipsModel:(WDPostAnswerTipsStructModel *)tipsModel {
    self = [super initWithFrame:frame];
    if (self) {
        self.tipsModel = tipsModel;
        [self createSubviews];
    }
    return self;
}

- (void)createSubviews {
    SSThemedView *bgView = [[SSThemedView alloc] initWithFrame:self.bounds];
    bgView.backgroundColor = [UIColor clearColor];
    [self addSubview:bgView];
    
    if (!isEmptyString(self.tipsModel.icon_day_url) && !isEmptyString(self.tipsModel.icon_night_url)) {
        TTImageView *iconImageView = [[TTImageView alloc] initWithFrame:CGRectMake(15, 9, 18, 18)];
        iconImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
        iconImageView.backgroundColor = [UIColor clearColor];
        iconImageView.enableNightCover = NO;
        iconImageView.userInteractionEnabled = NO;
        NSString *urlString = (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) ? self.tipsModel.icon_day_url : self.tipsModel.icon_night_url;
        [iconImageView setImageWithURLString:urlString];
        [self addSubview:iconImageView];
        self.iconImageView = iconImageView;
    }
    else {
        SSThemedImageView *fakeImageView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(15, 9, 18, 18)];
        fakeImageView.imageName = @"notice_ask";
        [self addSubview:fakeImageView];
        self.fakeImageView = fakeImageView;
    }
    
    SSThemedView *closeBgView = [[SSThemedView alloc] init];
    closeBgView.backgroundColor = [UIColor clearColor];
    closeBgView.size = CGSizeMake(40, 36);
    closeBgView.right = self.width;
    closeBgView.top = 0;
    closeBgView.alpha = 0;
    [self addSubview:closeBgView];
    
    SSThemedButton *closeButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
    NSString *imageName = @"titlebar_close";
    closeButton.imageName = imageName;
    closeButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -12, -10, -12);
    closeButton.size = CGSizeMake(16, 16);
    closeButton.centerY = self.height / 2.0;
    closeButton.right = self.width - 12;
    [closeButton addTarget:self action:@selector(closeButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:closeButton];
    
    SSThemedLabel *guideLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
    guideLabel.font = [UIFont systemFontOfSize:14];
    guideLabel.textColorThemeKey = kColorText6;
    guideLabel.text = self.tipsModel.text ? self.tipsModel.text : @"8月问答惩罚用户公式，共同打造健康社区";
    guideLabel.left = self.iconImageView ? self.iconImageView.right + 4 : (self.fakeImageView ? self.fakeImageView.right + 4 : 15);
    guideLabel.width = self.width - guideLabel.left - 12 - closeBgView.width;
    guideLabel.height = 21;
    guideLabel.centerY = self.height / 2.0;
    [self addSubview:guideLabel];
}

- (void)closeButtonTapped {
    if ([self.delegate respondsToSelector:@selector(detailPunishUserListViewCloseButtonTapped:)]) {
        [self.delegate detailPunishUserListViewCloseButtonTapped:self];
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (!isEmptyString(self.tipsModel.schema)) {
        [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:self.tipsModel.schema] userInfo:nil];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    if (!isEmptyString(self.tipsModel.icon_day_url) && !isEmptyString(self.tipsModel.icon_night_url)) {
        NSString *urlString = (TTThemeModeDay == [[TTThemeManager sharedInstance_tt] currentThemeMode]) ? self.tipsModel.icon_day_url : self.tipsModel.icon_night_url;
        [self.iconImageView setImageWithURLString:urlString];
    }
}

@end
