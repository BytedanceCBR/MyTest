//
//  TTWendaAnswerCellView.m
//  Article
//
//  Created by wangqi.kaisa on 2017/10/12.
//

#import "TTWendaAnswerCellView.h"
#import "TTWendaAnswerCellViewModel.h"
#import "TTWendaCellHelper.h"
#import "ExploreAvatarView.h"
#import "ExploreAvatarView+VerifyIcon.h"
#import "FRButtonLabel.h"
#import "TTAlphaThemedButton.h"
#import "TTTAttributedLabel.h"
//#import "TTRecommendUserCollectionViewWrapper.h"
//#import "FRSpreaderButton.h"
#import <TTFriendRelation/TTFollowThemeButton.h>
#import <TTNewsAccountBusiness/TTAccountManager.h>
#import "NSObject+FBKVOController.h"
#import "TTUGCDefine.h"
#import "SSMotionRender.h"
#import "WDLayoutHelper.h"
#import "WDUIHelper.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "WDPersonModel.h"
#import "WDAnswerEntity.h"
#import "WDQuestionEntity.h"
#import "WDQuestionDescEntity.h"
//#import "RecommendCardCache.h"
#import "TTFeedDislikeView.h"
#import "ExploreMixListDefine.h"
#import "WDAnswerService.h"
#import "WDDefines.h"
//#import "Thread.h"
#import <TTPhotoScrollVC/TTPhotoScrollViewController.h>
#import "TTArticleCellHelper.h"
#import "TTKitchenHeader.h"
#import <TTServiceKit/TTModuleBridge.h>
#import "FriendDataManager.h"

typedef NS_ENUM(NSInteger, WDImageViewTagPosition)
{
    WDImageViewTagPositionBottom = 0,             //默认右下角
    WDImageViewTagPositionTop = 1,                //可选右上角
};

@interface WDTagImageView : TTImageView

@property (nonatomic, strong) SSThemedImageView *tagView; //图标的背景
@property (nonatomic, strong) SSThemedLabel *tagLabel;    //用来显示长图、横图

@end

@implementation WDTagImageView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.tagView];
    }
    return self;
}

- (void)setTagLabelText:(NSString *)text {
    [self setTagLabelText:text position:WDImageViewTagPositionBottom];
}

- (void)setTagLabelText:(NSString *)text position:(WDImageViewTagPosition)position {
    if (!isEmptyString(text)) {
        self.tagView.hidden = NO;
        self.tagLabel.text = text;
        [self.tagLabel sizeToFit];
        
        CGFloat tagWidth = ceilf(self.tagLabel.size.width) + 6 * 2;
        self.tagView.frame = CGRectMake(self.width - tagWidth - 4, self.height - 20 - 4, tagWidth, 20);
        self.tagLabel.center = CGPointMake(self.tagView.width / 2, self.tagView.height / 2);
        if (position != WDImageViewTagPositionBottom) {
            self.tagView.top = 4;
        }
        else {
            self.tagView.bottom = self.height - 4;
        }
        self.tagView.right = self.width - 4;
    }
    else {
        self.tagView.hidden = YES;
    }
}

- (SSThemedImageView *)tagView {
    if (_tagView == nil) {
        _tagView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(self.width - 34 - 4, self.height - 20 - 4, 34, 20)];
        UIImage *image = [UIImage themedImageNamed:@"message_background_view"];
        image = [image resizableImageWithCapInsets:UIEdgeInsetsMake(image.size.height / 2, image.size.width / 2, image.size.height / 2 - 1, image.size.width / 2 - 1) resizingMode:UIImageResizingModeTile];
        _tagView.image = image;
        _tagView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        
        _tagLabel = [[SSThemedLabel alloc] init];
        _tagLabel.font = [UIFont tt_fontOfSize:10];
        _tagLabel.textColor = [UIColor tt_defaultColorForKey:kColorText12];
        _tagLabel.textAlignment = NSTextAlignmentCenter;
        [_tagView addSubview:_tagLabel];
        
        //放在遮罩上面
        _tagView.layer.zPosition = 1;
    }
    
    return _tagView;
}

@end

@interface TTWendaAnswerCellView()</*TTRecommendUserCollectionViewDelegate,*/UIGestureRecognizerDelegate>

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
  // quote view
@property (nonatomic, strong) SSThemedView  *quoteView;
@property (nonatomic, strong) TTImageView   *quoteImageView;
@property (nonatomic, strong) SSThemedLabel *quoteContentLabel;
@property (nonatomic, strong) TTAlphaThemedButton  *quoteTransparentButton;
// UGC Style Use
@property (nonatomic, strong) TTTAttributedLabel *questionContentLabel;
@property (nonatomic, strong) SSThemedView  *answerImagesBgView;
@property (nonatomic, strong) SSThemedView *singleContentImageShadowView;
@property (nonatomic, strong) NSArray<WDTagImageView *> *answerImageViews;
// both Use
@property (nonatomic, strong) TTTAttributedLabel *contentLabel;
@property (nonatomic, strong) SSThemedLabel *bottomLabel;
// action view
@property (nonatomic, strong) SSThemedView         *actionView;
@property (nonatomic, strong) SSThemedView         *lineView;
@property (nonatomic, strong) TTAlphaThemedButton   *diggButton;
@property (nonatomic, strong) TTAlphaThemedButton   *commentButton;
@property (nonatomic, strong) TTAlphaThemedButton   *forwardButton;
// separate view
@property (nonatomic, strong) SSThemedView         *topSeparateView;
@property (nonatomic, strong) SSThemedView         *bottomSeparateView;
// recommend user
//@property (nonatomic, strong) TTRecommendUserCollectionViewWrapper *collectionViewWrapper;
//@property (nonatomic, strong) FRSpreaderButton *foldRecommendButton;
@property (nonatomic, strong) SSThemedImageView *sanjiaoIcon;
// layout & view model
@property (nonatomic, strong) TTWendaAnswerCellLayoutModel *layoutModel;
@property (nonatomic, strong) TTWendaAnswerCellViewModel *viewModel;

@property (nonatomic, assign) BOOL                handlingExpand;
@property (nonatomic, assign) BOOL                fromRefreshData; //确保refreshData之后才执行alpha更改？
@property (nonatomic, assign) BOOL                isSelfFollow; //区分关注来源
@property (nonatomic, assign) CGFloat             cellTotalWidth;

@end

@implementation TTWendaAnswerCellView

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)willAppear {
    if (self.layoutModel.isExpanded) {
//        [self.collectionViewWrapper.collectionView willDisplay];
    }
}

