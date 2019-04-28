//
//  ExploreCommentCell.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-21.
//
//

#import "ExploreCommentCell.h"
#import "TTCommentReplyListView.h"
#import "ExploreAvatarView+VerifyIcon.h"
#import "UIButton+TTAdditions.h"
#import "SSUserSettingManager.h"
#import "SSMotionRender.h"
#import "DetailActionRequestManager.h"
#import <TTAccountBusiness.h>
#import "SSIndicatorTipsManager.h"
#import "SSAttributeLabel.h"
#import "NewsUserSettingManager.h"
#import "TTRoute.h"
#import "TTForumModel.h"
#import "TTGroupModel.h"

#import "TTLabelTextHelper.h"
#import "TTUserInfoView.h"
#import "FRRouteHelper.h"
#import "TTIndicatorView.h"
#import "TTDeviceHelper.h"
#import "UIImage+TTThemeExtension.h"
#import "TTBusinessManager+StringUtils.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"

#define kAvatarViewSize             (([TTDeviceHelper isPadDevice]) ? 44 : 32)
#define kAvatarRightPadding         15

#define kNameLabelHeight            17
#define kNameLabelFontSize          (([TTDeviceHelper isPadDevice]) ? 18 : 14)
#define kAccessoryTopPadding        (([TTDeviceHelper isPadDevice]) ? 10 : 4)
#define kAccessoryLabelHeight       10
#define kDescLabelTopPadding        (([TTDeviceHelper isPadDevice]) ? 10 : 5)
#define kNameLabelBottomPadding     26      //nameLabel和DesLabel之间的padding

#define kDescLabelFontSize          [SSUserSettingManager commentFontSize]
#define kDescLabelLineHeight        [SSUserSettingManager commentLineHeight]
#define kCellItemBottomPadding      12

#define kForumButtonHeight          30
#define kForumButtonFontSize        14

#define kTimeLabelHeight            20
#define kTimeLabelFontSize          12

#define kLeftMargin                 (([TTDeviceHelper isPadDevice]) ? 20 : 14)
#define kTopMargin                  (([TTDeviceHelper isPadDevice]) ? 15 : 14)
#define kRightMargin                (([TTDeviceHelper isPadDevice]) ? 20 : 12)
#define kBottomMargin               (([TTDeviceHelper isPadDevice]) ? 17 : 16)

#define kCommentMaxNumOfLines       8

#define kDisplayTopicMaxLength      20

//顶，评论button的frame
#define kCommentButtonWidth         (([TTDeviceHelper isPadDevice]) ? 49.5f : 48)
#define kCommentButtonHeight        28
#define kDigButtonWidth             (([TTDeviceHelper isPadDevice]) ? 74.5f : 54)


@interface ExploreCommentCell()

@property(nonatomic, strong, readwrite)SSCommentModel * commentModel;
@property(nonatomic, strong)ExploreAvatarView * avatarView;
@property(nonatomic, strong)UIView * bottomLineView;
@property(nonatomic, strong)TTUserInfoView * nameView;
@property(nonatomic, strong)UILabel * pgcAuthorLabel;
@property(nonatomic, strong)UILabel * accessoryLabel;
@property(nonatomic, strong)UILabel * descLabel;
@property(nonatomic, strong)TTCommentReplyListView *replyListView;
@property(nonatomic, strong)UIButton *forumButton;
@property(nonatomic, strong)UILabel * timeLabel;    //4.9开始隐藏评论时间标签
@property(nonatomic, strong)UIButton * digButton;
// @property(nonatomic, retain)UIButton * commentButton;
@property(nonatomic, strong)DetailActionRequestManager * actionManager;
@property(nonatomic, strong)UIButton * deleteButton;

@property(nonatomic, strong)UIButton * showMoreButton;
@property(nonatomic, assign)BOOL isEssay;
@end

@implementation ExploreCommentCell

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    self.delegate = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier frame:(CGRect)frame isEssay:(BOOL)isEssay
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = frame;
        _isEssay = isEssay;
        [self buildView];
        [self themeChanged:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fontSizeChanged) name:kSettingFontSizeChangedNotification object:nil];
    }
    return self;
}

