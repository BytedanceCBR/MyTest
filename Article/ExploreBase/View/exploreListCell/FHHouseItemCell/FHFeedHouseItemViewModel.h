//
//  FHFeedHouseItemViewModel.h
//  Article
//
//  Created by 张静 on 2018/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class FHExploreHouseItemData;

@interface FHFeedHouseItemViewModel : NSObject

-(instancetype)initWithTableView:(UITableView *)tableView;

-(void)updateWithHouseData:(FHExploreHouseItemData *_Nullable)data;

@end

NS_ASSUME_NONNULL_END
