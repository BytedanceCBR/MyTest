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
#import <FHHouseBase/FHSpringboardView.h>
#import "BDWebImage.h"
#import "UIColor+Theme.h"
#import "TTRoute.h"
#import "FHUserTracker.h"
#import "FHHouseBridgeManager.h"
#import "TTTracker.h"
#import "TTDeviceHelper.h"
#import "FHHomeHeaderTableViewCell.h"
#import "FHPlaceHolderCell.h"
#import "FHEnvContext.h"
#import <FHHouseBase/FHHouseBaseItemCell.h>
#import "TTArticleCategoryManager.h"
#import "UIFont+House.h"
#import "FHHomeScrollBannerCell.h"
#import <FHHouseList/FHCommuteManager.h>
#import "FHhomeHouseTypeBannerCell.h"
#import "FHHomePlaceHolderCell.h"
#import <FHHouseBase/TTDeviceHelper+FHHouse.h>

static NSMutableArray  * _Nullable identifierArr;

@interface FHHomeCellHelper ()

@property(nonatomic , strong) FHConfigDataModel *previousDataModel;
@property(nonatomic , assign) CGFloat headerHeight;
@property(nonatomic , strong) NSMutableDictionary *traceShowCache;

@end

@implementation FHHomeCellHelper


+(instancetype)sharedInstance
{
    static FHHomeCellHelper *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[FHHomeCellHelper alloc] init];
        manager.traceShowCache = [NSMutableDictionary new];
        [manager initFHHomeHeaderIconCountAndHeight];
    });
    return manager;
}

+ (void)registerCells:(UITableView *)tableView
{
    [tableView registerClass:[FHHomeHeaderTableViewCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeHeaderTableViewCell class])];
    
    [tableView registerClass:[FHHouseBaseItemCell class] forCellReuseIdentifier:@"FHHomeSmallImageItemCell"];
    
    [tableView registerClass:[FHPlaceHolderCell class] forCellReuseIdentifier:NSStringFromClass([FHPlaceHolderCell class])];
    
    [tableView registerClass:[FHHomeBaseTableCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeBaseTableCell class])];
    
    [tableView registerClass:[FHHomeEntrancesCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeEntrancesCell class])];
    
    [tableView registerClass:[FHHomePlaceHolderCell class] forCellReuseIdentifier:NSStringFromClass([FHHomePlaceHolderCell class])];
    
    [tableView registerClass:[FHhomeHouseTypeBannerCell class] forCellReuseIdentifier:NSStringFromClass([FHhomeHouseTypeBannerCell class])];
    
    [tableView registerClass:[FHHomeBannerCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeBannerCell class])];
    
    [tableView registerClass:[FHHomeScrollBannerCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeScrollBannerCell class])];
    
    [tableView registerClass:[FHHomeCityTrendCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeCityTrendCell class])];
    
    [tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:NSStringFromClass([UITableViewCell class])];
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
        // 首页轮播banner，数据封装的时候判断是否是有效的数据
        if (dataModel.mainPageBannerOpData.items.count > 0) {
            // 经过一层逻辑处理
           BOOL enableScrollBanner = [FHHomeScrollBannerCell hasValidModel:dataModel.mainPageBannerOpData];
            if (enableScrollBanner) {
                [modelsArray addObject:dataModel.mainPageBannerOpData];
            }
        }
        //不同频道cell顺序不同
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
    
    if ([tableView.delegate isKindOfClass:[FHHomeTableViewDelegate class]] && ![modelsArray isEqualToArray:((FHHomeTableViewDelegate *)tableView.delegate).modelsArray]) {
        ((FHHomeTableViewDelegate *)tableView.delegate).modelsArray = modelsArray;
        [tableView reloadData];
    }
    
    FHConfigDataModel *currentDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];

    if (currentDataModel && dataModel.currentCityId && ![self.traceShowCache.allKeys containsObject:dataModel.currentCityId] && ![FHHomeCellHelper sharedInstance].isFirstLanuch) {
        [FHHomeCellHelper sendCellShowTrace];
        [self.traceShowCache setValue:@"1" forKey:dataModel.currentCityId];
    }
}

