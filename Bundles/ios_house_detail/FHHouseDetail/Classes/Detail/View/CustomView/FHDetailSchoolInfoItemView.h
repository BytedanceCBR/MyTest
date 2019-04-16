//
//  FHDetailSchoolInfoItemView.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/16.
//

#import <UIKit/UIKit.h>

@class FHDetailDataNeighborhoodInfoSchoolItemModel,FHDetailSchoolInfoItemModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailSchoolInfoItemView : UIView

- (instancetype)initWithSchoolInfoModel:(FHDetailSchoolInfoItemModel *)itemModel;

@end

@interface FHDetailSchoolInfoItemModel : NSObject

@property(nonatomic, strong)FHDetailDataNeighborhoodInfoSchoolItemModel *schoolItem;
@property (nonatomic, assign)   BOOL       isFold; // 折叠
@property (nonatomic, weak)     UITableView       *tableView;

@end

NS_ASSUME_NONNULL_END
