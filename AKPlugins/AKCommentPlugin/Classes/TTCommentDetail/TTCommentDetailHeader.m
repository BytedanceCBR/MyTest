//
//  TTCommentDetailHeader.m
//  Article
//
//  Created by zhaoqin on 05/01/2017.
//
//

#import "TTCommentDetailHeader.h"
#import "TTCommentDetailCellLayout.h"
#import "TTCommentUIHelper.h"
#import <TTThemed/TTThemeManager.h>
#import <TTAvatar/ExploreAvatarView+VerifyIcon.h>
#import <TTAvatar/TTAsyncCornerImageView+VerifyIcon.h>
#import <TTAccountBusiness.h>
#import <TTBaseLib/TTBusinessManager.h>
#import <TTBaseLib/TTBusinessManager+StringUtils.h>
#import <TTPlatformBaseLib/TTIconFontDefine.h>
#import <TTPlatformUIModel/TTActionSheetController.h>
#import <TTUIWidget/TTUserInfoView.h>
#import <TTUIWidget/TTAsyncLabel.h>
#import <TTDiggButton/TTDiggButton.h>
#import <TTUIWidget/TTColorAsFollowButton.h>
#import <TTReporter/TTReportManager.h>
#import "TTCommentDetailHeaderGroupItem.h"
#import "TTCommentDetailHeaderDigItem.h"
#import <TTUGCFoundation/TTUGCEmojiParser.h>
#import <TTUIWidget/TTUGCAttributedLabel.h>
#import <TTUGCFoundation/TTRichSpanText.h>
#import <TTUGCFoundation/TTRichSpanText+Comment.h>
#import <TTUGCFoundation/TTRichSpanText+Emoji.h>


@interface TTCommentDetailHeaderUIHelper : NSObject

@end

@implementation TTCommentDetailHeaderUIHelper

+ (CGFloat)cellVerticalPadding {
    return [self fitSizeWithiPhone6:16.f iPhone5:16.f];
}

+ (CGFloat)cellHorizontalPadding {
    return [self fitSizeWithiPhone6:15.f iPhone5:15.f];
}

#pragma mark - avatar

+ (CGFloat)avatarNormalSize {
    return 36.f;
}

+ (CGSize)verifyLogoSize:(CGSize)standardSize {
    CGFloat vWidth = ceil([self avatarSize] / [self avatarNormalSize] * standardSize.width);
    CGFloat vHeight = ceil([self avatarSize] / [self avatarNormalSize] * standardSize.height);
    return CGSizeMake(vWidth, vHeight);
}

+ (CGFloat)avatarSize {
    return [self fitSizeWithiPhone6:36.f iPhone5:32.f];
}

+ (CGFloat)avatarRightPadding {
    return [self fitSizeWithiPhone6:12.f iPhone5:12.f];
}

#pragma mark - nameView

+ (CGFloat)nameViewFontSize {
    return [self fitSizeWithiPhone6:14.f iPhone5:13.f];
}

+ (CGFloat)nameViewRightPadding {
    return [self fitSizeWithiPhone6:14.f iPhone5:13.f];
}
+ (NSString *)nameViewTextColorKey {
    return kColorText5;
}

+ (CGFloat)nameViewBottomPadding {
    return [self fitSizeWithiPhone6:-1.f iPhone5:-2.f];
}

#pragma mark - userInfoLabel

+ (CGFloat)userInfoLabelTopPadding {
    return [self fitSizeWithiPhone6:1.5f iPhone5:1.5f];
}

+ (UIFont *)userInfoLabelFont {
    return [UIFont systemFontOfSize:[self fitSizeWithiPhone6:12.f iPhone5:12.f]];
}

#pragma mark - contentLabel

+ (CGFloat)contentLabelPadding {
    return [self fitSizeWithiPhone6:10.f iPhone5:10.f];
}

+ (UIFont *)contentLabelFont {
    return [UIFont systemFontOfSize:[TTCommentUIHelper tt_sizeWithFontSetting:[self fitSizeWithiPhone6:17.f iPhone5:16.f]]];
}

+ (UIColor *)contentLabelTextColor {
    return SSGetThemedColorWithKey(kColorText1);
}

