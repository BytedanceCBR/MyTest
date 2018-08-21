//
//  TTWendaCellView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/7/13.
//
//

#import "TTWendaCellView.h"
#import "TTWendaCellHelper.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTTAttributedLabel.h"
#import "TTAlphaThemedButton.h"
#import "TTFeedDislikeView.h"
#import "WDLayoutHelper.h"
#import "TTWenda.h"
#import "TTRoute.h"
#import "WDUIHelper.h"
#import "ExploreAvatarView.h"
#import "WDAnswerEntity.h"
#import "WDQuestionEntity.h"
#import "WDQuestionDescEntity.h"
#import "TTPlatformSwitcher.h"
#import "TTVerifyIconHelper.h"
#import "NSStringAdditions.h"
#import "ExploreAvatarView+VerifyIcon.h"
#import "TTNetworkUtilities.h"
#import "TTIndicatorView.h"
#import "FriendDataManager.h"
#import "ExploreMixListDefine.h"
#import "SSMotionRender.h"
#import "NSObject+FBKVOController.h"
#import "WDDefines.h"
#import "TTUGCDefine.h"
#import "TTWendaCellViewModel.h"
#import "FRButtonLabel.h"
#import "TTUIResponderHelper.h"
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import "TTFollowThemeButton.h"

@interface TTWendaCellView ()

// header view
@property (nonatomic, strong) SSThemedView *headerView;
@property (nonatomic, strong) ExploreAvatarView *avartarView;
@property (nonatomic, strong) FRButtonLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *actionLabel;
@property (nonatomic, strong) SSThemedLabel *introLabel;
@property (nonatomic, strong) TTFollowThemeButton *followButton;
// content view
@property (nonatomic, strong) SSThemedView *contentView;
@property (nonatomic, strong) TTTAttributedLabel *contentLabel;
@property (nonatomic, strong) TTImageView   *firstImageView;
@property (nonatomic, strong) TTImageView   *secondImageView;
@property (nonatomic, strong) TTImageView   *thirdImageView;
@property (nonatomic, strong) TTAlphaThemedButton  *answerButton;
@property (nonatomic, strong) SSThemedLabel *bottomLabel;
@property (nonatomic, strong) TTAlphaThemedButton *dislikeBtn;
@property (nonatomic, strong) SSThemedView  *lineView;
// viewModel
@property (nonatomic, strong) TTWendaCellViewModel *viewModel;

@property (nonatomic, assign) BOOL                isSelfFollow; //区分关注来源
@property (nonatomic, assign) CGFloat             cellTotalWidth;

@end

@implementation TTWendaCellView

- (void)dealloc {
    [self removeObserveNotification];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self createSubviews];
    }
    return self;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if ([TTWendaCellHelper verifyWithWendaOrderedData:data]) {
        ExploreOrderedData *orderedData = data;
        TTWendaCellViewModel *model = [[TTWendaCellViewModelManager sharedInstance] getCellBaseModelFromOrderedData:orderedData];
        // 只缓存主体的高度，上下padding因为随时会变化并且并不需要怎么计算所以不需要缓存
        [model calculateLayoutIfNeedWithOrderedData:orderedData cellWidth:width listType:listType];
        return model.cellCacheHeight;
    }
    return 0;
}

- (id)cellData {
    return self.orderedData;
}

- (void)refreshUI {
    [self refreshLayOutSubviews];
}

