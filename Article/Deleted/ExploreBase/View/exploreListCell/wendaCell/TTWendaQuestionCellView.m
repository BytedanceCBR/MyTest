//
//  TTWendaQuestionCellView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/10/12.
//

#import "TTWendaQuestionCellView.h"
#import "TTWendaQuestionCellViewModel.h"
#import "TTWendaCellHelper.h"
#import "ExploreAvatarView.h"
#import "ExploreAvatarView+VerifyIcon.h"
#import <FRButtonLabel.h>
#import "TTAlphaThemedButton.h"
#import "TTTAttributedLabel.h"
#import <TTFriendRelation/TTFollowManager.h>
#import <TTFriendRelation/TTFollowThemeButton.h>
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import "FriendDataManager.h"
#import "NSObject+FBKVOController.h"
#import "TTUGCDefine.h"
#import "WDLayoutHelper.h"
#import "WDUIHelper.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "WDPersonModel.h"
#import "WDAnswerEntity.h"
#import "WDQuestionEntity.h"
#import "WDQuestionDescEntity.h"
#import "TTFeedDislikeView.h"
#import "ExploreMixListDefine.h"
#import "WDDefines.h"
#import "TTWendaCellView.h"

@interface TTWendaQuestionCellView()

// header view
@property (nonatomic, strong) SSThemedView *headerView;
@property (nonatomic, strong) ExploreAvatarView *avartarView;
@property (nonatomic, strong) FRButtonLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *actionLabel;
@property (nonatomic, strong) SSThemedLabel *introLabel;
@property (nonatomic, strong) TTFollowThemeButton *followButton;
@property (nonatomic, strong) TTAlphaThemedButton *dislikeBtn;
// content view
@property (nonatomic, strong) SSThemedView *contentView;
// Not UGC Style Use
@property (nonatomic, strong) TTTAttributedLabel *contentLabel;
@property (nonatomic, strong) TTImageView   *firstImageView;
@property (nonatomic, strong) TTImageView   *secondImageView;
@property (nonatomic, strong) TTImageView   *thirdImageView;
// UGC Style Use
@property (nonatomic, strong) SSThemedLabel *postQuestionLabel;
@property (nonatomic, strong) SSThemedView  *questionDescView;
@property (nonatomic, strong) TTImageView   *questionImageView;
@property (nonatomic, strong) SSThemedView  *questionImageMaskView;
@property (nonatomic, strong) TTTAttributedLabel *questionDescLabel;
// both Use
@property (nonatomic, strong) SSThemedLabel *bottomLabel;
// line view
@property (nonatomic, strong) SSThemedView  *lineView;
// answer view
@property (nonatomic, strong) TTAlphaThemedButton  *answerButton;
// separate view
@property (nonatomic, strong) SSThemedView       *topSeparateView;
@property (nonatomic, strong) SSThemedView       *bottomSeparateView;
// layout & view model
@property (nonatomic, strong) TTWendaQuestionCellLayoutModel *layoutModel;
@property (nonatomic, strong) TTWendaQuestionCellViewModel *viewModel;

@property (nonatomic, assign) BOOL                isSelfFollow; //区分关注来源
@property (nonatomic, assign) CGFloat             cellTotalWidth;

// only for plan A
@property (nonatomic, strong) TTWendaCellView *oldCellView;

@end

@implementation TTWendaQuestionCellView

#pragma mark - Public

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if ([TTWendaCellHelper verifyWithWendaOrderedData:data]) {
        TTWendaQuestionCellLayoutModel *model = [[TTWendaQuestionCellLayoutModelManager sharedInstance] getCellBaseModelFromOrderedData:(ExploreOrderedData *)data];
        if (model.viewModel.isInvalidData) {
            return 0;
        }
        if (model.questionLayoutType == TTWendaQuestionLayoutTypeOld) {
            return [TTWendaCellView heightForData:data cellWidth:width listType:listType];
        }
        [model calculateLayoutIfNeedWithCellWidth:width];
        CGFloat topSepHeight = model.showTopSepView ? [TTDeviceUIUtils tt_padding:6] : 0;
        CGFloat bottomSepHeight = model.showBottomSepView ? [TTDeviceUIUtils tt_padding:6] : 0;
        return model.cellCacheHeight + topSepHeight + bottomSepHeight;
    }
    return 0;
}