+ (NSParagraphStyle *)contentLabelParagraphStyle {
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle.minimumLineHeight = [TTCommentUIHelper tt_sizeWithFontSetting:[self fitSizeWithiPhone6:17.f iPhone5:16.f]] * 1.4f;
    paragraphStyle.maximumLineHeight = [TTCommentUIHelper tt_sizeWithFontSetting:[self fitSizeWithiPhone6:17.f iPhone5:16.f]] * 1.4f;
    paragraphStyle.lineSpacing = 0;
    return paragraphStyle;
}

+ (UIFont *)timeLabelFont {
    return [UIFont systemFontOfSize:[self fitSizeWithiPhone6:12.f iPhone5:12.f]];
}

+ (NSString *)timeLabelTextColorKey {
    return kColorText13;
}

#pragma mark - followButton

+ (CGSize)followButtonSize {
    return CGSizeMake(72.f, 28.f);
}

+ (UIFont *)followButtonFont {
    return [UIFont systemFontOfSize:[self fitSizeWithiPhone6:12.f iPhone5:12.f]];
}

+ (CGFloat)fitSizeWithiPhone6:(CGFloat)size6 iPhone5:(CGFloat)size5 {
    return [self fitSizeWithiPhone6:size6 iPhone6P:size6 iPhone5:size5];
}

+ (CGFloat)fitSizeWithiPhone6:(CGFloat)size6 iPhone6P:(CGFloat)size6p iPhone5:(CGFloat)size5 {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad:
            return ceil(size6 * 1.3);
        case TTDeviceMode736:
            return ceil(size6p);
        case TTDeviceMode667:
            return ceil(size6);
        case TTDeviceMode568:
        case TTDeviceMode480:
            return ceil(size5);
        default:
            return ceil(size6);
    }
}
@end

#define kTTCommentContentLabelQuotedCommentUserURLString @"com.bytedance.kTTCommentContentLabelQuotedCommentUserURLString"

@interface TTCommentDetailHeader()<TTCommentDetailHeaderDigItemDelegate, TTUGCAttributedLabelDelegate>
@property (nonatomic, strong) TTCommentDetailModel *model;
@property (nonatomic, strong) TTAsyncCornerImageView *avatarView;
@property (nonatomic, strong) TTUserInfoView *nameView;
@property (nonatomic, strong) TTDiggButton *digButton;
@property (nonatomic, strong) SSThemedLabel *userInfoLabel;         //用户信息(头条号+认证信息)
@property (nonatomic, strong) SSThemedLabel *timeLabel;             //时间
@property (nonatomic, strong) TTUGCAttributedLabel *contentLabel;     //回复内容
@property (nonatomic, strong) SSThemedButton *deleteButton;         //删除
@property (nonatomic, strong) TTColorAsFollowButton *followButton;         //关注
@property (nonatomic, assign) BOOL needShowFollowBtnAlways;
@property (nonatomic, strong) SSThemedButton *reportButton;
@property (nonatomic, strong) TTCommentDetailHeaderDigItem *likeView;
@property (nonatomic, strong) TTCommentDetailHeaderGroupItem *groupItemView;
@property (nonatomic, strong) NSArray *menuItems;
@property (nonatomic, assign) BOOL needShowGroupItem;
@property (nonatomic, strong) TTRichSpanText *richSpanText;

@end

@implementation TTCommentDetailHeader

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithModel:(TTCommentDetailModel *)model frame:(CGRect)frame needShowGroupItem:(BOOL)showGroup {
    self = [super initWithFrame:frame];
    if (self) {
        _trackTag = @"update_detail";
        self.backgroundColorThemeKey = kColorBackground4;
        _model = model;
        //只有在进入时是未关注状态才等于true
        _needShowFollowBtnAlways = !model.user.isFollowing;
        _needShowGroupItem = showGroup;
        [self setupViews];
        [self refreshWithModel:model];
    }
    return self;
}