- (void)didDisappear {
    if (self.layoutModel.isExpanded) {
//        [self.collectionViewWrapper.collectionView didEndDisplaying];
    }
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if ([TTWendaCellHelper verifyWithWendaOrderedData:data]) {
        TTWendaAnswerCellLayoutModel *model = [[TTWendaAnswerCellLayoutModelManager sharedInstance] getCellBaseModelFromOrderedData:(ExploreOrderedData *)data];
        if (model.viewModel.isInvalidData) {
            return 0;
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
    self.fromRefreshData = YES;
    if ([TTWendaCellHelper verifyWithWendaOrderedData:data]) {
        self.layoutModel = [[TTWendaAnswerCellLayoutModelManager sharedInstance] getCellBaseModelFromOrderedData:(ExploreOrderedData *)data];
        self.viewModel = self.layoutModel.viewModel;
        if (self.viewModel.isInvalidData) {
            return;
        }
        [self createSubviewsIfNeeded];
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
        [self refreshContentLabelText];
        self.bottomLabel.text = self.viewModel.bottomContent;
        
        if (self.layoutModel.answerLayoutType == TTWendaAnswerLayoutTypeUGC) {
            self.questionContentLabel.hidden = NO;
            self.answerImagesBgView.hidden = NO;
            [self refreshQuestionLabelContent];
            [self refreshAnswerImagesView];
            if (self.quoteView) {
                self.quoteView.hidden = YES;
            }
            self.actionLabel.text = @"";
        }
        else {
            self.actionLabel.text = self.viewModel.actionTitle;
            self.quoteView.hidden = NO;
            [self refreshQuoteLabelContent];
            [self refreshQuoteImageView];
            if (self.questionContentLabel) {
                self.questionContentLabel.hidden = YES;
            }
            if (self.answerImagesBgView) {
                self.answerImagesBgView.hidden = YES;
            }
        }
        
        [self refreshDiggCount];
        [self refreshCommentCount];
        [self refreshForwardCount];
        [self refreshLayOutSubviews];
        [self addObserveKVO];
        [self addObserveNotification];
    }
}

- (void)refreshUI {
    [self refreshLayOutSubviews];
}

- (void)refreshLayOutSubviews {
    if (self.viewModel.isInvalidData) {
        return;
    }
    
    if (self.handlingExpand) {
        return;
    }
    
    self.cellTotalWidth = 0;
    CGFloat totalWidth = [self totalWidthForLayout];
    [self layoutTopSeparateView];
    [self layoutUserHeaderInfoViewWithTop:self.topSeparateView.bottom];
    CGFloat startY = self.headerView.bottom;
    self.contentView.width = totalWidth;
    
//    [self layoutRecommendUserCardsView];
//    startY += (self.collectionViewWrapper.height > 0) ? (self.collectionViewWrapper.height + 8) : 0;
    startY = 0;
    self.contentView.top = startY;
    CGFloat bottomLabelTop = 0;
    if (self.layoutModel.answerLayoutType == TTWendaAnswerLayoutTypeUGC) {
        [self layoutQuestionLabel];
        [self layoutContentLabelViewWithTop:self.questionContentLabel.bottom + [TTDeviceUIUtils tt_padding:3.0]];
        if (self.viewModel.hasAnswerImage) {
            [self layoutAnswerImagesBgViewWithTop:self.contentLabel.bottom + [TTDeviceUIUtils tt_padding:9.0]];
            bottomLabelTop = self.answerImagesBgView.bottom;
        } else {
            self.answerImagesBgView.height = 0;
            bottomLabelTop = self.contentLabel.bottom;
        }
        self.bottomLabel.hidden = self.layoutModel.isBottomLabelAndLineHidden;
        if (self.layoutModel.isBottomLabelAndLineHidden) {
            self.bottomLabel.width = 0;
            self.bottomLabel.height = 0;
            self.contentView.height = bottomLabelTop;
        } else {
            bottomLabelTop += [TTDeviceUIUtils tt_padding:7.0];
            [self layoutBottomLabelViewWithTop:bottomLabelTop];
            self.contentView.height = self.bottomLabel.bottom + [TTDeviceUIUtils tt_padding:7.0];
        }
    } else {
        self.bottomLabel.hidden = NO;
        [self layoutContentLabelViewWithTop:[TTDeviceUIUtils tt_padding:3.0]];
        [self layoutQuoteQuestionInfoViewWithTop:self.contentLabel.bottom - 2 + [TTDeviceUIUtils tt_padding:5.0]];
        bottomLabelTop = self.quoteView.bottom + [TTDeviceUIUtils tt_padding:7.0];
        [self layoutBottomLabelViewWithTop:bottomLabelTop];
        self.contentView.height = self.bottomLabel.bottom + [TTDeviceUIUtils tt_padding:7.0];
    }
    [self layoutAnswerActionViewWithTop:self.contentView.bottom];
    [self layoutBottomSeparateViewWithTop:self.actionView.bottom];
}

#pragma mark - Layout

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
    CGFloat contentWidth = totalWidth - [self.layoutModel horizontalPadding]*2;
    return contentWidth;
}

- (CGFloat)headerViewFirstLineMaxTextWidthForLayout {
    CGFloat firstLineMaxWidth = self.headerView.width - (self.avartarView.right + 10) - [self.layoutModel horizontalPadding];
    firstLineMaxWidth -= ([TTDeviceUIUtils tt_padding:20] + 17); // dislike icon 的宽度
    if (!self.layoutModel.isFollowButtonHidden) {
        firstLineMaxWidth -= ([TTDeviceUIUtils tt_padding:20] + 42); // 未关注 三个字 的宽度
    }
    return firstLineMaxWidth;
}

- (CGFloat)headerViewSecondLineMaxTextWidthForLayout {
    CGFloat secondLineMaxWidth = self.headerView.width - (self.avartarView.right + 10) - [self.layoutModel horizontalPadding];
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
    self.avartarView.left = [self.layoutModel horizontalPadding];
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
            self.followButton.right = self.headerView.width - [self.layoutModel horizontalPadding];
        } else {
            self.followButton.right = self.headerView.width - ([TTDeviceUIUtils tt_padding:20] + 17) - [self.layoutModel horizontalPadding];
        }
    }
    
    self.dislikeBtn.centerY = self.nameLabel.centerY;
    self.dislikeBtn.right = self.headerView.width - [self.layoutModel horizontalPadding] + (60-17)/2;
    self.dislikeBtn.hidden = self.viewModel.isInUGCStory ? YES : NO;
}

