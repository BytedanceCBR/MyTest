//
//  TTCertificationConditionView.m
//  Article
//
//  Created by wangdi on 2017/5/17.
//
//

#import "TTCertificationConditionView.h"


@implementation TTCertificationConditionModel

@end

@interface TTCertificationConditionCell ()

@property (nonatomic, strong) SSThemedImageView *iconView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *regexLabel;
@property (nonatomic, strong) SSThemedImageView *completeImageView;
@property (nonatomic, strong) SSThemedLabel *completeButton;
@property (nonatomic, strong) SSThemedView *bottomLine;

@end

@implementation TTCertificationConditionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedImageView *iconView = [[SSThemedImageView alloc] init];
    iconView.tintColorThemeKey = kColorBackground7;
    [self.contentView addSubview:iconView];
    self.iconView = iconView;
    
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.textColorThemeKey = kColorText1;
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    SSThemedLabel *regexLabel = [[SSThemedLabel alloc] init];
    regexLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
    regexLabel.textColorThemeKey = kColorText3;
    [self.contentView addSubview:regexLabel];
    self.regexLabel = regexLabel;
    
    SSThemedImageView *completeImageView = [[SSThemedImageView alloc] init];
    completeImageView.imageName = @"authentication_completed_icon";
    [self.contentView addSubview:completeImageView];
    self.completeImageView = completeImageView;
    
    SSThemedLabel *completeButton = [[SSThemedLabel alloc] init];
    completeButton.text = @"去完成";
    completeButton.backgroundColorThemeKey = kColorBackground7;
    completeButton.textColorThemeKey = kColorText7;
    completeButton.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:4];
    completeButton.clipsToBounds = YES;
    completeButton.textAlignment = NSTextAlignmentCenter;
    completeButton.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
    [self.contentView addSubview:completeButton];
    self.completeButton = completeButton;
    
    SSThemedView *bottomLine = [[SSThemedView alloc] init];
    bottomLine.backgroundColorThemeKey = kColorLine1;
    [self addSubview:bottomLine];
    self.bottomLine = bottomLine;
}

- (void)setModel:(TTCertificationConditionModel *)model
{
    _model = model;
    
    self.titleLabel.text = model.titleText;
    self.iconView.imageName = model.iconName;
    
    self.regexLabel.text = model.regexText;
    self.bottomLine.hidden = model.hiddenBottomLine;
    if(model.isCompletion) {
        self.userInteractionEnabled = NO;
        self.completeImageView.hidden = NO;
        self.completeButton.hidden = YES;
    } else {
        self.userInteractionEnabled = YES;
        self.completeImageView.hidden = YES;
        self.completeButton.hidden = NO;
    }
    
    if (model.type == TTCertificationConditionTypeAvailableFanCount) {
        [self.completeButton removeFromSuperview];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.completeImageView.width = [TTDeviceUIUtils tt_newPadding:52];
    self.completeImageView.height = [TTDeviceUIUtils tt_newPadding:42];
    self.completeImageView.left = self.width - self.completeImageView.width - [TTDeviceUIUtils tt_newPadding:15];
    self.completeImageView.top = (self.height - self.completeImageView.height) * 0.5;
    
    self.completeButton.left = self.completeImageView.left;
    self.completeButton.width = self.completeImageView.width;
    self.completeButton.height = [TTDeviceUIUtils tt_newPadding:28];
    self.completeButton.top = (self.height - self.completeButton.height) * 0.5;
    
    self.iconView.width = [TTDeviceUIUtils tt_newPadding:24];
    self.iconView.height = [TTDeviceUIUtils tt_newPadding:24];
    self.iconView.left = [TTDeviceUIUtils tt_newPadding:19];
    self.iconView.top = (self.height - self.iconView.height) / 2;
    
    self.titleLabel.left = self.iconView.right + [TTDeviceUIUtils tt_newPadding:21];
    self.titleLabel.top = [TTDeviceUIUtils tt_newPadding:18];
    self.titleLabel.width = self.completeImageView.left - self.titleLabel.left - [TTDeviceUIUtils tt_newPadding:10];
    self.titleLabel.height = [TTDeviceUIUtils tt_newPadding:22];
    
    
    self.regexLabel.left = self.titleLabel.left;
    self.regexLabel.top = self.titleLabel.bottom + [TTDeviceUIUtils tt_newPadding:2];
    self.regexLabel.width = self.titleLabel.width;
    self.regexLabel.height = [TTDeviceUIUtils tt_newPadding:17];
    
    self.bottomLine.left = [TTDeviceUIUtils tt_newPadding:15];
    self.bottomLine.width = self.width;
    self.bottomLine.height = [TTDeviceHelper ssOnePixel];
    self.bottomLine.top = self.height - self.bottomLine.height;
}

@end

@interface TTCertificationConditionHeaderView ()

@property (nonatomic, strong) SSThemedLabel *textLabel;

@end

@implementation TTCertificationConditionHeaderView

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
    SSThemedLabel *textLabel = [[SSThemedLabel alloc] init];
    textLabel.text = @"满足以下条件才可认证:";
    textLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newPadding:16]];
    textLabel.textColorThemeKey = kColorText1;
    [self addSubview:textLabel];
    self.textLabel = textLabel;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.textLabel.left = [TTDeviceUIUtils tt_newPadding:20];
    self.textLabel.height = [TTDeviceUIUtils tt_newPadding:22];
    self.textLabel.top = [TTDeviceUIUtils tt_newPadding:20];
    self.textLabel.width = self.width - self.textLabel.left;
    
}

@end
