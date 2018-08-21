//
//  TTVReplyListCell.m
//  Article
//
//  Created by lijun.thinker on 2017/6/1.
//
//

#import "TTVReplyListCell.h"
#import "TTDiggButton.h"
#import "TTIndicatorView.h"
#import "TTReportManager.h"
#import "TTIconFontDefine.h"
#import "TTDeviceUIUtils.h"
#import "DetailActionRequestManager.h"
#import "TTActionSheetController.h"
#import "TTVerifyIconHelper.h"
#import "TTUGCAttributedLabel.h"
#import "TTRichSpanText.h"
#import "TTRichSpanText+Emoji.h"
#import "TTRoute.h"
#import "TTArticleCellHelper.h"
#import <TTUIWidget/TTUserInfoView.h>
#import <TTAvatar/TTAsyncCornerImageView.h>
#import <TTUIWidget/TTAsyncLabel.h>
#import <KVOController/KVOController.h>
#import <TTSettingsManager/TTSettingsManager.h>
#import "TTAsyncCornerImageView+VerifyIcon.h"

NSString *const kTTVReplyListCellIdentifier = @"kTTVReplyListCellIdentifier";
#define kTTCommentCellDigButtonHitTestInsets UIEdgeInsetsMake(-30, -30, -10, -30)
#define kTTCommentContentLabelQuotedCommentUserURLString @"com.bytedance.kTTCommentContentLabelQuotedCommentUserURLString"


@interface TTVReplyListCell () <TTUGCAttributedLabelDelegate>
@property (nonatomic, strong) id <TTVReplyModelProtocol> commentModel;
@property (nonatomic, strong) TTVReplyListCellLayout *layout;
@property (nonatomic, strong) TTAsyncCornerImageView *avatarView;
@property (nonatomic, strong) TTUserInfoView *nameView;
@property (nonatomic, strong) TTDiggButton *digButton;
@property (nonatomic, strong) TTAsyncLabel *userInfoLabel;         //用户信息(头条号+认证信息)
@property (nonatomic, strong) TTAsyncLabel *timeLabel;             //时间
@property (nonatomic, strong) TTUGCAttributedLabel *contentLabel;     //回复内容
@property (nonatomic, strong) SSThemedButton *deleteButton;         //删除
@property (nonatomic, assign) BOOL hasQuotedContent;           //是否有引用内容
@property (nonatomic, strong) DetailActionRequestManager *actionManager;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, strong) TTActionSheetController *actionSheetController;
@end

@implementation TTVReplyListCell
@dynamic item;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        BOOL transitionAnimationEnable = [[[TTSettingsManager sharedManager] settingForKey:@"transition_animation_enabled" defaultValue:@NO freeze:YES] boolValue];
        if (!transitionAnimationEnable){
            self.backgroundSelectedColorThemeKey = kColorBackground3;
        }
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupViews];
    }
    return self;
}

- (id<TTVReplyModelProtocol>)commentModel {
    
    return self.item.model;
}

- (TTVReplyListCellLayout *)layout {
    
    return self.item.layout;
}


- (void)setItem:(TTVReplyListItem *)item {
    
    if (item) {
        [self.KVOController unobserve:self.commentModel];
        [super setItem:item];
        
        [self refreshSubViews];
        @weakify(self);
        [self.KVOController observe:self.commentModel keyPath:@keypath(self.commentModel, userDigg) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            @strongify(self);
            if (self.commentModel.userDigg) {
                self.commentModel.diggCount += 1;
            }else if (!self.commentModel.userDigg){
                self.commentModel.diggCount -= 1;
            }
            [self refreshDigButton];
        }];
    }
}

- (void)setupViews {
    
    [self.contentView addSubview:self.avatarView];
    [self.contentView addSubview:self.nameView];
    [self.contentView addSubview:self.userInfoLabel];
    [self.contentView addSubview:self.timeLabel];
    [self.contentView addSubview:self.contentLabel];
    [self.contentView addSubview:self.deleteButton];
    [self.contentView addSubview:self.digButton];
}