- (void)buildView
{
    self.avatarView = [[ExploreAvatarView alloc] initWithFrame:CGRectMake(kLeftMargin, kTopMargin, kAvatarViewSize, kAvatarViewSize)];
    self.avatarView.enableRoundedCorner = YES;
    self.avatarView.placeholder = @"big_defaulthead_head";
    
    [_avatarView addTouchTarget:self action:@selector(avatarViewClicked)];
    [self.avatarView setupVerifyViewForLength:32.f adaptationSizeBlock:^CGSize(CGSize standardSize) {
        CGFloat vWidth = ceil(standardSize.width * kAvatarViewSize / 32);
        return CGSizeMake(vWidth, vWidth);
    }];
    [self.contentView addSubview:_avatarView];
    
    self.pgcAuthorLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 23.f, 12.f)];
    self.pgcAuthorLabel.backgroundColor = [UIColor clearColor];
    self.pgcAuthorLabel.font = [UIFont systemFontOfSize:[TTDeviceHelper isPadDevice] ? 12.f : 9.f];
    self.pgcAuthorLabel.textAlignment = NSTextAlignmentCenter;
    self.pgcAuthorLabel.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.pgcAuthorLabel.layer.cornerRadius = 2.f;
    self.pgcAuthorLabel.text = @"作者";
    self.pgcAuthorLabel.hidden = YES;
    [self.contentView addSubview:_pgcAuthorLabel];
    
    self.accessoryLabel = [[UILabel alloc] init];
    self.accessoryLabel.backgroundColor = [UIColor clearColor];
    self.accessoryLabel.clipsToBounds = YES;
    self.accessoryLabel.font = [UIFont systemFontOfSize:10.f];
    self.accessoryLabel.hidden = YES;
    [self.contentView addSubview:_accessoryLabel];
    
    self.descLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    self.descLabel.clipsToBounds = YES;
    _descLabel.font = [UIFont systemFontOfSize:kDescLabelFontSize];
    _descLabel.backgroundColor = [UIColor clearColor];
    _descLabel.numberOfLines = kCommentMaxNumOfLines;
    [self.contentView addSubview:_descLabel];
    [self.descLabel setUserInteractionEnabled:YES];
    UIGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]
                                      initWithTarget:self action:@selector(handleLongPress:)];
    [self.descLabel addGestureRecognizer:longPress];
    
    self.forumButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _forumButton.titleLabel.font = [UIFont systemFontOfSize:kForumButtonFontSize];
    _forumButton.titleLabel.textAlignment = NSTextAlignmentLeft;
    _forumButton.backgroundColor = [UIColor clearColor];
    _forumButton.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    _forumButton.layer.cornerRadius = 6;
    _forumButton.hidden = YES;
    [self.contentView addSubview:_forumButton];
    
    self.timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel.font = [UIFont systemFontOfSize:kTimeLabelFontSize];
    _timeLabel.backgroundColor = [UIColor clearColor];
    _timeLabel.numberOfLines = 1;
    
    self.deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _deleteButton.backgroundColor = [UIColor clearColor];
    _deleteButton.titleLabel.font = [UIFont systemFontOfSize:kDescLabelFontSize];
    [_deleteButton setTitle:NSLocalizedString(@"删除", nil) forState:UIControlStateNormal];
    _deleteButton.hidden = YES;
    [_deleteButton addTarget:self action:@selector(deleteButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [_deleteButton sizeToFit];
    [self.contentView addSubview:_deleteButton];
    
    CGFloat shouldExplandHitTestSize = -16;
    
    self.commentButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _commentButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 1, 0, 0)];
    [_commentButton addTarget:self action:@selector(commentButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _commentButton.titleLabel.font = [UIFont systemFontOfSize:13.f];
    _commentButton.backgroundColor = [UIColor clearColor];
    [_commentButton setHitTestEdgeInsets:UIEdgeInsetsMake(shouldExplandHitTestSize, 0, shouldExplandHitTestSize, shouldExplandHitTestSize)];
    [self.contentView addSubview:_commentButton];
    
    self.digButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _digButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    [_digButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 1, 0, 0)];
//    [_digButton setImageEdgeInsets:UIEdgeInsetsMake(-3, 0, 0, 0)];
    [_digButton addTarget:self action:@selector(digButtonClicked) forControlEvents:UIControlEventTouchUpInside];
    _digButton.titleLabel.font = [UIFont systemFontOfSize:13.f];
    _digButton.backgroundColor = [UIColor clearColor];
    [_digButton setHitTestEdgeInsets:UIEdgeInsetsMake(shouldExplandHitTestSize, shouldExplandHitTestSize, shouldExplandHitTestSize, 0)];
    [self.contentView addSubview:_digButton];
    
    self.showMoreButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _showMoreButton.backgroundColor = [UIColor clearColor];
    _showMoreButton.hidden = YES;
    _showMoreButton.titleLabel.font = [UIFont systemFontOfSize:kDescLabelFontSize];
    [_showMoreButton setTitle:@"查看全文" forState:UIControlStateNormal];
    [_showMoreButton setTitle:@"查看全文" forState:UIControlStateHighlighted];
    [_showMoreButton sizeToFit];
    [_showMoreButton addTarget:self action:@selector(ShowMoreButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_showMoreButton];
    
    self.bottomLineView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_bottomLineView];
}

