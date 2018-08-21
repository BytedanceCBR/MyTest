//
//  TTXiguaLiveHorizonCell.m
//  Article
//
//  Created by lipeilun on 2017/12/5.
//

#import "TTXiguaLiveHorizonCell.h"
#import "TTXiguaLiveHelper.h"
#import "TTArticleCellHelper.h"
#import <TTAlphaThemedButton.h>
#import "TTXiguaLiveCardHorizontal.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTXiguaLiveLivingAnimationView.h"
#import "TTFeedDislikeView.h"
#import "ExploreMixListDefine.h"
#import "TTXiguaLiveManager.h"
#import "TTArticleCellConst.h"
#import "UIView+UGCAdditions.h"
#import "TTBusinessManager+StringUtils.h"
#import "SSImpressionManager.h"
#import "ExploreOrderedData+TTAd.h"

@implementation TTXiguaLiveHorizonCell

+ (Class)cellViewClass {
    return [TTXiguaLiveHorizonCellView class];
}

- (void)willDisplay {
    [self.cellView willAppear];
}

- (void)didEndDisplaying {
    [self.cellView didDisappear];
}

- (void)willAppear {
    [self.cellView willAppear];
}

- (void)cellInListWillDisappear:(CellInListDisappearContextType)context {
    [self.cellView didDisappear];
}

@end

@interface TTXiguaLiveHorizonCellItemView : SSThemedView
@property (nonatomic, strong) TTImageView *backImageView;
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *descLabel;
@property (nonatomic, strong) SSThemedLabel *watchCountLabel;
@property (nonatomic, strong) TTXiguaLiveLivingAnimationView *liveAnimationView;
@property (nonatomic, copy) NSDictionary *extraDic;
@property (nonatomic, strong) TTXiguaLiveModel *data;
@end

@implementation TTXiguaLiveHorizonCellItemView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.backImageView];
        [self addSubview:self.liveAnimationView];
        [self addSubview:self.titleLabel];
        [self addSubview:self.descLabel];
        [self addSubview:self.watchCountLabel];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat itemPicHeight = self.width * xg_horcell_pic_hw_factor();
    
    self.backImageView.frame = CGRectMake(0, 0, self.width, itemPicHeight);
//    self.liveAnimationView.origin = CGPointMake(xg_horcell_live_padding(), xg_horcell_live_padding());
    self.liveAnimationView.bottom = itemPicHeight - xg_horcell_live_padding();
    self.liveAnimationView.right = self.width - xg_horcell_live_padding();
    self.titleLabel.frame = CGRectMake(0, self.backImageView.bottom + xg_horcell_title_top(), self.width, xg_horcell_title_height());
    [self.watchCountLabel sizeToFit];
    [self.descLabel sizeToFit];
    CGFloat descWidthMax = self.width - self.watchCountLabel.width - xg_horcell_desc_padding();
    CGFloat descWidth = self.descLabel.width > descWidthMax ? descWidthMax : self.descLabel.width;
    self.descLabel.frame = CGRectMake(0, self.titleLabel.bottom + xg_horcell_desc_top(), descWidth, xg_horcell_desc_height());
    self.watchCountLabel.frame = CGRectMake(self.descLabel.right + xg_horcell_desc_padding(), self.titleLabel.bottom + xg_horcell_desc_top(), self.watchCountLabel.width, xg_horcell_desc_height());
}
- (void)refreshWithItemData:(TTXiguaLiveModel *)data WithExtraDic:(NSDictionary *)extraDic{
    self.data = data;
    self.titleLabel.text = data.title;
    self.descLabel.text = data.description;
    NSNumber *watchCount = @([data liveLiveInfoModel].watchingCount);
    self.watchCountLabel.text = [NSString stringWithFormat:@"%@人观看",[TTBusinessManager formatCommentCount:watchCount.longLongValue]];
    self.descLabel.text = [data liveUserInfoModel].name;
    [self.watchCountLabel sizeToFit];
    NSMutableDictionary *mutableShareDict = extraDic.mutableCopy;
    [mutableShareDict setValue:self.data.groupId forKey:@"group_id"];
    [mutableShareDict setValue:@"double_feed" forKey:@"cell_type"];
    self.extraDic = [mutableShareDict copy];
    [self.backImageView setImageWithURLString:[data largeImageModel].url];
}

