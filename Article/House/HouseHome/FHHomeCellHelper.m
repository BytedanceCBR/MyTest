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
#import "FHHomeConfigManager.h"
#import <BDWebImage.h>
#import "UIColor+Theme.h"
#import <TTRoute.h>
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
    [tableView registerClass:[FHHomeEntrancesCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeEntrancesCell class])];
    
    [tableView registerClass:[FHHomeBannerCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeBannerCell class])];
    
    [tableView registerClass:[FHHomeCityTrendCell class] forCellReuseIdentifier:NSStringFromClass([FHHomeCityTrendCell class])];
}

+ (void)registerDelegate:(UITableView *)tableView andDelegate:(FHHomeTableViewDelegate *)delegate
{
    __block NSMutableArray <JSONModel *>*modelsArray = [NSMutableArray new];
    [[FHHomeConfigManager sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        [modelsArray removeAllObjects];
        if ([x isKindOfClass:[FHConfigDataModel class]]) {
            FHConfigDataModel * dataModel = (FHConfigDataModel *)x;
            if (dataModel.opData) {
                [modelsArray addObject:dataModel.opData];
            }
            
            if (dataModel.opData2) {
                [modelsArray addObject:dataModel.opData2];
            }
        }
        delegate.modelsArray = modelsArray;
        tableView.delegate = delegate;
        tableView.dataSource = delegate;
    }];
}

+ (CGFloat)heightForFHHomeHeaderCellViewType
{
    return 300;
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

+ (void)fillFHHomeEntrancesCell:(FHHomeEntrancesCell *)cell withModel:(FHConfigDataOpDataModel *)model
{
    FHHomeEntrancesCell *cellEntrance = cell;
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    
    NSInteger countItems = model.items.count;
    if (countItems > 8) {
        countItems = 8;
    }
    
    for (int i = 0; i < countItems; i++) {
        FHSpringboardIconItemView *itemView = [[FHSpringboardIconItemView alloc] init];
        itemView.tag = i;
        FHConfigDataOpDataItemsModel *itemModel = [model.items objectAtIndex:i];
        itemView.backgroundColor = [UIColor whiteColor];
        if (itemModel.image.count > 0) {
            FHConfigDataOpData2ItemsImageModel * imageModel = itemModel.image[0];
            if (imageModel.url && [imageModel.url isKindOfClass:[NSString class]]) {
                [itemView.iconView bd_setImageWithURL:[NSURL URLWithString:imageModel.url]];
                [itemView.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
                   make.top.mas_equalTo(20);
                   make.width.height.mas_equalTo(56);
                }];
            }
        }
        
        if (itemModel.title && [itemModel.title isKindOfClass:[NSString class]]) {
            itemView.nameLabel.textColor = [UIColor themeBlue1];
            itemView.nameLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:14];
            itemView.nameLabel.text = itemModel.title;
            [itemView.nameLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(itemView.iconView.mas_bottom).mas_offset(8);
            }];
        }
        
        [itemsArray addObject:itemView];
    }
    
    cellEntrance.boardView.clickedCallBack = ^(NSInteger clickIndex){
//        if let logpb = item.logPb as NSDictionary?
//        {
//            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
//            toTracerParams(logpb["origin_from"] ?? "be_null", key: "origin_from")
//        }
//
//
//        let tracerParams = TracerParams.momoid() <|>
//        EnvContext.shared.homePageParams <|>
//        toTracerParams(item.logPb ?? "be_null", key: "log_pb") <|>
//        toTracerParams("maintab", key: "enter_from") <|>
//        toTracerParams("maintab_icon", key: "element_from") <|>
//        toTracerParams("click", key: "enter_type")
//
//
//        let parmasMap = tracerParams.paramsGetter([:])
//        let userInfo = TTRouteUserInfo(info: ["tracer": parmasMap])
//        if let openUrl = item.openUrl
//        {
//            TTRoute.shared().openURL(byPushViewController: URL(string: openUrl), userInfo: userInfo)
//        }
        
        if (model.items.count > clickIndex) {
            FHConfigDataOpDataItemsModel *itemModel = [model.items objectAtIndex:clickIndex];
            if (itemModel.openUrl) {
                NSURL *url = [NSURL URLWithString:itemModel.openUrl];
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
            }
        }
    };
    
    if (itemsArray.count > 0) {
        [cellEntrance.boardView addItemViews:itemsArray];
    }
}

