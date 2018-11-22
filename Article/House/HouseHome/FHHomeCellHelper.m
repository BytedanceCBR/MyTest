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
        FHConfigDataOpDataItemsModel *itemModel = [model.items objectAtIndex:i];
        itemView.backgroundColor = [UIColor whiteColor];
        if (itemModel.image.count > 0) {
            FHConfigDataOpData2ItemsImageModel * imageModel = itemModel.image[0];
            if (imageModel.url && [imageModel.url isKindOfClass:[NSString class]]) {
                [itemView.iconView bd_setImageWithURL:[NSURL URLWithString:imageModel.url]];
                [itemView.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
                   make.width.height.mas_equalTo(52);
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
    
    if (itemsArray.count > 0) {
        [cellEntrance.boardView addItemViews:itemsArray];
    }
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