- (id)cellData {
    return self.viewModel.orderedData;
}

- (void)refreshWithData:(id)data {
    if ([TTWendaCellHelper verifyWithWendaOrderedData:data]) {
        self.layoutModel = [[TTWendaQuestionCellLayoutModelManager sharedInstance] getCellBaseModelFromOrderedData:(ExploreOrderedData *)data];
        self.viewModel = self.layoutModel.viewModel;
        if (self.viewModel.isInvalidData) {
            return;
        }
        if (self.layoutModel.questionLayoutType == TTWendaQuestionLayoutTypeOld) {
            [self createOldCellViewIfNeeded];
            [self.oldCellView refreshWithData:data];
            return;
        }
        if (self.oldCellView) {
            self.oldCellView.hidden = YES;
        }
        [self createSubviewsIfNeeded];
        self.headerView.hidden = NO;
        self.contentView.hidden = NO;
        self.lineView.hidden = NO;
        self.answerButton.hidden = NO;
        self.topSeparateView.hidden = NO;
        self.bottomSeparateView.hidden = NO;
        [self removeObserveKVO];
        if (!isEmptyString(self.viewModel.avatarUrl)) {
            [self.avartarView setImageWithURLString:self.viewModel.avatarUrl];
            [self.avartarView showOrHideVerifyViewWithVerifyInfo:self.viewModel.userAuthInfo decoratorInfo:self.viewModel.userDecoration sureQueryWithID:YES userID:nil];
        }
        else {
            [self.avartarView setImageWithURLString:nil];
            [self.avartarView hideVerifyView];
        }
        self.nameLabel.text = self.viewModel.username;
        self.followButton.hidden = self.layoutModel.isFollowButtonHidden;
        if ([self.viewModel.userId isEqualToString:[TTAccountManager userID]]) {
            self.followButton.hidden = YES;
        }
        [self refreshIntroLabelContent];
        [self refreshFollowButtonState];
        if (self.layoutModel.questionLayoutType == TTWendaQuestionLayoutTypeUGC) {
            self.postQuestionLabel.hidden = NO;
            self.questionDescView.hidden = NO;
            self.questionImageView.hidden = NO;
            self.questionImageMaskView.hidden = NO;
            self.postQuestionLabel.text = @"提出问题";
            self.postQuestionLabel.font = [UIFont systemFontOfSize:[TTWendaQuestionCellLayoutModel feedPostQuestionLabelFontSize]];
            [self refreshQuestionImageView];
            [self refreshQuestionTitleText];
            if (self.contentLabel) {
                self.contentLabel.hidden = YES;
            }
            if (self.firstImageView) {
                self.firstImageView.hidden = YES;
                self.secondImageView.hidden = YES;
                self.thirdImageView.hidden = YES;
            }
            self.actionLabel.text = @"";
        }
        else {
            self.contentLabel.hidden = NO;
            self.actionLabel.text = self.viewModel.actionTitle;
            [self refreshContentLabelText];
            [self refreshQuestionAllImageViews];
            if (self.postQuestionLabel) {
                self.postQuestionLabel.hidden = YES;
            }
            if (self.questionDescView) {
                self.questionDescView.hidden = YES;
                self.questionImageView.hidden = YES;
                self.questionImageMaskView.hidden = YES;
            }
        }
        self.bottomLabel.text = self.viewModel.bottomContent;
        [self refreshLayOutSubviews];
        [self addObserveKVO];
        [self addObserveNotification];
    }
}

- (void)refreshUI {
    if (self.viewModel.isInvalidData) {
        return;
    }
    if (self.layoutModel.questionLayoutType == TTWendaQuestionLayoutTypeOld) {
        [self.oldCellView refreshUI];
    }
    else {
        [self refreshLayOutSubviews];
    }
}

#pragma mark - Layout