//- (void)layoutRecommendUserCardsView {
//    self.foldRecommendButton.left = self.followButton.right + 10;
//    self.foldRecommendButton.centerY = self.followButton.centerY;
//    self.foldRecommendButton.spreadEdgeInsets = UIEdgeInsetsMake(self.foldRecommendButton.top, 0, 10, 20);
//
//    self.sanjiaoIcon.centerX = self.foldRecommendButton.centerX;
//    self.sanjiaoIcon.bottom = self.headerView.height;
//
//    CGFloat colletionViewHeight = self.layoutModel.isExpanded ? WDPadding(224) : 0;
//    self.collectionViewWrapper.frame = CGRectMake(0, self.headerView.bottom, self.width, colletionViewHeight);
//
//    if (self.fromRefreshData && !self.layoutModel.isExpanded) {
//        self.dislikeBtn.alpha = 1;
//        self.foldRecommendButton.alpha = 0;
//    } else if (self.fromRefreshData) {
//        self.dislikeBtn.alpha = 0;
//        self.foldRecommendButton.alpha = 1;
//    }
//
//    if (self.fromRefreshData && self.collectionViewWrapper.height > 0) {
//        if ([[[RecommendCardCache defaultCache] dataSourceForUniqId:self.uniqueID] count] > 0) {
//            [self.collectionViewWrapper.collectionView configUserModels:[[RecommendCardCache defaultCache] dataSourceForUniqId:self.uniqueID] requesetModel:nil];
//        } else {
//            WeakSelf;
//            [TTRecommendUserCollectionView requestDataWithSource:self.categoryID scene:@"follow" sceneUserId:self.viewModel.userId groupId:self.viewModel.uniqueId complete:^(NSArray<FRRecommendCardStructModel *> *models) {
//                StrongSelf;
//                if (models) {
//                    [[RecommendCardCache defaultCache] insertRecommendArray:self.collectionViewWrapper.collectionView.allUserModels forCellId:self.uniqueID];
//                    [self.collectionViewWrapper.collectionView configUserModels:models requesetModel:nil];
//                }
//            }];
//        }
//        self.sanjiaoIcon.alpha = 1;
//        self.collectionViewWrapper.alpha = 1;
//    } else if (self.fromRefreshData) {
//        self.sanjiaoIcon.alpha = 0;
//        self.collectionViewWrapper.alpha = 0;
//    }
//    self.fromRefreshData = NO;
//}

- (void)layoutQuestionLabel {
    CGFloat contentWidth = [self contentWidthForLayout];
    self.questionContentLabel.frame = CGRectMake([self.layoutModel horizontalPadding], 0, contentWidth, self.layoutModel.questionLabelHeight);
}

- (void)layoutContentLabelViewWithTop:(CGFloat)top {
    CGFloat contentWidth = [self contentWidthForLayout];
    self.contentLabel.frame = CGRectMake([self.layoutModel horizontalPadding], top, contentWidth, self.layoutModel.contentLabelHeight);
}

- (void)layoutAnswerImagesBgViewWithTop:(CGFloat)top {
    self.answerImagesBgView.frame = CGRectMake(0, top, [self totalWidthForLayout], self.layoutModel.imagesBgViewHeight);
}

- (void)layoutQuoteQuestionInfoViewWithTop:(CGFloat)top  {
    self.quoteView.frame = CGRectMake([self.layoutModel horizontalPadding], top, [self contentWidthForLayout], self.layoutModel.quoteViewHeight);
    self.quoteTransparentButton.frame = self.quoteView.bounds;
    self.quoteImageView.frame = CGRectMake(1, 1, 68, 68);
    
    CGFloat quoteLabelWidth = self.quoteView.width - self.quoteImageView.width - [TTDeviceUIUtils tt_padding:15] - [TTDeviceUIUtils tt_padding:12];
    CGFloat quoteLabelHeight = [WDLayoutHelper heightOfText:self.viewModel.questionTitle
                                                   fontSize:WDFontSize(15)
                                                  lineWidth:quoteLabelWidth
                                                 lineHeight:WDPadding(20)
                                           maxNumberOfLines:2];
    
    self.quoteContentLabel.left = self.quoteImageView.right + [TTDeviceUIUtils tt_padding:15];
    self.quoteContentLabel.width = quoteLabelWidth;
    self.quoteContentLabel.height = quoteLabelHeight;
    self.quoteContentLabel.centerY = self.quoteView.height/2.0;
}

- (void)layoutBottomLabelViewWithTop:(CGFloat)top {
    self.bottomLabel.top = top;
    [self.bottomLabel sizeToFit];
    self.bottomLabel.height = self.layoutModel.bottomLabelHeight;
    self.bottomLabel.left = [self.layoutModel horizontalPadding];
}

- (void)layoutAnswerActionViewWithTop:(CGFloat)top {
    CGFloat totalWidth = [self totalWidthForLayout];
    CGFloat actionViewHeight = self.layoutModel.actionViewHeight;
    
    self.actionView.top = top;
    self.actionView.width = totalWidth;
    self.actionView.height = actionViewHeight;
    
    self.lineView.top = 0;
    self.lineView.left = (self.layoutModel.answerLayoutType == TTWendaAnswerLayoutTypeUGC) ? [self.layoutModel horizontalPadding] : 0;
    self.lineView.width = (self.layoutModel.answerLayoutType == TTWendaAnswerLayoutTypeUGC) ? [self contentWidthForLayout] :totalWidth;
    self.lineView.height = self.layoutModel.isBottomLabelAndLineHidden ? 0 : [TTDeviceHelper ssOnePixel];
    
    CGFloat buttonWidth = totalWidth/3;
    
    self.diggButton.height = actionViewHeight;
    self.diggButton.width = buttonWidth;
    
    self.commentButton.left = buttonWidth;
    self.commentButton.height = actionViewHeight;
    self.commentButton.width = buttonWidth;
    
    self.forwardButton.height = actionViewHeight;
    self.forwardButton.width = buttonWidth;
    
    if ([KitchenMgr getBOOL:kKCUGCU13ActionRegionLayoutStyle]) {
        self.forwardButton.left = 0;
        self.diggButton.left = buttonWidth * 2;
    }
    else {
        self.diggButton.left = 0;
        self.forwardButton.left = buttonWidth * 2;
    }
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
    if (self.layoutModel.answerLayoutType == TTWendaAnswerLayoutTypeUGC) {
        [self refreshAnswerLabelContentUgcStyle];
    }
    else {
        [self refreshAnswerLabelContentNotUgcStyle];
    }
}