- (void)fontSizeChanged
{
    _descLabel.font = [UIFont systemFontOfSize:kDescLabelFontSize];
    _deleteButton.titleLabel.font = [UIFont systemFontOfSize:kDescLabelFontSize];
    [_deleteButton sizeToFit];
    _showMoreButton.titleLabel.font = [UIFont systemFontOfSize:kDescLabelFontSize];
    [_showMoreButton sizeToFit];
}

- (void)themeChanged:(NSNotification *)notification
{
    self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
    
    //    _nameLabel.textColor = SSGetThemedColorWithKey(kColorText3);
    //    _nameLabel.backgroundColor = self.backgroundColor;
    _pgcAuthorLabel.textColor = [TTDeviceHelper isPadDevice] ? SSGetThemedColorWithKey(kColorText3) : SSGetThemedColorWithKey(kColorText5);
    _pgcAuthorLabel.layer.borderColor = [SSGetThemedColorWithKey(kColorLine6) CGColor];
    _accessoryLabel.textColor = SSGetThemedColorWithKey(kColorText9);
    _accessoryLabel.backgroundColor = self.backgroundColor;
    _descLabel.textColor = SSGetThemedColorWithKey(kColorText2);
    _descLabel.backgroundColor = self.backgroundColor;
    _bottomLineView.backgroundColor = [TTDeviceHelper isPadDevice] ? SSGetThemedColorWithKey(kColorLine10) : [UIColor colorWithDayColorName:@"dddddd" nightColorName:@"363636"];
    UIView *selectedColor = [UIView new];
    selectedColor.backgroundColor = [UIColor colorWithDayColorName:@"dddddd" nightColorName:@"1b1b1b"];
    self.selectedBackgroundView = selectedColor;
    [_commentButton setImage:[UIImage themedImageNamed:@"comment_video.png"] forState:UIControlStateNormal];
    [_commentButton setImage:[UIImage themedImageNamed:@"comment_video_press.png"] forState:UIControlStateHighlighted];
    [_commentButton setTitleColor:[UIColor colorWithDayColorName:@"999999" nightColorName:@"707070"] forState:UIControlStateNormal];
    [self refreshDiggButton];
    [_deleteButton setTitleColor:SSGetThemedColorWithKey(kColorText5) forState:UIControlStateNormal];
    
    [_forumButton setTitleColor:SSGetThemedColorWithKey(kColorText5) forState:UIControlStateNormal];
    _forumButton.layer.borderColor = [SSGetThemedColorWithKey(kColorLine6) CGColor];
    
    [_showMoreButton setTitleColor:SSGetThemedColorWithKey(kColorText5) forState:UIControlStateNormal];
}