- (void)refreshWithModel:(TTCommentDetailModel *)model {
    if (isEmptyString(model.user.name)) {
        return;
    }
    self.model = model;
    [self _refreshFollowButtonStateWithModel:model];
    
    [self.avatarView tt_setImageWithURLString:model.user.avatarURLString];
    [self.avatarView showOrHideVerifyViewWithVerifyInfo:model.user.userAuthInfo decoratorInfo:model.user.userDecoration sureQueryWithID:YES userID:nil];

    
    CGFloat maxWidth = (self.followButton.isHidden? self.width: self.followButton.left) - self.nameView.left - [TTCommentDetailHeaderUIHelper cellHorizontalPadding];
    [self.nameView refreshWithTitle:model.user.name relation:self.followButton.hidden? [self userRelationStr]: nil verifiedInfo:nil verified:NO owner:NO maxWidth:maxWidth > 0? maxWidth :0 appendLogoInfoArray:model.user.authorBadgeList];
    self.userInfoLabel.text = model.user.verifiedReason;
    [self.userInfoLabel sizeToFit];
    self.timeLabel.text = [TTBusinessManager customtimeStringSince1970:[model.createTime longLongValue]];
    
    if ([self isSelfComment]) {
        self.reportButton.hidden = YES;
    } else {
        self.reportButton.hidden = NO;
    }
    
    [self.timeLabel sizeToFit];

    TTRichSpanText *richSpanText;
    if (!isEmptyString(model.qutoedCommentModel.userID) && !isEmptyString(model.qutoedCommentModel.userName)) {
        /*
         * 回复引用的评论格式 -> COMMENT//@USERNAME：QUOTED COMMENT
         */
        richSpanText = [[TTRichSpanText alloc] initWithText:model.content
                                        richSpansJSONString:model.contentRichSpanJSONString];
        [richSpanText appendCommentQuotedUserName:model.qutoedCommentModel.userName userId:model.qutoedCommentModel.userID];
        TTRichSpanText *quotedRichSpanText = [[TTRichSpanText alloc] initWithText:model.qutoedCommentModel.commentContent
                                                              richSpansJSONString:model.qutoedCommentModel.commentContentRichSpanJSONString];
        [richSpanText appendRichSpanText:quotedRichSpanText];
    } else {
        richSpanText = [[TTRichSpanText alloc] initWithText:model.content
                                        richSpansJSONString:model.contentRichSpanJSONString];
    }

    NSMutableAttributedString *attributedString = [[TTUGCEmojiParser parseInCoreTextContext:richSpanText.text
                                                                                   fontSize:[TTCommentDetailHeaderUIHelper contentLabelFont].pointSize] mutableCopy];

    [attributedString addAttributes:@{
        NSParagraphStyleAttributeName: [TTCommentDetailHeaderUIHelper contentLabelParagraphStyle],
        NSFontAttributeName: [TTCommentDetailHeaderUIHelper contentLabelFont],
        NSForegroundColorAttributeName: [TTCommentDetailHeaderUIHelper contentLabelTextColor]
    } range:NSMakeRange(0, attributedString.length)];

    self.contentLabel.text = attributedString;
    self.richSpanText = richSpanText;

    NSArray <TTRichSpanLink *> *richSpanLinks = [richSpanText richSpanLinksOfAttributedString];
    for (TTRichSpanLink *richSpanLink in richSpanLinks) {
        NSRange range = NSMakeRange(richSpanLink.start, richSpanLink.length);
        if (NSMaxRange(range) <= self.contentLabel.attributedText.length) {
            if (richSpanLink.type == TTRichSpanLinkTypeQuotedCommentUser) {
                [self.contentLabel addLinkToURL:[NSURL URLWithString:kTTCommentContentLabelQuotedCommentUserURLString] withRange:range];
            } else {
                [self.contentLabel addLinkToURL:[NSURL URLWithString:richSpanLink.link] withRange:range];
            }
        }
    }

    self.digButton.selected = model.userDigg;
    [self.digButton setDiggCount:model.diggCount];
    self.digButton.borderColorThemeKey = self.digButton.selected? kColorLine4: kColorLine9;
    [self.likeView reloadDataWithModel:model];
    [self.groupItemView refreshWithDetailModel:model];

    [self setupLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self refreshWithModel:self.model];
}