- (void)openRouteUrl:(NSString *)url andParams:(NSDictionary *)param
{
    
}

+ (void)fillFHHomeBannerCell:(FHHomeBannerCell *)cell withModel:(FHConfigDataOpData2Model *)model
{
    FHHomeBannerCell *cellBanner = cell;
    NSMutableArray *itemsArray = [[NSMutableArray alloc] init];
    
    NSInteger countItems = model.items.count;
    if (countItems > 8) {
        countItems = 8;
    }
    
    for (int i = 0; i < countItems; i++) {
        FHHomeBannerItem *itemView = [[FHHomeBannerItem alloc] init];
        itemView.tag = i;
        FHConfigDataOpData2ItemsModel *itemModel = [model.items objectAtIndex:i];
        if (itemModel.image.count > 0) {
            FHConfigDataOpData2ItemsImageModel * imageModel = itemModel.image[0];
            if (imageModel.url && [imageModel.url isKindOfClass:[NSString class]]) {
                [itemView.iconView bd_setImageWithURL:[NSURL URLWithString:imageModel.url]];
            }
            
            if (i%2 == 0) {
                [itemView.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(-6.5);
                    make.top.mas_equalTo(10);
                    make.left.mas_equalTo(20);
                }];
            }else if (i%2 == 1)
            {
                [itemView.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(6.5);
                    make.top.mas_equalTo(10);
                    make.right.mas_equalTo(-20);
                }];
            }
        }
        
        if (itemModel.title && [itemModel.title isKindOfClass:[NSString class]]) {
            itemView.titleLabel.textColor = [UIColor themeBlue1];
            itemView.titleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
            itemView.titleLabel.text = itemModel.title;
            [itemView.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(8);
            }];
        }
        
        if (itemModel.descriptionStr && [itemModel.title isKindOfClass:[NSString class]]) {
            itemView.subTitleLabel.textColor = [UIColor themeGray3];
            itemView.subTitleLabel.font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
            itemView.subTitleLabel.text = itemModel.descriptionStr;
        }
        itemView.backgroundColor = [UIColor whiteColor];
        [itemsArray addObject:itemView];
    }
    
    cellBanner.bannerView.clickedCallBack = ^(NSInteger clickIndex){
        //        if let logpb = item.logPb as NSDictionary?
        //        {
        //            EnvContext.shared.homePageParams = EnvContext.shared.homePageParams <|>
        //            toTracerParams(logpb["origin_from"] ?? "be_null", key: "origin_from")
        //        }
        //
        //
        //        let tracerParams = TracerParams.momoid() <|>
        //        EnvContext.shared.homePageParams <|>
        //        toTracerParams(item.logPb ?? "be_null", key: "log_pb") <|>
        //        toTracerParams("maintab", key: "enter_from") <|>
        //        toTracerParams("maintab_icon", key: "element_from") <|>
        //        toTracerParams("click", key: "enter_type")
        //
        //
        //        let parmasMap = tracerParams.paramsGetter([:])
        //        let userInfo = TTRouteUserInfo(info: ["tracer": parmasMap])
        //        if let openUrl = item.openUrl
        //        {
        //            TTRoute.shared().openURL(byPushViewController: URL(string: openUrl), userInfo: userInfo)
        //        }
        
        if (model.items.count > clickIndex) {
            FHConfigDataOpDataItemsModel *itemModel = [model.items objectAtIndex:clickIndex];
            if (itemModel.openUrl) {
                NSURL *url = [NSURL URLWithString:itemModel.openUrl];
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
            }
        }
    };
    
    if (itemsArray.count > 0) {
        [cellBanner.bannerView addItemViews:itemsArray];
    }
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
}


+ (NSString *)configIdentifier:(JSONModel *)model
{
    if ([model isKindOfClass:[FHConfigDataOpDataModel class]]) {
        return NSStringFromClass([FHHomeEntrancesCell class]);
    }
    
    if ([model isKindOfClass:[FHConfigDataOpData2Model class]]) {
        return NSStringFromClass([FHHomeBannerCell class]);
    }
    
    return NSStringFromClass([FHHomeBaseTableCell class]);
}

@end