- (void)refreshCondition:(SSCommentModel *)model
{
    self.commentModel = model;
    
    [_avatarView setImageWithURLString:model.userAvatarURL];
    [_avatarView showOrHideVerifyViewWithVerifyInfo:model.userAuthInfo decoratorInfo:nil sureQueryWithID:YES userID:nil];
    
    CGFloat titleLabelOriginX = CGRectGetMaxX(_avatarView.frame) + kAvatarRightPadding;
    if (!_nameView) {
        CGFloat maxWidth = self.width - titleLabelOriginX - kRightMargin - 135;
        _nameView = [[TTUserInfoView alloc] initWithBaselineOrigin:CGPointMake(titleLabelOriginX, kTopMargin + 1 + kNameLabelHeight/2) maxWidth:maxWidth limitHeight:kNameLabelHeight title:model.userName fontSize:kNameLabelFontSize verifiedInfo:model.verifiedInfo verified:NO owner:NO appendLogoInfoArray:model.authorBadgeList];
        [self.contentView addSubview:_nameView];
    }
    else {
        [_nameView refreshWithTitle:model.userName relation:nil verifiedInfo:model.verifiedInfo verified:NO owner:NO maxWidth:0 appendLogoInfoArray:model.authorBadgeList];
    }
    __weak typeof(self) wSelf = self;
    [_nameView clickTitleWithAction:^(NSString *title) {
        [wSelf nameViewClicked];
    }];
    
    self.pgcAuthorLabel.centerY = _nameView.centerY;
    self.accessoryLabel.frame = CGRectMake(_nameView.left + ([TTDeviceHelper isPadDevice] ? 5.f : 0), kTopMargin + kNameLabelHeight + 1 + kAccessoryTopPadding, 120, kAccessoryLabelHeight);
//    _pgcAuthorLabel.hidden = !model.isPGCAuthor;
    _pgcAuthorLabel.left = _nameView.right + ([TTDeviceHelper isPadDevice] ? 5.f : 3.f);
    
    NSString *accessoryInfo = [[self class] showAccessoryInfoWithModel:model];
    if (!isEmptyString(accessoryInfo)) {
        [_accessoryLabel setText:accessoryInfo];
        _accessoryLabel.hidden = NO;
    }
    
    [self refreshDescLabelTextWithModel:model];
    
    if (model.forumModel) {
        [_forumButton setTitle:[[self class] displayForumNameForModel:model] forState:UIControlStateNormal];
        [_forumButton addTarget:self action:@selector(pushToforumViewController) forControlEvents:UIControlEventTouchUpInside];
    }
    
    [_timeLabel setText:[TTBusinessManager customtimeStringSince1970:[model.commentCreateTime doubleValue]]];
    
    [self refreshFrame];
    [self refreshCommentButton];
    [self refreshDiggButton];
}

- (void)refreshDescLabelTextWithModel:(SSCommentModel *)model
{
    [_descLabel setAttributedText:[TTLabelTextHelper attributedStringWithString:model.commentContent fontSize:kDescLabelFontSize lineHeight:kDescLabelLineHeight lineBreakMode:NSLineBreakByTruncatingTail]];
}

- (void)refreshDiggButton
{
    NSString * diggCount = nil;
    diggCount = [NSString stringWithFormat:@"%@", [TTBusinessManager formatCommentCount:[_commentModel.digCount intValue]]];
    [_digButton setTitle:diggCount forState:UIControlStateNormal];
    if (_commentModel.userDigged) {
        [_digButton setImage:[UIImage themedImageNamed:@"digup_video_press.png"] forState:UIControlStateNormal];
        [_digButton setImage:[UIImage themedImageNamed:@"digup_video_press.png"] forState:UIControlStateHighlighted];
        [_digButton setTitleColor:SSGetThemedColorWithKey(kColorText4) forState:UIControlStateNormal];
    }
    else {
        [_digButton setImage:[UIImage themedImageNamed:@"digup_video.png"] forState:UIControlStateNormal];
        [_digButton setImage:[UIImage themedImageNamed:@"digup_video.png"] forState:UIControlStateHighlighted];
        [_digButton setTitleColor:SSGetThemedColorWithKey(kColorText3) forState:UIControlStateNormal];
    }
}

- (void)refreshCommentButton
{
    
    NSString *commentCountString = nil;
    commentCountString = [NSString stringWithFormat:@"%@", [TTBusinessManager formatCommentCount:[self.commentModel.replyCount intValue]]];
    [self.commentButton setTitle:commentCountString forState:UIControlStateNormal];
    [self.commentButton setTitleColor:SSGetThemedColorWithKey(kColorText3) forState:UIControlStateNormal];
}