- (void)onClickCell {
    UIViewController *audienceVC = [[TTXiguaLiveManager sharedManager] audienceRoomWithUserID:[self.data liveUserInfoModel].userId extraInfo:self.extraDic];
    [self.navigationController pushViewController:audienceVC animated:YES];
}

#pragma mark - GET

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColorThemeKey = kColorText1;
        _titleLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:17]];
        _titleLabel.numberOfLines = 1;
    }
    return _titleLabel;
}

- (SSThemedLabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _descLabel.textColorThemeKey = kColorText3;
        _descLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        _descLabel.numberOfLines = 1;
    }
    return _descLabel;
}

- (SSThemedLabel *)watchCountLabel {
    if (!_watchCountLabel) {
        _watchCountLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _watchCountLabel.textColorThemeKey = kColorText3;
        _watchCountLabel.font = [UIFont tt_fontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        _watchCountLabel.numberOfLines = 1;
    }
    return _watchCountLabel;
}


- (TTImageView *)backImageView {
    if (!_backImageView) {
        _backImageView = [[TTImageView alloc] init];
        _backImageView.enableNightCover = YES;
        _backImageView.imageContentMode = TTImageViewContentModeScaleAspectFill;
        _backImageView.clipsToBounds = YES;
        _backImageView.backgroundColorThemeKey = kColorBackground3;
    }
    return _backImageView;
}

- (TTXiguaLiveLivingAnimationView *)liveAnimationView {
    if (!_liveAnimationView) {
        _liveAnimationView = [[TTXiguaLiveLivingAnimationView alloc] initWithStyle:TTXiguaLiveLivingAnimationViewStyleMiddleAndLine];
    }
    return _liveAnimationView;
}

@end

@interface TTXiguaLiveHorizonCellView()<SSImpressionProtocol>
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTAlphaThemedButton *dislikeButton;
@property (nonatomic, strong) TTXiguaLiveHorizonCellItemView *leftItemView;
@property (nonatomic, strong) TTXiguaLiveHorizonCellItemView *rightItemView;
@property (nonatomic, strong) TTXiguaLiveCardHorizontal *horizontalData;
//@property (nonatomic, strong) SSThemedView *bottomLineView;
//分割线（视图）
@property (nonatomic, strong) SSThemedView           * topSeparateView;
@property (nonatomic, strong) SSThemedView           * bottomSeparateView;
@property (nonatomic, assign) BOOL                   isDisplaying;
@end


@implementation TTXiguaLiveHorizonCellView

- (void)dealloc{
    [[SSImpressionManager shareInstance] removeRegist:self];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.leftItemView];
        [self addSubview:self.rightItemView];
        [self addSubview:self.dislikeButton];
//        [self addSubview:self.bottomLineView];
        self.topSeparateView = [self ugc_addSubviewWithClass:[SSThemedView class] themePath:@"#ThreadU11TopSeparateView"];
        self.bottomSeparateView = [self ugc_addSubviewWithClass:[SSThemedView class]];
        self.bottomSeparateView.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:self.topSeparateView];
        [self addSubview:self.bottomSeparateView];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
        return;
    }
    
    if ([self.orderedData.originalData isKindOfClass:[TTXiguaLiveCardHorizontal class]]) {
        self.horizontalData = (TTXiguaLiveCardHorizontal *)self.orderedData.xiguaLiveCardHorizontal;
    } else {
        self.horizontalData = nil;
        return;
    }
    
    if ([[self.horizontalData modelArray] count] != 2) {
        self.orderedData = nil;
        self.horizontalData = nil;
        return;
    }
    NSMutableDictionary *extraDic = [NSMutableDictionary dictionary];
    [extraDic setValue:self.orderedData.categoryID forKey:@"category_name"];
    [extraDic setValue:self.orderedData.logPb forKey:@"log_pb"];
    
    [extraDic setValue:@(1) forKey:@"card_position"];
    [self.leftItemView refreshWithItemData:[self.horizontalData modelArray][0] WithExtraDic:extraDic];

    [extraDic setValue:@(2) forKey:@"card_position"];
    [self.rightItemView refreshWithItemData:[self.horizontalData modelArray][1] WithExtraDic:extraDic];
}