- (void)refreshWithData:(id)data {
    [self removeObserveKVO];
    if ([TTWendaCellHelper verifyWithWendaOrderedData:data]) {
        ExploreOrderedData *orderedData = data;
        self.orderedData = orderedData;
        self.viewModel = [[TTWendaCellViewModelManager sharedInstance] getCellBaseModelFromOrderedData:orderedData];
        if (!isEmptyString(self.viewModel.avatarUrl)) {
            [self.avartarView setImageWithURLString:self.viewModel.avatarUrl];
            [self.avartarView showOrHideVerifyViewWithVerifyInfo:self.viewModel.userAuthInfo decoratorInfo:self.viewModel.userDecoration sureQueryWithID:YES userID:nil];
        }
        else {
            [self.avartarView setImageWithURLString:nil];
            [self.avartarView hideVerifyView];
        }
        self.nameLabel.text = [NSString stringWithFormat:@"%@",self.viewModel.username];
        self.actionLabel.text = self.viewModel.actionTitle;
        self.followButton.hidden = self.viewModel.isFollowButtonHidden;
        if ([self.viewModel.userId isEqualToString:[TTAccountManager userID]]) {
            self.followButton.hidden = YES;
        }
        [self refreshIntroLabelContent];
        [self refreshFollowButtonState];
        [self refreshContentLabelText];
        if (self.viewModel.cellShowType == TTWendaCellViewTypeQuestionPureTitle) {
            self.bottomLabel.text = self.viewModel.bottomContent;
        }
        else if (self.viewModel.cellShowType == TTWendaCellViewTypeQuestionRightImage) {
            self.bottomLabel.text = self.viewModel.bottomContent;
            [self.firstImageView setImageWithModel:self.viewModel.questionImageModel];
        }
        else if (self.viewModel.cellShowType == TTWendaCellViewTypeQuestionThreeImage) {
            self.bottomLabel.text = self.viewModel.bottomContent;
            [self.firstImageView setImageWithModel:[self.viewModel.threeImageModels objectAtIndex:0]];
            [self.secondImageView setImageWithModel:[self.viewModel.threeImageModels objectAtIndex:1]];
            [self.thirdImageView setImageWithModel:[self.viewModel.threeImageModels objectAtIndex:2]];
        }
        [self addObserveKVO];
        [self refreshLayOutSubviews];
        [self addObserveNotification];
    }
}

#pragma mark - Layout View

- (CGFloat)totalWidthForLayout {
    if (self.cellTotalWidth) {
        return self.cellTotalWidth;
    }
    CGFloat totalWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat valueWidth = totalWidth;
    if ([TTDeviceHelper isPadDevice]) {
        CGSize windowSize = [TTUIResponderHelper windowSize];
        CGFloat edgePadding = [TTUIResponderHelper paddingForViewWidth:windowSize.width];
        valueWidth = windowSize.width - edgePadding*2;
    }
    if (totalWidth > valueWidth) {
        totalWidth = valueWidth;
    }
    self.cellTotalWidth = totalWidth;
    return totalWidth;
}

- (CGFloat)contentWidthForLayout {
    CGFloat totalWidth = [self totalWidthForLayout];
    CGFloat contentWidth = totalWidth - 15*2;
    return contentWidth;
}

- (void)layoutUserHeaderInfoViewWithTop:(CGFloat)top {
    CGFloat headerHeight = [TTDeviceUIUtils tt_padding:15.0] + 36.0 + [TTDeviceUIUtils tt_padding:8.0];
    self.headerView.frame = CGRectMake(0, top, [self totalWidthForLayout], headerHeight);
    
    self.avartarView.left = 15;
    self.avartarView.top = [TTDeviceUIUtils tt_padding:15.0];
    
    self.nameLabel.top = self.avartarView.top + 2;
    self.nameLabel.left = self.avartarView.right + 10;
    
    [self.actionLabel sizeToFit];
    self.actionLabel.height = 14;
    self.actionLabel.top = self.nameLabel.top;
    
    [self.introLabel sizeToFit];
    self.introLabel.height = 12;
    self.introLabel.left = self.nameLabel.left;
    self.introLabel.top = self.nameLabel.bottom + 6;
    
    [self refreshUserHeaderSubviewsPosition];
    
    if (isEmptyString(self.introLabel.text)) {
        self.introLabel.width = 0;
        self.nameLabel.centerY = self.avartarView.top + self.avartarView.height / 2.0;
        self.actionLabel.top = self.nameLabel.top;
    }
    
    if (!self.viewModel.isFollowButtonHidden) {
        self.followButton.top = self.nameLabel.top - 7.0;
        self.followButton.right = self.headerView.width - 15;
    }
    
}

- (void)layoutContentLabelViewWithTop:(CGFloat)top {
    CGFloat contentWidth = [self contentWidthForLayout];
    if (self.viewModel.cellShowType == TTWendaCellViewTypeQuestionRightImage) {
        CGFloat mediumImageWidth = [TTDeviceUIUtils tt_padding:113];
        CGFloat questionLabelWidth = contentWidth - mediumImageWidth - [TTDeviceUIUtils tt_padding:12];
        contentWidth = questionLabelWidth;
    }
    self.contentLabel.frame = CGRectMake(15, top, contentWidth, self.viewModel.contentLabelHeight);
}