- (void)refreshLayOutSubviews {
    if (self.viewModel.isInvalidData) {
        return;
    }
    self.cellTotalWidth = 0;
    CGFloat totalWidth = [self totalWidthForLayout];
    [self layoutTopSeparateView];
    [self layoutUserHeaderInfoViewWithTop:self.topSeparateView.bottom];
    CGFloat startY = self.headerView.bottom;
    self.contentView.width = totalWidth;
    self.contentView.top = startY;
    
    CGFloat bottomLabelTop = 0;
    if (self.layoutModel.questionLayoutType == TTWendaQuestionLayoutTypeUGC) {
        self.postQuestionLabel.top = 0;
        self.postQuestionLabel.left = 15;
        [self.postQuestionLabel sizeToFit];
        self.postQuestionLabel.height = [TTWendaQuestionCellLayoutModel feedPostQuestionLabelLineHeight];
        [self layoutQuestionDescViewWithTop:self.postQuestionLabel.bottom + [TTDeviceUIUtils tt_padding:9.0]];
        bottomLabelTop = self.questionDescView.bottom;
        self.bottomLabel.hidden = self.layoutModel.isBottomLabelAndLineHidden;
        if (self.layoutModel.isBottomLabelAndLineHidden) {
            self.bottomLabel.width = 0;
            self.bottomLabel.height = 0;
            self.contentView.height = bottomLabelTop;
        } else {
            bottomLabelTop += [TTDeviceUIUtils tt_padding:9.0];
            [self layoutBottomLabelViewWithTop:bottomLabelTop];
            self.contentView.height = self.bottomLabel.bottom + [TTDeviceUIUtils tt_padding:10.0];
        }
    }
    else {
        CGFloat contentLabelTop = [TTDeviceUIUtils tt_padding:3.0];
        [self layoutContentLabelViewWithTop:contentLabelTop];
        self.bottomLabel.hidden = NO;
        self.firstImageView.hidden = YES;
        self.secondImageView.hidden = YES;
        self.thirdImageView.hidden = YES;
        bottomLabelTop = self.contentLabel.bottom - 2 + [TTDeviceUIUtils tt_padding:10.0];
        if (self.viewModel.viewType != TTWendaQuestionCellViewTypePureTitle) {
            [self layoutQuestionImageViewWithTop:bottomLabelTop];
            bottomLabelTop = self.firstImageView.bottom + [TTDeviceUIUtils tt_padding:10.0];
        }
        [self layoutBottomLabelViewWithTop:bottomLabelTop];
        self.contentView.height = self.bottomLabel.bottom + [TTDeviceUIUtils tt_padding:10.0];
    }
    
    [self layoutAnswerViewWithTop:self.contentView.bottom];
    [self layoutBottomSeparateViewWithTop:self.answerButton.bottom];
}

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

- (CGFloat)headerViewFirstLineMaxTextWidthForLayout {
    CGFloat firstLineMaxWidth = self.headerView.width - (self.avartarView.right + 10) - 15;
    firstLineMaxWidth -= ([TTDeviceUIUtils tt_padding:15] + 17); // dislike icon 的宽度
    if (!self.layoutModel.isFollowButtonHidden) {
        // 关注按钮和dislike之间的间距是20，关注按钮或dislike与前面文字最小间距都是15
        firstLineMaxWidth -= ([TTDeviceUIUtils tt_padding:20] + 42); // 未关注 三个字 的宽度
    }
    return firstLineMaxWidth;
}

- (CGFloat)headerViewSecondLineMaxTextWidthForLayout {
    CGFloat secondLineMaxWidth = self.headerView.width - (self.avartarView.right + 10) - 15;
    secondLineMaxWidth -= ([TTDeviceUIUtils tt_padding:15] + 17); // dislike icon 的宽度
    return secondLineMaxWidth;
}

