//
//  FHUGCEncyclopediaLynxCell.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/5/18.
//

#import "FHUGCBaseCell.h"

NS_ASSUME_NONNULL_BEGIN
@protocol FHUGCEncyclopediaLynxCellDelegate <NSObject>

@optional
//dislike确认
- (void)dislikeConfirm:(NSDictionary *)data cell:(FHUGCBaseCell *)cell;

//cell点击
- (void)tapCellAction:(NSDictionary *)data;
@end

@interface FHUGCEncyclopediaLynxCell : FHUGCBaseCell
@property(nonatomic , weak) id<FHUGCEncyclopediaLynxCellDelegate> delegate;
@property (strong, nonatomic) NSDictionary *data;
@end

NS_ASSUME_NONNULL_END