- (void)layoutRightQuestionImageViewWithTop:(CGFloat)top {
    CGFloat totalWidth = [self totalWidthForLayout];
    
    CGFloat mediumImageHeight = [TTDeviceUIUtils tt_padding:74];
    CGFloat mediumImageWidth = [TTDeviceUIUtils tt_padding:113];
    
    self.firstImageView.top = top;
    self.firstImageView.width = mediumImageWidth;
    self.firstImageView.height = mediumImageHeight;
    self.firstImageView.right = totalWidth - 15;
}

- (void)layoutThreeQuestionImageViewWithTop:(CGFloat)top {
    CGFloat contentWidth = [self contentWidthForLayout];
    
    CGFloat mediumImageHeight = [TTDeviceUIUtils tt_padding:74];
    CGFloat mediumImageWidth = [TTDeviceUIUtils tt_padding:113];
    
    CGFloat threeImageWidth = (contentWidth - 6)/3;
    CGFloat threeImageHeight = ceilf(threeImageWidth * mediumImageHeight / mediumImageWidth);
    
    self.firstImageView.frame = CGRectMake(15, top, threeImageWidth, threeImageHeight);
    self.secondImageView.frame = CGRectMake(self.firstImageView.right + 3, self.firstImageView.top, threeImageWidth, threeImageHeight);
    self.thirdImageView.frame = CGRectMake(self.secondImageView.right + 3, self.firstImageView.top, threeImageWidth, threeImageHeight);
}

- (void)layoutBottomLabelViewWithTop:(CGFloat)top {
    self.bottomLabel.top = top;
    [self.bottomLabel sizeToFit];
    self.bottomLabel.height = 12;
    self.bottomLabel.left = 15 + 39 + [TTDeviceUIUtils tt_padding:12];
}

- (void)layoutJumpToAnswerButton {
    self.answerButton.left = 15;
    self.answerButton.centerY = self.bottomLabel.centerY;
}

- (void)layoutDislikeButtonIfImageLeft:(BOOL)isImageLeft {
    [self.dislikeBtn removeFromSuperview];
    [self.contentView addSubview:self.dislikeBtn];
    self.dislikeBtn.centerY = self.bottomLabel.centerY;
    if (isImageLeft) {
        self.dislikeBtn.right = self.firstImageView.left - [TTDeviceUIUtils tt_padding:20] + (60-17)/2;
    }
    else {
        self.dislikeBtn.right = [self totalWidthForLayout] - 15 + (60-17)/2;
    }
}

- (void)layoutSingleLineViewWithTop:(CGFloat)top {
    self.lineView.left = 15;
    self.lineView.width = [self contentWidthForLayout];
    self.lineView.top = top;
    self.lineView.height = self.viewModel.showBottomLine ? [TTDeviceHelper ssOnePixel] : 0;
}

# pragma mark - Refresh View