- (void)layoutTopSeparateView {
    self.topSeparateView.width = [self totalWidthForLayout];
    self.topSeparateView.height = self.layoutModel.showTopSepView ? [TTDeviceUIUtils tt_padding:6] : 0;
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
    
    CGFloat firstLineMaxWidth = [self headerViewFirstLineMaxTextWidthForLayout];
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
        [self.introLabel sizeToFit];
        self.introLabel.height = 12;
        self.introLabel.left = self.nameLabel.left;
        self.introLabel.top = self.nameLabel.bottom + 6;
        CGFloat secondLineMaxWidth = [self headerViewSecondLineMaxTextWidthForLayout];
        if (self.introLabel.width > secondLineMaxWidth) {
            self.introLabel.width = secondLineMaxWidth;
        }
    } else {
        self.introLabel.width = 0;
        self.introLabel.height = 0;
        self.nameLabel.centerY = self.avartarView.top + self.avartarView.height / 2.0;
        self.actionLabel.top = self.nameLabel.top;
    }
    
    if (!self.layoutModel.isFollowButtonHidden) {
        self.followButton.top = self.nameLabel.top - 7.0;
        if (self.viewModel.isInUGCStory) {
            self.followButton.right = self.headerView.width - 15;
        } else {
            self.followButton.right = self.headerView.width - ([TTDeviceUIUtils tt_padding:20] + 17) - 15;
        }
    }
    
    self.dislikeBtn.centerY = self.nameLabel.centerY;
    self.dislikeBtn.right = self.headerView.width - 15 + (60-17)/2;
    self.dislikeBtn.hidden = self.viewModel.isInUGCStory ? YES : NO;
}

- (void)layoutContentLabelViewWithTop:(CGFloat)top {
    CGFloat contentWidth = [self contentWidthForLayout];
    self.contentLabel.frame = CGRectMake(15, top, contentWidth, self.layoutModel.contentLabelHeight);
}

- (void)layoutQuestionImageViewWithTop:(CGFloat)top {
    if (self.viewModel.viewType == TTWendaQuestionCellViewTypeOneImage) {
        self.firstImageView.hidden = NO;
        self.firstImageView.frame = CGRectMake(15, top, self.layoutModel.questionImageWidth, self.layoutModel.questionImageHeight);
    } else if (self.viewModel.viewType == TTWendaQuestionCellViewTypeTwoImage) {
        self.firstImageView.hidden = NO;
        self.secondImageView.hidden = NO;
        self.firstImageView.frame = CGRectMake(15, top, self.layoutModel.questionImageWidth, self.layoutModel.questionImageHeight);
        self.secondImageView.frame = CGRectMake(self.firstImageView.right + 3, top, self.layoutModel.questionImageWidth, self.layoutModel.questionImageHeight);
    } else if (self.viewModel.viewType == TTWendaQuestionCellViewTypeThreeImage) {
        self.firstImageView.hidden = NO;
        self.secondImageView.hidden = NO;
        self.thirdImageView.hidden = NO;
        self.firstImageView.frame = CGRectMake(15, top, self.layoutModel.questionImageWidth, self.layoutModel.questionImageHeight);
        self.secondImageView.frame = CGRectMake(self.firstImageView.right + 3, top, self.layoutModel.questionImageWidth, self.layoutModel.questionImageHeight);
        self.thirdImageView.frame = CGRectMake(self.secondImageView.right + 3, top, self.layoutModel.questionImageWidth, self.layoutModel.questionImageHeight);
    }
}

- (void)layoutQuestionDescViewWithTop:(CGFloat)top {
    self.questionDescView.frame = CGRectMake(15, top, [self contentWidthForLayout], self.layoutModel.questionDescViewHeight);
    if (self.viewModel.hasQuestionImage) {
        self.questionImageView.frame = CGRectMake(self.questionDescView.left, self.questionDescView.top, self.layoutModel.questionImageWidth, self.layoutModel.questionImageHeight);
        self.questionImageMaskView.frame = CGRectZero;
    } else {
        self.questionImageView.frame = CGRectMake(self.questionDescView.left + [TTDeviceUIUtils tt_padding:11], self.questionDescView.top + [TTDeviceUIUtils tt_padding:11], self.layoutModel.questionImageWidth, self.layoutModel.questionImageHeight);
        self.questionImageMaskView.frame = self.questionImageView.bounds;
    }
    
    CGFloat fontSize = [TTWendaQuestionCellLayoutModel feedQuestionTitleFontSize];
    CGFloat lineHeight = [TTWendaQuestionCellLayoutModel feedQuestionTitleLayoutLineHeight];
    CGFloat labelLeft = self.questionImageView.right - self.questionDescView.left + [TTDeviceUIUtils tt_padding:12];
    CGFloat labelWidth = self.questionDescView.width - labelLeft - [TTDeviceUIUtils tt_padding:12];
    CGFloat labelHeight = [WDLayoutHelper heightOfText:self.viewModel.questionTitle
                                              fontSize:fontSize
                                             lineWidth:labelWidth
                                            lineHeight:lineHeight
                                      maxNumberOfLines:3];
    labelHeight = (labelHeight / lineHeight) * lineHeight;
    self.questionDescLabel.left = labelLeft;
    self.questionDescLabel.width = labelWidth;
    self.questionDescLabel.height = labelHeight;
    self.questionDescLabel.centerY = self.questionDescView.height/2.0 - 1;
}

