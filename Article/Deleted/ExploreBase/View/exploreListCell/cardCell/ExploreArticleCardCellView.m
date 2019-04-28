//
//  ExploreArticleCardCellView.m
//  Article
//
//  Created by Chen Hong on 14/11/21.
//
//

#import "ExploreArticleCardCellView.h"
#import "ExploreArticleCellView.h"
#import "ExploreArticleStockCellView.h"
#import "TTLayOutCellViewBase.h"

#import "TTRoute.h"
#import "ExploreCellHelper.h"
#import "ExploreMixListDefine.h"
#import "TTCategoryDefine.h"
#import "NewsDetailConstant.h"
#import "ArticleDetailHeader.h"
#import "ExploreArticleTitleRightPicCellView.h"

// cell model
#import "Card+CoreDataClass.h"
#import "TTArticleCardCellViewHeaderView.h"
#import "TTArticleCardCellViewFooterView.h"

#import "TTUISettingHelper.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"
#import "TTActionPopView.h"
#import "UIImage+TTThemeExtension.h"

#import "ArticleImpressionHelper.h"
#import "TTPlatformSwitcher.h"
#import "TTFeedDislikeView.h"
#import "Book.h"
#import "ExploreOrderedData+TTAd.h"


#define kHeaderViewHeight 40
#define kFooterViewHeight ([TTDeviceHelper isScreenWidthLarge320] ? 40 : 36)

#define kHasLine 1

@interface ExploreArticleCardCellView () <TTDislikePopViewDelegate>

@property(nonatomic,strong)TTArticleCardCellViewHeaderView *headerView;
@property(nonatomic,strong)TTArticleCardCellViewFooterView *footerView;

#if kHasLine
@property(nonatomic,strong)SSThemedView *topLine;
@property(nonatomic,strong)SSThemedView *topLine2;
@property(nonatomic,strong)SSThemedView *bottomLine;
@property(nonatomic,strong)SSThemedView *bottomLine2;
@property(nonatomic,strong)SSThemedView *leftLine;
@property(nonatomic,strong)SSThemedView *rightLine;
#endif

@property(nonatomic,strong)NSMutableArray<ExploreCellViewBase *> *subCellViewArray;
@property(nonatomic,strong)NSMutableArray<NSNumber *> *subCellViewVisibleStatus;

@property(nonatomic,strong)UIButton *unInterestedButton;  // 不感兴趣
@property(nonatomic,strong)SSThemedButton *moreButton;    // 新版不感兴趣

@property (nonatomic, strong) ExploreOrderedData *orderedData;

@end

@implementation ExploreArticleCardCellView


- (void)dealloc {
    for (ExploreCellViewBase *itemView in self.subCellViewArray) {
        [ExploreCellHelper recycleCellView:itemView];
    }
}

+ (CGFloat)headerViewTopPadding
{
    if ([TTDeviceHelper isPadDevice]) {
        return 20;
    } else {
        return kCellSeprateViewHeight();
    }
}

+ (CGFloat)footerViewBottomPading
{
    if ([TTDeviceHelper isPadDevice]) {
        return 20;
    } else {
        return kCellSeprateViewHeight();
    }
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
        Card *cardModel = orderedData.card;
        NSArray *cardItems = [cardModel cardItems];
        if (cardItems.count == 0) {
            return [TTDeviceHelper ssOnePixel];
        }
        
        BOOL isPad = [TTDeviceHelper isPadDevice];
        
        float height = [self headerViewTopPadding] + kFooterViewHeight + [self footerViewBottomPading];
        if ([orderedData preCellHasBottomPadding] && !isPad) {
            height -= [self headerViewTopPadding];
        }

        CGFloat headerViewHeight = [self heightForHeaderViewWithData:cardModel];
        height += headerViewHeight;
        
        if ((isEmptyString(cardModel.showMoreModel.urlString) || isEmptyString(cardModel.showMoreModel.title)) && cardModel.tabLists.count == 0) {
            height -= kFooterViewHeight;
        }

        if (!isPad) {
            if ([orderedData nextCellHasTopPadding]) {
                height -= [self footerViewBottomPading];
            }
        }
        
        CGFloat subCellHeight = 0;
        NSInteger count = cardItems.count;
        for (NSInteger idx = 0; idx < count; idx++) {
            id item = cardItems[idx];
            if ([item isKindOfClass:[ExploreOrderedData class]]) {
                ExploreOrderedData *itemOrderedData = (ExploreOrderedData *)item;
                [itemOrderedData setIsInCard:YES];
                itemOrderedData.cardPrimaryID = orderedData.primaryID;
            }
            CGFloat itemH = [ExploreCellHelper heightForData:item cellWidth:width listType:listType];
            
            if ([item respondsToSelector:@selector(isVideoPGCCard)] &&
                [item isVideoPGCCard]) {
                CGSize picSize = [ExploreArticleTitleRightPicCellView picSizeWithCellWidth:width];
                
                if (idx == 0 && count > 1) {
                    itemH = picSize.height + kVideoPGCCellTopInset * 3;
                } else if (idx == count - 1 && count > 1) {
                    itemH = picSize.height + kVideoPGCCellTopInset * 3;
                } else {
                    itemH = picSize.height + kVideoPGCCellTopInset * 2;
                }
            }
            subCellHeight += itemH;
            //height += itemH;
        }
        
        if (fabs(subCellHeight - 0) < DBL_EPSILON) {
            //子cell的高度都是0 不显示这个卡片
            return 0;
        }
        
        height += subCellHeight;
        return ceilf(height);
    }
    return 0.f;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _headerView = [[TTArticleCardCellViewHeaderView alloc] initWithFrame:CGRectZero];
        [self addSubview:_headerView];
        [_headerView setTarget:self selector:@selector(showTop)];
        _footerView = [[TTArticleCardCellViewFooterView alloc] initWithFrame:CGRectZero];
        [self addSubview:_footerView];
        [_footerView setTarget:self selector:@selector(showBottom)];
        