- (void)refreshSubViews {
    
    [self refreshDigButton];
    [self refreshAvatarView];
    [self refreshNameView];
    [self refreshUserInfo];
    [self refreshTimeLabel];
    [self refreshContent];
    [self refreshDeleteButton];
}

- (void)refreshAvatarView {
    [self.avatarView tt_setImageWithURLString:self.commentModel.user.avatarURLString];
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:nil decoratorInfo:self.commentModel.user.userDecoration];

}

- (void)refreshNameView {
    CGFloat maxWidth = self.width - [TTVReplyListCellHelper cellRightPadding] - self.digButton.width - [TTVReplyListCellHelper nameViewRightPadding] - self.nameView.left;
    TTVerifyIconModel *iconModel = [TTVerifyIconHelper labelIconOfVerifyInfo:self.commentModel.user.userAuthInfo];
    self.nameView.verifiedLogoInfo = iconModel.logoInfo;
    [self.nameView refreshWithTitle:self.commentModel.user.name relation:[self.commentModel userRelationDescription] verifiedInfo:nil verified:[TTVerifyIconHelper isVerifiedOfVerifyInfo:self.commentModel.user.userAuthInfo] owner:self.commentModel.isOwner maxWidth:maxWidth appendLogoInfoArray:self.commentModel.user.authorBadgeList];
}

- (void)refreshTimeLabel {
    self.timeLabel.top = self.layout.timeLayout.top;
    self.timeLabel.left = self.layout.timeLayout.left;
    self.timeLabel.width = self.layout.timeLayout.width;
    self.timeLabel.text = self.layout.timeLayout.text;
}

- (void)refreshDigButton {
    [self.digButton setDiggCount:self.commentModel.diggCount];
    self.digButton.selected = self.commentModel.userDigg;
    [self.digButton sizeToFit];
    self.digButton.centerY = self.nameView.centerY - 2.f;
    self.digButton.right = self.contentView.right - [TTVReplyListCellHelper cellRightPadding];
}

- (void)refreshUserInfo {
    self.userInfoLabel.left = self.layout.userInfoLayout.left;
    self.userInfoLabel.width = self.layout.userInfoLayout.width;
    if (self.userInfoLabel.width > 0) {
        self.userInfoLabel.text = self.layout.userInfoLayout.text;
    }
}

- (void)refreshContent {
    self.contentLabel.top = self.layout.contentLayout.top;
    self.contentLabel.width = self.layout.contentLayout.width;
    self.contentLabel.height = self.layout.contentLayout.height;

    NSMutableAttributedString *attributedString = [self.layout.contentLayout.attributedText mutableCopy];

    [attributedString addAttributes:@{
        NSParagraphStyleAttributeName: [TTVReplyListCellHelper contentLabelParagraphStyle],
        NSFontAttributeName: [TTVReplyListCellHelper contentLabelFont],
        NSForegroundColorAttributeName: [TTVReplyListCellHelper contentLabelTextColor]
    } range:NSMakeRange(0, attributedString.length)];

    self.contentLabel.text = [attributedString copy];

    NSDictionary *linkAttributes = @{
        NSParagraphStyleAttributeName: [TTVReplyListCellHelper contentLabelParagraphStyle],
        NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5],
        NSFontAttributeName : [TTVReplyListCellHelper contentLabelFont]
    };
    self.contentLabel.linkAttributes = linkAttributes;
    self.contentLabel.activeLinkAttributes = linkAttributes;
    self.contentLabel.inactiveLinkAttributes = linkAttributes;

    NSArray <TTRichSpanLink *> *richSpanLinks = [self.layout.contentLayout.richSpanText richSpanLinksOfAttributedString];
    for (TTRichSpanLink *richSpanLink in richSpanLinks) {
        NSRange range = NSMakeRange(richSpanLink.start, richSpanLink.length);
        if (NSMaxRange(range) <= self.layout.contentLayout.attributedText.length) {
            if (richSpanLink.type == TTRichSpanLinkTypeQuotedCommentUser) {
                [self.contentLabel addLinkToURL:[NSURL URLWithString:kTTCommentContentLabelQuotedCommentUserURLString] withRange:range];
            } else {
                [self.contentLabel addLinkToURL:[NSURL URLWithString:richSpanLink.link] withRange:range];
            }
        }
    }

}