- (void)refreshFrame
{
    //如果没有accessory信息，nameLabel相对于avatar垂直居中
    CGFloat descLabelOriY;
    NSString *accessoryInfo = [[self class] showAccessoryInfoWithModel:_commentModel];
    if (isEmptyString(accessoryInfo)) {
        _nameView.centerY = _avatarView.centerY;
        descLabelOriY = kTopMargin + kNameLabelHeight + (kAvatarViewSize - kNameLabelHeight)/2 + kDescLabelTopPadding;
    }
    else {
        _nameView.centerY = kTopMargin + 1 + kNameLabelHeight/2;
        descLabelOriY = _accessoryLabel.bottom + kDescLabelTopPadding;
    }
    _commentButton.frame = CGRectMake(self.width - kRightMargin - kCommentButtonWidth, 0, kCommentButtonWidth, kCommentButtonHeight);
    _commentButton.centerY = _avatarView.centerY;
    _digButton.frame = CGRectMake(self.width - kRightMargin - kCommentButtonWidth - kDigButtonWidth, CGRectGetMinY(_commentButton.frame), kDigButtonWidth, CGRectGetHeight(_commentButton.frame));
    
    CGFloat descLabelHeight = [ExploreCommentCell descLabelHeightForModel:self.commentModel width:self.width];
    CGFloat descLabelWidth = [ExploreCommentCell widthForDescLabel:self.width];
    
    _descLabel.frame = CGRectMake(_nameView.left, descLabelOriY, descLabelWidth, descLabelHeight);
    
    CGFloat cursorOrinY = _descLabel.bottom;
    if (_commentModel.forumModel) {
        //显示话题入口
        [_forumButton sizeToFit];
        CGFloat realHeight = [TTLabelTextHelper heightOfText:_forumButton.titleLabel.text fontSize:_forumButton.titleLabel.font.pointSize forWidth:_forumButton.width];
        _forumButton.frame = CGRectMake(_descLabel.left, cursorOrinY + kCellItemBottomPadding, _forumButton.width + 20, realHeight + 13);
        _forumButton.hidden = NO;
        cursorOrinY += kCellItemBottomPadding + _forumButton.height;
    }
    else {
        _forumButton.hidden = YES;
    }
    
    BOOL needShowShowMoreButton = [ExploreCommentCell needShowShowMoreButtonForModel:self.commentModel width:self.width descLabelHeight:descLabelHeight];
    if (needShowShowMoreButton) {
        _showMoreButton.hidden = NO;
        _showMoreButton.left = _descLabel.left;
        _showMoreButton.top = kCellItemBottomPadding + cursorOrinY;
        cursorOrinY += kCellItemBottomPadding + _showMoreButton.height;
    } else {
        _showMoreButton.hidden = YES;
    }
    
    if ([TTAccountManager isLogin] &&
        [_commentModel.userID longLongValue] != 0 &&
        [TTAccountManager userIDLongInt] == [_commentModel.userID longLongValue])
    {
        _deleteButton.hidden = NO;
        CGFloat left;
        if (needShowShowMoreButton) {
            left = _showMoreButton.right + 5;
        }
        else {
            left = _descLabel.left;
        }
        _deleteButton.left = left;
        CGFloat y = needShowShowMoreButton ? _showMoreButton.top : (kCellItemBottomPadding + cursorOrinY);
        cursorOrinY += needShowShowMoreButton ? 0 : (kCellItemBottomPadding + _deleteButton.height);
        _deleteButton.top = y;
    }
    else {
        _deleteButton.hidden = YES;
    }
    
    if ([_commentModel hasReply]) {
        if (!_replyListView) {
            _replyListView = [[TTCommentReplyListView alloc] initWithWidth:descLabelWidth
                                                                 toComment:(id<TTCommentModelProtocol>)_commentModel];
            __weak typeof(self) wself = self;
            [_replyListView didClickReplyToMakeAction:^(TTCommentReplyModel *replyModel) {
                if (wself.delegate && [wself.delegate respondsToSelector:@selector(commentViewCellBase:replyListClickedWithModel:)]) {
                    [wself.delegate commentViewCellBase:wself replyListClickedWithModel:wself.commentModel];
                    wrapperTrackEvent(@"comment", @"enter_detail_comment");
                }
            }];
            [_replyListView didClickReplyToViewUser:^(TTCommentReplyModel *replyModel) {
                //定位到profile或moment详情页
                if ([replyModel isUserReplyModel]) {
                    if (wself.delegate && [wself.delegate respondsToSelector:@selector(commentViewCellBase:replyListAvatarClickedWithUserID:commentModel:)]) {
                        [wself.delegate commentViewCellBase:wself replyListAvatarClickedWithUserID:replyModel.userID commentModel:wself.commentModel];
                    }
                }
                else {
                    if (wself.delegate && [wself.delegate respondsToSelector:@selector(commentViewCellBase:replyListClickedWithModel:)]) {
                        wrapperTrackEvent(@"comment", @"enter_detail_comment");
                        [wself.delegate commentViewCellBase:wself replyListClickedWithModel:wself.commentModel];
                    }
                }
            }];
            [self.contentView addSubview:_replyListView];
        }
        [_replyListView refreshReplyListWithComment:(id<TTCommentModelProtocol>)_commentModel];
        _replyListView.origin = CGPointMake(_descLabel.left, kCellItemBottomPadding + cursorOrinY);
        _replyListView.hidden = NO;
        cursorOrinY += kCellItemBottomPadding + _replyListView.height;
    }
    else {
        _replyListView.hidden = YES;
    }
    
    _bottomLineView.frame = CGRectMake(15.f, cursorOrinY + kBottomMargin - 0.5, [[UIScreen mainScreen] bounds].size.width - 30.f, [TTDeviceHelper ssOnePixel]);
}