#if kHasLine
        _topLine = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _topLine.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_topLine];
        _bottomLine = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLine.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_bottomLine];
        
        _topLine2 = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _topLine2.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_topLine2];
        _bottomLine2 = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _bottomLine2.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_bottomLine2];
        
        _leftLine = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _leftLine.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_leftLine];
        
        _rightLine = [[SSThemedView alloc] initWithFrame:CGRectZero];
        _rightLine.backgroundColorThemeKey = kColorLine1;
        [self addSubview:_rightLine];
#endif
        
        self.subCellViewArray = [NSMutableArray arrayWithCapacity:3];
        self.subCellViewVisibleStatus = [NSMutableArray arrayWithCapacity:3];

        [self reloadThemeUI];
    }
    return self;
}

- (UIButton *)unInterestedButton
{
    if (self.listType == ExploreOrderedDataListTypeFavorite) {
        if (_unInterestedButton) {
            [_unInterestedButton removeFromSuperview];
            _unInterestedButton = nil;
        }
        return nil;
    }
    
    if (!_unInterestedButton) {
        NSString *imgName = [TTDeviceHelper isPadDevice] ? @"dislikeicon_card_textpage" : @"add_textpage";
        _unInterestedButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 44)];
        [_unInterestedButton setImage:[UIImage themedImageNamed:imgName] forState:UIControlStateNormal];
        _unInterestedButton.backgroundColor = [UIColor clearColor];
        [_unInterestedButton addTarget:self action:@selector(unInterestButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.headerView addSubview:_unInterestedButton];
    }
    return _unInterestedButton;
}