- (void)layoutBottomLabelViewWithTop:(CGFloat)top {
    self.bottomLabel.top = top;
    [self.bottomLabel sizeToFit];
    self.bottomLabel.height = self.layoutModel.bottomLabelHeight;
    self.bottomLabel.left = 15;
}

- (void)layoutAnswerViewWithTop:(CGFloat)top {
    CGFloat totalWidth = [self totalWidthForLayout];
    CGFloat totalHeight = self.layoutModel.answerViewHeight;
    
    self.lineView.top = top;
    self.lineView.left = (self.layoutModel.questionLayoutType == TTWendaQuestionLayoutTypeUGC) ? 15 : 0;
    self.lineView.width = (self.layoutModel.questionLayoutType == TTWendaQuestionLayoutTypeUGC) ? [self contentWidthForLayout] : totalWidth;
    self.lineView.height = self.layoutModel.isBottomLabelAndLineHidden ? 0 : [TTDeviceHelper ssOnePixel];
    
    self.answerButton.top = top;
    self.answerButton.left = 0;
    self.answerButton.width = totalWidth;
    self.answerButton.height = totalHeight;
}

- (void)layoutBottomSeparateViewWithTop:(CGFloat)top {
    self.bottomSeparateView.top = top;
    self.bottomSeparateView.width = [self totalWidthForLayout];
    self.bottomSeparateView.height = self.layoutModel.showBottomSepView ? [TTDeviceUIUtils tt_padding:6] : 0;
}

#pragma mark - Refresh

- (void)refreshIntroLabelContent {
    self.introLabel.text = [self.viewModel secondLineContent];
    self.isSelfFollow = NO;
}

- (void)refreshFollowButtonState {
    [self.followButton setFollowed:self.viewModel.isFollowed];
    self.isSelfFollow = NO;
}

- (void)refreshContentLabelText {
    NSString *title = self.viewModel.questionTitle;
    NSString *textColorKey = kColorText1;
    if (!self.viewModel.isInFollowChannel && !self.viewModel.isInUGCStory && self.viewModel.hasRead) {
        textColorKey = kColorText1Highlighted;
    }
    CGFloat fontSize = [TTWendaQuestionCellLayoutModel feedQuestionAbstractContentFontSize];
    CGFloat lineHeight = fontSize;
    NSMutableAttributedString *attributedString = [WDLayoutHelper attributedStringWithString:title fontSize:fontSize lineHeight:lineHeight lineSpace:6];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:textColorKey] range:NSMakeRange(0, [attributedString.string length])];
    self.contentLabel.text = attributedString;
}

- (void)refreshQuestionAllImageViews {
    if (self.viewModel.viewType == TTWendaQuestionCellViewTypeOneImage) {
        [self.firstImageView setImageWithModel:[self.viewModel.imageModels objectAtIndex:0]];
    }
    else if (self.viewModel.viewType == TTWendaQuestionCellViewTypeTwoImage) {
        [self.firstImageView setImageWithModel:[self.viewModel.imageModels objectAtIndex:0]];
        [self.secondImageView setImageWithModel:[self.viewModel.imageModels objectAtIndex:1]];
    }
    else if (self.viewModel.viewType == TTWendaQuestionCellViewTypeThreeImage) {
        [self.firstImageView setImageWithModel:[self.viewModel.imageModels objectAtIndex:0]];
        [self.secondImageView setImageWithModel:[self.viewModel.imageModels objectAtIndex:1]];
        [self.thirdImageView setImageWithModel:[self.viewModel.imageModels objectAtIndex:2]];
    }
}