+ (CGFloat)heightWithModel:(TTCommentDetailModel *)model width:(CGFloat)width {
    if (isEmptyString(model.user.name)) {
        return 0;
    }
    CGFloat contentLabelWidth = width - (2 * [TTCommentDetailHeaderUIHelper cellHorizontalPadding]) - [TTCommentDetailHeaderUIHelper avatarSize] - [TTCommentDetailHeaderUIHelper avatarRightPadding];
    CGFloat height = [TTCommentDetailHeaderUIHelper cellVerticalPadding];
    height += [TTCommentDetailHeaderUIHelper avatarSize];
    height += [TTCommentDetailHeaderUIHelper contentLabelPadding];
    height += [TTUGCAttributedLabel sizeThatFitsAttributedString:[self _contentLabelAttributedStringWithModel:model] withConstraints:CGSizeMake(contentLabelWidth, 0) limitedToNumberOfLines:0].height;
    height += [TTCommentDetailHeaderUIHelper contentLabelPadding];
    
    height += 24.f; //DigItem
    return height;
}

#pragma mark action
- (void)handleLongPress:(UIGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"复制", nil) action:@selector(customCopy:)];
        if (copyItem) {
            self.menuItems = menu.menuItems;
            menu.menuItems = @[copyItem];
        }
        [menu setTargetRect:self.contentLabel.frame inView:self.contentLabel.superview];
        [menu setMenuVisible:YES animated:YES];
        
        self.contentLabel.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"d4d4d4" nightColorName:@"353535"]];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideMenu) name:UIMenuControllerWillHideMenuNotification object:nil];
        wrapperTrackEvent(@"update_detail", @"longpress");
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)willHideMenu {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    self.contentLabel.backgroundColor = [UIColor clearColor];
    
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = self.menuItems;
}

- (BOOL)canPerformAction:(SEL)action withSender:(__unused id)sender {
    return action == @selector(customCopy:);
}

- (void)customCopy:(__unused id)sender {
    [[UIPasteboard generalPasteboard] setString:self.richSpanText.text];
    wrapperTrackEvent(self.trackTag, @"longpress_copy");
}

- (void)avatarViewOnClick:(id)sender {
    wrapperTrackEvent(self.trackTag, @"click_avatar");
    if (self.delegate && [self.delegate respondsToSelector:@selector(dynamicDetailHeader:avatarViewOnClick:)]) {
        [self.delegate dynamicDetailHeader:self avatarViewOnClick:sender];
    }
}

- (void)nameViewOnClick:(id)sender {
    wrapperTrackEvent(self.trackTag, @"click_name");
    if (self.delegate && [self.delegate respondsToSelector:@selector(dynamicDetailHeader:nameViewOnClick:)]) {
        [self.delegate dynamicDetailHeader:self nameViewOnClick:sender];
    }
}

- (void)followButtonOnClick:(id)sender {
    _needShowFollowBtnAlways = YES;
    if (self.model.user.isBlocking) {
        [self blockButtonOnClick:sender];
        return;
    }

    if (self.delegate && [self.delegate respondsToSelector:@selector(dynamicDetailHeader:followButtonOnClick:)]) {
        [self.delegate dynamicDetailHeader:self followButtonOnClick:sender];
    }
}

- (void)digButtonOnClick:(id)sender {
//    wrapperTrackEvent(self.trackTag, @"top_digg_click");
    if (self.delegate && [self.delegate respondsToSelector:@selector(dynamicDetailHeader:digButtonOnClick:)]) {
        [self.delegate dynamicDetailHeader:self digButtonOnClick:sender];
    }
}

- (void)blockButtonOnClick:(id)sender {
    wrapperTrackEvent(self.trackTag, @"click_deblacklist");
    if (self.delegate && [self.delegate respondsToSelector:@selector(dynamicDetailHeader:blockButtonOnClick:)]) {
        [self.delegate dynamicDetailHeader:self blockButtonOnClick:sender];
    }
}

- (void)deleteButtonOnClick:(id)sender {
    wrapperTrackEvent(self.trackTag, @"delete");
    if (self.delegate && [self.delegate respondsToSelector:@selector(dynamicDetailHeader:deleteButtonOnClick:)]) {
        [self.delegate dynamicDetailHeader:self deleteButtonOnClick:sender];
    }
}

- (void)reportButtonOnClick:(id)sender {
    wrapperTrackEvent(self.trackTag, @"report");
    if (self.delegate && [self.delegate respondsToSelector:@selector(dynamicDetailHeader:reportButtonOnClick:)]) {
        [self.delegate dynamicDetailHeader:self reportButtonOnClick:sender];
    }
}

#pragma mark - TTUGCAttributedLabel Delegate