- (SSThemedButton *)moreButton {
    if (!_moreButton) {
        _moreButton = [[SSThemedButton alloc] init];
        [_moreButton setImage:[UIImage themedImageNamed:@"function_icon"] forState:UIControlStateNormal];
        _moreButton.backgroundColor = [UIColor clearColor];
        [_moreButton addTarget:self action:@selector(moreViewClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_moreButton];
    }
    return _moreButton;
}

- (void)layoutMoreButtonView {
    CGFloat side = self.headerView.height;
    _moreButton.frame = CGRectMake(self.width - side - 1, self.headerView.top, side, side);
    //5.7需求 后端同时传头部的主副标题，但没有落地url
    if([[self class] isNewHeadStyleWithData:self.orderedData.card]){
        _moreButton.centerY = 22;
    }
}

- (NSDictionary *)extraValueDic {
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    if (self.orderedData.card) {
        [dic setObject:@(self.orderedData.card.uniqueID) forKey:@"item_id"];
    }
    if (self.orderedData.categoryID) {
        [dic setObject:self.orderedData.categoryID forKey:@"category_id"];
    }
    if ([self getRefer]) {
        [dic setObject:[NSNumber numberWithUnsignedInteger:[self getRefer]] forKey:@"location"];
    }
    [dic setObject:@1 forKey:@"gtype"];
    return dic;
}

- (void)moreViewClick {
    wrapperTrackEventWithCustomKeys(@"new_list", @"click_more", [TTActionPopView.shareGroupId stringValue], nil, [self extraValueDic]);
    
    if (self.orderedData.actionList.count > 0) {
        NSMutableArray *actionItem = [[NSMutableArray alloc] init];
        for (NSDictionary *action in self.orderedData.actionList) {
            long type = [action[@"action"] integerValue];
            switch (type) {
                case 1: {
                    NSString *descrip = @"不感兴趣";
                    NSString *iconName = @"ugc_icon_not_interested";
                    NSString *desc = [action objectForKey:@"desc"];
                    if (![desc isEqualToString:@""]) {
                        descrip = [action[@"desc"] stringValue];
                    }
                    NSMutableArray *dislikeWords = [[NSMutableArray alloc] init];
                    if (self.orderedData.card.uniqueID == 0) {
                        break;
                    }
                    for (NSDictionary *words in self.orderedData.card.filterWords) {
                        TTFeedDislikeWord *word = [[TTFeedDislikeWord alloc] initWithDict:words];
                        [dislikeWords addObject:word];
                    }
                     __weak typeof(self) wself = self;
                    if ([dislikeWords count] > 0) {
                         TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:descrip iconName:iconName hasSub:YES action:^{
                             [[TTActionPopView shareView] showDislikeView:wself.orderedData dislikeWords:dislikeWords groupID:@(self.orderedData.card.uniqueID)];
                             wrapperTrackEventWithCustomKeys(@"new_list", @"show_dislike_with_reason", [TTActionPopView.shareGroupId stringValue], nil, [self extraValueDic]);
                         }];
                        [actionItem addObject:item];
                    } else {
                        TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:descrip iconName:iconName hasSub:NO action:^{
                            [[TTActionPopView shareView] showDislikeView:wself.orderedData dislikeWords:dislikeWords groupID:@(self.orderedData.card.uniqueID)];
                            [wself dislikeButtonClicked:[[NSArray<NSString *> alloc] init] onlyOne:NO];
                        }];
                        [actionItem addObject:item];
                    }
                }
                    break;
                case 2:{
                    NSString *iconName = @"ugc_icon_dislike";
                    NSString *desc = [action[@"desc"] stringValue];
                    if (desc != nil && [desc isEqualToString:@""]) {
                        TTFeedDislikeWord *word = [[TTFeedDislikeWord alloc] initWithDict:action[@"extra"]];
                        if (word != nil) {
                            __weak typeof(self) wself = self;
                            TTActionListItem *item = [[TTActionListItem alloc] initWithDescription:desc iconName:iconName hasSub:NO action:^{
                                [wself dislikeButtonClicked:@[word] onlyOne:YES];
                            }];
                            [actionItem addObject:item];
                        }
                    }
                }
                    break;
                default:
                    break;
            }
        }
        TTActionPopView *popupView = [[TTActionPopView alloc] initWithActionItems:actionItem width:self.width];
        
        popupView.delegate = self;
        CGPoint p = self.moreButton.center;
        [popupView showAtPoint:p fromView:self.moreButton];
    }
}

- (void)dislikeButtonClicked:(NSArray<NSString *> *)selectedWords onlyOne:(BOOL)onlyOne {
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (selectedWords.count > 0) {
        [userInfo setValue:selectedWords forKey:kExploreMixListNotInterestWordsKey];
        if (onlyOne) {
            wrapperTrackEventWithCustomKeys(@"new_list", @"confirm_dislike_only_reason", [TTActionPopView.shareGroupId stringValue], nil, [self extraValueDic]);
        } else {
            wrapperTrackEventWithCustomKeys(@"new_list", @"confirm_dislike_with_reason", [TTActionPopView.shareGroupId stringValue], nil, [self extraValueDic]);
        }
    } else {
        wrapperTrackEventWithCustomKeys(@"new_list", @"confirm_dislike_no_reason", [TTActionPopView.shareGroupId stringValue], nil, [self extraValueDic]);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
}

#pragma mark - shouldRefresh
- (BOOL)shouldRefresh{
    __block BOOL result = NO;
    
    [self.subCellViewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        ExploreCellViewBase *subCellView = (ExploreCellViewBase *)obj;
        if ([subCellView isKindOfClass:[ExploreArticleStockCellView class]]) {
           result = [((ExploreArticleStockCellView *)(subCellView)) shouldRefresh];
        }
    }];
    
    return result;
}

#pragma mark - unInterestButton action
- (void)unInterestButtonClicked:(id)sender
{
    TTFeedDislikeView *dislikeView = [[TTFeedDislikeView alloc] init];
    TTFeedDislikeViewModel *viewModel = [[TTFeedDislikeViewModel alloc] init];
    viewModel.keywords = self.orderedData.card.filterWords;
    viewModel.groupID = [NSString stringWithFormat:@"%lld", self.orderedData.card.uniqueID];
    viewModel.logExtra = self.orderedData.log_extra;
    [dislikeView refreshWithModel:viewModel];
    CGPoint point = _unInterestedButton.center;
    [dislikeView showAtPoint:point
                    fromView:_unInterestedButton
             didDislikeBlock:^(TTFeedDislikeView * _Nonnull view) {
                 [self exploreDislikeViewOKBtnClicked:view];
             }];
}

