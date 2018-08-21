//
//  TTPLCenterMessageCell.m
//  Article
//
//  Created by 杨心雨 on 2017/1/8.
//
//

#import "TTIMCenterMessageCell.h"
// Views
#import "SSThemed.h"
#import "TTImageView+TrafficSave.h"
#import "TTPLUnreadNumberView.h"
// Utils
#import "UIView-Extension.h"

@interface TTIMCenterMessageCell ()

/** 头像 */
@property (nonatomic, strong) TTImageView *avatarImageView;
/** 名称 */
@property (nonatomic, strong) SSThemedLabel *nameLabel;
/** 未读消息数 */
@property (nonatomic, strong) TTPLUnreadNumberView *unreadNumberView;
/** 右箭头 */
@property (nonatomic, strong) SSThemedImageView *arrowImgView;
/** 分割线 */
@property (nonatomic, strong) SSThemedView *bottomLine;

@end

@implementation TTIMCenterMessageCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubviews];
        [self tt_addThemeNotification];
    }
    return self;
}

- (void)dealloc {
    [self tt_removeThemeNotification];
}

- (void)setupSubviews {
    CGFloat avatarSide = 42;
    
    _avatarImageView = [[TTImageView alloc] initWithFrame:CGRectMake(0, 0, avatarSide, avatarSide)];
    _avatarImageView.contentMode = UIViewContentModeScaleAspectFill;
    _avatarImageView.layer.cornerRadius = avatarSide / 2;
    _avatarImageView.layer.masksToBounds = YES;
    _avatarImageView.backgroundColorThemeKey = kColorBackground1;
    [self.contentView addSubview:_avatarImageView];
    
    _unreadNumberView = [[TTPLUnreadNumberView alloc] init];
    [self.contentView addSubview:_unreadNumberView];
    
    _nameLabel = [[SSThemedLabel alloc] init];
    _nameLabel.font = [UIFont systemFontOfSize:16];
    _nameLabel.textColorThemeKey = kColorText1;
    _nameLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.contentView addSubview:_nameLabel];
    
    _arrowImgView = [[SSThemedImageView alloc] init];
    _arrowImgView.imageName = @"setting_message_rightarrow";
    [_arrowImgView sizeToFit];
    [self.contentView addSubview:_arrowImgView];
    
    _bottomLine = [[SSThemedView alloc] init];
    _bottomLine.backgroundColorThemeKey = kColorLine1;
    [self.contentView addSubview:_bottomLine];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _avatarImageView.left = 15;
    _avatarImageView.centerY = self.height / 2;
    
    _arrowImgView.right = self.width - 15;
    _arrowImgView.centerY = _avatarImageView.centerY;
    
    _unreadNumberView.right = _arrowImgView.left - 9;
    _unreadNumberView.centerY = _avatarImageView.centerY;
    
    [_nameLabel sizeToFit];
    _nameLabel.size = CGSizeMake((_unreadNumberView.left - 16) - (_avatarImageView.right + 12), ceil(_nameLabel.height));
    _nameLabel.left = _avatarImageView.right + 12;
    _nameLabel.centerY = _avatarImageView.centerY;
    
    _bottomLine.frame = CGRectMake(15, self.height - [TTDeviceHelper ssOnePixel], self.width - 15, [TTDeviceHelper ssOnePixel]);
}

- (void)setUnreadNumber:(NSUInteger)number {
    _unreadNumberView.unreadNumber = number;
}

#pragma mark Theme
- (void)tt_selfThemeChanged:(NSNotification *)notification {
    self.contentView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

@end