- (void)refreshAnswerLabelContentUgcStyle {
    NSString *title = self.viewModel.answerTitle;
    NSString *textColorKey = kColorText1;
    if (!self.viewModel.isInFollowChannel && !self.viewModel.isInUGCStory && self.viewModel.hasRead) {
        textColorKey = kColorText1Highlighted;
    }
    CGFloat fontSize = [TTWendaAnswerCellLayoutModel feedAnswerTitleContentFontSize];
    CGFloat lineHeight = [TTWendaAnswerCellLayoutModel feedAnswerTitleContentLineHeight] - 1;
    NSMutableAttributedString *token = [[NSMutableAttributedString alloc] initWithString:@"..."
                                                                              attributes:@{
                                                                                           NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                                                           NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:textColorKey]}
                                        ];
    NSMutableAttributedString *token2 = [[NSMutableAttributedString alloc] initWithString:@"全文"
                                                                               attributes:@{
                                                                                            NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                                                            NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]}
                                         ];
    [token appendAttributedString:token2];
    self.contentLabel.attributedTruncationToken = token;
    self.contentLabel.font = [UIFont systemFontOfSize:fontSize];
    NSMutableAttributedString *attributedString = [WDLayoutHelper attributedStringWithString:title fontSize:fontSize lineHeight:lineHeight];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:textColorKey] range:NSMakeRange(0, [attributedString.string length])];
    self.contentLabel.numberOfLines = self.layoutModel.answerLinesCount;
    self.contentLabel.attributedText = attributedString;
}

- (void)refreshAnswerLabelContentNotUgcStyle {
    NSString *title = self.viewModel.answerTitle;
    NSString *textColorKey = kColorText1;
    if (!self.viewModel.isInFollowChannel && !self.viewModel.isInUGCStory && self.viewModel.hasRead) {
        textColorKey = kColorText1Highlighted;
    }
    CGFloat fontSize = [TTWendaAnswerCellLayoutModel feedAnswerAbstractContentFontSize];
    CGFloat lineHeight = [TTWendaAnswerCellLayoutModel feedAnswerAbstractContentLineHeight];
    CGFloat lineSpace = [TTWendaAnswerCellLayoutModel feedAnswerAbstractContentLineSpace];
    NSMutableAttributedString *token = [[NSMutableAttributedString alloc] initWithString:@"..."
                                                                              attributes:@{
                                                                                           NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                                                           NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:textColorKey]}
                                        ];
    NSMutableAttributedString *token2 = [[NSMutableAttributedString alloc] initWithString:@"全文"
                                                                               attributes:@{
                                                                                            NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                                                            NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText5]}
                                         ];
    [token appendAttributedString:token2];
    self.contentLabel.attributedTruncationToken = token;
    self.contentLabel.font = [UIFont systemFontOfSize:fontSize];
    NSMutableAttributedString *attributedString = [WDLayoutHelper attributedStringWithString:title fontSize:fontSize lineHeight:lineHeight lineSpace:lineSpace];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:textColorKey] range:NSMakeRange(0, [attributedString.string length])];
    self.contentLabel.numberOfLines = self.layoutModel.answerLinesCount;
    self.contentLabel.attributedText = attributedString;
}

- (void)refreshQuestionLabelContent {
    NSString *title = self.viewModel.questionShowTitle;
    NSString *textColorKey = kColorText1;
    CGFloat fontSize = [TTWendaAnswerCellLayoutModel feedQuestionTitleContentFontSize];
    CGFloat lineHeight = [TTWendaAnswerCellLayoutModel feedQuestionTitleContentLineHeight] - 1;
    NSMutableAttributedString *token = [[NSMutableAttributedString alloc] initWithString:@"...?"
                                                                              attributes:@{
                                                                                           NSFontAttributeName : [UIFont boldSystemFontOfSize:fontSize],
                                                                                           NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:textColorKey]}
                                        ];
    self.questionContentLabel.attributedTruncationToken = token;
    self.questionContentLabel.font = [UIFont boldSystemFontOfSize:fontSize];
    NSMutableAttributedString *attributedString = [WDLayoutHelper attributedStringWithString:title
                                                                                    fontSize:fontSize
                                                                                  isBoldFont:YES
                                                                                  lineHeight:lineHeight];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:textColorKey] range:NSMakeRange(0, [attributedString.string length])];
    self.questionContentLabel.numberOfLines = 2;
    self.questionContentLabel.attributedText = attributedString;
}

- (void)refreshAnswerImagesView {
    for (TTImageView *imageView in self.answerImageViews) {
        imageView.hidden = YES;
    }
    NSInteger fullCount = self.viewModel.answerEntity.thumbImageList.count;
    self.singleContentImageShadowView.hidden = (fullCount == 1) ? NO : YES;
    [self.layoutModel.imageViewRects enumerateObjectsUsingBlock:^(NSValue * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CGRect frame = obj.CGRectValue;
        if (idx >= fullCount) {
            *stop = YES;
            return;
        }
        WDTagImageView *imageView = self.answerImageViews[idx];
        TTImageInfosModel *thumbImageModel = self.viewModel.answerEntity.thumbImageList[idx];
        TTImageInfosModel *largeImageModel = self.viewModel.answerEntity.largeImageList[idx];
        if (fullCount == 1) {
            // 单张需展示大图
            thumbImageModel = largeImageModel;
        }
        BOOL isVLongImage = NO;
        BOOL isHLongImage = NO;
        if (largeImageModel.height > 0 && largeImageModel.width > 0) {
            isVLongImage = (largeImageModel.height >= largeImageModel.width * 2);
            isHLongImage = (largeImageModel.width >= largeImageModel.height * 3);
        }
        NSString *tips = @"";
        WDImageViewTagPosition position = WDImageViewTagPositionBottom;
        if (thumbImageModel.imageFileType == TTImageFileTypeGIF) {
            tips = @"GIF";
        }
        else if (isVLongImage) {
            tips = @"长图";
            if (fullCount == 1) {
                position = WDImageViewTagPositionTop;
            }
        }
        else if (isHLongImage) {
            tips = @"横图";
        }
        imageView.hidden = NO;
        imageView.frame = frame;
        if (idx == 0) {
            self.singleContentImageShadowView.frame = frame;
        }
        [imageView setTagLabelText:tips position:position];
        [imageView setImageWithModel:thumbImageModel];
    }];
}

- (void)refreshQuoteLabelContent {
    NSMutableAttributedString *attributedString = [WDLayoutHelper attributedStringWithString:self.viewModel.questionTitle
                                                                                    fontSize:WDFontSize(15)
                                                                                  lineHeight:WDFontSize(19)
                                                                                   lineSpace:[TTDeviceUIUtils tt_padding:1]];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kColorText1] range:NSMakeRange(0, [attributedString.string length])];
    self.quoteContentLabel.attributedText = attributedString;
}

- (void)refreshQuoteImageView {
    if (self.viewModel.questionImageModel) {
        [self.quoteImageView setImageWithModel:self.viewModel.questionImageModel];
    }
    else {
        self.quoteImageView.image = [UIImage imageNamed:@"feed_source_logo"];
    }
}