- (void)layoutUnInterestedBtn
{
    CGFloat w = _unInterestedButton.imageView.image.size.width/2;
    if (w == 0) {
        w = 8.5f;
    }
    
    CGFloat centerX, y;
    
    if ([TTDeviceHelper isPadDevice]) {
        centerX = self.width - 5 - w;
    } else {
        centerX = self.width - 15 - w;
    }
    y = self.headerView.height/2 - _unInterestedButton.height/2;

    _unInterestedButton.centerX = centerX;
    _unInterestedButton.top = ceilf(y);
    
    //5.7需求 后端同时传头部的主副标题，但没有落地url
    if([[self class] isNewHeadStyleWithData:self.orderedData.card]){
        _unInterestedButton.centerY = 22;
    }
    
    //热点要闻需求
    Card *card = self.orderedData.card;
    if ([card.cardType integerValue] == 6) {
        _unInterestedButton.top = ceilf(y) + 4;
    }
}

#pragma mark TTFeedDislikeView

- (void)exploreDislikeViewOKBtnClicked:(TTFeedDislikeView *)dislikeView {
    if (!self.orderedData) {
        return;
    }
    NSArray *filterWords = [dislikeView selectedWords];
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithCapacity:3];
    [userInfo setValue:self.orderedData forKey:kExploreMixListNotInterestItemKey];
    if (filterWords.count > 0) {
        [userInfo setValue:filterWords forKey:kExploreMixListNotInterestWordsKey];
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kExploreMixListNotInterestNotification object:self userInfo:userInfo];
    //v3 打点
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:6];
    [params setValue:@"no_interest" forKey:@"dislike_type"];
    [params setValue:@"click_dislike" forKey:@"enter_from"];
    [params setValue:self.orderedData.categoryID forKey:@"category_name"];
    [params setValue:@"stream" forKey:@"tab_name"];
    [params setValue:@"list" forKey:@"position"];
    NSString *cardId = [NSString stringWithFormat:@"%lld", self.orderedData.card.uniqueID];
    [params setValue:cardId forKey:@"card_id"];
    [TTTrackerWrapper eventV3:@"rt_dislike" params:params];
}

#pragma mark -

- (void)themeChanged:(NSNotification *)notification
{
    [super themeChanged:notification];
    
    _headerView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    
    _footerView.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    
    if ([TTDeviceHelper isPadDevice]) {
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    } else {
        self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    }
    
    NSString *imgName = [TTDeviceHelper isPadDevice] ? @"dislikeicon_card_textpage" : @"add_textpage";
    
    [_unInterestedButton setImage:[UIImage themedImageNamed:imgName] forState:UIControlStateNormal];
}

- (void)fontSizeChanged
{
    [ExploreCellHelper refreshFontSizeForRecycleCardViews];
    
    for (ExploreCellViewBase *subCell in self.subCellViewArray) {
        if ([subCell isKindOfClass:[ExploreCellViewBase class]]) {
            [subCell fontSizeChanged];
        }
    }
    
    [self refreshUI];
}