- (void)refreshDeleteButton {
    self.deleteButton.hidden = self.layout.deleteLayout.hidden;
    if (!self.deleteButton.isHidden) {
        self.deleteButton.width = self.layout.deleteLayout.width;
        self.deleteButton.right = self.layout.deleteLayout.right;
        self.deleteButton.centerY = self.timeLabel.centerY;
    }
}

#pragma mark action
- (void)avatarViewOnClick:(id)sender {
    wrapperTrackEvent([self _trackerSource], @"click_replier_avatar");
    if (self.delegate && [self.delegate respondsToSelector:@selector(replyListCell:avatarTappedWithModel:)]) {
        [self.delegate replyListCell:self avatarTappedWithModel:self.commentModel];
    }
}

- (void)nameViewOnClick:(id)sender {
    
    wrapperTrackEvent([self _trackerSource], @"click_replier_name");
    if (self.delegate && [self.delegate respondsToSelector:@selector(replyListCell:avatarTappedWithModel:)]) {
        [self.delegate replyListCell:self nameViewonClickedWithModel:self.commentModel];
    }
}

- (void)replyButtonOnClick:(id)sender {
    wrapperTrackEvent([self _trackerSource], @"reply_replier_button");
    if (self.delegate && [self.delegate respondsToSelector:@selector(replyListCell:replyButtonClickedWithModel:)]) {
        [self.delegate replyListCell:self replyButtonClickedWithModel:self.commentModel];
    }
}

- (void)deleteButtonOnClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(replyListCell:deleteCommentWithModel:)]) {
        [self.delegate replyListCell:self deleteCommentWithModel:self.commentModel];
    }
}

- (void)digButtonOnClick:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(replyListCell:digCommentWithModel:)]) {
        [self.delegate replyListCell:self digCommentWithModel:self.commentModel];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [self refreshContent];

    self.timeLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.userInfoLabel.textColor = [UIColor tt_themedColorForKey:kColorText13];
}

#pragma mark - TTTAttributedLabel Delegate

- (void)attributedLabel:(TTUGCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
	if ([url.absoluteString isEqualToString:kTTCommentContentLabelQuotedCommentUserURLString]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(replyListCell:quotedNameOnClickedWithModel:)]) {
            if (!isEmptyString(self.commentModel.tt_qutoedCommentStructModel.user_id.stringValue)) {
                [self.delegate replyListCell:self quotedNameOnClickedWithModel:self.commentModel];
            }
        }
    } else {
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
    }
}

#pragma mark - private methods

- (NSString *)_trackerSource {
    return @"update_detail";
}

- (BOOL)isDetailComment {
    return YES;
}

#pragma mark - UIMenuController
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)handleLongPress:(UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"复制", nil) action:@selector(customCopy:)];
        UIMenuItem *reportItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"举报", nil) action:@selector(reportComment:)];
        if (copyItem) {
            self.menuItems = menu.menuItems;
            menu.menuItems = @[copyItem, reportItem];
        }
        [menu setTargetRect:self.contentLabel.frame inView:self.contentLabel.superview];
        [menu setMenuVisible:YES animated:YES];
        [self changeContentLabelBackgroundColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideMenu) name:UIMenuControllerWillHideMenuNotification object:nil];
        wrapperTrackEvent([self _trackerSource], @"replier_longpress");
    }
}

- (void)willHideMenu {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    [self resetContentLabelBackgroundColor];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = self.menuItems;
    
}