- (void)refreshLayOutSubviews {
    if (self.viewModel.cellCacheHeight == 0) return;
    self.cellTotalWidth = 0;
    CGFloat totalWidth = [self totalWidthForLayout];
    [self layoutUserHeaderInfoViewWithTop:0];
    CGFloat startY = self.headerView.bottom;
    self.contentView.width = totalWidth;
    self.contentView.top = startY;
    self.answerButton.hidden = YES;
    self.firstImageView.hidden = YES;
    self.secondImageView.hidden = YES;
    self.thirdImageView.hidden = YES;
    
    CGFloat contentLabelTop = [TTDeviceUIUtils tt_padding:3.0];
    
    if (self.viewModel.cellShowType == TTWendaCellViewTypeQuestionPureTitle) {
        self.answerButton.hidden = NO;
        [self layoutContentLabelViewWithTop:contentLabelTop];
        [self layoutBottomLabelViewWithTop:self.contentLabel.bottom - 2 + [TTDeviceUIUtils tt_padding:14.0]];
        [self layoutJumpToAnswerButton];
        [self layoutDislikeButtonIfImageLeft:NO];
        [self layoutSingleLineViewWithTop:self.bottomLabel.bottom + [TTDeviceUIUtils tt_padding:14.0]];
        self.contentView.height = self.lineView.bottom;
    }
    else if (self.viewModel.cellShowType == TTWendaCellViewTypeQuestionRightImage) {
        self.answerButton.hidden = NO;
        self.firstImageView.hidden = NO;
        [self layoutContentLabelViewWithTop:contentLabelTop];
        [self layoutRightQuestionImageViewWithTop:self.contentLabel.top];
        CGFloat bottomLabelTop = 0;
        CGFloat mediumImageHeight = [TTDeviceUIUtils tt_padding:74];
        BOOL isLabelMoreHeight = (self.viewModel.contentLabelHeight > mediumImageHeight);
        if (self.viewModel.isThreeLineInRightImage && !isLabelMoreHeight) {
            bottomLabelTop = (self.firstImageView.bottom + [TTDeviceUIUtils tt_padding:10]);
        }
        else {
            bottomLabelTop = (self.contentLabel.bottom - 2 + [TTDeviceUIUtils tt_padding:14.0]);
        }
        [self layoutBottomLabelViewWithTop:bottomLabelTop];
        [self layoutJumpToAnswerButton];
        if (self.viewModel.isThreeLineInRightImage) {
            [self layoutDislikeButtonIfImageLeft:NO];
            [self layoutSingleLineViewWithTop:self.bottomLabel.bottom + [TTDeviceUIUtils tt_padding:14.0]];
        }
        else {
            [self layoutDislikeButtonIfImageLeft:YES];
            [self layoutSingleLineViewWithTop:self.firstImageView.bottom + [TTDeviceUIUtils tt_padding:14.0]];
        }
        self.contentView.height = self.lineView.bottom;
    }
    else if (self.viewModel.cellShowType == TTWendaCellViewTypeQuestionThreeImage) {
        self.answerButton.hidden = NO;
        self.firstImageView.hidden = NO;
        self.secondImageView.hidden = NO;
        self.thirdImageView.hidden = NO;
        [self layoutContentLabelViewWithTop:contentLabelTop];
        [self layoutThreeQuestionImageViewWithTop:self.contentLabel.bottom - 2 + [TTDeviceUIUtils tt_padding:5.0]];
        [self layoutBottomLabelViewWithTop:self.firstImageView.bottom + [TTDeviceUIUtils tt_padding:14.0]];
        [self layoutJumpToAnswerButton];
        [self layoutDislikeButtonIfImageLeft:NO];
        [self layoutSingleLineViewWithTop:self.bottomLabel.bottom + [TTDeviceUIUtils tt_padding:14.0]];
        self.contentView.height = self.lineView.bottom;
    }
}

- (void)refreshIntroLabelContent {
    self.introLabel.text = [self.viewModel secondLineContentIsFollowChannel:[self.categoryID isEqualToString:kTTFollowCategoryID]];
    self.isSelfFollow = NO;
}

// 关注按钮不显示的情况
- (void)refreshIntroLabelsPosition {
    CGFloat secondLineMaxWidth = [self headerViewSecondLineMaxTextWidthForLayout];
    [self.introLabel sizeToFit];
    self.introLabel.height = 12;
    if (!isEmptyString(self.introLabel.text)) {
        self.nameLabel.top = self.avartarView.top + 2;
        if (self.introLabel.width > secondLineMaxWidth) {
            self.introLabel.width = secondLineMaxWidth;
        }
    }
    else {
        self.introLabel.width = 0;
        self.nameLabel.centerY = self.avartarView.top + self.avartarView.height / 2.0;
    }
    self.actionLabel.top = self.nameLabel.top;
    if (self.viewModel.cellShowType == TTWendaFeedCellTypeAnswer) {
        self.dislikeBtn.centerY = self.nameLabel.centerY;
    }
    else {
        self.dislikeBtn.centerY = self.bottomLabel.centerY;
    }
}

- (void)refreshFollowButtonState {
    [self.followButton setFollowed:self.viewModel.wenda.userEntity.isFollowing];
    self.isSelfFollow = NO;
}