- (void)refreshUI {
    BOOL hasLabel = YES;
    
    BOOL isPad = [TTDeviceHelper isPadDevice];
    
    CGFloat topPadding = [self.class headerViewTopPadding];
    if ([self.orderedData preCellHasBottomPadding] && !isPad) {
        topPadding = 0;
    }
    
    Card *cardModel = self.orderedData.card;
    
    if (isEmptyString(cardModel.cardTitle) && isEmptyString(cardModel.titlePrefix) && [cardModel.cardType intValue] == 1) {
        hasLabel = NO;
    }
    
    self.unInterestedButton.hidden = NO;
    CGFloat headerViewHeight = [[self class] heightForHeaderViewWithData:cardModel];
    _headerView.frame = CGRectMake(0, topPadding, self.width, headerViewHeight);
    [_headerView refreshUIWithModel:self.orderedData];
    
    if (hasLabel && [self.orderedData.showDislike boolValue]) {
        if ([self.orderedData isFeedUGC]) {
            self.unInterestedButton.hidden = YES;
            if ([self.orderedData.actionList count] > 0) {
                self.moreButton.hidden = NO;
                [self layoutMoreButtonView];
            } else {
                self.moreButton.hidden = YES;
            }
        } else {
            if (!_unInterestedButton) {
                [_headerView addSubview:self.unInterestedButton];
            }
            if (_unInterestedButton) {
                _unInterestedButton.hidden = NO;
                _moreButton.hidden = YES;
                [self layoutUnInterestedBtn];
            }
        }
    } else {
        _unInterestedButton.hidden = YES;
        _moreButton.hidden = YES;
    }

#if DEBUG
    self.unInterestedButton.hidden = NO;
    [self layoutUnInterestedBtn];
#endif
    self.unInterestedButton.hidden = YES;
    CGFloat y = _headerView.bottom;
    
    ExploreCellViewBase *lastSubCellView = nil;
    
    for (NSInteger idx = 0; idx < self.subCellViewArray.count; idx++) {
        ExploreCellViewBase *subCell = self.subCellViewArray[idx];

        CGFloat itemH = [ExploreCellHelper heightForData:subCell.cellData cellWidth:self.width listType:self.listType];

        if ([subCell isHotNewsCellInCard]) {
            subCell.showAvatar = [subCell.cellData isHotNewsCellWithAvatar];
            subCell.showRedDot = [subCell.cellData isHotNewsCellWithRedDot];
        }

        BOOL isVideoPGCCard = NO;
        if ([subCell.cellData respondsToSelector:@selector(isVideoPGCCard)]) {
            isVideoPGCCard = [subCell.cellData isVideoPGCCard];
        }
        if (isVideoPGCCard) {
            CGSize picSize = [ExploreArticleTitleRightPicCellView picSizeWithCellWidth:subCell.width];

            if (idx == 0 && self.subCellViewArray.count > 1) {
                subCell.position = ExploreCellPositionTop;
                itemH = picSize.height + kVideoPGCCellTopInset * 3;
            } else if (idx == self.subCellViewArray.count - 1 && self.subCellViewArray.count > 1) {
                subCell.position = ExploreCellPositionBottom;
                itemH = picSize.height + kVideoPGCCellTopInset * 3;
            } else {
                subCell.position = ExploreCellPositionMiddle;
                itemH = picSize.height + kVideoPGCCellTopInset * 2;
            }

            subCell.hideBottomLine = YES;
        } else {
            subCell.hideBottomLine = NO;
        }

        subCell.frame = CGRectMake(0, y, self.width, itemH);
        [subCell refreshUI];

        y += itemH;

        lastSubCellView = subCell;
    }

    if ((isEmptyString(cardModel.showMoreModel.urlString) || isEmptyString(cardModel.showMoreModel.title)) && cardModel.tabLists.count == 0)  {
        _footerView.frame = CGRectMake(0, y, self.width, 0);
        lastSubCellView.hideBottomLine = YES;
        [lastSubCellView refreshUI];
        _footerView.hidden = YES;
    } else {
        _footerView.frame = CGRectMake(0, y, self.width, kFooterViewHeight);
        _footerView.hidden = NO;
    }
    [_footerView refreshUIWithModel:self.orderedData];
#if kHasLine
    
    if (isPad) {
        _topLine.hidden = YES;
        _topLine2.hidden = NO;
        _bottomLine.hidden = YES;
        _bottomLine2.hidden = NO;
        
        if(topPadding == 0){
            _topLine2.frame = CGRectMake(0, [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
        }
        else{
            _topLine2.frame = CGRectMake(0, topPadding - [TTDeviceHelper ssOnePixel], self.width, [TTDeviceHelper ssOnePixel]);
        }
        
        _bottomLine2.frame = CGRectMake(0, _footerView.bottom, self.width, [TTDeviceHelper ssOnePixel]);
        
        _leftLine.frame = CGRectMake(0, _topLine2.top, [TTDeviceHelper ssOnePixel], _bottomLine2.bottom - _topLine2.top);
        _rightLine.frame = CGRectMake(_topLine2.right-[TTDeviceHelper ssOnePixel], _topLine2.top, [TTDeviceHelper ssOnePixel], _bottomLine2.bottom - _topLine2.top);
    }
#endif
}

- (void)refreshWithData:(id)data {
    if ([data isKindOfClass:[ExploreOrderedData class]]) {
        self.orderedData = data;
    } else {
        self.orderedData = nil;
    }
    
    Card *cardModel = self.orderedData.card;
    if (!cardModel) return;
    
    // 回收之前的itemView
    for (ExploreCellViewBase *itemView in self.subCellViewArray) {
        [ExploreCellHelper recycleCellView:itemView];
        [itemView removeFromSuperview];
    }
    
    [self.subCellViewArray removeAllObjects];
    [self.subCellViewVisibleStatus removeAllObjects];

    if (cardModel) {
        self.cardId = [@(cardModel.uniqueID) stringValue];
        
        __block ExploreCellViewBase *lastSubCellView = nil;
        
        [cardModel.cardItems enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if ([obj isKindOfClass:[ExploreOrderedData class]]) {
                [(ExploreOrderedData *)obj setIsInCard:YES];
            }
            ExploreCellViewBase *subCellView = [ExploreCellHelper dequeueTableCellViewForData:obj];
            
            subCellView.width = self.width;
            subCellView.isCardSubCellView = YES;
            subCellView.cardId = [@(cardModel.uniqueID) stringValue];
            subCellView.cardCategoryId = self.orderedData.categoryID;
            if ([cardModel.cardType integerValue] == 6) {
                subCellView.isHotNewsCellInCard = YES;
            }
            
            if ([subCellView isKindOfClass:[ExploreArticleCellView class]]) {
                ((ExploreArticleCellView *)(subCellView)).hideUnInerestedButton = YES;
            }
            
            if (subCellView) {
                [self addSubview:subCellView];
                [self.subCellViewArray addObject:subCellView];
                [self.subCellViewVisibleStatus addObject:@(0)];
                subCellView.cardSubCellIndex = idx + 1;
                [subCellView refreshWithData:obj];
            }
            
            lastSubCellView = subCellView;
        }];
        
        if (isEmptyString(cardModel.showMoreModel.title)) {
            lastSubCellView.hideBottomLine = YES;
        }
        
#if kHasLine
        if ([TTDeviceHelper isPadDevice]) {
            [self bringSubviewToFront:_leftLine];
            [self bringSubviewToFront:_rightLine];
        }
#endif
    }
}

#pragma mark - display cycle

- (void)willDisplay {
    // 重置显示状态
    [self resetSubCellViewVisibleState];
    
    // 检查cell整体显示时各子cell的状态
    [self checkSubCellViewVisibleState];
    
    // 开始监听tableview滚动
    WeakSelf;
    [self.KVOController observe:self.tableView keyPath:@"contentOffset" options:NSKeyValueObservingOptionNew block:^(id  _Nullable observer, UITableView * _Nonnull tableView, NSDictionary<NSString *,id> * _Nonnull change) {
        StrongSelf;
        [self checkSubCellViewVisibleState];
    }];
}

- (void)didEndDisplaying {
    // 结束监听tableView滚动
    [self.KVOController unobserve:self.tableView];
    
    // 结束所有子cell的显示状态
    [self endSubCellViewVisibleState];
    
    [self.subCellViewArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        ExploreCellViewBase *subCellView = (ExploreCellViewBase *)obj;
        if ([subCellView isKindOfClass:[ExploreArticleStockCellView class]]) {
            [((ExploreArticleStockCellView *)(subCellView)) didEndDisplaying];
        }
    }];
}