- (void)attributedLabel:(TTUGCAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([url.absoluteString isEqualToString:kTTCommentContentLabelQuotedCommentUserURLString]) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(dynamicDetailHeader:quotedNameViewOnClick:)]) {
            [self.delegate dynamicDetailHeader:self quotedNameViewOnClick:nil];
        }
    } else {
        if ([[TTRoute sharedRoute] canOpenURL:url]) {
            [[TTRoute sharedRoute] openURLByPushViewController:url];
        }
    }
}

#pragma mark - TTCommentDetailHeaderDigItemDelegate

- (void)commentDetailHeaderDigItem:(TTCommentDetailHeaderDigItem *)digItem diggUserAvatarClicked:(SSUserModel *)userModel {
    if (self.delegate && [self.delegate respondsToSelector:@selector(dynamicDetailHeader:diggedUserAvatarOnClick:)]) {
        [self.delegate dynamicDetailHeader:self diggedUserAvatarOnClick:userModel];
    }
}

- (void)commentDetailHeaderDigItem:(TTCommentDetailHeaderDigItem *)digItem diggUsersAccessoryClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(dynamicDetailHeader:diggCountLabelOnClick:)]) {
        [self.delegate dynamicDetailHeader:self diggCountLabelOnClick:sender];
    }
}

#pragma mark - layout subviews

- (void)setupViews {
    [self addSubview:self.likeView];
    [self addSubview:self.groupItemView];
    [self addSubview:self.avatarView];
    [self addSubview:self.nameView];
    [self addSubview:self.digButton];
    [self addSubview:self.userInfoLabel];
    [self addSubview:self.timeLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.reportButton];
    [self addSubview:self.deleteButton];
    [self addSubview:self.followButton];
    [self addSubview:({
        SSThemedView *bottomShadow = [[SSThemedView alloc] initWithFrame:CGRectMake(0, self.height - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel])];
        bottomShadow.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
        bottomShadow.backgroundColorThemeKey = kColorLine1;
        bottomShadow;
    })];
}

- (void)setupLayout {
    self.avatarView.top = [TTCommentDetailHeaderUIHelper cellVerticalPadding];
    self.avatarView.left = [TTCommentDetailHeaderUIHelper cellHorizontalPadding];
    self.avatarView.size = CGSizeMake([TTCommentDetailHeaderUIHelper avatarSize], [TTCommentDetailHeaderUIHelper avatarSize]);
    
    self.nameView.bottom = self.avatarView.centerY - [TTCommentDetailHeaderUIHelper nameViewBottomPadding];
    self.nameView.left = self.avatarView.right + [TTCommentDetailHeaderUIHelper avatarRightPadding];
    
    self.userInfoLabel.left = self.nameView.left;
    self.userInfoLabel.top = self.avatarView.centerY + [TTCommentDetailHeaderUIHelper  userInfoLabelTopPadding];
    
    self.followButton.centerY = self.nameView.centerY;
    self.followButton.top -= 1;
    self.followButton.right = self.width - [TTCommentDetailHeaderUIHelper cellHorizontalPadding];
    CGFloat timeLabelMaxRight;
    if (self.followButton.isHidden) {
        timeLabelMaxRight = self.width - TTCommentDetailHeaderUIHelper.cellHorizontalPadding;
    } else {
        timeLabelMaxRight = self.followButton.left - 15.f;
    }
    if (self.timeLabel.right > timeLabelMaxRight) {
        self.timeLabel.right = timeLabelMaxRight;
        self.userInfoLabel.width = self.timeLabel.left - self.userInfoLabel.left - 2.f;
    }
    self.contentLabel.top = self.userInfoLabel.bottom + [TTDeviceUIUtils tt_newPadding:7];
    
    self.contentLabel.left = self.nameView.left;
    self.contentLabel.width = self.width - [TTCommentDetailHeaderUIHelper cellHorizontalPadding] - self.contentLabel.left;
    self.contentLabel.height = [TTUGCAttributedLabel sizeThatFitsAttributedString:self.contentLabel.attributedText withConstraints:CGSizeMake(self.width - (2 * [TTCommentDetailHeaderUIHelper cellHorizontalPadding]) - [TTCommentDetailHeaderUIHelper avatarSize] - [TTCommentDetailHeaderUIHelper avatarRightPadding], 0) limitedToNumberOfLines:0].height;

    self.groupItemView.left = self.contentLabel.left;
    self.groupItemView.top = self.contentLabel.bottom + 2.f;
    self.groupItemView.width = self.followButton.right - self.groupItemView.left;

    self.timeLabel.left = self.contentLabel.left;
    if (self.needShowGroupItem) {
        self.timeLabel.top = self.groupItemView.bottom + [TTCommentDetailHeaderUIHelper fitSizeWithiPhone6:6.f iPhone6P:10.f iPhone5:6.f];
    } else {
        self.timeLabel.top = self.contentLabel.bottom + [TTCommentDetailHeaderUIHelper fitSizeWithiPhone6:6.f iPhone6P:10.f iPhone5:6.f];
    }
    self.groupItemView.hidden = !self.needShowGroupItem;
    
//    self.reportButton.left = self.timeLabel.right - [TTDeviceUIUtils tt_newPadding:2];
//    self.reportButton.centerY = self.timeLabel.centerY;
    
    self.likeView.top = self.timeLabel.bottom + [TTDeviceUIUtils tt_newPadding:12.f];
    self.likeView.left = self.contentLabel.left;
    
    [self.digButton sizeToFit];
    // 由于sizeToFit没有将EdagesInset考虑进来，造成文字截断，尝试用UIButton也有同样的问题
    CGSize size = self.digButton.frame.size;
    size.width += 6;
    self.digButton.size = size;
    self.digButton.centerY = self.likeView.centerY;
    self.digButton.right = self.followButton.right;
    
    self.deleteButton.centerY = self.timeLabel.centerY;
    self.deleteButton.right = self.followButton.right;
    
    self.reportButton.centerY = self.timeLabel.centerY;
    self.reportButton.right = self.followButton.right;
    
    self.deleteButton.hidden = ![self isSelfComment];
    self.height = self.likeView.bottom + [TTDeviceUIUtils tt_newPadding:16.f];
}