- (void)shouldHideBottomline:(BOOL)shouldHide
{
    _bottomLineView.hidden = shouldHide;
}

- (void)prepareForReuse
{
    [self shouldHideBottomline:NO];
}

+ (CGFloat)widthForDescLabel:(CGFloat)cellWidth
{
    return ceil(cellWidth - kLeftMargin - kAvatarViewSize - kAvatarRightPadding - kRightMargin - 4);
}

+ (CGFloat)descLabelHeightWithoutLinesLimitForModel:(SSCommentModel *)model width:(CGFloat)width
{
    return [self descLabelHeightForModel:model width:[self widthForDescLabel:width] maxNumberOfLines:0];
}

+ (CGFloat)descLabelHeightForModel:(SSCommentModel *)model width:(CGFloat)width
{
    return [self descLabelHeightForModel:model width:[self widthForDescLabel:width] maxNumberOfLines:kCommentMaxNumOfLines];
}

+ (CGFloat)descLabelHeightForModel:(SSCommentModel *)model width:(CGFloat)width maxNumberOfLines:(NSInteger)numberOfLines
{
    if (isEmptyString(model.commentContent)) {
        return kDescLabelFontSize + 3;
    }
    
    return [TTLabelTextHelper heightOfText:model.commentContent fontSize:kDescLabelFontSize forWidth:width forLineHeight:kDescLabelLineHeight constraintToMaxNumberOfLines:numberOfLines firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
}

+ (NSString *)displayForumNameForModel:(SSCommentModel *)model
{
    NSString *displayForumName = model.forumModel.name;
    if (displayForumName.length > kDisplayTopicMaxLength) {
        displayForumName = [displayForumName substringToIndex:kDisplayTopicMaxLength - 1];
    }
    return displayForumName;
}

+ (BOOL)needShowShowMoreButtonForModel:(SSCommentModel *)model width:(CGFloat)width descLabelHeight:(CGFloat)descLabelHeight
{
    if (descLabelHeight <= 0) {
        descLabelHeight = [self descLabelHeightForModel:model width:width];
    }
    return ([self descLabelHeightWithoutLinesLimitForModel:model width:width] > descLabelHeight);
}

+ (CGFloat)heightForModel:(SSCommentModel *)model width:(CGFloat)width
{
    CGFloat height = kTopMargin;
    height += kNameLabelHeight;
    NSString *accessoryInfo = [[self class] showAccessoryInfoWithModel:model];
    if (isEmptyString(accessoryInfo)) {
        height += (kAvatarViewSize - kNameLabelHeight)/2 + kDescLabelTopPadding;
    }
    else {
        height += kAccessoryLabelHeight + kAccessoryTopPadding + kDescLabelTopPadding + 1;
    }
    
    CGFloat descLabelHeight = [self descLabelHeightForModel:model width:width];
    height += descLabelHeight;
    
    if (model.forumModel) {
        height += kCellItemBottomPadding + kForumButtonHeight;
    }
    
    BOOL shouldShowDeleteButton = [TTAccountManager isLogin] && [model.userID longLongValue] != 0 && [TTAccountManager userIDLongInt] == [model.userID longLongValue];
    
    if ([self needShowShowMoreButtonForModel:model width:width descLabelHeight:descLabelHeight] ||
        shouldShowDeleteButton) {
        UIButton * tmpButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tmpButton.titleLabel.font = [UIFont systemFontOfSize:kDescLabelFontSize];
        [tmpButton setTitle:@"查看全文" forState:UIControlStateNormal];
        [tmpButton setTitle:@"查看全文" forState:UIControlStateHighlighted];
        [tmpButton sizeToFit];
        height += kCellItemBottomPadding + tmpButton.height;
    }
    
    if ([model hasReply]) {
        height += kCellItemBottomPadding + [TTCommentReplyListView heightForListViewWithReplyArr:model.replyModelArr width:[ExploreCommentCell widthForDescLabel:width] toComment:(id<TTCommentModelProtocol>)model];
    }
    
    height += kBottomMargin;
    height += [TTDeviceHelper ssOnePixel];
    
    return height;
}

+ (NSString *)showAccessoryInfoWithModel:(SSCommentModel *)model
{
    NSString *accessoryInfo = model.accessoryInfo;
    if (isEmptyString(accessoryInfo)) {
        accessoryInfo = [TTBusinessManager customtimeStringSince1970:[model.commentCreateTime doubleValue]];
    }
    return accessoryInfo;
}

#pragma mark -- button response

- (void)avatarViewClicked
{
    wrapperTrackEvent(@"comment", @"click_avatar");
    [self showAuthorProfile];
}

- (void)nameViewClicked
{
    wrapperTrackEvent(@"comment", @"click_name");
    [self showAuthorProfile];
}

- (void)showAuthorProfile
{
    if([self.commentModel.userID longLongValue] > 0)
    {
        if (_delegate && [_delegate respondsToSelector:@selector(commentViewCellBase:avatarTappedWithCommentModel:)]) {
            [_delegate commentViewCellBase:self avatarTappedWithCommentModel:self.commentModel];
        }
    }
    
    [self hideMenu];
}

- (void)digButtonClicked
{
    if (!_commentModel.userDigged && !_commentModel.userBuried) {
        [SSMotionRender motionInView:_digButton byType:SSMotionTypeZoomInAndDisappear image:[UIImage themedImageNamed:@"add_all_dynamic.png"] offsetPoint:CGPointMake(-13.f, -5.f)];
        if (!_actionManager) {
            self.actionManager = [[DetailActionRequestManager alloc] init];
        }
        _commentModel.userDigged = YES;
        _commentModel.digCount = @([_commentModel.digCount intValue] + 1);
        _digButton.imageView.contentMode = UIViewContentModeCenter;
        _digButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        _digButton.imageView.alpha = 1.f;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            _digButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
            _digButton.imageView.alpha = 0.f;
        } completion:^(BOOL finished){
            [self refreshDiggButton];
            _digButton.imageView.alpha = 0.f;
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                _digButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
                _digButton.imageView.alpha = 1.f;
            } completion:^(BOOL finished){
                
            }];
        }];
        [self showDigupIndicatorView];
        
        TTDetailActionReuestContext *context = [TTDetailActionReuestContext new];
        context.itemCommentID = [NSString stringWithFormat:@"%@", _commentModel.commentID];
        context.groupModel = _commentModel.groupModel;
        [_actionManager setContext:context];
        
        [_actionManager startItemActionByType:DetailActionCommentDigg];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        [dic setValue:_commentModel.commentID.stringValue forKey:@"ext_value"];
        wrapperTrackEventWithCustomKeys(@"comment", @"digg_button", _commentModel.groupModel.groupID, nil, dic);
    }
    else if (_commentModel.userDigged) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经赞过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
    else {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经踩过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
    [self hideMenu];
}