// subView是否在view的区域内
- (BOOL)isSubView:(UIView *)subView visibleInView:(UIView *)view {
    CGRect rect = [subView convertRect:subView.bounds toView:view];
    if (CGRectIntersectsRect(rect, view.bounds)) {
        return YES;
    }
    return NO;
}

- (void)checkSubCellViewVisibleState {
    UITableView *tableView = self.tableView;
    if (!tableView) return;
    
    for (int i = 0; i < self.subCellViewArray.count; ++i) {
        ExploreCellViewBase *cellView = self.subCellViewArray[i];
        BOOL newVisibleState = [self isSubView:cellView visibleInView:tableView];
        BOOL oldVisibleState = [self.subCellViewVisibleStatus[i] boolValue];
        
        if (oldVisibleState != newVisibleState) {
            if (newVisibleState) {
                [self beginImpressionForSubCellView:cellView];
            } else {
                [self endImpressionForSubCellView:cellView];
            }
            self.subCellViewVisibleStatus[i] = @(newVisibleState);
        }
    }
}

- (void)endSubCellViewVisibleState {
    for (int i = 0; i < self.subCellViewArray.count; ++i) {
        ExploreCellViewBase *cellView = self.subCellViewArray[i];
        BOOL oldVisibleState = [self.subCellViewVisibleStatus[i] boolValue];
        if (oldVisibleState) {
            [self endImpressionForSubCellView:cellView];
            self.subCellViewVisibleStatus[i] = @(NO);
        }
    }
}

- (void)resetSubCellViewVisibleState {
    for (int i = 0; i < self.subCellViewVisibleStatus.count; ++i) {
        self.subCellViewVisibleStatus[i] = @(NO);
    }
}

- (void)beginImpressionForSubCellView:(ExploreCellViewBase *)subCellView {
    ExploreOrderedData *orderedData = subCellView.cellData;
    
    if (![orderedData isKindOfClass:[ExploreOrderedData class]]) return;
    
    //NSLog(@"%@ %p %@", NSStringFromSelector(_cmd), subCellView, orderedData.uniqueID);
    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.categoryID = self.orderedData.categoryID;
    params.concernID = self.orderedData.concernID;
    params.refer = subCellView.cell.refer;
    params.cellStyle = subCellView.cellStyle;
    params.cellSubStyle = subCellView.cellSubStyle;
    [ArticleImpressionHelper recordGroupForExploreOrderedData:orderedData status:SSImpressionStatusRecording params:params];
}

