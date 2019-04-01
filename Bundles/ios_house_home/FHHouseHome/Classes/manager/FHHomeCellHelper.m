//
//  FHHomeCellHelper.m
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import "FHHomeCellHelper.h"
#import "FHHomeEntrancesCell.h"
#import "FHHomeBannerCell.h"
#import "FHHomeCityTrendCell.h"
#import <FHHouseBase/FHConfigModel.h>
#import "UITableView+FDTemplateLayoutCell.h"
#import <FHHouseRent/FHSpringboardView.h>
#import <BDWebImage.h>
#import "UIColor+Theme.h"
#import <TTRoute.h>
#import "FHUserTracker.h"
#import "FHHouseBridgeManager.h"
#import <TTTracker.h>
#import "TTDeviceHelper.h"
#import "FHHomeHeaderTableViewCell.h"
#import "FHPlaceHolderCell.h"
#import "FHEnvContext.h"
#import <FHHouseBase/FHHouseBaseItemCell.h>

#define kFHHomeBannerDefaultHeight 60.0 //banner高度

#define kFHHomeIconDefaultHeight 52.0 //icon高度

#define kFHHomeIconRowCount 4 //每行icon个数

#define kFHHomeBannerRowCount 2 //每行banner个数

static NSMutableArray  * _Nullable identifierArr;

@interface FHHomeCellHelper ()

@property(nonatomic , strong) FHConfigDataModel *previousDataModel;
@property(nonatomic , assign) CGFloat headerHeight;

@end

@implementation FHHomeCellHelper


+(instancetype)sharedInstance
{
    static FHHomeCellHelper *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHHomeCellHelper alloc] init];
    });
    return manager;
}

+ (void)registerCells:(UITableView *)tableView
{
    [tableView registerClass:[FHHomeHeaderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeHeaderTableViewCell class])];
    
    [tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:NSStringFromClass([FHHouseBaseItemCell class])];
    
    [tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:NSStringFromClass([FHPlaceHolderCell class])];
    
    [tableView registerClass:[FHHomeBaseTableCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeBaseTableCell class])];
    
    [tableView registerClass:[FHHomeEntrancesCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeEntrancesCell class])];
    
    [tableView registerClass:[FHHomeBannerCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeBannerCell class])];
    
    [tableView registerClass:[FHHomeCityTrendCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeCityTrendCell class])];
}

+ (void)registerDelegate:(UITableView *)tableView andDelegate:(id)delegate
{
    tableView.delegate = delegate;
    tableView.dataSource = delegate;
}

- (void)refreshFHHomeTableUI:(UITableView *)tableView andType:(FHHomeHeaderCellPositionType)type
{
    self.headerType = type;
    
    NSMutableArray <JSONModel *>*modelsArray = [NSMutableArray new];
    FHConfigDataModel * dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (!dataModel) {
        dataModel = [[FHEnvContext sharedInstance] readConfigFromLocal];
    }
    
    if ([dataModel isKindOfClass:[FHConfigDataModel class]]) {
        if (dataModel.opData.items.count != 0) {
            [modelsArray addObject:dataModel.opData];
        }
        //不同频道cell顺序不同
        if (type == FHHomeHeaderCellPositionTypeForNews) {
            
            if (dataModel.opData2.items.count != 0) {
                [modelsArray addObject:dataModel.opData2];
            }
            
            if (dataModel.cityStats.count > 0) {
                for (FHConfigDataCityStatsModel *model in dataModel.cityStats) {
                    
                    if (model.houseType.integerValue == FHHouseTypeSecondHandHouse) {
                        [modelsArray addObject:model];
                        break;
                    }
                }
            }
        }else
        {
            if (dataModel.cityStats.count > 0) {
                for (FHConfigDataCityStatsModel *model in dataModel.cityStats) {
                    
                    if (model.houseType.integerValue == FHHouseTypeSecondHandHouse) {
                        [modelsArray addObject:model];
                        break;
                    }
                }
            }
            
            if (dataModel.opData2.items.count != 0) {
                [modelsArray addObject:dataModel.opData2];
            }
        }

    }
    
    if ([tableView.delegate isKindOfClass:[FHHomeTableViewDelegate class]] && ![modelsArray isEqualToArray:((FHHomeTableViewDelegate *)tableView.delegate).modelsArray]) {
        ((FHHomeTableViewDelegate *)tableView.delegate).modelsArray = modelsArray;
        [tableView reloadData];
        
        [FHHomeCellHelper sendCellShowTrace];
    }
}