- (void)deleteButtonClicked:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentViewCellBase:deleteCommentWithCommentModel:)]) {
        [_delegate commentViewCellBase:self deleteCommentWithCommentModel:self.commentModel];
    }
}

- (void)commentButtonClicked
{
    wrapperTrackEvent(@"comment", @"click_comment");
    if (_commentModel.isBlocking || _commentModel.isBlocked) {
        NSString * description = nil;
        if (_commentModel.isBlocked) {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockedUser];
            if (!description) {
                description = @" 根据对方设置，您不能进行此操作";
            }
        } else {
            description = [[SSIndicatorTipsManager shareInstance] indicatorTipsForKey:kTipForActionToBlockingUser];
            if (!description) {
                description = @"您已拉黑此用户，不能进行此操作";
            }
        }
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(description, nil) indicatorImage:[UIImage themedImageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
        
        return;
    }
    if (_delegate && [_delegate respondsToSelector:@selector(commentViewCellBase:replyButtonClickedWithModel:)]) {
        [_delegate commentViewCellBase:self replyButtonClickedWithModel:self.commentModel];
    }
}

////////////////////////////////////////

#pragma mark -- protected

- (void)showDigupIndicatorView {
    
}

/*
 *  tableViewCell选中时会默认清除所有subView的backgroundColor，需要重新设置
 */
