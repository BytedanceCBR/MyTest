//
//  TTRecommendUserCell.m
//  Article
//
//  Created by 王双华 on 16/11/30.
//
//

#import "TTRecommendUserCell.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "RecommendUserCardsData.h"
#import "TTUISettingHelper.h"
#import "TTRecommendUserCardCell.h"
#import "SSThemed.h"
#import "TTAlphaThemedButton.h"
#import "TTFeedDislikeView.h"
#import "ExploreMixListDefine.h"
#import "ExploreArticleCellViewConsts.h"
#import "SSImpressionModel.h"
#import "ArticleImpressionHelper.h"
#import "FriendDataManager.h"
#import "TTIndicatorView.h"
#import "TTFollowThemeButton.h"
#import "TTRoute.h"
#import "TTRecommendUserCollectionView.h"
#import "ExploreItemActionManager.h"
#import <TTAccountManager.h>

#define kHeaderViewHeight 40
#define kFooterViewHeight 10

#define kLeftPadding 15
#define kRightPadding 15

#define kRecommendLabelHeight ([TTDeviceHelper isScreenWidthLarge320] ? 20 : 18)
#define kShowMoreLabelHeight 18

#define kRecommendLabelFontSize ([TTDeviceHelper isScreenWidthLarge320] ? 16 : 14)
#define kShowMoreLabelFontSize 14



@interface TTRecommendUserCell ()

@property (nonatomic, strong) TTRecommendUserCellView *recommendUserCellView;

@end

@interface TTRecommendUserCellView () <TTRecommendUserCollectionViewDelegate>

@property (nonatomic, strong) TTRecommendUserCollectionView *collectionView;
@property (nonatomic, strong) ExploreOrderedData *orderedData;
@property (nonatomic, strong) RecommendUserCardsData *recommendUserCardsData;

@property (nonatomic, strong) SSThemedView *topRect;
@property (nonatomic, strong) SSThemedView *bottomRect;
@property (nonatomic, strong) SSThemedLabel *recommendLabel;
@property (nonatomic, strong) SSThemedLabel *showMoreLabel;

@end

@implementation TTRecommendUserCell

+ (Class)cellViewClass
{
    return [TTRecommendUserCellView class];
}

- (ExploreCellViewBase *)createCellView
{
    if (!_recommendUserCellView) {
        self.recommendUserCellView = [[TTRecommendUserCellView alloc] initWithFrame:self.bounds];
    }
    return _recommendUserCellView;
}

- (void)willDisplay
{
    [_recommendUserCellView.collectionView willDisplay];
}

- (void)didEndDisplaying
{
    [_recommendUserCellView.collectionView didEndDisplaying];
}

@end

@implementation TTRecommendUserCellView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.collectionView = [TTRecommendUserCollectionView collectionView];
        self.collectionView.needSupplementCard = YES;
        self.collectionView.recommendUserDelegate = self;
        [self addSubview:self.collectionView];
    }
    return self;
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType slice:(BOOL)slice {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        NSUInteger cellViewType = [self cellTypeForCacheHeightFromOrderedData:data];
        CGFloat cacheH = [orderedData cacheHeightForListType:listType cellType:cellViewType];
        if (cacheH > 0) {
            if (cacheH > 0) {
                if ([orderedData nextCellHasTopPadding]){
                    cacheH -= kCellSeprateViewHeight();
                }
                if ([orderedData preCellHasBottomPadding]) {
                    cacheH -= kCellSeprateViewHeight();
                }
                if (cacheH > 0) {
                    return cacheH;
                }
            }
            return 0.f;
        }
        
        CGFloat height = kHeaderViewHeight;
        
        height += [TTDeviceUIUtils tt_newPadding:180.f]; // collectionView 高度
        
        if (!slice) {
            height += 2 * kCellSeprateViewHeight();
        }
        height += kFooterViewHeight;
        if (orderedData.cellType == ExploreOrderedDataCellTypeArticle) {
            height += 5;
        }
        
        height = ceilf(height);

        [orderedData saveCacheHeight:height forListType:listType cellType:cellViewType];

        
        if (height > 0) {
            if ([orderedData nextCellHasTopPadding]) {
                height -= kCellSeprateViewHeight();
            }
            if ([orderedData preCellHasBottomPadding]) {
                height -= kCellSeprateViewHeight();
            }
            if (height > 0) {
                return height;
            }
        }
    }
    
    return 0.f;

}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    return [TTRecommendUserCellView heightForData:data cellWidth:width listType:listType slice:NO];
}

- (NSUInteger)refer {
    return [[self cell] refer];
}

- (id)cellData {
    return self.orderedData;
}

- (BOOL)shouldRefresh {
    if ([[self recommendUserCardsData] needRefreshUI]) {
        return [[self recommendUserCardsData] needRefreshUI];
    }

    return NO;
}

