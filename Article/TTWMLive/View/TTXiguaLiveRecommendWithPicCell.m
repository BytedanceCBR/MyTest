//
//  TTXiguaLiveRecommendWithPicCell.m
//  Article
//
//  Created by lipeilun on 2017/12/6.
//

#import "TTXiguaLiveRecommendWithPicCell.h"
#import <TTImageView.h>
#import "TTArticleCellHelper.h"
#import "TTXiguaLiveHelper.h"
#import "TTXiguaLiveLivingAnimationView.h"

@interface TTXiguaLiveRecommendWithPicCell()
@property (nonatomic, strong) TTImageView *backImageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@property (nonatomic, strong) TTXiguaLiveLivingAnimationView *liveAnimationView;
@end

@implementation TTXiguaLiveRecommendWithPicCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backImageView];
        [self addSubview:self.liveAnimationView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.descLabel];
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification {
    self.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.backImageView.frame = CGRectMake(0, 0, self.width, [TTDeviceUIUtils tt_newPadding:170]);
    self.liveAnimationView.origin = CGPointMake(xg_horcell_live_padding(), xg_horcell_live_padding());
    self.titleLabel.frame = CGRectMake(0, self.backImageView.bottom + [TTDeviceUIUtils tt_newPadding:8], self.width, [TTDeviceUIUtils tt_newPadding:24]);
    self.descLabel.frame = CGRectMake(0, self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:2], self.width, [TTDeviceUIUtils tt_newPadding:17]);
}

- (void)configWithModel:(TTXiguaLiveModel *)model {
    self.titleLabel.text = model.title;
    self.descLabel.text = [TTXiguaLiveHelper generateDescText:model];
    [self.backImageView setImageWithURLString:[model largeImageModel].url];
}

- (void)tryBeginAnimation {
    [self.liveAnimationView beginAnimation];
}

- (void)tryStopAnimation {
    [self.liveAnimationView stopAnimation];
}

#pragma mark - GET

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        _titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:17]];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (SSThemedLabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _descLabel.textColorThemeKey = kColorText3;
        _descLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        _descLabel.numberOfLines = 1;
    }
    return _descLabel;
}

- (TTImageView *)backImageView {
    if (!_backImageView) {
        _backImageView = [[TTImageView alloc] init];
        _backImageView.enableNightCover = YES;
        _backImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _backImageView.clipsToBounds = YES;
        _backImageView.backgroundColorThemeKey = kColorBackground3;
    }
    return _backImageView;
}

- (TTXiguaLiveLivingAnimationView *)liveAnimationView {
    if (!_liveAnimationView) {
        _liveAnimationView = [[TTXiguaLiveLivingAnimationView alloc] initWithStyle:TTXiguaLiveLivingAnimationViewStyleMiddleAndLine];
        [_liveAnimationView beginAnimation];
    }
    return _liveAnimationView;
}

@end