+ (CGFloat)heightForData:(ExploreOrderedData *)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    CGFloat cellHeight = xg_horcell_top();
    cellHeight += !data.preCellHasBottomPadding && data.hasTopPadding ? kUFSeprateViewHeight() : 0;
    cellHeight += !data.isInCard && !data.nextCellHasTopPadding ? kUFSeprateViewHeight() : 0;
    CGFloat itemPicWidth = (width - xg_left() - xg_right() - xg_horcell_mid()) / 2;
    CGFloat itemPicHeight = itemPicWidth * xg_horcell_pic_hw_factor();
    cellHeight += itemPicHeight;
    return cellHeight += xg_horcell_title_top() + xg_horcell_title_height() + xg_horcell_desc_top() + xg_horcell_desc_height() + xg_horcell_desc_bottom();
}

- (void)willAppear {
    _isDisplaying = YES;
    [self.leftItemView.liveAnimationView beginAnimation];
    [self.rightItemView.liveAnimationView beginAnimation];
    
    [self recordImpressionsWithStatus:SSImpressionStatusRecording];
    [[SSImpressionManager shareInstance] addRegist:self];

}

- (void)didDisappear {
    _isDisplaying = NO;
    [self.leftItemView.liveAnimationView stopAnimation];
    [self.rightItemView.liveAnimationView stopAnimation];
    [self recordImpressionsWithStatus:SSImpressionStatusEnd];
}

- (id)cellData {
    return self.orderedData;
}

- (void)refreshUI {
    BOOL needTop = !self.orderedData.preCellHasBottomPadding && self.orderedData.hasTopPadding;
    CGFloat top = needTop ? kUFSeprateViewHeight() : 0;
    self.topSeparateView.frame = needTop ? CGRectMake(0, 0, self.width, kUFSeprateViewHeight()) : CGRectZero;
    self.topSeparateView.hidden = !needTop;
    
    self.titleLabel.frame = CGRectMake(xg_left(), top + xg_horcell_toptitle_top(), xg_horcell_toptitle_width(), xg_horcell_toptitle_height());
    
    self.leftItemView.frame = CGRectMake(xg_left(), top + xg_horcell_top(), (self.width - xg_left() - xg_right() - xg_horcell_mid()) / 2, self.height - xg_horcell_desc_bottom() - xg_horcell_top());
    self.rightItemView.frame = CGRectMake(self.leftItemView.right + xg_horcell_mid(), self.leftItemView.top, self.leftItemView.width, self.leftItemView.height);
    
    self.dislikeButton.size = CGSizeMake(60, 44);
    self.dislikeButton.centerY = self.titleLabel.centerY;
    self.dislikeButton.right = self.rightItemView.right + 21.5;
    
    BOOL needBottom = !self.orderedData.isInCard && !self.orderedData.nextCellHasTopPadding;
    self.bottomSeparateView.frame = needBottom ? CGRectMake(0, self.height - kUFSeprateViewHeight(), self.width, kUFSeprateViewHeight()) : CGRectZero;
    self.bottomSeparateView.hidden = !needBottom;
//    self.bottomLineView.frame = CGRectMake(kCellLeftPadding, self.height - [TTDeviceHelper ssOnePixel], self.width - kCellLeftPadding - kCellRightPadding, [TTDeviceHelper ssOnePixel]);
//    if ([(ExploreOrderedData *)self.orderedData nextCellHasTopPadding] || self.hideBottomLine) {
//        self.bottomLineView.hidden = YES;
//    } else {
//        self.bottomLineView.hidden = NO;
//    }
}