// 关注按钮显示的情况
- (void)refreshUserHeaderSubviewsPosition {
    CGFloat firstLineMaxWidth = [self headerViewFirstLineMaxTextWidthForLayout];
    CGFloat secondLineMaxWidth = [self headerViewSecondLineMaxTextWidthForLayout];
    CGFloat nameLabelMaxWidth = firstLineMaxWidth - self.actionLabel.width - 6;
    [self.nameLabel sizeToFit];
    self.nameLabel.height = 14;
    CGFloat fittingWidth = self.nameLabel.width;
    if (self.nameLabel.width > nameLabelMaxWidth) {
        self.nameLabel.width = nameLabelMaxWidth;
    }
    else {
        self.nameLabel.width = fittingWidth;
    }
    self.actionLabel.left = self.nameLabel.right + 6;
    if (!isEmptyString(self.introLabel.text)) {
        if (self.introLabel.width > secondLineMaxWidth) {
            self.introLabel.width = secondLineMaxWidth;
        }
    }
}

- (CGFloat)headerViewFirstLineMaxTextWidthForLayout {
    CGFloat firstLineMaxWidth = self.headerView.width - (self.avartarView.right + 10) - 15;
    if (!self.viewModel.isFollowButtonHidden) {
        firstLineMaxWidth -= ([TTDeviceUIUtils tt_padding:20] + 42);
    }
    return firstLineMaxWidth;
}

- (CGFloat)headerViewSecondLineMaxTextWidthForLayout {
    CGFloat secondLineMaxWidth = self.headerView.width - (self.avartarView.right + 10) - 15;
    secondLineMaxWidth -= ([TTDeviceUIUtils tt_padding:15] + 17); // dislike icon 的宽度
    return secondLineMaxWidth;
}

- (void)refreshContentLabelText {
    CGFloat fontSize = 0;
    NSString *title = @"";
    NSString *textColorKey = kColorText1;
    if (![self.categoryID isEqualToString:kTTFollowCategoryID] && self.viewModel.wenda.hasRead.boolValue) {
        textColorKey = kColorText1Highlighted;
    }
    if (self.viewModel.cellShowType == TTWendaCellViewTypeQuestionRightImage) {
        fontSize = [TTWendaCellViewModel feedQuestionAbstractContentFontSize];
        title = self.viewModel.questionTitle;
        self.contentLabel.attributedTruncationToken = nil;
        self.contentLabel.font = [UIFont systemFontOfSize:fontSize];
    }
    else {
        fontSize = [TTWendaCellViewModel feedQuestionAbstractContentFontSize];
        title = self.viewModel.questionTitle;
        self.contentLabel.attributedTruncationToken = nil;
        self.contentLabel.font = [UIFont systemFontOfSize:fontSize];
    }
    NSMutableAttributedString *attributedString = [WDLayoutHelper attributedStringWithString:title fontSize:fontSize lineHeight:fontSize lineSpace:6];
    
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:textColorKey] range:NSMakeRange(0, [attributedString.string length])];
    self.contentLabel.text = attributedString;
}

- (void)refreshBottomLabelContent {
    self.bottomLabel.text = self.viewModel.bottomContent;
    [self.bottomLabel sizeToFit];
    self.bottomLabel.height = 12;
}

# pragma mark - private

- (void)createSubviews {
    [self createUserHeaderInfoView];
    [self createMainContentView];
}

- (void)createUserHeaderInfoView {
    self.headerView = [[SSThemedView alloc] init];
    self.headerView.backgroundColorThemeKey = kColorBackground4;
    [self addSubview:self.headerView];
    
    [self.headerView addSubview:self.avartarView];
    
    WeakSelf;
    self.nameLabel = [[FRButtonLabel alloc] init];
    self.nameLabel.font = [UIFont boldSystemFontOfSize:14];
    self.nameLabel.textColorThemeKey = kColorText1;
    self.nameLabel.tapHandle = ^{
        StrongSelf;
        [self avatarViewClick];
    };
    [self.headerView addSubview:self.nameLabel];
    
    self.actionLabel = [[SSThemedLabel alloc] init];
    self.actionLabel.font = [UIFont systemFontOfSize:14];
    self.actionLabel.textColorThemeKey = kColorText1;
    [self.headerView addSubview:self.actionLabel];
    
    self.introLabel = [[SSThemedLabel alloc] init];
    self.introLabel.font = [UIFont systemFontOfSize:12];
    self.introLabel.textColorThemeKey = kColorText3;
    [self.headerView addSubview:self.introLabel];
    
    [self.headerView addSubview:self.followButton];
}

