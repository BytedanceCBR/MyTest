//
//  TTPopularHashtagCollectionViewCell.m
//  Article
//
//  Created by lipeilun on 2018/1/17.
//

#import "TTPopularHashtagCollectionViewCell.h"
#import <TTImageView.h>
#import <SSThemed.h>
#import <TTKitchenHeader.h>
//#import "FRConcernHomepageViewControllerProtocol.h"
#import <UIImageView+WebCache.h>

@interface TTPopularHashtagCollectionCellDescView : SSThemedView
@property (nonatomic, strong) SSThemedImageView *iconView;
@property (nonatomic, strong) SSThemedLabel *textLabel;
@end

@implementation TTPopularHashtagCollectionCellDescView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.iconView];
        [self addSubview:self.textLabel];
    }
    return self;
}

- (CGFloat)widthWithIconURL:(NSString *)iconURL number:(NSInteger)number text:(NSString *)text maxWidth:(CGFloat)maxWidth {
    if (!isEmptyString(text)) {
        self.textLabel.text = text;
    } else {
        self.textLabel.text = [NSString stringWithFormat:@"%@讨论", [TTBusinessManager formatCommentCount:number]];
    }
    
    CGFloat width = 0;
    if (!isEmptyString(iconURL)) {
        self.iconView.hidden = NO;
        [self.iconView sd_setImageWithURL:[NSURL URLWithString:iconURL]];
        CGSize size = [self.textLabel.text boundingRectWithSize:CGSizeMake(maxWidth - [TTDeviceUIUtils tt_newPadding:7] - [TTDeviceUIUtils tt_newPadding:11] - [TTDeviceUIUtils tt_newPadding:2] - [TTDeviceUIUtils tt_newPadding:7], [TTDeviceUIUtils tt_newPadding:16])
                                                        options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:11]]}
                                                        context:nil].size;
        width += [TTDeviceUIUtils tt_newPadding:7] + [TTDeviceUIUtils tt_newPadding:11] + size.width + [TTDeviceUIUtils tt_newPadding:2] + [TTDeviceUIUtils tt_newPadding:7];
    } else {
        self.iconView.hidden = YES;
        self.iconView.image = nil;
        CGSize size = [self.textLabel.text boundingRectWithSize:CGSizeMake(maxWidth - 2 * [TTDeviceUIUtils tt_newPadding:7], [TTDeviceUIUtils tt_newPadding:16])
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:11]]}
                                                        context:nil].size;
        width += size.width + 2 * [TTDeviceUIUtils tt_newPadding:7] + [TTDeviceUIUtils tt_newPadding:2];
    }

    return width;
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self refreshUI];
}

- (void)refreshUI {
    if (!self.iconView.hidden) {
        self.iconView.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:7], 0, [TTDeviceUIUtils tt_newPadding:11], [TTDeviceUIUtils tt_newPadding:11]);
        self.iconView.centerY = self.height / 2;
        self.textLabel.frame = CGRectMake(self.iconView.right + [TTDeviceUIUtils tt_newPadding:2], 0, self.width - self.iconView.right - [TTDeviceUIUtils tt_newPadding:7] - [TTDeviceUIUtils tt_newPadding:2], self.height);
    } else {
        self.iconView.frame = CGRectZero;
        self.textLabel.frame = CGRectMake([TTDeviceUIUtils tt_newPadding:7], 0, self.width - 2 * [TTDeviceUIUtils tt_newPadding:7] + [TTDeviceUIUtils tt_newPadding:2], self.height);
    }
}

- (SSThemedImageView *)iconView {
    if (!_iconView) {
        _iconView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:11], [TTDeviceUIUtils tt_newPadding:11])];
        _iconView.contentMode = UIViewContentModeScaleAspectFill;
        _iconView.clipsToBounds = YES;
        _iconView.backgroundColor = [UIColor clearColor];
        _iconView.enableNightCover = NO;
    }
    return _iconView;
}

- (SSThemedLabel *)textLabel {
    if (!_textLabel) {
        _textLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _textLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:11]];
        _textLabel.numberOfLines = 1;
    }
    return _textLabel;
}

@end