#pragma mark - private methods

- (void)_refreshFollowButtonStateWithModel:(TTCommentDetailModel *)model {
    if ([self isSelfComment]) {
        self.followButton.hidden = YES;
        return;
    }
    if (self.model.user.isFollowing && !_needShowFollowBtnAlways) {
        self.followButton.hidden = YES;
        return;
    }

    if (model.user.isBlocking) {
        [self.followButton setAttributedTitle:nil forState:UIControlStateNormal];
        [self.followButton setTitle:@"取消拉黑" forState:UIControlStateNormal];
        self.followButton.titleColorThemeKey = kColorText3;
        [self.followButton.titleLabel sizeToFit];
        [self.followButton sizeToFit];
        return;
    }
    if (model.user.isFollowing) {
        [self.followButton setTitle:@"已关注" forState:UIControlStateNormal];
        self.followButton.titleColorThemeKey = kColorText3;
    } else {
        [self.followButton setTitle:@"关注" forState:UIControlStateNormal];
        self.followButton.titleColorThemeKey = kColorText5;
    }
    self.followButton.hidden = NO;
    self.needShowFollowBtnAlways = YES; //只要显示过一次 就不再hidden;
    [self.followButton.titleLabel sizeToFit];
    [self.followButton sizeToFit];
    
    // add by zjing 隐藏关注按钮
    self.followButton.hidden = YES;

}

+ (NSAttributedString *)_contentLabelAttributedStringWithModel:(TTCommentDetailModel *)model {
    TTRichSpanText *richSpanText;
    if (!isEmptyString(model.qutoedCommentModel.userID) && !isEmptyString(model.qutoedCommentModel.userName)) {
        /*
         * 回复引用的评论格式 -> COMMENT//@USERNAME：QUOTED COMMENT
         */
        richSpanText = [[TTRichSpanText alloc] initWithText:model.content
                                        richSpansJSONString:model.contentRichSpanJSONString];
        [richSpanText appendCommentQuotedUserName:model.qutoedCommentModel.userName userId:model.qutoedCommentModel.userID];
        TTRichSpanText *quotedRichSpanText = [[TTRichSpanText alloc] initWithText:model.qutoedCommentModel.commentContent
                                                              richSpansJSONString:model.qutoedCommentModel.commentContentRichSpanJSONString];
        [richSpanText appendRichSpanText:quotedRichSpanText];
    } else {
        richSpanText = [[TTRichSpanText alloc] initWithText:model.content
                                        richSpansJSONString:model.contentRichSpanJSONString];
    }

    NSMutableAttributedString *attributedString = [[TTUGCEmojiParser parseInCoreTextContext:richSpanText.text
                                                                                   fontSize:[TTCommentDetailHeaderUIHelper contentLabelFont].pointSize] mutableCopy];

    [attributedString addAttributes:@{
        NSParagraphStyleAttributeName: [TTCommentDetailHeaderUIHelper contentLabelParagraphStyle],
        NSFontAttributeName: [TTCommentDetailHeaderUIHelper contentLabelFont],
        NSForegroundColorAttributeName: [TTCommentDetailHeaderUIHelper contentLabelTextColor]
    } range:NSMakeRange(0, attributedString.length)];

    return attributedString;
}

