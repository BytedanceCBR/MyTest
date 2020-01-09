//
//  FHOldDetailSchoolInfoItemView.h
//  FHHouseDetail
//
//  Created by 张静 on 2019/4/16.
//

#import <UIKit/UIKit.h>

@class FHDetailDataNeighborhoodInfoSchoolItemModel,FHOldDetailSchoolInfoItemModel;

NS_ASSUME_NONNULL_BEGIN

@interface FHOldDetailSchoolInfoItemView : UIView

@property (nonatomic, assign)   CGFloat       schoolHeight;
@property (nonatomic, assign)   CGFloat       bottomY;
@property(nonatomic, copy) void(^foldBlock)(FHOldDetailSchoolInfoItemView *itemView, CGFloat height);

- (instancetype)initWithSchoolInfoModel:(FHOldDetailSchoolInfoItemModel *)itemModel;
- (CGFloat)viewHeight;
@end

@interface FHOldDetailSchoolInfoItemModel : NSObject

@property(nonatomic, strong)FHDetailDataNeighborhoodInfoSchoolItemModel *schoolItem;
@property (nonatomic, assign)   BOOL       isFold; // 折叠
@property (nonatomic, weak)     UITableView       *tableView;

@end

NS_ASSUME_NONNULL_END