+ (void)sendCellShowTrace
{
    
    FHConfigDataOpData2Model *modelOpdata2 = [FHHomeConfigManager sharedInstance].currentDataModel.opData2;
    
    if (modelOpdata2.items > 0)
    {
        [modelOpdata2.items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            NSString *stringOpStyle = @"be_null";
            FHConfigDataOpData2ItemsModel *item = (FHConfigDataOpData2ItemsModel *)obj;
            NSMutableDictionary *dictTraceParams = [NSMutableDictionary dictionary];
            
            if ([item isKindOfClass:[FHConfigDataOpData2ItemsModel class]]) {
                if ([item.logPb isKindOfClass:[NSDictionary class]]) {
                    NSString *stringName =  item.logPb[@"operation_name"];
                    [dictTraceParams setValue:stringName forKey:@"operation_name"];
                }
            }
            [dictTraceParams setValue:@"house_app2c_v2" forKey:@"event_type"];
            
            [dictTraceParams setValue:@"maintab" forKey:@"page_type"];
            
            
            [TTTracker eventV3:@"operation_show" params:dictTraceParams];
        }];
    }
    
    [identifierArr removeAllObjects];
    
}

- (CGFloat)heightForFHHomeHeaderCellViewType
{
    FHConfigDataModel * dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (!dataModel) {
        dataModel = [[FHEnvContext sharedInstance] readConfigFromLocal];
    }
    
    //如果数据无变化直接返回
    if (self.previousDataModel == dataModel) {
        return self.headerHeight;
    }
    

    CGFloat height = 0;
    if ([dataModel isKindOfClass:[FHConfigDataModel class]]) {
        
        NSInteger countValue = dataModel.opData.items.count;
        
        if (countValue > 0) {
            if (countValue > 8)
            {
                countValue = 8;
            }
            CGFloat heightPadding = [FHHomeCellHelper sharedInstance].headerType == FHHomeHeaderCellPositionTypeForNews ? 62 : 47;
            height += ((countValue - 1)/kFHHomeIconRowCount + 1) * (kFHHomeIconDefaultHeight * [TTDeviceHelper scaleToScreen375] + heightPadding);
        }
        
        NSInteger opData2CountValue = dataModel.opData2.items.count;
        
        if (opData2CountValue > 0) {
            if (opData2CountValue > 4)
            {
                opData2CountValue = 4;
            }
            height += ((opData2CountValue - 1)/kFHHomeBannerRowCount + 1) * (10 + [TTDeviceHelper scaleToScreen375] * kFHHomeBannerDefaultHeight);
        }
        BOOL hasCity = NO;
        if (dataModel.cityStats.count > 0) {
            for (FHConfigDataCityStatsModel *model in dataModel.cityStats) {
                if (model.houseType.integerValue == FHHouseTypeSecondHandHouse) {
                    hasCity = YES;
                    break;
                }
            }
            if (hasCity) {
                height += 84;
            }else {
                height += 10;
            }
        }
    }
    self.headerHeight = height;
    self.previousDataModel = dataModel;
    return height;
}

+ (Class)cellClassFromCellViewType:(FHHomeCellViewType)cellType
{
    switch (cellType) {
        case FHHomeCellViewTypeEntrances:
            return [FHHomeEntrancesCell class];
            break;
        case FHHomeCellViewTypeBanner:
            return [FHHomeBannerCell class];
            break;
        case FHHomeCellViewTypeCityTrend:
            return [FHHomeCityTrendCell class];
            break;
        default:
            break;
    }
}

#pragma mark 填充数据 fill data =======================