- (BOOL)isSelfComment {
    if (![TTAccountManager isLogin]) {
        return NO;
    }
    if ([TTAccountManager userIDLongInt] != [self.model.user.ID longLongValue]) {
        return NO;
    }
    return YES;
}

- (NSString *)userRelationStr {
    NSString *result = nil;
    if (self.model.user.isFollowing && self.model.user.isFollowed) {
        result = @"(互相关注)";
    }
    if (self.model.user.isFollowing && !self.model.user.isFollowed) {
        result = @"(已关注)";
    }
    return result;
}

- (void)themeChanged:(NSNotification *)notification {
    [self refreshWithModel:self.model];
}

#pragma mark - getter & setter
- (TTAsyncCornerImageView *)avatarView {
    if (!_avatarView) {
        _avatarView = [[TTAsyncCornerImageView alloc] initWithFrame:CGRectMake([TTCommentDetailHeaderUIHelper cellHorizontalPadding], [TTCommentDetailHeaderUIHelper cellVerticalPadding], [TTCommentDetailHeaderUIHelper avatarSize], [TTCommentDetailHeaderUIHelper avatarSize]) allowCorner:YES];
        _avatarView.cornerRadius = _avatarView.height / 2;
        _avatarView.placeholderName = @"big_defaulthead_head";
        _avatarView.borderWidth = 0;
        _avatarView.coverColor = [[UIColor blackColor] colorWithAlphaComponent:0.05];
        _avatarView.borderColor = [UIColor clearColor];
        [_avatarView setupVerifyViewForLength:[TTCommentDetailHeaderUIHelper avatarNormalSize] adaptationSizeBlock:^CGSize(CGSize standardSize) {
            return [TTCommentDetailHeaderUIHelper verifyLogoSize:standardSize];
        }];
        // add by zjing 去掉头像点击
//        [_avatarView addTouchTarget:self action:@selector(avatarViewOnClick:)];
    }
    return _avatarView;
}

- (TTUserInfoView *)nameView {
    if (!_nameView) {
        CGFloat maxWidth = self.width - [TTCommentDetailHeaderUIHelper cellHorizontalPadding] -[TTCommentDetailHeaderUIHelper avatarSize] - [TTCommentDetailHeaderUIHelper avatarRightPadding] - [TTCommentDetailHeaderUIHelper nameViewRightPadding] - [TTCommentDetailHeaderUIHelper followButtonSize].width - [TTCommentDetailHeaderUIHelper cellHorizontalPadding];
        _nameView = [[TTUserInfoView alloc] initWithBaselineOrigin:CGPointMake(0, 0) maxWidth:maxWidth limitHeight:[UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]].lineHeight title:nil fontSize:[TTCommentDetailHeaderUIHelper nameViewFontSize] verifiedInfo:nil appendLogoInfoArray:nil];
        WeakSelf;
        [_nameView setTextColorThemedKey:[TTCommentDetailHeaderUIHelper nameViewTextColorKey]];
        [_nameView clickTitleWithAction:^(NSString *title){
            StrongSelf;
            [self nameViewOnClick:nil];
        }];
    }
    return _nameView;
}