- (BOOL)canPerformAction:(SEL)action withSender:(__unused id)sender {
    return (action == @selector(customCopy:) ||
            action == @selector(reportComment:));
}

- (void)customCopy:(__unused id)sender {
    [[UIPasteboard generalPasteboard] setString:self.layout.contentLayout.richSpanText.text];
    wrapperTrackEvent([self _trackerSource], @"replier_longpress_copy");
}

- (void)reportComment:(__unused id)sender {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setValue:self.commentModel.commentID forKey:@"comment_id"];
    [params setValue:self.commentModel.user.ID forKey:@"user_id"];
    wrapperTrackEvent([self _trackerSource], @"replier_longpress_report");
    
    self.actionSheetController = [[TTActionSheetController alloc] init];
    
    [self.actionSheetController insertReportArray:[TTReportManager fetchReportUserOptions]];
    WeakSelf;
    [self.actionSheetController performWithSource:TTActionSheetSourceTypeUser completion:^(NSDictionary * _Nonnull parameters) {
        if (parameters[@"report"]) {
            TTReportUserModel *model = [[TTReportUserModel alloc] init];
            model.userID = wself.commentModel.user.ID;
            model.commentID = wself.commentModel.commentID;
            model.groupID = wself.commentModel.groupID;
            [[TTReportManager shareInstance] startReportUserWithType:parameters[@"report"] inputText:parameters[@"criticism"] message:nil source:@(TTReportSourceComment).stringValue userModel:model animated:YES];
        }
    }];
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
        return;
    }
    
    [super touchesBegan:touches withEvent:event];
}

- (void)hideMenu {
    UIMenuController *menu = [UIMenuController sharedMenuController];
    if ([menu isMenuVisible]) {
        [menu setMenuVisible:NO animated:YES];
    }
}

- (void)changeContentLabelBackgroundColor {
    self.contentLabel.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"d4d4d4" nightColorName:@"353535"]];
}

- (void)resetContentLabelBackgroundColor {
    self.contentLabel.backgroundColor = [UIColor clearColor];
}

#pragma mark getter & setter
- (TTAsyncCornerImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake([TTVReplyListCellHelper cellHorizontalPadding], [TTVReplyListCellHelper cellVerticalPadding], [TTVReplyListCellHelper avatarSize], [TTVReplyListCellHelper avatarSize]) allowCorner:YES];
        _avatarView.cornerRadius = [TTVReplyListCellHelper avatarSize] / 2;
        _avatarView.placeholderName = @"big_defaulthead_head";
        _avatarView.borderWidth = 0;
        _avatarView.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        _avatarView.borderColor = [UIColor clearColor];
        [_avatarView addTouchTarget:self action:@selector(avatarViewOnClick:)];
    }
    return _avatarView;
}

- (TTUserInfoView *)nameView {
    if (!_nameView) {
        CGFloat maxWidth = self.width - [TTVReplyListCellHelper cellHorizontalPadding] - [TTVReplyListCellHelper avatarSize] - [TTVReplyListCellHelper avatarRightPadding] - [TTVReplyListCellHelper cellRightPadding] - 30.f - [TTVReplyListCellHelper nameViewRightPadding];
        _nameView = [[TTUserInfoView alloc] initWithBaselineOrigin:CGPointMake(0, 0) maxWidth:maxWidth limitHeight:[UIFont systemFontOfSize:[TTVReplyListCellHelper nameViewFontSize]].lineHeight title:nil fontSize:[TTVReplyListCellHelper nameViewFontSize] verifiedInfo:nil appendLogoInfoArray:nil];
        _nameView.frame = CGRectMake(self.avatarView.right + [TTVReplyListCellHelper avatarRightPadding], [TTVReplyListCellHelper cellVerticalPadding], maxWidth, [TTDeviceUIUtils tt_newPadding:20.f]);
        [_nameView setTextColorThemedKey:kColorText5];
        WeakSelf;
        __weak typeof(_nameView) weakNameView = _nameView;
        [_nameView clickTitleWithAction:^(NSString *title) {
            [wself nameViewOnClick:weakNameView];
        }];
    }
    return _nameView;
}

