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

#define kFHHomeBannerDefaultHeight 60.0 //banner高度

#define kFHHomeIconDefaultHeight 52.0 //icon高度

#define kFHHomeIconRowCount 4 //每行icon个数

#define kFHHomeBannerRowCount 2 //每行banner个数

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

+ (void)registerDelegate:(UITableView *)tableView andDelegate:(id)delegate
{
    tableView.delegate = delegate;
    tableView.dataSource = delegate;
}
- (void)refreshFHHomeTableUI:(UITableView *)tableView
{
    NSMutableArray <JSONModel *>*modelsArray = [NSMutableArray new];
    
    FHConfigDataModel * dataModel = [FHHomeConfigManager sharedInstance].currentDataModel;
    if ([dataModel isKindOfClass:[FHConfigDataModel class]]) {
        if (dataModel.opData.items.count != 0) {
            [modelsArray addObject:dataModel.opData];
        }
        
        if (dataModel.opData2.items.count != 0) {
            [modelsArray addObject:dataModel.opData2];
        }
        if (dataModel.cityStats.count > 0) {
            
            for (FHConfigDataCityStatsModel *model in dataModel.cityStats) {
                
                if ([model.houseType isEqualToString:@"2"]) {
                    [modelsArray addObject:model];
                    break;
                }
            }
        }
    }
    
    if ([tableView.delegate isKindOfClass:[FHHomeTableViewDelegate class]]) {
        ((FHHomeTableViewDelegate *)tableView.delegate).modelsArray = modelsArray;
    }
    [tableView reloadData];
}

+ (CGFloat)heightForFHHomeHeaderCellViewType
{
    FHConfigDataModel * dataModel = [FHHomeConfigManager sharedInstance].currentDataModel;
    CGFloat height = 0;
    if ([dataModel isKindOfClass:[FHConfigDataModel class]]) {
        
        if (dataModel.opData.items.count > 0) {
            height += ((dataModel.opData.items.count - 1)/kFHHomeIconRowCount + 1) * 120;
        }
        
        if (dataModel.opData2.items.count > 0) {
            height += ((dataModel.opData2.items.count - 1)/kFHHomeBannerRowCount + 1) * (10 + [TTDeviceHelper scaleToScreen375] * kFHHomeBannerDefaultHeight);
        }
        if (dataModel.cityStats.count > 0) {
            for (FHConfigDataCityStatsModel *model in dataModel.cityStats) {
                
                if ([model.houseType isEqualToString:@"2"]) {
                    height += 89;
                    break;
                }
            }
        }
    }
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
            itemView = [[FHSpringboardIconItemView alloc] init];
        }else
        {
            if (index < cellEntrance.boardView.currentItems.count && [cellEntrance.boardView.currentItems[index] isKindOfClass:[FHSpringboardIconItemView class]]) {
                itemView = (FHSpringboardIconItemView *)cellEntrance.boardView.currentItems[index];
            }else
            {
                itemView = [[FHSpringboardIconItemView alloc] init];
            }
        }
        
        itemView.tag = index;
        FHConfigDataOpDataItemsModel *itemModel = [model.items objectAtIndex:index];
        itemView.backgroundColor = [UIColor whiteColor];
        if (itemModel.image.count > 0) {
            FHConfigDataOpData2ItemsImageModel * imageModel = itemModel.image[0];
            if (imageModel.url && [imageModel.url isKindOfClass:[NSString class]]) {
                [itemView.iconView bd_setImageWithURL:[NSURL URLWithString:imageModel.url]];
                [itemView.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.top.mas_equalTo(20);
                    make.width.height.mas_equalTo(kFHHomeIconDefaultHeight * [TTDeviceHelper scaleToScreen375]);
                }];
            }
        }
        
        if (itemModel.title && [itemModel.title isKindOfClass:[NSString class]]) {
            itemView.nameLabel.textColor = [UIColor themeBlue1];
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
            [dictTrace setValue:itemModel.logPb forKey:@"log_pb"];
            [dictTrace setValue:@"maintab" forKey:@"enter_from"];
            [dictTrace setValue:@"maintab_icon" forKey:@"element_from"];
            [dictTrace setValue:@"click" forKey:@"enter_type"];
            
            NSDictionary *userInfoDict = @{@"tracer":dictTrace};
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
            
            if (itemModel.openUrl) {
                NSURL *url = [NSURL URLWithString:itemModel.openUrl];
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
            }
        }
    };
    
    if (itemsArray.count > 0 && isNeedAllocNewItems) {
        [cellEntrance.boardView addItemViews:itemsArray];
    }
    
    [cellEntrance setNeedsLayout];
    [cellEntrance layoutIfNeeded];
    
}

- (void)openRouteUrl:(NSString *)url andParams:(NSDictionary *)param
{
    
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
            
            if (index%kFHHomeBannerRowCount == 0) {
                [itemView.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.right.mas_equalTo(-6.5);
                    make.top.mas_equalTo(10);
                    make.height.mas_equalTo(kFHHomeBannerDefaultHeight * [TTDeviceHelper scaleToScreen375]);
                    make.left.mas_equalTo([TTDeviceHelper isScreenWidthLarge320] ? 20 : 10);
                }];
            }else if (index%kFHHomeBannerRowCount == 1)
            {
                [itemView.iconView mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.left.mas_equalTo(6.5);
                    make.top.mas_equalTo(10);
                    make.height.mas_equalTo(kFHHomeBannerDefaultHeight * [TTDeviceHelper scaleToScreen375]);
                    make.right.mas_equalTo(-([TTDeviceHelper isScreenWidthLarge320] ? 20 : 10));
                }];
            }
        }
        
        if (itemModel.title && [itemModel.title isKindOfClass:[NSString class]]) {
            itemView.titleLabel.textColor = [UIColor themeBlue1];
            UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:15];
            if (!font) {
                font = [UIFont systemFontOfSize:15];
            }
            itemView.titleLabel.font = font;
            itemView.titleLabel.text = itemModel.title;
            [itemView.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(12);
            }];
        }
        
        if (itemModel.descriptionStr && [itemModel.title isKindOfClass:[NSString class]]) {
            itemView.subTitleLabel.textColor = [UIColor themeGray3];
            UIFont *font = [UIFont fontWithName:@"PingFangSC-Regular" size:10];
            if (!font) {
                font = [UIFont systemFontOfSize:10];
            }
            itemView.subTitleLabel.font = font;
            itemView.subTitleLabel.text = itemModel.descriptionStr;
            
            if (![TTDeviceHelper isScreenWidthLarge320]) {
                [itemView.subTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                    make.bottom.mas_equalTo(-5);
                }];
            }
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
            [dictTrace setValue:itemModel.logPb forKey:@"log_pb"];
            [dictTrace setValue:@"maintab" forKey:@"enter_from"];
            [dictTrace setValue:@"maintab_icon" forKey:@"element_from"];
            [dictTrace setValue:@"click" forKey:@"enter_type"];
            
            NSDictionary *userInfoDict = @{@"tracer":dictTrace};
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
            
            if (itemModel.openUrl) {
                NSURL *url = [NSURL URLWithString:itemModel.openUrl];
                [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
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
    //
    [cellBanner setNeedsLayout];
    [cellBanner layoutIfNeeded];
}

+ (void)fillFHHomeCityTrendCell:(FHHomeCityTrendCell *)cell withModel:(FHConfigDataCityStatsModel *)model {
    
    [cell updateWithModel:model];
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


+ (NSString *)configIdentifier:(JSONModel *)model
{
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

@end