- (void)createMainContentView {
    self.contentView = [[SSThemedView alloc] init];
    self.contentView.backgroundColorThemeKey = kColorBackground4;
    [self addSubview:self.contentView];
    
    self.contentLabel = [[TTTAttributedLabel alloc] init];
    self.contentLabel.font = [UIFont systemFontOfSize:[TTWendaCellViewModel feedQuestionAbstractContentFontSize]];
    self.contentLabel.numberOfLines = 3;
    [self.contentView addSubview:self.contentLabel];
    
    self.bottomLabel = [[SSThemedLabel alloc] init];
    self.bottomLabel.font = [UIFont systemFontOfSize:12];
    self.bottomLabel.textColorThemeKey = kColorText3;
    [self.contentView addSubview:self.bottomLabel];
    
    [self.contentView addSubview:self.answerButton];
    [self.contentView addSubview:self.dislikeBtn];
    
    [self createThreeImageView];
    
    self.lineView = [[SSThemedView alloc] init];
    self.lineView.backgroundColorThemeKey = kColorLine1;
    [self.contentView addSubview:self.lineView];
}

- (void)createThreeImageView {
    self.firstImageView = [[TTImageView alloc] init];
    self.firstImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.firstImageView.backgroundColorThemeKey = kColorBackground2;
    self.firstImageView.borderColorThemeKey = kColorLine1;
    self.firstImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.firstImageView];
    
    self.secondImageView = [[TTImageView alloc] init];
    self.secondImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.secondImageView.backgroundColorThemeKey = kColorBackground2;
    self.secondImageView.borderColorThemeKey = kColorLine1;
    self.secondImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.secondImageView];
    
    self.thirdImageView = [[TTImageView alloc] init];
    self.thirdImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.thirdImageView.backgroundColorThemeKey = kColorBackground2;
    self.thirdImageView.borderColorThemeKey = kColorLine1;
    self.thirdImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.thirdImageView];
}

- (void)addObserveKVO {
    WeakSelf;
    if (![self.categoryID isEqualToString:kTTFollowCategoryID]) {
        [self.KVOController observe:self.viewModel.wenda.userEntity keyPath:NSStringFromSelector(@selector(isFollowing)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            TTWendaCellView *cellView = observer;
            if (!cellView.followButton.hidden) {
                if (!cellView.isSelfFollow) {
                    [cellView refreshFollowButtonState];
                }
            }
            else {
                [cellView refreshIntroLabelContent];
                [cellView refreshIntroLabelsPosition];
            }
        }];
    }
    [self.KVOController observe:self.viewModel.wenda.questionEntity keyPath:NSStringFromSelector(@selector(followCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self refreshBottomLabelContent];
    }];
    [self.KVOController observe:self.viewModel.wenda.questionEntity keyPath:NSStringFromSelector(@selector(niceAnsCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self refreshBottomLabelContent];
    }];
    [self.KVOController observe:self.viewModel.wenda.questionEntity keyPath:NSStringFromSelector(@selector(normalAnsCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self refreshBottomLabelContent];
    }];
}

- (void)removeObserveKVO {
    [self.KVOController unobserveAll];
}

- (void)addObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
}

- (void)removeObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)updateFollowStateWithNewIsFollowing:(BOOL)isFollowing {
    if (self.viewModel.wenda.userEntity.isFollowing == isFollowing) {
        return;
    }
    self.viewModel.wenda.userEntity.isFollowing = isFollowing;
    [self.viewModel.wenda save];
}

# pragma mark - Notification

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    [self refreshContentLabelText];
}

- (void)followNotification:(NSNotification *)notify {
    // 仅用来处理外面的
    if (self.isSelfFollow) {
        return;
    }
    NSString * userID = notify.userInfo[kRelationActionSuccessNotificationUserIDKey];
    NSString * userIDOfSelf = self.viewModel.userId;
    if (!isEmptyString(userID) && [userID isEqualToString:userIDOfSelf]) {
        NSInteger actionType = [(NSNumber *)notify.userInfo[kRelationActionSuccessNotificationActionTypeKey] integerValue];
        BOOL isFollowedState = self.viewModel.wenda.userEntity.isFollowing;
        if (actionType == FriendActionTypeFollow) {
            isFollowedState = YES;
        }else if (actionType == FriendActionTypeUnfollow) {
            isFollowedState = NO;
        }
        [self updateFollowStateWithNewIsFollowing:isFollowedState];
    }
}

