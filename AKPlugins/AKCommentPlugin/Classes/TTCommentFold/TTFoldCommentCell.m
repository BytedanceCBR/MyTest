//
//  TTFoldCommentCell.m
//  Article
//
//  Created by muhuai on 21/02/2017.
//
//

#import "TTFoldCommentCell.h"
#import <TTVerifyKit/TTVerifyIconModel.h>
#import <TTVerifyKit/TTVerifyIconHelper.h>
#import <TTAvatar/TTAsyncCornerImageView+VerifyIcon.h>
#import <TTUIWidget/TTUserInfoView.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTBusinessManager.h>
#import <TTBaseLib/TTBusinessManager+StringUtils.h>
#import <TTBaseLib/TTDeviceUIUtils.h>


NSString *const kTTFoldCommentCellIdentifier = @"kTTFoldCommentCellIdentifier";

@interface TTFoldCommentCell ()
@property (nonatomic, strong) TTAsyncCornerImageView *avatarView;
@property (nonatomic, strong) TTUserInfoView *nameView;
@property (nonatomic, strong) SSThemedLabel *contentLabel;
@property (nonatomic, strong) SSThemedLabel *timeLabel;

@property (nonatomic, strong) id<TTCommentModelProtocol> model;
@end

@implementation TTFoldCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColorThemeKey = kColorBackground3;
        [self setupViews];
    }
    return self;
}

- (void)setupViews {
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.nameView];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.timeLabel];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)avatarViewOnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(commentCell:avatarViewOnClickWithModel:)]) {
        [self.delegate commentCell:self avatarViewOnClickWithModel:self.model];
    }
}

- (void)nameViewOnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(commentCell:nameViewOnClickWithModel:)]) {
        [self.delegate commentCell:self nameViewOnClickWithModel:self.model];
    }
}

- (void)refreshWithModel:(id<TTCommentModelProtocol>)model layout:(TTFoldCommentCellLayout *)layout {
    self.model = model;
    self.avatarView.frame = layout.avatarViewFrame;
    self.nameView.frame = layout.nameViewFrame;
    self.contentLabel.frame = layout.contentLabelFrame;
    self.timeLabel.frame = layout.timeLabelFrame;
    
    [self.avatarView tt_setImageWithURLString:model.userAvatarURL];
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:model.userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];
    
    self.contentLabel.attributedText = layout.contentAttriString;

    [self.nameView refreshWithTitle:model.userName relation:nil verifiedInfo:nil verified:NO owner:model.isOwner maxWidth:self.nameView.width appendLogoInfoArray:model.authorBadgeList];
    self.timeLabel.text = [TTBusinessManager simpleDateStringSince:[model.commentCreateTime doubleValue]];
}

- (TTAsyncCornerImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:36.f], [TTDeviceUIUtils tt_newPadding:36.f]) allowCorner:YES];
        _avatarView.cornerRadius = _avatarView.height / 2.f;
        _avatarView.placeholderName = @"big_defaulthead_head";
        _avatarView.coverColor = [[UIColor whiteColor] colorWithAlphaComponent:0.05];
        _avatarView.borderColor = [UIColor clearColor];
        _avatarView.borderWidth = 0.f;
        [_avatarView setupVerifyViewForLength:36.f adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTVerifyIconHelper tt_newSize:standardSize];
        }];
        
        [_avatarView addTouchTarget:self action:@selector(avatarViewOnClick:)];
    }
    return _avatarView;
}

- (TTUserInfoView *)nameView {
    if (!_nameView) {
        _nameView = [[TTUserInfoView alloc] initWithBaselineOrigin:CGPointZero maxWidth:0.f limitHeight:0.f title:nil fontSize:[TTDeviceUIUtils tt_newFontSize:14.f] verifiedInfo:nil appendLogoInfoArray:nil];
        _nameView.textColorThemedKey = kColorText5;
        WeakSelf;
        [_nameView clickTitleWithAction:^(NSString *title) {
            StrongSelf;
            [self nameViewOnClick:nil];
        }];
    }
    return _nameView;
}

- (SSThemedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColorThemeKey = kColorText1;
    }
    return _contentLabel;
}

- (SSThemedLabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _timeLabel.textColorThemeKey = kColorText1;
        _timeLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]];
    }
    return _timeLabel;
}
@end