+ (void)fillFHHomeEntrancesCell:(FHHomeEntrancesCell *)cell withModel:(FHConfigDataOpDataModel *)model
{
    FHHomeEntrancesCell *cellEntrance = cell;
    
    BOOL isNeedAllocNewItems = YES;
    
    //判断是否需要重复创建
    if (cellEntrance.boardView.currentItems.count == model.items.count) {
        isNeedAllocNewItems = NO;
    }else
    {
        for (UIView *subView in cellEntrance.boardView.subviews) {
            [subView removeFromSuperview];
        }
    }
    
    NSInteger countItems = model.items.count;
    if (countItems > 8) {
        countItems = 8;
    }
    
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    for (int index = 0; index < countItems; index++) {
        FHSpringboardIconItemView *itemView = nil;
        if (isNeedAllocNewItems) {
            if ([FHHomeCellHelper sharedInstance].headerType == FHHomeHeaderCellPositionTypeForNews) {
                itemView = [[FHSpringboardIconItemView alloc] init];
            }else
            {
                itemView = [[FHSpringboardIconItemView alloc] initWithIconBottomPadding:-27];
            }
        }else
        {
            if (index < cellEntrance.boardView.currentItems.count && [cellEntrance.boardView.currentItems[index] isKindOfClass:[FHSpringboardIconItemView class]]) {
                itemView = (FHSpringboardIconItemView *)cellEntrance.boardView.currentItems[index];
            }else
            {
                if ([FHHomeCellHelper sharedInstance].headerType == FHHomeHeaderCellPositionTypeForNews) {
                    itemView = [[FHSpringboardIconItemView alloc] init];
                }else
                {
                    itemView = [[FHSpringboardIconItemView alloc] initWithIconBottomPadding:-27];
                }
            }
        }
        
        itemView.tag = index;
        FHConfigDataOpDataItemsModel *itemModel = [model.items objectAtIndex:index];
        itemView.backgroundColor = [UIColor whiteColor];
        if (itemModel.image.count > 0) {
            FHConfigDataOpData2ItemsImageModel * imageModel = itemModel.image[0];
            if (imageModel.url && [imageModel.url isKindOfClass:[NSString class]]) {

                [itemView.iconView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:[UIImage imageNamed:@"icon_placeholder"]];

                [itemView.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(20);
                    make.width.height.mas_equalTo(kFHHomeIconDefaultHeight * [TTDeviceHelper scaleToScreen375]);
                }];
            }
        }
        
        if (itemModel.title && [itemModel.title isKindOfClass:[NSString class]]) {
            itemView.nameLabel.textColor = [UIColor themeGray1];
            UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            if (!font) {
                font = [UIFont systemFontOfSize:14];
            }
            itemView.nameLabel.font = font;
            itemView.nameLabel.text = itemModel.title;
            [itemView.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(itemView.iconView.mas_bottom).mas_offset(8);
            }];
        }
        
        if (isNeedAllocNewItems)
        {
            [itemsArray addObject:itemView];
        }
    }
    
    cellEntrance.boardView.clickedCallBack = ^(NSInteger clickIndex){
        if (model.items.count > clickIndex) {
            FHConfigDataOpDataItemsModel *itemModel = [model.items objectAtIndex:clickIndex];
            
            NSMutableDictionary *dictTrace = [NSMutableDictionary new];
            [dictTrace setValue:@"maintab" forKey:@"enter_from"];
            [dictTrace setValue:@"maintab_icon" forKey:@"element_from"];
            [dictTrace setValue:@"click" forKey:@"enter_type"];
            
            if ([itemModel.logPb isKindOfClass:[NSDictionary class]] && itemModel.logPb[@"element_from"] != nil) {
                [dictTrace setValue:itemModel.logPb[@"element_from"] forKey:@"element_from"];
            }
            
            NSString *stringOriginFrom = itemModel.logPb[@"origin_from"];
            if ([stringOriginFrom isKindOfClass:[NSString class]] && stringOriginFrom.length != 0) {
                [[[FHHouseBridgeManager sharedInstance] envContextBridge] setTraceValue:stringOriginFrom forKey:@"origin_from"];
                [dictTrace setValue:stringOriginFrom forKey:@"origin_from"];
            }else
            {
                [[[FHHouseBridgeManager sharedInstance] envContextBridge] setTraceValue:@"be_null" forKey:@"origin_from"];
                [dictTrace setValue:@"be_null" forKey:@"origin_from"];
            }
            
            NSDictionary *userInfoDict = @{@"tracer":dictTrace};
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
            
            if ([itemModel.openUrl isKindOfClass:[NSString class]]) {
                
                NSURL *url = [NSURL URLWithString:itemModel.openUrl];
                if ([itemModel.openUrl containsString:@"snssdk1370://category_feed"]) {
                    [FHHomeConfigManager sharedInstance].isNeedTriggerPullDownUpdate = YES;
                    [FHHomeConfigManager sharedInstance].isTraceClickIcon = YES;
                    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
                }else
                {
                    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
                }
            }
        }
    };
    
    if (itemsArray.count > 0 && isNeedAllocNewItems) {
        [cellEntrance.boardView addItemViews:itemsArray];
    }
    
    [cellEntrance setNeedsLayout];
    [cellEntrance layoutIfNeeded];
    
}