- (void)refreshDone {
    if ([self recommendUserCardsData]) {
        [[self recommendUserCardsData] setNeedRefreshUI:YES];
    }
}

#pragma mark - getter and setter

/** 顶部分割面 */
- (SSThemedView *)topRect {
    if (_topRect == nil) {
        _topRect = [[SSThemedView alloc] init];
        _topRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_topRect];
    }

    return _topRect;
}

/** 底部分割线 */
- (SSThemedView *)bottomRect {
    if (_bottomRect == nil) {
        _bottomRect = [[SSThemedView alloc] init];
        _bottomRect.backgroundColorThemeKey = kColorBackground3;
        [self addSubview:_bottomRect];
    }

    return _bottomRect;
}

- (SSThemedLabel *)recommendLabel {
    if (!_recommendLabel) {
        _recommendLabel = [[SSThemedLabel alloc] init];
        _recommendLabel.font = [UIFont systemFontOfSize:kRecommendLabelFontSize];
        _recommendLabel.numberOfLines = 1;
        _recommendLabel.textColorThemeKey = kColorText1;
        _recommendLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        [self addSubview:_recommendLabel];
    }

    return _recommendLabel;
}

- (SSThemedLabel *)showMoreLabel {
    if (!_showMoreLabel) {
        _showMoreLabel = [[SSThemedLabel alloc] init];
        _showMoreLabel.font = [UIFont systemFontOfSize:kShowMoreLabelFontSize];
        _showMoreLabel.textAlignment = NSTextAlignmentRight;
        _showMoreLabel.numberOfLines = 1;
        _showMoreLabel.textColorThemeKey = kColorText1;
        _showMoreLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
        [self addSubview:_showMoreLabel];
    }

    return _showMoreLabel;
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    self.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    _collectionView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    _recommendLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    _showMoreLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
}

- (void)refreshUI {
    self.topRect.frame = CGRectMake(0, 0, 0, kCellSeprateViewHeight());
    self.bottomRect.frame = CGRectMake(0, 0, 0, kCellSeprateViewHeight());

    self.recommendLabel.frame = CGRectMake(kLeftPadding, (kHeaderViewHeight - kRecommendLabelHeight) / 2, self.width - kLeftPadding - kRightPadding, kRecommendLabelHeight);

    self.collectionView.frame = CGRectMake(0, kHeaderViewHeight, self.width, [TTDeviceUIUtils tt_newPadding:182.f]);

    self.showMoreLabel.centerY = self.recommendLabel.centerY;
    self.showMoreLabel.right = self.width - kRightPadding;
    self.showMoreLabel.height = kShowMoreLabelHeight;

    if ([self.orderedData preCellHasBottomPadding]) {
        CGRect bounds = self.bounds;
        bounds.origin.y = 0;
        self.bounds = bounds;
        self.topRect.hidden = YES;
    } else {
        CGRect bounds = self.bounds;
        bounds.origin.y = - kCellSeprateViewHeight();
        self.bounds = bounds;
        self.topRect.bottom = 0;
        self.topRect.width = self.width;
        self.topRect.hidden = NO;
    }

    if (!([self.orderedData nextCellHasTopPadding])) {
        self.bottomRect.bottom = self.height + self.bounds.origin.y;
        self.bottomRect.width = self.width;
        self.bottomRect.hidden = NO;
    } else {
        self.bottomRect.hidden = YES;
    }
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
        return;
    }
    
    if ([self.orderedData.originalData isKindOfClass:[RecommendUserCardsData class]]) {
        self.recommendUserCardsData = (RecommendUserCardsData *)self.orderedData.originalData;
    } else {
        self.recommendUserCardsData = nil;
        return;
    }
    
    self.recommendLabel.text = _recommendUserCardsData.title;
    [self.recommendLabel sizeToFit];

    self.showMoreLabel.text = _recommendUserCardsData.showMore;
    [self.showMoreLabel sizeToFit];

    if ([self.orderedData.categoryID isEqualToString:kTTWeitoutiaoCategoryID]) {
        self.collectionView.followSource = TTFollowNewSourceRecommendUserWeitoutiaoCategory;
    } else if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
        self.collectionView.followSource = TTFollowNewSourceRecommendUserMainFeed;
    } else if ([self.orderedData.categoryID isEqualToString:kTTFollowCategoryID]) {
        self.collectionView.followSource = TTFollowNewSourceRecommendUserFollowCategory;
    } else {
        self.collectionView.followSource = TTFollowNewSourceRecommendUserOtherCategory;
    }
    
    FRUserRelationUserRecommendV1SupplementRecommendsRequestModel* requestModel = nil;
    if (self.recommendUserCardsData.hasMore) {
        requestModel = [[FRUserRelationUserRecommendV1SupplementRecommendsRequestModel alloc] init];
        requestModel.source = @"feedrec";
    }
    
    [self.collectionView configUserModels:self.recommendUserCardsData.userCardModels requesetModel:requestModel];
}