# pragma mark - Action

- (void)avatarViewClick {
    [self.viewModel enterUserInfoPage];
}

/*
 *关注逻辑：
 * 未关注时：展示关注按钮，头像旁不展示关注与否相关文案；点击切换状态，文案不更新；跳转个人页面切换状态，文案不更新，按钮切换状态
 * 已关注时：不展示关注按钮，头像旁展示已关注文案；跳转个人页面切换状态，文案更新，按钮隐藏依旧
 * 也就是按钮展示时，更新按钮状态；按钮不展示时，更新文案内容
 * 展示按钮时：
 * 未关注点击按钮，成功后展开推荐用户卡片；dislike按钮变sanjiao按钮；点击可切换展开收起状态
 * 已关注点击按钮，成功后收起推荐用户卡片；sanjiao按钮变dislike按钮
 * 此处需要直接修改按钮状态，避免等待通知后闪动一下
 */
- (void)followButtonClick:(TTFollowThemeButton *)followBtn {
    if (self.followButton.isLoading) {
        return;
    }
    
    //
    BOOL isFollowed = self.viewModel.isFollowed;
    
    if (isFollowed) {
        [self eventV3:@"rt_unfollow" extra:@{@"follow_type":@"from_group"} userIDKey:@"to_user_id"];
    }
    else {
        [self eventV3:@"rt_follow" extra:@{@"follow_type":@"from_group"} userIDKey:@"to_user_id"];
    }
    
    self.isSelfFollow = YES;
    
    [followBtn startLoading];
    WeakSelf;
    [[TTFollowManager sharedManager] startFollowAction:isFollowed? FriendActionTypeUnfollow: FriendActionTypeFollow
                                             userID:self.viewModel.userId
                                           platform:nil
                                               name:nil
                                               from:nil
                                             reason:nil
                                          newReason:nil
                                          newSource:@(TTFollowNewSourceFeedWendaCell)
                                         completion:^(FriendActionType type, NSError * _Nullable error, NSDictionary * _Nullable result) {
                                             StrongSelf;
                                             if (!error) {
                                                 BOOL expand = (type == FriendActionTypeFollow ? YES : NO);
                                                 [self updateFollowStateWithNewIsFollowing:expand];
                                                 [followBtn stopLoading:^{}];
                                                 [self refreshFollowButtonState];
                                             }
                                             else {
                                                 NSString *hint = [[[result tt_dictionaryValueForKey:@"result"] tt_dictionaryValueForKey:@"data"] tt_stringValueForKey:@"description"];
                                                 if (!TTNetworkConnected()) {
                                                     hint = @"网络不给力，请稍后重试";
                                                 }
                                                 if (isEmptyString(hint)) {
                                                     hint = NSLocalizedString(type == FriendActionTypeFollow ? @"关注失败" : @"取消关注失败", nil);
                                                 }
                                                 [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:hint indicatorImage:[UIImage imageNamed:@"close_popup_textpage.png"] autoDismiss:YES dismissHandler:nil];
                                                 [followBtn stopLoading:^{}];
                                                 [self refreshFollowButtonState];
                                             }
                                             
                                         }];
}

- (void)dislikeViewClick:(UIButton *)dislikeBtn {
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = self.viewModel.dislikeWords;
    viewModel.groupID = self.viewModel.uniqueId;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = dislikeBtn.center;
    [dislikeView showAtPoint:point
                    fromView:dislikeBtn
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

- (void)answerButtonClick {
    [self.viewModel enterAnswerQuestionPage];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict setValue:self.orderedData.categoryID forKey:@"category_name"];
    [dict setValue:self.viewModel.wenda.questionEntity.qid forKey:@"qid"];
    [dict setValue:self.viewModel.wenda.questionEntity.allAnsCount forKey:@"t_ans_num"];
    [dict setValue:self.viewModel.wenda.questionEntity.niceAnsCount forKey:@"r_ans_num"];
    [TTTrackerWrapper eventV3:@"channel_write_answer" params:dict];
}

- (void)backgroundViewClick {
    [self.viewModel enterAnswerListPage];
    [self refreshContentLabelText];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self backgroundViewClick];
}

