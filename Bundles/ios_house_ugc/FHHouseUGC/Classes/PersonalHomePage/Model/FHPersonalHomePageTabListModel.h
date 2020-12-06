//
//  FHPersonalHomePageTabListModel.h
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHPersonalHomePageTabItemModel <NSObject>
@end

@interface FHPersonalHomePageTabItemModel : JSONModel

@property (nonatomic, copy, nullable) NSString *showName;
@property (nonatomic, copy, nullable) NSString *tabName;
@property (nonatomic, copy, nullable) NSString *count;

@end


@interface FHPersonalHomePageTabListDataModel : JSONModel
@property (nonatomic, strong, nullable) NSArray <FHPersonalHomePageTabItemModel> *ugcTabList;
@end


@interface FHPersonalHomePageTabListModel : JSONModel
@property (nonatomic, copy, nullable) NSString *status;
@property (nonatomic, copy, nullable) NSString *message;
@property(nonatomic,strong, nullable) FHPersonalHomePageTabListDataModel *data;

@end

NS_ASSUME_NONNULL_END