- (void)refreshDiggCount {
    self.diggButton.selected = self.viewModel.answerEntity.isDigg;
    [self.diggButton setTitle:self.viewModel.diggContent forState:UIControlStateNormal];
    [self.diggButton setTitle:self.viewModel.diggContent forState:UIControlStateSelected];
}

- (void)refreshCommentCount {
    [self.commentButton setTitle:self.viewModel.commentContent forState:UIControlStateNormal];
}

- (void)refreshForwardCount {
    [self.forwardButton setTitle:self.viewModel.forwardContent forState:UIControlStateNormal];
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

- (void)createSubviewsIfNeeded {
    [self createUserHeaderInfoView];
//    if (!_collectionViewWrapper) {
//        [self addSubview:self.collectionViewWrapper];
//    }
    [self createMainContentView];
    [self createAnswerActionView];
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
    
//    [self.headerView addSubview:self.foldRecommendButton];
    [self.headerView addSubview:self.sanjiaoIcon];
    [self.headerView addSubview:self.followButton];
    
    [self.headerView addSubview:self.dislikeBtn];
}

- (void)createMainContentView {
    if (self.contentView == nil) {
        self.contentView = [[SSThemedView alloc] init];
        self.contentView.backgroundColorThemeKey = kColorBackground4;
        [self addSubview:self.contentView];
        
        self.contentLabel = [[TTTAttributedLabel alloc] init];
        [self.contentView addSubview:self.contentLabel];
        
        self.bottomLabel = [[SSThemedLabel alloc] init];
        self.bottomLabel.font = [UIFont systemFontOfSize:12];
        self.bottomLabel.textColorThemeKey = kColorText3;
        [self.contentView addSubview:self.bottomLabel];
    }
    
    if (self.layoutModel.answerLayoutType == TTWendaAnswerLayoutTypeUGC) {
        if (self.questionContentLabel == nil) {
            [self createQuestionContentLabel];
            [self.contentView addSubview:self.questionContentLabel];
        }
        if (self.answerImagesBgView == nil) {
            [self createAnswerImagesBgView];
            [self.contentView addSubview:self.answerImagesBgView];
        }
    }
    else {
        if (self.quoteView == nil) {
            [self createQuoteQuestionView];
            [self.contentView addSubview:self.quoteView];
        }
    }
}

- (void)createQuoteQuestionView {
    self.quoteView = [[SSThemedView alloc] init];
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
        self.quoteView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground21];
    }
    else {
        self.quoteView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground1];
    }
    
    self.quoteImageView = [[TTImageView alloc] init];
    self.quoteImageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.quoteView addSubview:self.quoteImageView];
    
    self.quoteContentLabel = [[SSThemedLabel alloc] init];
    self.quoteContentLabel.numberOfLines = 2;
    self.quoteContentLabel.font = [UIFont systemFontOfSize:WDFontSize(15)];
    self.quoteContentLabel.textColorThemeKey = kColorText1;
    [self.quoteView addSubview:self.quoteContentLabel];
    
    self.quoteTransparentButton = [[TTAlphaThemedButton alloc] init];
    self.quoteTransparentButton.backgroundColor = [UIColor clearColor];
    [self.quoteTransparentButton addTarget:self action:@selector(transparentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.quoteView addSubview:self.quoteTransparentButton];
}

- (void)createQuestionContentLabel {
    self.questionContentLabel = [[TTTAttributedLabel alloc] init];
    self.questionContentLabel.numberOfLines = 2;
    self.questionContentLabel.font = [UIFont boldSystemFontOfSize:[TTWendaAnswerCellLayoutModel feedQuestionTitleContentFontSize]];
}

- (void)createAnswerImagesBgView {
    self.answerImagesBgView = [[SSThemedView alloc] init];
    self.answerImagesBgView.backgroundColorThemeKey = kColorBackground4;
    
    NSMutableArray<WDTagImageView *> *answerImageViews = [NSMutableArray array];
    for (int i = 0; i < self.layoutModel.maxImageCount; i++) {
        WDTagImageView *imageView = [self createOneAnswerImageView];
        imageView.tag = i;
        [answerImageViews addObject:imageView];
        if (i == 0) {
            [self.answerImagesBgView addSubview:self.singleContentImageShadowView];
        }
        [self.answerImagesBgView addSubview:imageView];
    }
    self.answerImageViews = answerImageViews;
}

- (WDTagImageView *)createOneAnswerImageView {
    WDTagImageView *imageView = [[WDTagImageView alloc] init];
    imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
    imageView.layer.borderColor = [[UIColor colorWithHexString:@"000000"] colorWithAlphaComponent:0.08f].CGColor;
    imageView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    imageView.imageView.contentMode = UIViewContentModeScaleAspectFill;
    imageView.clipsToBounds = YES;
    imageView.userInteractionEnabled = YES;
    if (!self.viewModel.tapImageJump) {
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapAnswerImageView:)];
        tapGesture.delegate = self;
        [imageView addGestureRecognizer:tapGesture];
    }
    return imageView;
}