- (TTDiggButton *)digButton {
    if (!_digButton) {
        _digButton = [TTDiggButton diggButtonWithStyleType:TTDiggButtonStyleTypeCommentOnly];
        _digButton.frame = CGRectMake(self.nameView.right, [TTVReplyListCellHelper cellVerticalPadding], [TTDeviceUIUtils tt_newPadding:80], [TTDeviceUIUtils tt_newPadding:15]);
        _digButton.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        _digButton.imageEdgeInsets = UIEdgeInsetsMake(-2, 0, 2, 0);
        _digButton.hitTestEdgeInsets = kTTCommentCellDigButtonHitTestInsets;
 
        WeakSelf;
        [_digButton setClickedBlock:^(TTDiggButtonClickType type) {
            [wself digButtonOnClick:nil];
        }];
    }
    return _digButton;
}

- (TTAsyncLabel *)userInfoLabel {
    if (!_userInfoLabel) {
        _userInfoLabel = [[TTAsyncLabel alloc] init];
        _userInfoLabel.frame = CGRectMake(self.nameView.left, self.nameView.bottom, self.width - [TTVReplyListCellHelper cellHorizontalPadding] - [TTVReplyListCellHelper avatarSize] - [TTVReplyListCellHelper avatarRightPadding], [TTDeviceUIUtils tt_newPadding:16.5f]);
        _userInfoLabel.font = [TTVReplyListCellHelper userInfoLabelFont];
        _userInfoLabel.textColor = [UIColor tt_themedColorForKey:kColorText13];
        _userInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _userInfoLabel.backgroundColor = [UIColor clearColor];
        _userInfoLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
        _userInfoLabel.numberOfLines = 1;
    }
    return _userInfoLabel;
}

- (TTAsyncLabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[TTAsyncLabel alloc] init];
        _timeLabel.frame = CGRectMake(self.nameView.left, self.contentLabel.bottom, self.width - [TTVReplyListCellHelper cellHorizontalPadding] - [TTVReplyListCellHelper avatarSize] - [TTVReplyListCellHelper avatarRightPadding], [TTDeviceUIUtils tt_newPadding:16.5f]);
        _timeLabel.font = [TTVReplyListCellHelper timeLabelFont];
        _timeLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        _timeLabel.numberOfLines = 1;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
    }
    return _timeLabel;
}

- (TTUGCAttributedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectMake(self.nameView.left, self.timeLabel.bottom + [TTVReplyListCellHelper contentLabelPadding], 0, 0)];
        _contentLabel.font = [UIFont tt_fontOfSize:[TTVReplyListCellHelper contentLabelFont].pointSize]; // 采用苹方字体能正确居中对齐...
        _contentLabel.textColor = SSGetThemedColorWithKey(kColorText1);
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
        _contentLabel.numberOfLines = 0;
        _contentLabel.delegate = self;

        _contentLabel.longPressGestureRecognizer.enabled = NO;
        [_contentLabel addGestureRecognizer:({
            [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
        })];
    }
    return _contentLabel;
}

- (SSThemedButton *)deleteButton {
    if (!_deleteButton) {
        _deleteButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.backgroundColor = [UIColor clearColor];
        _deleteButton.titleLabel.font = [TTVReplyListCellHelper deleteButtonFont];
        _deleteButton.titleColorThemeKey = kColorText1;
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        _deleteButton.hidden = YES;
        _deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_deleteButton addTarget:self action:@selector(deleteButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.hitTestEdgeInsets = UIEdgeInsetsMake(-13, -8, -13, -8);
        _deleteButton.height = [TTVReplyListCellHelper deleteButtonFont].lineHeight;
    }
    return _deleteButton;
}

@end


