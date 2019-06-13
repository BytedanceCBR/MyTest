//
//  FHUGCRecommendSubCell.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FHUGCRecommendSubCell;

@protocol FHUGCRecommendSubCellDelegate <NSObject>

- (void)joinIn:(id)model cell:(FHUGCRecommendSubCell *)cell;

@end

@interface FHUGCRecommendSubCell : UITableViewCell

@property(nonatomic , weak) id<FHUGCRecommendSubCellDelegate> delegate;

- (void)refreshWithData:(id)data;

@end

NS_ASSUME_NONNULL_END