- (void)createAnswerActionView {
    if (self.actionView == nil) {
        self.actionView = [[SSThemedView alloc] init];
        [self addSubview:self.actionView];
        
        self.lineView = [[SSThemedView alloc] init];
        self.lineView.backgroundColorThemeKey = kColorLine1;
        [self.actionView addSubview:self.lineView];
        
        self.diggButton = [[TTAlphaThemedButton alloc] init];
        self.diggButton.selectedTitleColorThemeKey = kColorText4;
        [self.diggButton setSelectedImageName:@"feed_like_press"];
        [self.diggButton addTarget:self action:@selector(diggButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionView addSubview:self.diggButton];
        
        self.commentButton = [[TTAlphaThemedButton alloc] init];
        [self.commentButton addTarget:self action:@selector(commentButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.actionView addSubview:self.commentButton];
        
        self.forwardButton = [[TTAlphaThemedButton alloc] init];
        [self.forwardButton addTarget:self action:@selector(forwardButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [self.actionView addSubview:self.forwardButton];
    }
    
    CGFloat sepPadding = 5 / 2;
    CGFloat buttonFontSize = 12;
    NSString *titleColorKey = kColorText2;
    NSString *diggImageName = @"feed_like";
    NSString *commentImageName = @"comment_feed";
    NSString *forwardImageName = @"feed_share";
    UIEdgeInsets diggInsets = UIEdgeInsetsMake(0, sepPadding, 0, -sepPadding);
    UIEdgeInsets forwardInsets = UIEdgeInsetsMake(0, -10, 0, 10);
    if ([KitchenMgr getBOOL:kKCUGCU13ActionRegionLayoutStyle]) {
        if ([TTDeviceHelper isScreenWidthLarge320]) {
            buttonFontSize = 13;
        }
        titleColorKey = kColorText1;
        diggImageName = @"u13_like_feed";
        commentImageName = @"u13_comment_feed";
        forwardImageName = @"u13_share_feed";
        diggInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        forwardInsets = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    
    [self.diggButton setImageEdgeInsets:UIEdgeInsetsMake(0, -sepPadding, 0, sepPadding)];
    [self.diggButton setTitleEdgeInsets:UIEdgeInsetsMake(0, sepPadding, 0, -sepPadding)];
    [self.commentButton setImageEdgeInsets:UIEdgeInsetsMake(0, -sepPadding, 0, sepPadding)];
    [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, sepPadding, 0, -sepPadding)];
    [self.forwardButton setImageEdgeInsets:UIEdgeInsetsMake(0, -sepPadding, 0, sepPadding)];
    [self.forwardButton setTitleEdgeInsets:UIEdgeInsetsMake(0, sepPadding, 0, -sepPadding)];
    self.diggButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
    self.commentButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
    self.forwardButton.titleLabel.font = [UIFont systemFontOfSize:buttonFontSize];
    self.diggButton.titleColorThemeKey = titleColorKey;
    self.commentButton.titleColorThemeKey = titleColorKey;
    self.forwardButton.titleColorThemeKey = titleColorKey;
    [self.diggButton setImageName:diggImageName];
    [self.diggButton setContentEdgeInsets:diggInsets];
    [self.commentButton setImageName:commentImageName];
    [self.forwardButton setImageName:forwardImageName];
    [self.forwardButton setContentEdgeInsets:forwardInsets];
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
            TTWendaAnswerCellView *cellView = observer;
            // 按钮显示
            if (!cellView.followButton.hidden) {
                if (!cellView.isSelfFollow) {
                    [cellView refreshFollowButtonState];
                }
            }
            // 按钮不显示
            else {
                if (!cellView.viewModel.isInUGCStory) {
                    [cellView refreshIntroLabelContent];
                    [cellView afterRefreshIntroLabelContent];
                }
            }
        }];
    }
    [self.KVOController observe:self.viewModel.answerEntity keyPath:NSStringFromSelector(@selector(isDigg)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self refreshDiggCount];
    }];
    [self.KVOController observe:self.viewModel.answerEntity keyPath:NSStringFromSelector(@selector(commentCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self refreshCommentCount];
    }];
    [self.KVOController observe:self.viewModel.answerEntity keyPath:NSStringFromSelector(@selector(forwardCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self refreshForwardCount];
    }];
    if (!self.layoutModel.isBottomLabelAndLineHidden) {
        [self.KVOController observe:self.viewModel.answerEntity keyPath:NSStringFromSelector(@selector(readCount)) options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
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
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(feedWendaForwardSuccess:) name:kTTForumRePostThreadSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(followNotification:) name:RelationActionSuccessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themeChanged:) name:TTThemeManagerThemeModeChangedNotification object:nil];
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    [self refreshContentLabelText];
    if (self.layoutModel.answerLayoutType == TTWendaAnswerLayoutTypeUGC) {
        [self refreshQuestionLabelContent];
    } else {
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay){
            self.quoteView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground21];
        } else {
            self.quoteView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground1];
        }
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
        } else if (actionType == FriendActionTypeUnfollow) {
            isFollowedState = NO;
        }
        [self.viewModel updateNewFollowStateWithValue:isFollowedState];
    }
}

//- (void)feedWendaForwardSuccess:(NSNotification *)notification {
//    if ([notification.userInfo[@"repostOperationItemType"] integerValue] == TTRepostOperationItemTypeWendaAnswer && [notification.userInfo[@"repostOperationItemID"] isEqualToString:self.viewModel.answerId]) {
//        [self.viewModel afterForwardAnswerToUGCIsComment:[notification.userInfo[@"is_repost_to_comment"] boolValue]];
//    }
//}

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
    } else {
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
                                                 if (self.viewModel.isInUGCStory) {
                                                     BOOL isFollowing = (type == FriendActionTypeFollow ? YES : NO);
                                                     [self.viewModel updateNewFollowStateWithValue:isFollowing];
                                                     [followBtn stopLoading:^{}];
                                                     [self refreshFollowButtonState];
                                                 } else {
                                                     BOOL expand = (type == FriendActionTypeFollow ? YES : NO);
//                                                     [self handleExpandStateChange:expand isFromArrowButton:NO];
                                                 }
                                             } else {
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

//- (void)operationBtnClick:(SSThemedButton *)btn {
//    BOOL expand = (self.layoutModel.isExpanded ? NO : YES);
//    [self handleExpandStateChange:expand isFromArrowButton:YES];
//    btn.selected = !btn.selected;
//    [UIView animateWithDuration:0.25 animations:^{
//        if(btn.selected) {
//            self.foldRecommendButton.imageView.transform =  CGAffineTransformMakeRotation(M_PI - 0.001);
//        } else {
//            self.foldRecommendButton.imageView.transform = CGAffineTransformRotate(self.foldRecommendButton.imageView.transform, M_PI + 0.001);
//        }
//    }];
//}

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

- (void)onTapAnswerImageView:(UITapGestureRecognizer *)gesture {
    if ([gesture.view isKindOfClass:[WDTagImageView class]]) {
        WDTagImageView *imageView = (WDTagImageView *)gesture.view;
        if ([self.answerImageViews containsObject:imageView]) {
            TTPhotoScrollViewController *showImageViewController = [[TTPhotoScrollViewController alloc] init];
            showImageViewController.finishBackView = [self getSuitableFinishBackViewWithCurrentContext];
            NSArray *largeImageUrls = [self largeImageUrls];
            NSInteger largeImageCount = largeImageUrls.count;
            showImageViewController.imageInfosModels = largeImageUrls;
            NSMutableArray *placeHoldersFrames = [[NSMutableArray alloc] init];
            for (NSUInteger i = 0; i < largeImageCount; i++) {
                WDTagImageView *currentImageView = [self.answerImageViews objectAtIndex:i];
                CGRect imageFrame = currentImageView.frame;
                imageFrame.origin.y = imageFrame.origin.y + self.answerImagesBgView.top + self.contentView.top;
                CGRect frame = [self convertRect:imageFrame toView:nil];
                [placeHoldersFrames addObject:[NSValue valueWithCGRect:frame]];
            }
            showImageViewController.placeholderSourceViewFrames = placeHoldersFrames;
            [showImageViewController setStartWithIndex:imageView.tag];
            [showImageViewController presentPhotoScrollView];
            [self.viewModel trackThumbImageFullScreenShowClick];
        }
    }
}

- (void)transparentButtonClick  {
    [self.viewModel enterAnswerListPage];
}

- (void)diggButtonClick:(TTAlphaThemedButton *)diggButton {
    if ([self.viewModel.answerEntity isBuryed]) {
        [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:NSLocalizedString(@"您已经反对过", nil) indicatorImage:nil autoDismiss:YES dismissHandler:nil];
    }
    else {
        WDDiggType diggType = WDDiggTypeDigg;
        if (![self.viewModel.answerEntity isDigg]) {
            [self.viewModel trackDiggButtonClicked];
            [self diggAnimationWith:diggButton];
        }
        else {
            [self.viewModel trackCancelDiggButtonClicked];
            if (diggButton.selected) {
                diggButton.selected = NO;
            }
            [self.viewModel afterCancelDiggAnswer];
            diggType = WDDiggTypeUnDigg;
        }
        [WDAnswerService digWithAnswerID:self.viewModel.answerId
                                diggType:diggType
                               enterFrom:nil
                                apiParam:nil
                             finishBlock:nil];
    }
}

- (void)commentButtonClick {
    [self.viewModel trackCommentButtonClicked];
    [self.viewModel enterAnswerDetailPageFromComment];
    [self refreshContentLabelText];
}

- (void)forwardButtonClick {
    [self.viewModel trackForwardButtonClicked];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] init];

    parameters[@"fw_id"] = self.viewModel.repostParams.fw_id;
    parameters[@"fw_id_type"] = self.viewModel.repostParams.fw_id_type;
    parameters[@"opt_id"] = self.viewModel.repostParams.opt_id;
    parameters[@"opt_id_type"] = self.viewModel.repostParams.opt_id_type;
    parameters[@"fw_user_id"] = self.viewModel.repostParams.fw_user_id;
    parameters[@"repost_type"] = self.viewModel.repostParams.repost_type;
    parameters[@"cover_url"] = self.viewModel.repostParams.cover_url;
    parameters[@"title"] = self.viewModel.repostParams.title;
    parameters[@"schema"] = self.viewModel.repostParams.schema;

    [[TTRoute sharedRoute] openURLByPresentViewController:[NSURL URLWithString:@"sslocal://repost_page"] userInfo:TTRouteUserInfoWithDict([parameters copy])];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self.viewModel enterAnswerDetailPage];
    [self refreshContentLabelText];
}