- (void)refreshQuestionImageView {
    if (self.viewModel.hasQuestionImage){
        self.questionImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        self.questionImageView.layer.borderColor = [[UIColor colorWithHexString:@"dddddd"] colorWithAlphaComponent:1.0f].CGColor;;
        WeakSelf;
        [self.questionImageView setImageWithModel:[self.viewModel.imageModels objectAtIndex:0] placeholderImage:nil options:0 success:^(UIImage *image, BOOL cached) {
            StrongSelf;
            self.questionImageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
            self.questionImageView.layer.borderColor = [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.08f].CGColor;
        } failure:nil];
    }
    else {
        self.questionImageView.layer.borderWidth = 0;
        self.questionImageView.layer.borderColor = [UIColor clearColor].CGColor;
        self.questionImageView.image = [UIImage imageNamed:@"feed_source_logo"];
    }
}

- (void)refreshQuestionTitleText {
    NSString *title = self.viewModel.questionTitle;
    NSString *textColorKey = kColorText1;
    CGFloat fontSize = [TTWendaQuestionCellLayoutModel feedQuestionTitleFontSize];
    CGFloat lineHeight = [TTWendaQuestionCellLayoutModel feedQuestionTitleLineHeight];
    NSMutableAttributedString *attributedString = [WDLayoutHelper attributedStringWithString:title fontSize:fontSize isBoldFont:YES lineHeight:lineHeight];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:textColorKey] range:NSMakeRange(0, [attributedString.string length])];
    self.questionDescLabel.attributedText = attributedString;
}

- (void)refreshBottomLabelContentAndLayout {
    self.bottomLabel.text = self.viewModel.bottomContent;
    [self.bottomLabel sizeToFit];
    self.bottomLabel.height = self.layoutModel.bottomLabelHeight;
}

- (void)afterRefreshIntroLabelContent {
    if (!isEmptyString(self.introLabel.text)) {
        [self.introLabel sizeToFit];
        self.introLabel.height = 12;
        self.nameLabel.top = self.avartarView.top + 2;
        CGFloat secondLineMaxWidth = [self headerViewSecondLineMaxTextWidthForLayout];
        if (self.introLabel.width > secondLineMaxWidth) {
            self.introLabel.width = secondLineMaxWidth;
        }
    }
    else {
        self.introLabel.width = 0;
        self.introLabel.height = 0;
        self.nameLabel.centerY = self.avartarView.top + self.avartarView.height / 2.0;
    }
    self.actionLabel.top = self.nameLabel.top;
    self.dislikeBtn.centerY = self.nameLabel.centerY;
}

#pragma mark - Create

- (void)createOldCellViewIfNeeded {
    if (self.oldCellView == nil) {
        self.oldCellView = [[TTWendaCellView alloc] initWithFrame:self.bounds];
        [self addSubview:self.oldCellView];
    }
    self.oldCellView.hidden = NO;
    [self bringSubviewToFront:self.oldCellView];
    if (self.headerView) {
        self.headerView.hidden = YES;
    }
    if (self.contentView) {
        self.contentView.hidden = YES;
    }
    if (self.postQuestionLabel) {
        self.postQuestionLabel.hidden = YES;
    }
    if (self.questionDescView) {
        self.questionDescView.hidden = YES;
        self.questionImageView.hidden = YES;
        self.questionImageMaskView.hidden = YES;
    }
    if (self.firstImageView) {
        self.firstImageView.hidden = YES;
        self.secondImageView.hidden = YES;
        self.thirdImageView.hidden = YES;
    }
    if (self.lineView) {
        self.lineView.hidden = YES;
    }
    if (self.answerButton) {
        self.answerButton.hidden = YES;
    }
    if (self.topSeparateView && self.bottomSeparateView) {
        self.topSeparateView.hidden = YES;
        self.bottomSeparateView.hidden = YES;
    }
}

- (void)createSubviewsIfNeeded {
    [self createUserHeaderInfoView];
    [self createMainContentView];
    [self createAnswerQuestionView];
    [self createTwoSeparateView];
}