- (TTDiggButton *)digButton {
    if (!_digButton) {
        _digButton = [TTDiggButton diggButtonWithStyleType:TTDiggButtonStyleTypeCommentOnly];
        _digButton.frame = CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:64], [TTDeviceUIUtils tt_newPadding:24]);
        _digButton.imageEdgeInsets = UIEdgeInsetsMake(-2, 0, 2, 0);
        _digButton.titleEdgeInsets = UIEdgeInsetsMake(0, 6, 0, 0);
        if ([TTDeviceHelper OSVersionNumber] >= 8.f && UIAccessibilityIsBoldTextEnabled()) {
            _digButton.imageEdgeInsets = UIEdgeInsetsMake(-2, -1, 2, 1);
        }
        _digButton.hitTestEdgeInsets = UIEdgeInsetsMake(-14, -14, -14, -14);
        WeakSelf;
        __weak typeof(_digButton) weakDigButton = _digButton;
        [_digButton setClickedBlock:^(TTDiggButtonClickType type) {
            weakDigButton.borderColorThemeKey = kColorLine4;
            [wself digButtonOnClick:weakDigButton];
        }];
    }
    return _digButton;
}

- (SSThemedLabel *)userInfoLabel {
    if (!_userInfoLabel) {
        _userInfoLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _userInfoLabel.font = [TTCommentDetailHeaderUIHelper userInfoLabelFont];
        _userInfoLabel.textColorThemeKey = kColorText13;
        _userInfoLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _userInfoLabel.numberOfLines = 1;
    }
    return _userInfoLabel;
}

- (SSThemedLabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _timeLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        _timeLabel.textColorThemeKey = kColorText1;
    }
    return _timeLabel;
}

- (TTUGCAttributedLabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
        _contentLabel.font = [TTCommentUIHelper tt_fontOfSize:[TTCommentDetailHeaderUIHelper contentLabelFont].pointSize]; // 采用苹方字体能正确居中对齐...
        _contentLabel.textColor = SSGetThemedColorWithKey(kColorText1);
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.layer.backgroundColor = [UIColor clearColor].CGColor;
        _contentLabel.numberOfLines = 0;
        _contentLabel.delegate = self;

        NSDictionary *linkAttributes = @{
            NSParagraphStyleAttributeName: [TTCommentDetailHeaderUIHelper contentLabelParagraphStyle],
            NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText3],
            NSFontAttributeName : [TTCommentDetailHeaderUIHelper contentLabelFont]
        };
        _contentLabel.linkAttributes = linkAttributes;
        _contentLabel.activeLinkAttributes = linkAttributes;
        _contentLabel.inactiveLinkAttributes = linkAttributes;

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
        _deleteButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        _deleteButton.titleColorThemeKey = kColorText13;
        _deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_deleteButton setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteButton sizeToFit];
        [_deleteButton addTarget:self action:@selector(deleteButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
        _deleteButton.hidden = YES;
    }
    return _deleteButton;
}

- (TTColorAsFollowButton *)followButton {
    if (!_followButton) {
        _followButton = [TTColorAsFollowButton buttonWithType:UIButtonTypeCustom];
        _followButton.titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        _followButton.enableHighlightAnim = YES;
        _followButton.titleColorThemeKey = kColorText6;
        [_followButton addTarget:self action:@selector(followButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _followButton;
}

- (SSThemedButton *)reportButton {
    if (!_reportButton) {
        _reportButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _reportButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        _reportButton.titleColorThemeKey = kColorText1;
        _reportButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [_reportButton setTitle:@"举报" forState:UIControlStateNormal];
        [_reportButton sizeToFit];
        [_reportButton addTarget:self action:@selector(reportButtonOnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _reportButton;
}

- (TTCommentDetailHeaderDigItem *)likeView {
    if (!_likeView) {
        _likeView = [[TTCommentDetailHeaderDigItem alloc] initWithModel:self.model Width:self.width - self.avatarView.left - [TTCommentDetailHeaderUIHelper cellHorizontalPadding]];
        _likeView.delegate = self;
    }
    return _likeView;
}

- (TTCommentDetailHeaderGroupItem *)groupItemView {
    if (!_groupItemView) {
        _groupItemView = [[TTCommentDetailHeaderGroupItem alloc] initWithFrame:CGRectMake(0, 0, self.width, [TTDeviceUIUtils tt_padding:58.f])];
        _groupItemView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _groupItemView.hidden = YES;
    }
    return _groupItemView;
}
@end