- (void)endImpressionForSubCellView:(ExploreCellViewBase *)subCellView {    
    ExploreOrderedData *orderedData = subCellView.cellData;
    
    if (![orderedData isKindOfClass:[ExploreOrderedData class]]) return;
    
    //NSLog(@"%@ %p %@", NSStringFromSelector(_cmd), subCellView, orderedData.uniqueID);
    SSImpressionParams *params = [[SSImpressionParams alloc] init];
    params.categoryID = self.orderedData.categoryID;
    params.concernID = self.orderedData.concernID;
    params.refer = subCellView.cell.refer;
    params.cellStyle = subCellView.cellStyle;
    params.cellSubStyle = subCellView.cellSubStyle;
    [ArticleImpressionHelper recordGroupForExploreOrderedData:orderedData status:SSImpressionStatusEnd params:params];
}

//- (ExploreCellViewBase *)selectedCellView {
//    //selectedSubCellIndex从1开始
//    if (self.selectedSubCellIndex > 0 && self.selectedSubCellIndex <= self.subCellViewArray.count) {
//        ExploreCellViewBase *cellView = [self.subCellViewArray objectAtIndex:self.selectedSubCellIndex - 1];
//        return cellView;
//    }
//    
//    return nil;
//}

- (id)cellData {
    return self.orderedData;
}

- (void)showTop {
    if ([self.orderedData.card.cardType integerValue] == 6) {
        //热点要闻卡片禁止headerview点击跳转
        return;
    }
    [self showMoreFromBottom:NO];
}

- (void)showBottom {
    [self showMoreFromBottom:YES];
}

- (void)showMoreFromBottom:(BOOL)fromBottom {
    NSString *eventLabel = nil;
    NSString *url = nil;
    int pos = 0;
    
    if (fromBottom) {
        eventLabel = @"click_bottom_0";
        pos = -1;
        url = self.orderedData.card.showMoreModel.urlString;
        ExploreOrderedData *orderedData = self.orderedData.card.cardItems.firstObject;
        Book *book = orderedData.book;
        if([orderedData isKindOfClass:[ExploreOrderedData class]] && book) {
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            [params setValue:@"click_novel_card" forKey:@"enter_from"];
            [params setValue:@"novel_channel" forKey:@"category_name"];
            [TTTrackerWrapper eventV3:@"enter_category" params:[params copy] isDoubleSending:YES];
        }
    } else {
        eventLabel = @"click_top";
        pos = 0;
        if (!isEmptyString(self.orderedData.card.titleUrl)) {
            url = self.orderedData.card.titleUrl;
        }
        else {
            url = self.orderedData.card.showMoreModel.urlString;
        }
    }
    
    Card *cardModel = self.orderedData.card;
    
    if (!isEmptyString(url)) {
        TTRouteParamObj *paramObj = [[TTRoute sharedRoute] routeParamObjWithURL:[NSURL URLWithString:url]];
        
        NSString *pageName = paramObj.host;
        if ([pageName isEqualToString:@"feed"]) {
            pageName = @"channel_detail";
        } else if ([pageName isEqualToString:@"forum"]) {
            pageName = @"forum_detail";
        }

        NSString *cardId = [NSString stringWithFormat:@"%lld", cardModel.uniqueID];

        wrapperTrackEventWithCustomKeys(@"subscription", @"enter", cardId, nil, @{@"source":@"card"});
        wrapperTrackEventWithCustomKeys(@"card", eventLabel, cardId, nil, @{@"category_name":[NSString stringWithFormat:@"%@",self.orderedData.categoryID]});
        
        if (!isEmptyString(self.orderedData.categoryID) ) {
            if ([self.orderedData.categoryID isEqualToString:kTTMainCategoryID]) {
                eventLabel = @"click_headline";
            }
            else {
                eventLabel = [NSString stringWithFormat:@"click_%@", self.orderedData.categoryID];
            }
        }
        
        NSMutableDictionary *conditionDict = nil;
        if ([pageName isEqualToString:@"detail"]) {
            // 详情页统计 go_detail
            conditionDict = [NSMutableDictionary dictionary];
            [conditionDict setValue:self.orderedData.categoryID forKey:kNewsDetailViewConditionCategoryIDKey];
            [conditionDict setValue:@(NewsGoDetailFromSourceCategory) forKey:kNewsGoDetailFromSourceKey];

            if (!isEmptyString(cardId)) {
                NSDictionary *cardParam = @{@"card_id":cardId, @"card_position":@(pos)};
                [conditionDict setValue:cardParam forKey:@"stat_params"];
            }
        } else {
            // 卡片统计
            NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
            [dict setValue:@"umeng" forKey:@"category"];
            [dict setValue:pageName forKey:@"tag"];
            [dict setValue:eventLabel forKey:@"label"];
            [dict setValue:cardId forKey:@"card_id"];
            [dict setValue:@(pos) forKey:@"card_position"];
        
            if ([pageName isEqualToString:@"forum_detail"]) {
                conditionDict = [NSMutableDictionary dictionary];
                [conditionDict setValue:dict forKey:@"forum_umeng"];
            } else {
//                [TTTrackerWrapper eventData:dict];大可说卡片原来的统计太多了，现在只发一个统计
            }
        }
        
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:url] userInfo:TTRouteUserInfoWithDict(conditionDict)];
    }
}

