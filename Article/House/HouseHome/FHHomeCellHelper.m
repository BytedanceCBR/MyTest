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
    WeakSelf;
    [[FHHomeConfigManager sharedInstance].configDataReplay subscribeNext:^(id  _Nullable x) {
        StrongSelf;

        if ([x isKindOfClass:[FHConfigDataModel class]]) {
            
        }


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
    for (int i = 0; i < 4; i++) {
        FHSpringboardIconItemView *itemView = [[FHSpringboardIconItemView alloc] init];
        switch (i) {
            case 0:
                itemView.backgroundColor = [UIColor redColor];
                break;
            case 1:
                itemView.backgroundColor = [UIColor blueColor];
                break;
            case 2:
                itemView.backgroundColor = [UIColor purpleColor];
                break;
            case 3:
                itemView.backgroundColor = [UIColor orangeColor];
                break;
            default:
                break;
        }
        [itemsArray addObject:itemView];
    }
    [cellEntrance.rowsView addItemViews:itemsArray];
}

+ (void)fillFHHomeBannerCell:(FHHomeBannerCell *)cell withModel:(FHConfigDataOpData2Model *)model
{

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