- (void)createUserHeaderInfoView {
    if (self.headerView) {
        return;
    }
    
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
    [self.headerView addSubview:self.dislikeBtn];
}

- (void)createMainContentView {
    if (self.contentView == nil) {
        self.contentView = [[SSThemedView alloc] init];
        self.contentView.backgroundColorThemeKey = kColorBackground4;
        [self addSubview:self.contentView];
        
        self.bottomLabel = [[SSThemedLabel alloc] init];
        self.bottomLabel.font = [UIFont systemFontOfSize:12];
        self.bottomLabel.textColorThemeKey = kColorText3;
        [self.contentView addSubview:self.bottomLabel];
    }
    
    if (self.layoutModel.questionLayoutType == TTWendaQuestionLayoutTypeUGC) {
        if (self.postQuestionLabel == nil) {
            self.postQuestionLabel = [[SSThemedLabel alloc] init];
            self.postQuestionLabel.font = [UIFont systemFontOfSize:[TTWendaQuestionCellLayoutModel feedPostQuestionLabelFontSize]];
            self.postQuestionLabel.textColorThemeKey = kColorText1;
            [self.contentView addSubview:self.postQuestionLabel];
        }
        if (self.questionDescView == nil) {
            [self createQuestionDescView];
        }
    }
    else {
        if (self.contentLabel == nil) {
            self.contentLabel = [[TTTAttributedLabel alloc] init];
            self.contentLabel.font = [UIFont systemFontOfSize:[TTWendaQuestionCellLayoutModel feedQuestionAbstractContentFontSize]];
            self.contentLabel.numberOfLines = 2;
            [self.contentView addSubview:self.contentLabel];
        }
        if (self.firstImageView == nil) {
            [self createThreeImageView];
        }
    }
}

- (void)createQuestionDescView {
    self.questionDescView = [[SSThemedView alloc] init];
    self.questionDescView.backgroundColorThemeKey = kColorBackground4;
    self.questionDescView.borderColorThemeKey = kColorLine10;
    self.questionDescView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    self.questionDescView.layer.shadowColor = [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.04f].CGColor;
    self.questionDescView.layer.shadowOffset = CGSizeMake(0.f, 1.f);
    self.questionDescView.layer.shadowRadius = 5;
    self.questionDescView.layer.shadowOpacity = 1;
    [self.contentView addSubview:self.questionDescView];
    
    self.questionImageView = [[TTImageView alloc] init];
    self.questionImageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    self.questionImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.questionImageView];
    
    self.questionImageMaskView = [[SSThemedView alloc] init];
    self.questionImageMaskView.backgroundColor = [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.02f];
    [self.questionImageView addSubview:self.questionImageMaskView];
    
    self.questionDescLabel = [[TTTAttributedLabel alloc] init];
    self.questionDescLabel.numberOfLines = 3;
    self.questionDescLabel.font = [UIFont boldSystemFontOfSize:[TTWendaQuestionCellLayoutModel feedQuestionTitleFontSize]];
    [self.questionDescView addSubview:self.questionDescLabel];
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