#pragma mark - UIResponder

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self.avatarView.imageView refreshCoverView];
    if ([_commentModel hasReply]) {
        [_replyListView refreshReplyListBackgroundColors];
    }
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self.avatarView.imageView refreshCoverView];
    if ([_commentModel hasReply]) {
        [_replyListView refreshReplyListBackgroundColors];
    }
}

- (void)pushToforumViewController
{
    if (!isEmptyString(_commentModel.forumModel.forumID) && !isEmptyString(_commentModel.groupModel.groupID)) {
        [FRRouteHelper openForumDetailByForumID:[_commentModel.forumModel.forumID longLongValue] enterFrom:@"click_detail_comment" threadID:0 group:[_commentModel.groupModel.groupID longLongValue]];
    }
    else {
        NSString *scheme = _commentModel.forumModel.desc;
        if (!isEmptyString(scheme)) {
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:scheme]];
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)handleLongPress:(UIGestureRecognizer*)recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        UIMenuItem *copyItem = [[UIMenuItem alloc] initWithTitle:NSLocalizedString(@"复制", nil) action:@selector(customCopy:)];
        if (copyItem) {
            menu.menuItems = @[copyItem];
        }
        [menu setTargetRect:self.descLabel.frame inView:self.descLabel.superview];
        [menu setMenuVisible:YES animated:YES];
        [self changeDescLabelBackgroundColor];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willHideMenu) name:UIMenuControllerWillHideMenuNotification object:nil];
    }
}

- (void)willHideMenu {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIMenuControllerWillHideMenuNotification object:nil];
    [self resetDescLabelBackgroundColor];
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(__unused id)sender
{
    return (action == @selector(customCopy:));
}

- (void)changeDescLabelBackgroundColor
{
    self.descLabel.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"d4d4d4" nightColorName:@"353535"]];
}

- (void)resetDescLabelBackgroundColor
{
    self.descLabel.backgroundColor = self.backgroundColor;
}

- (void)customCopy:(__unused id)sender {
    [[UIPasteboard generalPasteboard] setString:self.descLabel.text];
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
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

- (void)ShowMoreButtonClicked:(id)sender
{
    if (_delegate && [_delegate respondsToSelector:@selector(commentViewCellBase:showMoreButtonClickedWithModel:)]) {
        [_delegate commentViewCellBase:self showMoreButtonClickedWithModel:self.commentModel];
    }
}

@end