# pragma mark TTFeedDislikeView

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)view {
    if (!self.orderedData) {
        return;
    }
    NSArray *filterWords = [view selectedWords];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

#pragma mark - Track Event

- (void)eventV3:(NSString *)event extra:(NSDictionary *)extra
{
    [self eventV3:event extra:extra userIDKey:nil];
}

- (void)eventV3:(NSString *)event extra:(NSDictionary *)extra userIDKey:(NSString *)userIDKey
{
    NSMutableDictionary *params = nil;
    if ([extra count] > 0) {
        params = [NSMutableDictionary dictionaryWithDictionary:extra];
    }
    else{
        params = [NSMutableDictionary dictionary];
    }
    
    if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
        [params setValue:@"click_headline" forKey:@"enter_from"];
    }
    else{
        [params setValue:@"click_category" forKey:@"enter_from"];
    }
    [params setValue:self.orderedData.categoryID forKey:@"category_name"];
    [params setValue:self.orderedData.uniqueID forKey:@"group_id"];
    [params setValue:self.viewModel.wenda.questionEntity.qid forKey:@"qid"];
    [params setValue:self.viewModel.wenda.answerEntity.ansid forKey:@"ansid"];
    if (!isEmptyString(userIDKey)){
        [params setValue:self.viewModel.userId forKey:userIDKey];
    }
    else{
        [params setValue:self.viewModel.userId forKey:@"user_id"];
    }
    [TTTrackerWrapper eventV3:event params:params];
}

#pragma mark - GET/SET

- (NSString *)categoryID {
    return self.orderedData.categoryID;
}

- (ExploreAvatarView *)avartarView {
    if (!_avartarView) {
        _avartarView = [[ExploreAvatarView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
        _avartarView.imageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _avartarView.userInteractionEnabled = YES;
        _avartarView.enableRoundedCorner = YES;
        _avartarView.highlightedMaskView = nil;
        _avartarView.imageView.layer.cornerRadius = self.avartarView.width/2.f;
        [_avartarView addTouchTarget:self action:@selector(avatarViewClick)];
        [_avartarView setupVerifyViewForLength:36 adaptationSizeBlock:nil];
        
        UIView *coverView = [[UIView alloc] initWithFrame:self.avartarView.bounds];
        coverView.backgroundColor = [UIColor blackColor];
        coverView.layer.opacity = 0.05;
        coverView.layer.cornerRadius = coverView.width / 2.f;
        coverView.layer.masksToBounds = YES;
        [_avartarView insertSubview:coverView belowSubview:self.avartarView.verifyView];
    }
    return _avartarView;
}

- (TTFollowThemeButton *)followButton {
    if (!_followButton) {
        TTFollowedType followType = TTFollowedType102;
        TTUnfollowedType unFollowType = TTUnfollowedType102;
        TTFollowedMutualType mutualType = TTFollowedMutualType102;
        _followButton = [[TTFollowThemeButton alloc] initWithUnfollowedType:unFollowType followedType:followType followedMutualType:mutualType];
        [_followButton addTarget:self action:@selector(followButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _followButton;
}

- (TTAlphaThemedButton *)answerButton {
    if (!_answerButton) {
        // 39, 12 -> 39, 18
        _answerButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 39, 24)];
        _answerButton.titleColorThemeKey = kColorText5;
        _answerButton.imageName = @"write_ask";
        _answerButton.titleLabel.font = [UIFont systemFontOfSize:12];
        [_answerButton setTitle:@"回答" forState:UIControlStateNormal];
        [_answerButton setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 0)];
        [_answerButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, 0)];
        [_answerButton addTarget:self action:@selector(answerButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _answerButton;
}

- (TTAlphaThemedButton *)dislikeBtn {
    if (!_dislikeBtn) {
        // 17,12 -> 60,44
        _dislikeBtn = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _dislikeBtn.titleColorThemeKey = kColorText4;
        _dislikeBtn.imageName = @"add_textpage";
        [_dislikeBtn addTarget:self action:@selector(dislikeViewClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dislikeBtn;
}

@end

