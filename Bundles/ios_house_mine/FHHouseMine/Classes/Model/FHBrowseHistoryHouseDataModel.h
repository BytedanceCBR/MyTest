//
//  FHBrowseHistoryHouseDataModel.h
//  AKCommentPlugin
//
//  Created by wangxinyu on 2020/7/13.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"
#import "FHSearchHouseModel.h"

@class FHHouseListBaseItemModel;
@class FHHouseRentDataItemsModel;
@class FHDetailNeighborhoodDataModel;

@protocol FHBrowseHistoryHouseDataModel<NSObject>
@end

@interface FHBrowseHistoryHouseDataModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, copy, nullable) NSString *total;
@property (nonatomic, copy, nullable) NSString *searchId;
@property (nonatomic, strong, nullable) NSArray<FHHouseListBaseItemModel *> *historyItems;

@end

@interface FHBrowseHistoryHouseResultModel : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy, nullable) NSString *status;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, strong, nullable) FHBrowseHistoryHouseDataModel *data;

@end

@interface FHBrowseHistoryContentModel : FHSearchBaseItemModel

@property (nonatomic, copy, nullable) NSString *text;

@end