- (void)createAnswerQuestionView {
    if (self.lineView == nil) {
        self.lineView = [[SSThemedView alloc] init];
        self.lineView.backgroundColorThemeKey = kColorLine1;
        [self addSubview:self.lineView];
        
        self.answerButton = [[TTAlphaThemedButton alloc] init];
        self.answerButton.titleEdgeInsets = UIEdgeInsetsMake(0, 5, 0, 0);
        self.answerButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
        [self.answerButton setTitle:@"我有靠谱回答" forState:UIControlStateNormal];
        [self.answerButton addTarget:self action:@selector(answerButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:self.answerButton];
    }
    CGFloat fontSize = 14;
    NSString *titleColorKey = kColorText2;
    NSString *imageName = @"attention_write_ask";
    if (self.layoutModel.questionLayoutType == TTWendaQuestionLayoutTypeUGC) {
        fontSize = 13;
        if (![TTDeviceHelper isScreenWidthLarge320]) {
            fontSize = 12;
        }
        titleColorKey = kColorText1;
        imageName = @"u13_attention_write_ask";
    }
    self.answerButton.titleColorThemeKey = titleColorKey;
    self.answerButton.titleLabel.font = [UIFont systemFontOfSize:fontSize];
    self.answerButton.imageName = imageName;
}

- (void)createTwoSeparateView {
    if (self.topSeparateView && self.bottomSeparateView) {
        return;
    }
    self.topSeparateView = [[SSThemedView alloc] init];
    self.topSeparateView.backgroundColorThemeKey = kColorBackground3;
    [self addSubview:self.topSeparateView];
    
    self.bottomSeparateView = [[SSThemedView alloc] init];
    self.bottomSeparateView.backgroundColorThemeKey = kColorBackground3;
    [self addSubview:self.bottomSeparateView];
}

#pragma mark - KVO

- (void)addObserveKVO {
    WeakSelf;
    if (!self.viewModel.isInFollowChannel) {
        [self.KVOController observe:self.viewModel.userEntity keyPath:NSStringFromSelector(@selector(isFollowing)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            TTWendaQuestionCellView *cellView = observer;
            if (!cellView.followButton.hidden) {
                if (!cellView.isSelfFollow) {
                    [cellView refreshFollowButtonState];
                }
            }
            else {
                if (!cellView.viewModel.isInUGCStory) {
                    [cellView refreshIntroLabelContent];
                    [cellView afterRefreshIntroLabelContent];
                }
            }
        }];
    }
    if (!self.layoutModel.isBottomLabelAndLineHidden) {
        [self.KVOController observe:self.viewModel.questionEntity keyPath:NSStringFromSelector(@selector(followCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            [self refreshBottomLabelContentAndLayout];
        }];
        [self.KVOController observe:self.viewModel.questionEntity keyPath:NSStringFromSelector(@selector(niceAnsCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            [self refreshBottomLabelContentAndLayout];
        }];
        [self.KVOController observe:self.viewModel.questionEntity keyPath:NSStringFromSelector(@selector(normalAnsCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
            StrongSelf;
            [self refreshBottomLabelContentAndLayout];
        }];
    }
}

- (void)removeObserveKVO {
    [self.KVOController unobserveAll];
}

#pragma mark - Notification

- (void)addObserveNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    if (self.layoutModel.questionLayoutType == TTWendaQuestionLayoutTypeUGC) {
        [self refreshQuestionTitleText];
    }
    else {
        [self refreshContentLabelText];
    }
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
        BOOL isFollowedState = self.viewModel.isFollowed;
        if (actionType == FriendActionTypeFollow) {
            isFollowedState = YES;
        }else if (actionType == FriendActionTypeUnfollow) {
            isFollowedState = NO;
        }
        [self.viewModel updateNewFollowStateWithValue:isFollowedState];
    }
}

#pragma mark - Action

- (void)avatarViewClick {
    [self.viewModel enterUserInfoPage];
}

- (void)followButtonClick:(TTFollowThemeButton *)followBtn {
    if (self.followButton.isLoading) {
        return;
    }
    BOOL isFollowed = self.viewModel.isFollowed;
    if (isFollowed) {
        [self.viewModel trackCancelFollowButtonClicked];
    }
    else {
        [self.viewModel trackFollowButtonClicked];
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
                                                 BOOL isFollowing = (type == FriendActionTypeFollow ? YES : NO);
                                                 [self.viewModel updateNewFollowStateWithValue:isFollowing];
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
    [self.viewModel trackAnswerQuestionButtonClicked];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.viewModel enterAnswerListPage];
    if (self.layoutModel.questionLayoutType != TTWendaQuestionLayoutTypeUGC) {
        [self refreshContentLabelText];
    }
}

#pragma mark - TTFeedDislikeView

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)view {
    NSArray *filterWords = [view selectedWords];
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:self.viewModel.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

#pragma mark - GET

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

- (TTAlphaThemedButton *)dislikeBtn {
    if (!_dislikeBtn) {
        _dislikeBtn = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)]; // 17,12 -> 60,44
        _dislikeBtn.titleColorThemeKey = kColorText4;
        _dislikeBtn.imageName = @"add_textpage";
        [_dislikeBtn addTarget:self action:@selector(dislikeViewClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dislikeBtn;
}

@end