//- (void)handleExpandStateChange:(BOOL)expand isFromArrowButton:(BOOL)isFromArrowButton {
//    if (!self.tableView) {
//        UIResponder *obj = self.nextResponder;
//        while (obj && ![obj isKindOfClass:[UITableView class]]) {
//            obj = obj.nextResponder;
//        }
//        if (obj) {
//            self.tableView = (UITableView *)obj;
//        }
//    }
//    self.handlingExpand = YES;
//    if (expand) {
//        WeakSelf;
//        [TTRecommendUserCollectionView requestDataWithSource:self.uniqueID scene:@"follow" sceneUserId:self.viewModel.userId groupId:self.viewModel.uniqueId complete:^(NSArray<FRRecommendCardStructModel *> *models) {
//            StrongSelf;
//            if (models) {
////                [[RecommendCardCache defaultCache] insertRecommendArray:self.collectionViewWrapper.collectionView.allUserModels forCellId:self.uniqueID];
//                [self.collectionViewWrapper.collectionView configUserModels:models requesetModel:nil];
//
//                self.layoutModel.needCalculateLayout = YES;
//                self.layoutModel.isExpanded = YES;
//                NSString *categoryName = [self.categoryID length] > 0 ? self.categoryID : @"";
//                [TTTrackerWrapper eventV3:@"follow_card" params:@{@"action_type":@"show",
//                                                                  @"category_name":categoryName,
//                                                                  @"source": @"list",
//                                                                  @"is_direct" : @(0)
//                                                                  }];
//                [self.tableView beginUpdates];
//                [self.tableView endUpdates];
//                self.handlingExpand = NO;
//
//                self.collectionViewWrapper.frame = CGRectMake(0, self.headerView.bottom, self.width, 0);
//
//                if (!isFromArrowButton) {
//                    self.dislikeBtn.alpha = 0;
//                }
//                [UIView animateWithDuration:0.25 animations:^{
//                    self.collectionViewWrapper.alpha = 1;
//                    [self refreshLayOutSubviews];
//                    self.sanjiaoIcon.alpha = 1;
//                    if (!isFromArrowButton) {
//                        self.foldRecommendButton.alpha = 1;
//                    }
//                } completion:^(BOOL finished) {
//                    [self.collectionViewWrapper.collectionView willDisplay];
//
//                    [self.viewModel updateNewFollowStateWithValue:expand];
//                    [self.followButton stopLoading:^{}];
//                    [self refreshFollowButtonState];
//                }];
//            } else {
//                [self.viewModel updateNewFollowStateWithValue:expand];
//                [self.followButton stopLoading:^{}];
//                [self refreshFollowButtonState];
//            }
//        }];
//    }
//    // 收起（需要区分两种来源）
//    else {
//        self.layoutModel.needCalculateLayout = YES;
//        self.layoutModel.isExpanded = NO;
//        [self.tableView beginUpdates];
//        [self.tableView endUpdates];
//        self.handlingExpand = NO;
//
//        if (!isFromArrowButton) {
//            self.foldRecommendButton.alpha = 0;
//        }
//        [UIView animateWithDuration:0.25 animations:^{
//            [self refreshLayOutSubviews];
//            self.collectionViewWrapper.alpha = 0;
//            self.sanjiaoIcon.alpha = 0;
//            if (!isFromArrowButton) {
//                self.dislikeBtn.alpha = 1;
//            }
//        } completion:^(BOOL finished) {
//            [self.collectionViewWrapper.collectionView didEndDisplaying];
////            [[RecommendCardCache defaultCache] clearDataOfUniqId:self.uniqueID];
//
//            [self.viewModel updateNewFollowStateWithValue:expand];
//            [self.followButton stopLoading:^{}];
//            [self refreshFollowButtonState];
//        }];
//    }
//}

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

#pragma mark - TTRecommendUserCollectionViewDelegate

