//
//  FHFeedHouseItemViewModel.h
//  Article
//
//  Created by 张静 on 2018/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHExploreHouseItemData;
@class FHFeedHouseHeaderView;
@class FHFeedHouseFooterView;

@interface FHFeedHouseItemViewModel : NSObject

@property(nonatomic , weak) FHFeedHouseHeaderView *headerView;
@property(nonatomic , weak) FHFeedHouseFooterView *footerView;

-(instancetype)initWithTableView:(UITableView *)tableView;

-(void)updateWithHouseData:(FHExploreHouseItemData *_Nullable)data;

-(void)addHouseShowLog;

@end

NS_ASSUME_NONNULL_END