+ (void)fillFHHomeBannerCell:(FHHomeBannerCell *)cell withModel:(FHConfigDataOpData2Model *)model
{
    FHHomeBannerCell *cellBanner = cell;
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    
    NSInteger countItems = model.items.count;
    
    BOOL isNeedAllocNewItems = YES;
    
    //判断是否需要重复创建
    if (cellBanner.bannerView.currentItems.count == model.items.count) {
        isNeedAllocNewItems = NO;
    }else
    {
        for (UIView *subView in cellBanner.bannerView.subviews) {
            [subView removeFromSuperview];
        }
    }
    
    if (countItems >= 4) {
        countItems = 4;
    }
    
    for (int index = 0; index < countItems; index++) {
        
        FHHomeBannerItem *itemView = nil;
        if (isNeedAllocNewItems) {
            itemView = [[FHHomeBannerItem alloc] init];
        }else
        {
            if (index < cellBanner.bannerView.currentItems.count && [cellBanner.bannerView.currentItems[index] isKindOfClass:[FHHomeBannerItem class]]) {
                itemView = cellBanner.bannerView.currentItems[index];
            }else
            {
                itemView = [[FHHomeBannerItem alloc] init];
            }
        }
        itemView.tag = index;
        FHConfigDataOpData2ItemsModel *itemModel = [model.items objectAtIndex:index];
        if (itemModel.image.count > 0) {
            FHConfigDataOpData2ItemsImageModel * imageModel = itemModel.image[0];
            if (imageModel.url && [imageModel.url isKindOfClass:[NSString class]]) {
                [itemView.iconView bd_setImageWithURL:[NSURL URLWithString:imageModel.url]];
            }
            
            CGFloat isHasCityTrend = 0;
            
            if (![FHHomeConfigManager sharedInstance].currentDataModel.cityStats && [FHHomeCellHelper sharedInstance].headerType == FHHomeHeaderCellPositionTypeForFindHouse) {
                isHasCityTrend = 5;
            }
            
            if (index%kFHHomeBannerRowCount == 0) {
                [itemView.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(-6.5);
                    make.top.mas_equalTo(5 + isHasCityTrend);
                    make.bottom.mas_equalTo(-5 + isHasCityTrend);
                    make.height.mas_equalTo(kFHHomeBannerDefaultHeight * [TTDeviceHelper scaleToScreen375]);
                    make.left.mas_equalTo([TTDeviceHelper isScreenWidthLarge320] ? 20 : 10);
                }];
            }else if (index%kFHHomeBannerRowCount == 1)
            {
                [itemView.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(6.5);
                    make.top.mas_equalTo(5 + isHasCityTrend);
                    make.bottom.mas_equalTo(-5 + isHasCityTrend);
                    make.height.mas_equalTo(kFHHomeBannerDefaultHeight * [TTDeviceHelper scaleToScreen375]);
                    make.right.mas_equalTo(-([TTDeviceHelper isScreenWidthLarge320] ? 20 : 10));
                }];
            }
        }

        BOOL isFindHouse = [FHHomeCellHelper sharedInstance].headerType == FHHomeHeaderCellPositionTypeForFindHouse;

        if (itemModel.title && [itemModel.title isKindOfClass:[NSString class]]) {
            itemView.titleLabel.textColor = [UIColor themeGray1];
            
            UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:isFindHouse ? ([TTDeviceHelper isScreenWidthLarge320] ? 16 : 14) : 15];
            if (!font) {
                font = [UIFont systemFontOfSize:15];
            }
            itemView.titleLabel.font = font;
            if (itemModel.title.length > 5)
            {
                itemView.titleLabel.text = [itemModel.title substringToIndex:5];
            }else
            {
                itemView.titleLabel.text = itemModel.title;
            }
            [itemView.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo([TTDeviceHelper isScreenWidthLarge320] ? 10 : 8);
            }];
        }
        
        if (itemModel.descriptionStr && [itemModel.title isKindOfClass:[NSString class]]) {
            itemView.subTitleLabel.textColor = [UIColor themeGray3];
            UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:isFindHouse ? ([TTDeviceHelper isScreenWidthLarge320] ? 12 : 10) : 10];
            if (!font) {
                font = [UIFont systemFontOfSize:10];
            }
            itemView.subTitleLabel.font = font;
            if (itemModel.descriptionStr.length > 8)
            {
                itemView.subTitleLabel.text = [itemModel.descriptionStr substringToIndex:8];
            }else
            {
                itemView.subTitleLabel.text = itemModel.descriptionStr;
            }
            
            [itemView.subTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo([TTDeviceHelper isScreenWidthLarge320] ? -10 : -8);
            }];
        }
        itemView.backgroundColor = [UIColor whiteColor];
        if (isNeedAllocNewItems) {
            [itemsArray addObject:itemView];
        }
    }
    
    cellBanner.bannerView.clickedCallBack = ^(NSInteger clickIndex){
        if (model.items.count > clickIndex) {
            FHConfigDataOpDataItemsModel *itemModel = [model.items objectAtIndex:clickIndex];
            
            NSMutableDictionary *dictTrace = [NSMutableDictionary new];
            [dictTrace setValue:@"maintab" forKey:@"enter_from"];
            [dictTrace setValue:@"click" forKey:@"enter_type"];
            
            
            if ([itemModel.logPb isKindOfClass:[NSDictionary class]] && itemModel.logPb[@"element_from"] != nil) {
                [dictTrace setValue:itemModel.logPb[@"element_from"] forKey:@"element_from"];
            }
            
            NSString *stringOriginFrom = itemModel.logPb[@"origin_from"];
            if ([stringOriginFrom isKindOfClass:[NSString class]] && stringOriginFrom.length != 0) {
                [[[FHHouseBridgeManager sharedInstance] envContextBridge] setTraceValue:stringOriginFrom forKey:@"origin_from"];
                [dictTrace setValue:stringOriginFrom forKey:@"origin_from"];

            }else
            {
                [[[FHHouseBridgeManager sharedInstance] envContextBridge] setTraceValue:@"school_operation" forKey:@"origin_from"];
                [dictTrace setValue:@"school_operation" forKey:@"origin_from"];

            }
            
            NSDictionary *userInfoDict = @{@"tracer":dictTrace};
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
            
            if (itemModel.openUrl) {
                NSURL *url = [NSURL URLWithString:itemModel.openUrl];
                
                if ([itemModel.openUrl containsString:@"snssdk1370://category_feed"]) {
                    [FHHomeConfigManager sharedInstance].isNeedTriggerPullDownUpdate = YES;
                    [FHHomeConfigManager sharedInstance].isTraceClickIcon = YES;
                    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
                }else
                {
                    [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
                }
            }
        }
    };
    
    if (itemsArray.count > 0 && isNeedAllocNewItems) {
        [cellBanner.bannerView addItemViews:itemsArray];
    }
    
    //    [cellBanner.bannerView mas_updateConstraints:^(MASConstraintMaker *make) {
    //        make.left.top.right.equalTo(cellBanner.contentView);
    //        make.height.mas_equalTo(70 * ((countItems + 1)/2));
    //    }];
    
    [cellBanner setNeedsLayout];
    [cellBanner layoutIfNeeded];
    
}