- (void)trackWithEvent:(NSString *)event extraDic:(NSDictionary *)extraDic {
    if (isEmptyString(event)) {
        return;
    }
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:self.categoryID forKey:@"category_name"];
    [dict setValue:self.viewModel.userId forKey:@"profile_user_id"];
    [dict setValue:self.viewModel.uniqueId forKey:@"group_id"];
    if (extraDic) {
        [dict addEntriesFromDictionary:extraDic];
    }
    [dict setValue:@"list" forKey:@"source"];
    [TTTrackerWrapper eventV3:event params:dict];
    if ([event isEqualToString:@"follow"] || [event isEqualToString:@"unfollow"]) { // "rt_follow" 关注动作统一化 埋点
        NSMutableDictionary* rtFollowDict = [NSMutableDictionary dictionaryWithObject:@"from_recommend" forKey:@"follow_type"];
        [rtFollowDict setValue:self.categoryID forKey:@"category_name"];
        [rtFollowDict setValue:@"list_follow_card_horizon" forKey:@"source"];
        [rtFollowDict setValue:self.viewModel.orderedData.logPb forKey:@"log_pb"];
        [rtFollowDict setValue:@(1) forKey:@"_staging_flag"];
        [rtFollowDict setValue:[extraDic objectForKey:@"order"] forKey:@"order"];
        [rtFollowDict setValue:[extraDic objectForKey:@"user_id"] forKey:@"to_user_id"];
        [rtFollowDict setValue:[extraDic objectForKey:@"server_source"] forKey:@"server_source"];
        [rtFollowDict setValue:[extraDic objectForKey:@"is_redpacket"] forKey:@"is_redpacket"];
        
        if ([event isEqualToString:@"follow"]) {
            [TTTrackerWrapper eventV3:@"rt_follow" params:rtFollowDict];
        } else {
            [TTTrackerWrapper eventV3:@"rt_unfollow" params:rtFollowDict];
        }
    }
}

- (NSDictionary *)impressionParams {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:self.categoryID forKey:@"category_name"];
    [dict setValue:self.viewModel.userId forKey:@"profile_user_id"];
    [dict setValue:self.uniqueID forKey:@"unique_id"];
    return dict;
}

- (NSString *)categoryID {
    return self.viewModel.orderedData.categoryID;
}

#pragma mark - GET

- (NSString *)uniqueID {
    return self.viewModel.orderedData.uniqueID;
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

//- (FRSpreaderButton *)foldRecommendButton {
//    if (!_foldRecommendButton) {
//        _foldRecommendButton = [FRSpreaderButton buttonWithType:UIButtonTypeCustom];
//        _foldRecommendButton.layer.cornerRadius =  4;
//        _foldRecommendButton.layer.masksToBounds = YES;
//        _foldRecommendButton.alpha = 0;
//        _foldRecommendButton.imageName = @"personal_home_arrow";
//        _foldRecommendButton.backgroundColor = [UIColor clearColor];
//        _foldRecommendButton.borderColorThemeKey = kColorLine1;
//        _foldRecommendButton.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:28], [TTDeviceUIUtils tt_newPadding:28]);
//        [_foldRecommendButton addTarget:self action:@selector(operationBtnClick:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    return _foldRecommendButton;
//}

- (SSThemedImageView *)sanjiaoIcon {
    if (!_sanjiaoIcon) {
        SSThemedImageView *sanjiaoIcon = [[SSThemedImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 5)];
        sanjiaoIcon.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        sanjiaoIcon.imageName = @"sanjiao";
        sanjiaoIcon.alpha = 0;
        _sanjiaoIcon = sanjiaoIcon;
    }
    return _sanjiaoIcon;
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
        _dislikeBtn = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        _dislikeBtn.titleColorThemeKey = kColorText4;
        _dislikeBtn.imageName = @"add_textpage";
        [_dislikeBtn addTarget:self action:@selector(dislikeViewClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dislikeBtn;
}

//- (TTRecommendUserCollectionViewWrapper *)collectionViewWrapper {
//    if (!_collectionViewWrapper) {
//        _collectionViewWrapper = [[TTRecommendUserCollectionViewWrapper alloc] initWithFrame:CGRectZero];;
//        _collectionViewWrapper.collectionView.recommendUserDelegate = self;
//        _collectionViewWrapper.backgroundColorThemeKey = kColorBackground3;
//        _collectionViewWrapper.alpha = 0;
//    }
//    if (!_collectionViewWrapper.collectionView.delegate) {
//        _collectionViewWrapper.collectionView.delegate = _collectionViewWrapper.collectionView;
//    }
//    return _collectionViewWrapper;
//}

- (SSThemedView *)singleContentImageShadowView
{
    if (!_singleContentImageShadowView) {
        _singleContentImageShadowView = [[SSThemedView alloc] init];
        _singleContentImageShadowView.layer.masksToBounds = NO;
        _singleContentImageShadowView.layer.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:0.08f].CGColor;
        _singleContentImageShadowView.layer.shadowRadius = 6.0f;
        _singleContentImageShadowView.layer.shadowOpacity = 1.0;
        _singleContentImageShadowView.layer.shadowOffset = CGSizeMake(0, 0);
        _singleContentImageShadowView.backgroundColor = [UIColor whiteColor];
        _singleContentImageShadowView.hidden = YES;
    }
    return _singleContentImageShadowView;
}

- (NSArray<TTImageInfosModel *> *)largeImageUrls
{
    NSMutableArray *imageUrls = @[].mutableCopy;
    NSInteger totalCount = self.viewModel.answerEntity.largeImageList.count;
    if (totalCount >= self.layoutModel.displayImageCount) {
        for (NSInteger i = 0; i < self.layoutModel.displayImageCount; i++) {
            TTImageInfosModel *infoModel = [self.viewModel.answerEntity.largeImageList objectAtIndex:i];
            [imageUrls addObject:infoModel];
        }
    }
    return [imageUrls copy];
}

- (UIView *)getSuitableFinishBackViewWithCurrentContext
{
    __block UIView *view;
    [[TTModuleBridge sharedInstance_tt] triggerAction:@"getSuitableFinishBackViewWithCurrentContext" object:nil withParams:nil complete:^(id  _Nullable result) {
        if ([result isKindOfClass:[UIView class]]) {
            view = result;
        }
    }];
    return view;
}

#pragma mark - Animation

- (void)diggAnimationWith:(TTAlphaThemedButton *)sender {
   
    [SSMotionRender motionInView:sender.imageView
                          byType:SSMotionTypeZoomInAndDisappear
                           image:[UIImage themedImageNamed:@"add_all_dynamic"]
                     offsetPoint:CGPointMake(4.f, -9.f)];
    if (!sender.selected){
        sender.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
        sender.imageView.contentMode = UIViewContentModeCenter;
        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
            sender.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
        } completion:^(BOOL finished) {
            sender.selected = YES;
            sender.alpha = 0;
            
            [self.viewModel afterDiggAnswer];
            
            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
                sender.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
                sender.alpha = 1;
            } completion:nil];
        }];
    }else {
        [self.viewModel afterDiggAnswer];
    }
}

@end