#pragma mark - TTRecommendUserCollectionViewDelegate

- (void)trackWithEvent:(NSString *)event extraDic:(NSDictionary *)extraDic {
    if (isEmptyString(event)) {
        return;
    }
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObject:self.orderedData.categoryID forKey:@"category_name"];
    if (extraDic) {
        [dic addEntriesFromDictionary:extraDic];
    }
    
    if ([event isEqualToString:@"follow"] || [event isEqualToString:@"unfollow"]) { // "rt_follow" 关注动作统一化 埋点
        NSMutableDictionary* rtFollowDict = [NSMutableDictionary dictionaryWithObject:@"from_recommend" forKey:@"follow_type"];
        [rtFollowDict setValue:self.orderedData.categoryID forKey:@"category_name"];
        if (![extraDic tt_stringValueForKey:@"profile_user_id"]
            || [[extraDic tt_stringValueForKey:@"profile_user_id"] isEqualToString:@"0"]
            || [[extraDic tt_stringValueForKey:@"profile_user_id"] isEqualToString:@""]
            || [[extraDic tt_stringValueForKey:@"profile_user_id"] isEqualToString:[TTAccountManager userID]]) {
            //原来的卡片
            [rtFollowDict setValue:@"list_follow_card_horizon" forKey:@"source"];
        } else {
            [rtFollowDict setValue:@"list_follow_card_horizon_related" forKey:@"source"];
            [rtFollowDict setValue:[extraDic objectForKey:@"profile_user_id"] forKey:@"profile_user_id"];
        }
        [rtFollowDict setValue:self.orderedData.logPb forKey:@"log_pb"];
        [rtFollowDict setValue:[extraDic objectForKey:@"order"] forKey:@"order"];
        [rtFollowDict setValue:[extraDic objectForKey:@"user_id"] forKey:@"to_user_id"];
        [rtFollowDict setValue:[extraDic objectForKey:@"server_source"] forKey:@"server_source"];
        [rtFollowDict setValue:[extraDic objectForKey:@"server_extra"] forKey:@"server_extra"];
        [rtFollowDict setValue:[extraDic objectForKey:@"is_redpacket"] forKey:@"is_redpacket"];
        if ([event isEqualToString:@"follow"]) {
            [rtFollowDict setValue:[extraDic objectForKey:@"user_recommend_follow_event"] forKey:@"user_recommend_follow_event"];
        }else {
            [rtFollowDict setValue:[extraDic objectForKey:@"user_recommend_unfollow_event"] forKey:@"user_recommend_unfollow_event"];
        }
        
        if ([event isEqualToString:@"follow"]) {
            [TTTrackerWrapper eventV3:@"rt_follow" params:rtFollowDict];
        } else {
            [TTTrackerWrapper eventV3:@"rt_unfollow" params:rtFollowDict];
        }
    } else {
        [TTTrackerWrapper eventV3:event params:dic];//取消关注双发
    }
}

- (NSString *)categoryID {
    return self.orderedData.categoryID;
}

- (void)onRemoveModel:(FRRecommendCardStructModel *)model originalModels:(NSArray<FRRecommendCardStructModel *> *)models {
    self.recommendUserCardsData.userCardModels = models;
    if (models == nil || models.count == 0) {
        if (!self.orderedData) {
            return;
        }
        [ExploreItemActionManager removeOrderedData:self.orderedData];
    }
}

- (void)onReplaceModel:(FRRecommendCardStructModel *)oldModel newModel:(FRRecommendCardStructModel *)newModel originalModels:(NSArray<FRRecommendCardStructModel *> *)models {
    self.recommendUserCardsData.userCardModels = models;
    if (models == nil || models.count == 0) {//保护用
        if (!self.orderedData) {
            return;
        }
        [ExploreItemActionManager removeOrderedData:self.orderedData];
    }
}

- (void)onCardEmpty {
    
}

- (NSDictionary *)impressionParams {
    NSMutableDictionary* dict = [NSMutableDictionary dictionaryWithObject:self.orderedData.categoryID forKey:@"category_name"];
    [dict setValue:self.orderedData.uniqueID forKey:@"unique_id"];
    [dict setValue:@"list_follow_card_horizon" forKey:@"card_type"];
    //添加impressionParams
    return dict;
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    RecommendUserCardsData *recommendUserCardsData = self.recommendUserCardsData;
    if (recommendUserCardsData != nil) {
        NSURL *openURL = [TTStringHelper URLWithURLString:recommendUserCardsData.showMoreJumpURL];
        if ([[TTRoute sharedRoute] canOpenURL:openURL]) {
            [[TTRoute sharedRoute] openURLByPushViewController:openURL];
        }
    }
    [self trackWithEvent:@"follow_card" extraDic:@{@"action_type":@"click_more"}];
}

@end