+ (void)fillFHHomeCityTrendCell:(FHHomeCityTrendCell *)cell withModel:(FHConfigDataCityStatsModel *)model {
    
    WeakSelf;
    BOOL isFindHouse = [FHHomeCellHelper sharedInstance].headerType == FHHomeHeaderCellPositionTypeForFindHouse;

    [cell updateTrendFont:isFindHouse];
    
    [cell updateWithModel:model];
    cell.clickedDataSourceCallback = ^(UIButton * _Nonnull btn) {
        [wself addHomeCityMarketDataSourceLog];
    };
    cell.trendView.clickedRightCallback = ^{
        
        // logpb处理
        id<FHHouseEnvContextBridge> contextBridge = [[FHHouseBridgeManager sharedInstance]envContextBridge];
        [contextBridge setTraceValue:@"city_market" forKey:@"origin_from"];
        [contextBridge setTraceValue:@"be_null" forKey:@"origin_search_id"];

        if (model.openUrl.length > 0) {
            
            NSMutableString *urlStr = [NSMutableString stringWithString:model.openUrl];
            [urlStr appendString:@"?"];
            if (![urlStr containsString:@"enter_from"]) {
                [urlStr appendString:@"&enter_from=maintab_operation"];
            }
            if (![urlStr containsString:@"search_id"]) {
                [urlStr appendString:@"&search_id=be_null"];
            }
            if (![urlStr containsString:@"origin_from"]) {
                [urlStr appendString:@"&origin_from=maintab_operation"];
            }
            if (![urlStr containsString:@"origin_search_id"]) {
                [urlStr appendString:@"&origin_search_id=be_null"];
            }
            NSURL *url = [NSURL URLWithString:urlStr];
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
        }
        [wself addHomeCityMarketClickLog];
    };
}