@interface TTPopularHashtagCollectionViewCell()
@property (nonatomic, strong) SSThemedImageView *hashtagImageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTPopularHashtagCollectionCellDescView *descView;
@property (nonatomic, strong) FRForumStructModel *hashtagModel;
@end

@implementation TTPopularHashtagCollectionViewCell

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.hashtagImageView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.descView];
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTalkCount:) name:kHashtagHomepageTalkCountUpdateNotification object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification {
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    self.hashtagImageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground1];
    NSDictionary *iconDict = [[KitchenMgr getDictionary:kKCUGCPopularHashtagCellDescIcon] tt_dictionaryValueForKey:self.hashtagModel.icon_style.stringValue];
    
    NSString *iconURL = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? [iconDict tt_stringValueForKey:@"day"] : [iconDict tt_stringValueForKey:@"night"];
    if (!isEmptyString(iconURL)) {
        [self.descView.iconView sd_setImageWithURL:[NSURL URLWithString:iconURL]];
    }
}


- (void)updateTalkCount:(NSNotification *)notification {
    if ([notification.userInfo tt_integerValueForKey:@"forum_id"] == self.hashtagModel.forum_id.integerValue) {
        self.hashtagModel.talk_count = @([notification.userInfo tt_integerValueForKey:@"talk_count"]);
        [self refreshUI];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];

    [self refreshUI];
}

- (void)configWithModel:(FRForumStructModel *)model {
    self.hashtagModel = model;
    
    self.titleLabel.text = model.forum_name;
    if (!isEmptyString(model.avatar_url)) {
        [self.hashtagImageView sd_setImageWithURL:[NSURL URLWithString:model.avatar_url]];
    }
    
    if (model.label_style.integerValue == 1) {
        self.descView.backgroundColorThemeKey = nil;
        self.descView.backgroundColors = @[@"FEEEEE", @"492A2A"];
        self.descView.textLabel.textColorThemeKey = kColorText4;
    } else {
        self.descView.backgroundColors = nil;
        self.descView.backgroundColorThemeKey = kColorBackground3;
        self.descView.textLabel.textColorThemeKey = kColorText14;
    }
    [self refreshUI];
}

- (void)refreshUI {
    self.hashtagImageView.frame = CGRectMake(0, [TTDeviceUIUtils tt_newPadding:3], [TTDeviceUIUtils tt_newPadding:36], [TTDeviceUIUtils tt_newPadding:36]);
    self.titleLabel.frame = CGRectMake(self.hashtagImageView.right + [TTDeviceUIUtils tt_newPadding:8], self.hashtagImageView.top, self.width - self.hashtagImageView.right - [TTDeviceUIUtils tt_newPadding:10], [TTDeviceUIUtils tt_newPadding:16]);
    
    NSDictionary *iconDict = [[KitchenMgr getDictionary:kKCUGCPopularHashtagCellDescIcon] tt_dictionaryValueForKey:self.hashtagModel.icon_style.stringValue];
    
    NSString *iconURL = [[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay ? [iconDict tt_stringValueForKey:@"day"] : [iconDict tt_stringValueForKey:@"night"];
    self.descView.frame = CGRectMake(self.titleLabel.left, self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:3], [self.descView widthWithIconURL:iconURL number:self.hashtagModel.talk_count.integerValue text:self.hashtagModel.sub_title maxWidth:self.titleLabel.width], [TTDeviceUIUtils tt_newPadding:17]);
}

#pragma mark - GET

- (SSThemedImageView *)hashtagImageView {
    if (!_hashtagImageView) {
        _hashtagImageView = [[SSThemedImageView alloc] initWithFrame:CGRectZero];
        _hashtagImageView.layer.cornerRadius = 4;
        _hashtagImageView.layer.borderWidth = 0;
        _hashtagImageView.enableNightCover = YES;
        _hashtagImageView.contentMode = UIViewContentModeScaleAspectFill;
        _hashtagImageView.clipsToBounds = YES;
        _hashtagImageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground1];
    }
    return _hashtagImageView;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (TTPopularHashtagCollectionCellDescView *)descView {
    if (!_descView) {
        _descView = [[TTPopularHashtagCollectionCellDescView alloc] init];
        _descView.clipsToBounds = YES;
        _descView.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:8.5f];
    }
    return _descView;
}

@end