// subcell点击高亮
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    self.selectedSubCellData = nil;
    UITouch *touch = [touches anyObject];
    ExploreCellViewBase *cellView = [self cellViewFromTouchView:touch.view];
    
    if ([cellView isKindOfClass:[ExploreCellViewBase class]] && ![SSCommonLogic transitionAnimationEnable]) {
        [cellView setHighlighted:YES animated:NO];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    ExploreCellViewBase *cellView = [self cellViewFromTouchView:touch.view];
    
    if ([cellView isKindOfClass:[ExploreCellViewBase class]]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cellView setHighlighted:NO animated:NO];
        });
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    ExploreCellViewBase *cellView = [self cellViewFromTouchView:touch.view];
    
    if (cellView != self && [cellView isKindOfClass:[ExploreCellViewBase class]]) {
        self.selectedSubCellData = cellView.cellData;
        self.selectedSubCellIndex = cellView.cardSubCellIndex;
        self.selectedSubCellView = cellView;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [cellView setHighlighted:NO animated:NO];
        });
    } else {
        self.selectedSubCellData = nil;
        self.selectedSubCellView = nil;
    }
}

- (ExploreCellViewBase *)cellViewFromTouchView:(UIView *)view {
    ExploreCellViewBase *cellView = nil;
    while (view && ![view isKindOfClass:[ExploreCellViewBase class]]) {
        view = view.superview;
    }
    if ([view isKindOfClass:[ExploreCellViewBase class]]) {
        cellView = (ExploreCellViewBase *)view;
    }
    return cellView;
}

//5.7需求 后端同时传头部的主副标题，但没有落地url
// 计算HeaderView的高度
+ (CGFloat)heightForHeaderViewWithData:(Card *)cardModel{
    
    if (isEmptyString(cardModel.cardTitle) && isEmptyString(cardModel.titlePrefix))
        return 0;
    else{
        //5.7需求 后端同时传头部的主副标题，但没有落地url
        if([self isNewHeadStyleWithData:cardModel]){
            return 35;
        }
        else{
            return kHeaderViewHeight;
        }
    }
}

//判断主副标题和落地url以及cardDayIcon
+ (BOOL)isNewHeadStyleWithData:(Card *)cardModel{
    if([cardModel.cardType intValue]== 5){
        return YES;
    }
    else{
        return NO;
    }
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    ExploreOrderedData *selectedOrderedData = self.selectedSubCellData;
    Card *cardObj = [self.orderedData card];
    NSInteger cardIndex = self.selectedSubCellIndex;
    NSString *cardId = self.cardId;
    
    ExploreCellViewBase *selectedCellView = self.selectedSubCellView;
    
    if (selectedCellView == self || selectedCellView == nil) {
        return;
    }
    
    if (!isEmptyString(cardId)) {
        context.cardId = cardId;
        context.cardIndex = cardIndex;
    }
    
    NSDictionary *extra = @{@"category_name": [NSString stringWithFormat:@"%@", self.orderedData.categoryID]};
    NSString *label = [NSString stringWithFormat:@"click_cell_%ld",(long)cardIndex];
    wrapperTrackEventWithCustomKeys(@"card", label, [NSString stringWithFormat:@"%lld", cardObj.uniqueID], nil, extra);
    
    if ([selectedOrderedData.originalData isKindOfClass:[Article class]] && cardIndex > 0) {
        // feed流卡片推荐文章
        wrapperTrackEvent(@"card", [NSString stringWithFormat:@"click_article_%ld", cardIndex]);
    }
    
    if ([selectedCellView respondsToSelector:@selector(didSelectWithContext:)]) {
        context.orderedData = selectedOrderedData;
        context.categoryId = self.orderedData.categoryID;//使用外层orderedData的categoryId，subCell的orderedData的categoryId是个假的
        [selectedCellView didSelectWithContext:context];
    }
}

@end