+ (void)fillAllHomeHeaderCell:(FHHomeHeaderTableViewCell *)cell withModel:(FHConfigDataModel *)model
{
    [cell refreshUI:FHHomeHeaderCellPositionTypeForFindHouse];
}

+ (void)configureCell:(FHHomeBaseTableCell *)cell withJsonModel:(JSONModel *)model
{
    cell.fd_enforceFrameLayout = NO; //
    
    if ([cell isKindOfClass:[FHHomeEntrancesCell class]] && [model isKindOfClass:[FHConfigDataOpDataModel class]]) {
        [self fillFHHomeEntrancesCell:(FHHomeEntrancesCell *)cell withModel:(FHConfigDataOpDataModel *)model];
    }
    
    if ([cell isKindOfClass:[FHHomeBannerCell class]] && [model isKindOfClass:[FHConfigDataOpData2Model class]]) {
        [self fillFHHomeBannerCell:(FHHomeBannerCell *)cell withModel:(FHConfigDataOpData2Model *)model];
    }
    
    if ([cell isKindOfClass:[FHHomeCityTrendCell class]] && [model isKindOfClass:[FHConfigDataCityStatsModel class]]) {
        cell.fd_enforceFrameLayout = YES;
        [self fillFHHomeCityTrendCell:(FHHomeCityTrendCell *)cell withModel:(FHConfigDataCityStatsModel *)model];
    }
}


/**
 * 根据数据填充首页列表cell
 */
+ (void)configureHomeListCell:(FHHomeBaseTableCell *)cell withJsonModel:(JSONModel *)model
{
    if([cell isKindOfClass:[FHHomeHeaderTableViewCell class]] && [model isKindOfClass:[FHConfigDataModel class]])
    {
        [self fillAllHomeHeaderCell:(FHHomeHeaderTableViewCell *)cell withModel:(FHConfigDataModel *)model];
    }
}


- (void)openRouteUrl:(NSString *)url andParams:(NSDictionary *)param
{
    
}

+ (NSString *)configIdentifier:(JSONModel *)model
{
    if ([model isKindOfClass:[FHConfigDataModel class]]) {
        return NSStringFromClass([FHHomeHeaderTableViewCell class]);
    }
    
    if ([model isKindOfClass:[FHConfigDataOpDataModel class]]) {
        return NSStringFromClass([FHHomeEntrancesCell class]);
    }
    
    if ([model isKindOfClass:[FHConfigDataOpData2Model class]]) {
        return NSStringFromClass([FHHomeBannerCell class]);
    }
    
    if ([model isKindOfClass:[FHConfigDataCityStatsModel class]]) {
        return NSStringFromClass([FHHomeCityTrendCell class]);
    }
    
    return NSStringFromClass([FHHomeBaseTableCell class]);
}

#pragma mark 埋点

+ (void)handleCellShowLogWithModel:(JSONModel *)model
{
    NSString *identifier = [self configIdentifier:model];
    if (!identifierArr) {
        
        identifierArr = @[].mutableCopy;
    }
    if (![identifierArr containsObject:identifier]) {
        
        [identifierArr addObject:identifier];
        if ([identifier isEqualToString:NSStringFromClass([FHHomeCityTrendCell class])]) {
            
            [self addHomeCityMarketShowLog];
        }
    }
    
}
+ (void)addHomeCityMarketShowLog
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"page_type"] = @"maintab";
    [FHUserTracker writeEvent:@"city_market_show" params:param];
}

+(void)addHomeCityMarketDataSourceLog
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"page_type"] = @"maintab";
    [FHUserTracker writeEvent:@"city_market_data_source" params:param];
}

+(void)addHomeCityMarketClickLog
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"page_type"] = @"maintab";
    [FHUserTracker writeEvent:@"city_market_click" params:param];
}

@end