+ (void)sendCellShowTrace
{
    FHConfigDataModel *currentDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    FHConfigDataOpData2Model *modelOpdata2 = currentDataModel.opData2;
    FHConfigDataCityStatsModel *cityStatsModel = currentDataModel.cityStats;
    
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
    
    if(cityStatsModel)
    {
        [self addHomeCityMarketShowLog];
    }
    
}

+ (void)sendBannerTypeCellShowTrace:(FHHouseType)houseType
{
    FHConfigDataModel *currentDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    FHConfigDataOpData2Model *modelOpdata2 = currentDataModel.opData2;
    FHConfigDataCityStatsModel *cityStatsModel = currentDataModel.cityStats;
    
    NSArray<FHConfigDataOpData2ItemsModel> *items = nil;
    
    for (NSInteger i = 0; i < currentDataModel.opData2list.count; i ++) {
        FHConfigDataOpData2ListModel *dataModelItem = currentDataModel.opData2list[i];
        if (dataModelItem.opData2Type && [dataModelItem.opData2Type integerValue] == houseType && dataModelItem.opDataList && dataModelItem.opDataList.items.count > 0) {
            items = dataModelItem.opDataList.items;
        }
    }
    
    if (items > 0)
    {
        [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
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
}

- (void)clearShowCache
{
    [self.traceShowCache removeAllObjects];
}

- (CGFloat)initFHHomeHeaderIconCountAndHeight
{
    self.kFHHomeIconRowCount = 5;
    self.kFHHomeIconDefaultHeight = 42;
    //下版本等实验结论再上
    //    if ([[[FHEnvContext sharedInstance] getConfigFromCache].opData.iconRowNum isKindOfClass:[NSNumber class]]) {
    //        if ([[[FHEnvContext sharedInstance] getConfigFromCache].opData.iconRowNum integerValue] == 5) {
    //            [FHHomeCellHelper sharedInstance].kFHHomeIconRowCount = 5;
    //            [FHHomeCellHelper sharedInstance].kFHHomeIconDefaultHeight = 42;
    //        }else
    //        {
    //            [FHHomeCellHelper sharedInstance].kFHHomeIconRowCount = 4;
    //            [FHHomeCellHelper sharedInstance].kFHHomeIconDefaultHeight = 57;
    //        }
    //    }else
    //    {
    //        [FHHomeCellHelper sharedInstance].kFHHomeIconRowCount = 4;
    //        [FHHomeCellHelper sharedInstance].kFHHomeIconDefaultHeight = 57;
    //    }
}

- (CGFloat)heightForFHHomeListHouseSectionHeight
{
    CGFloat padding = 0;
    if ([[FHEnvContext sharedInstance] getConfigFromCache].houseTypeList.count <= 1) {
        padding = 90;
    }
    // 108: topbar   49:tahbar  45:sectionHeader
    if ([TTDeviceHelper isIPhoneXSeries]) {
        return MAIN_SCREENH_HEIGHT - 108 - 49  + padding;
    }else
    {
        return MAIN_SCREENH_HEIGHT - 64 - 49  + padding;
    }
}

- (CGFloat)heightForFHHomeHeaderCellViewType
{
    //未开通城市返回
    if (![[FHEnvContext sharedInstance] getConfigFromCache].cityAvailability.enable.boolValue)
    {
        return 0;
    }
    
    if (self.kFHHomeIconRowCount == 0 || self.kFHHomeIconDefaultHeight) {
        [self initFHHomeHeaderIconCountAndHeight];
    }
    
    FHConfigDataModel * dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    if (!dataModel) {
        dataModel = [[FHEnvContext sharedInstance] readConfigFromLocal];
    }
    
    BOOL isHasFindHouseCategory = YES;

    //如果数据无变化直接返回
    if (self.previousDataModel == dataModel && isHasFindHouseCategory) {
        return self.headerHeight;
    }
    
    CGFloat height = 0;
    if ([dataModel isKindOfClass:[FHConfigDataModel class]]) {
        
        NSInteger countValue = dataModel.opData.items.count;
        
        if (countValue > 0) {
            height = [FHHomeEntrancesCell cellHeightForModel:dataModel.opData];
        }
                
        if (dataModel.mainPageBannerOpData.items.count > 0) {
            // 经过一层逻辑处理
            BOOL available = [FHHomeScrollBannerCell hasValidModel:dataModel.mainPageBannerOpData];
            if (available) {
                height += [FHHomeScrollBannerCell cellHeight];
            }
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
+ (void)fillFHHomeEntrancesCell:(FHHomeEntrancesCell *)cell withModel:(FHConfigDataOpDataModel *)model withTraceParams:(NSDictionary *)traceParams{
    
    FHHomeEntrancesCell *cellEntrance = cell;
    
    NSInteger countItems = model.items.count;
//    if (countItems > [FHHomeCellHelper sharedInstance].kFHHomeIconRowCount * 2) {
//        countItems = [FHHomeCellHelper sharedInstance].kFHHomeIconRowCount * 2;
//    }
    
    [cell updateWithItems:model.items];
    
    cellEntrance.clickBlock = ^(NSInteger clickIndex , FHConfigDataOpDataItemsModel *itemModel){
        NSMutableDictionary *dictTrace = [NSMutableDictionary new];
        [dictTrace setValue:@"maintab" forKey:@"enter_from"];

        if ([traceParams isKindOfClass:[NSDictionary class]]) {
            [dictTrace addEntriesFromDictionary:traceParams];
        }
        
        //首页工具箱里面的icon追加上报
        NSString *enterFrom = dictTrace[@"enter_from"];
        [self addCLickIconLog:itemModel];
        
        [dictTrace setValue:@"maintab_icon" forKey:@"element_from"];
        [dictTrace setValue:@"click" forKey:@"enter_type"];
        
        if ([itemModel.logPb isKindOfClass:[NSDictionary class]] && itemModel.logPb[@"element_from"] != nil) {
            [dictTrace setValue:itemModel.logPb[@"element_from"] forKey:@"element_from"];
        }
        
        NSString *stringOriginFrom = itemModel.logPb[@"origin_from"];
        if ([stringOriginFrom isKindOfClass:[NSString class]] && stringOriginFrom.length != 0) {
            [[[FHHouseBridgeManager sharedInstance] envContextBridge] setTraceValue:stringOriginFrom forKey:@"origin_from"];
            [dictTrace setValue:stringOriginFrom forKey:@"origin_from"];
        }else{
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
            }else if ([itemModel.openUrl containsString:@"://commute_list"]){
                //通勤找房
                [[FHCommuteManager sharedInstance] tryEnterCommutePage:itemModel.openUrl logParam:dictTrace];
            }else{
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
            }
        }
    };
    
    
    [cellEntrance setNeedsLayout];

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
            
            [itemView.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
                if (index%kFHHomeBannerRowCount == 0) {
                    make.right.mas_equalTo(-6.5);
                    make.left.mas_equalTo([TTDeviceHelper isScreenWidthLarge320] ? 20 : 10);
                }else
                {
                    make.left.mas_equalTo(6.5);
                    make.right.mas_equalTo(-([TTDeviceHelper isScreenWidthLarge320] ? 20 : 10));
                }
                
                if (index/kFHHomeBannerRowCount == 0) {
                    make.top.mas_equalTo(12);
                    make.bottom.mas_equalTo(-2);
                }else
                {
                    make.top.mas_equalTo(8);
                    make.bottom.mas_equalTo(-6);
                }
            }];
        }

        BOOL isFindHouse = YES;

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
        itemView.backgroundColor = [UIColor clearColor];
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
//    [cellBanner layoutIfNeeded];

}

// 首页轮播banner
+ (void)fillFHHomeScrollBannerCell:(FHHomeScrollBannerCell *)cell withModel:(FHConfigDataMainPageBannerOpDataModel *)model {
    // 更新cell数据
     [cell updateWithModel:model];
}

+ (void)fillFHHomeCityTrendCell:(FHHomeCityTrendCell *)cell withModel:(FHConfigDataCityStatsModel *)model {
//    model.openUrl = @"sslocal://mapfind_house?center_latitude=34.7579750000&center_longitude=113.6654120000&house_type=2&resize_level=10&rm=a";
    WeakSelf;
    BOOL isFindHouse = YES;

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
            TTRouteUserInfo* info = nil;
            if (model.logPb != nil) {
                info = [[TTRouteUserInfo alloc] initWithInfo:model.logPb];
            }
            [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:info];
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
        [self fillFHHomeEntrancesCell:(FHHomeEntrancesCell *)cell withModel:(FHConfigDataOpDataModel *)model withTraceParams:nil];
    }
    
    if ([cell isKindOfClass:[FHHomeBannerCell class]] && [model isKindOfClass:[FHConfigDataOpData2Model class]]) {
        [self fillFHHomeBannerCell:(FHHomeBannerCell *)cell withModel:(FHConfigDataOpData2Model *)model];
    }
    
    if ([cell isKindOfClass:[FHHomeCityTrendCell class]] && [model isKindOfClass:[FHConfigDataCityStatsModel class]]) {
        cell.fd_enforceFrameLayout = YES;
        [self fillFHHomeCityTrendCell:(FHHomeCityTrendCell *)cell withModel:(FHConfigDataCityStatsModel *)model];
    }
    
    if ([cell isKindOfClass:[FHHomeScrollBannerCell class]] && [model isKindOfClass:[FHConfigDataMainPageBannerOpDataModel class]]) {
        [self fillFHHomeScrollBannerCell:(FHHomeScrollBannerCell *)cell withModel:(FHConfigDataMainPageBannerOpDataModel *)model];
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
    
    if ([model isKindOfClass:[FHConfigDataMainPageBannerOpDataModel class]]) {
        return NSStringFromClass([FHHomeScrollBannerCell class]);
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

+(void)addCLickIconLog:(FHConfigDataOpDataItemsModel *)itemModel
{
    NSMutableDictionary *param = [NSMutableDictionary dictionary];
    param[@"log_pb"] = itemModel.logPb ?: @"be_null";
    param[@"page_type"] = @"tools_box";
    [FHUserTracker writeEvent:@"click_icon" params:param];
}

//匹配房源名称
+ (NSArray <NSString *>*)matchHouseSegmentedTitleArray
{
    FHConfigDataModel *configDataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    NSMutableArray *titleArrays = [[NSMutableArray alloc] initWithCapacity:3];
    for (int i = 0; i < configDataModel.houseTypeList.count; i++) {
        NSNumber *houseTypeNum = configDataModel.houseTypeList[i];
        if ([houseTypeNum isKindOfClass:[NSNumber class]]) {
            NSString * houseStr = [self matchHouseString:[houseTypeNum integerValue]];
            if (kIsNSString(houseStr) && houseStr.length != 0) {
                [titleArrays addObject:houseStr];
            }
        }
    }
    return titleArrays;
}

+ (NSString *)matchHouseString:(FHHouseType)houseType
{
    switch (houseType) {
        case FHHouseTypeNewHouse:
        {
            return @"新房";
        }
            break;
        case FHHouseTypeRentHouse:
        {
            return @"租房";
        }
            break;
        case FHHouseTypeNeighborhood:
        {
            return @"小区";
        }
            break;
        case FHHouseTypeSecondHandHouse:
        {
            return @"二手房";
        }
            break;
            
        default:
            return @"";
            break;
    }
}

@end