- (void)unInterestedAction:(TTAlphaThemedButton *)sender {
    if (!self.orderedData) {
        return;
    }
    
    [TTFeedDislikeView dismissIfVisible];
    
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = nil;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.xiguaLiveModel.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = sender.center;
    [dislikeView showAtPoint:point
                    fromView:sender
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)view {
    if (!self.orderedData) {
        return;
    }
    NSArray * filterWords = [view selectedWords];
    NSMutableDictionary * userInfo = @{}.mutableCopy;
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        userInfo[kExploreMixListNotInterestWordsKey] = filterWords;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = touches.anyObject;
    CGPoint point = [touch locationInView:self];
    if (CGRectContainsPoint(self.leftItemView.frame, point)) {
        [self.leftItemView onClickCell];
    } else if (CGRectContainsPoint(self.rightItemView.frame, point)) {
        [self.rightItemView onClickCell];
    }
    
    [super touchesBegan:touches withEvent:event];
}

#pragma mark - GET

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectZero];
        _titleLabel.textColorThemeKey = kColorText3;
        _titleLabel.font = [UIFont tt_fontOfSize:12];
        _titleLabel.text = @"正在直播";
    }
    return _titleLabel;
}

- (TTXiguaLiveHorizonCellItemView *)leftItemView {
    if (!_leftItemView) {
        _leftItemView = [TTXiguaLiveHorizonCellItemView new];
    }
    return _leftItemView;
}

- (TTXiguaLiveHorizonCellItemView *)rightItemView {
    if (!_rightItemView) {
        _rightItemView = [TTXiguaLiveHorizonCellItemView new];
    }
    return _rightItemView;
}

//- (SSThemedView *)bottomLineView {
//    if (!_bottomLineView) {
//        _bottomLineView = [[SSThemedView alloc] init];
//        _bottomLineView.backgroundColorThemeKey = kColorLine1;
//    }
//    return _bottomLineView;
//}

- (TTAlphaThemedButton *)dislikeButton {
    if (!_dislikeButton) {
        _dislikeButton = [[TTAlphaThemedButton alloc] init];
        _dislikeButton.imageName = @"add_textpage";
        [_dislikeButton addTarget:self action:@selector(unInterestedAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _dislikeButton;
}

#pragma mark - SSImpression related

- (void)needRerecordImpressions
{
    [self recordImpressionsWithStatus:_isDisplaying ? SSImpressionStatusRecording :SSImpressionStatusSuspend];
}

- (void)recordImpressionsWithStatus:(SSImpressionStatus)status
{
    if (self.leftItemView) {
        [self processImpressionForItemModel:self.leftItemView.data status:status];
    }
    if (self.rightItemView) {
        [self processImpressionForItemModel:self.rightItemView.data status:status];
    }
}

- (void)processImpressionForItemModel:(TTXiguaLiveModel *)model status:(SSImpressionStatus)status
{
    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    SSImpressionGroupType groupType = SSImpressionGroupTypeGroupList;
    NSString *groupID;
    params.categoryID = self.orderedData.categoryID;
    if (!model) {
        params.refer = self.cell.refer;
        groupID = self.orderedData.uniqueID;
    } else {
        params.refer = 1;
        groupID = model.groupId;
    }
    
    [[SSImpressionManager shareInstance] recordWithListKey:params.categoryID listType:groupType itemID:groupID modelType:SSImpressionModelTypeXiguaRecommendItem adID:nil status:status userInfo:@{@"extra": @{@"refer": @(params.refer)}, @"params": params}];
}

@end
