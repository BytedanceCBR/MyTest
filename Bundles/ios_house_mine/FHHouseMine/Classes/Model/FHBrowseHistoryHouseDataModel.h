//
//  FHBrowseHistoryHouseDataModel.h
//  AKCommentPlugin
//
//  Created by wangxinyu on 2020/7/13.
//

#import "JSONModel.h"
#import "FHBaseModelProtocol.h"

NS_ASSUME_NONNULL_BEGIN

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

/**
 浏览历史页面新房、二手房model
*/
@interface FHBrowseHistoryHouseResultModel : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy, nullable) NSString *status;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, strong, nullable) FHBrowseHistoryHouseDataModel *data;

@end

@protocol FHBrowseHistoryRentDataModel<NSObject>
@end

@interface FHBrowseHistoryRentDataModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, copy, nullable) NSString *total;
@property (nonatomic, copy, nullable) NSString *searchId;
@property (nonatomic, strong, nullable) NSArray<FHHouseRentDataItemsModel *> *historyItems;

@end

/**
 浏览历史页面租房model
*/
@interface FHBrowseHistoryRentResultModel : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy, nullable) NSString *status;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, strong, nullable) FHBrowseHistoryHouseDataModel *data;

@end

@protocol FHBrowseHistoryNeighborhoodDataModel<NSObject>
@end

@interface FHBrowseHistoryNeighborhoodDataModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, assign) NSInteger offset;
@property (nonatomic, copy, nullable) NSString *total;
@property (nonatomic, copy, nullable) NSString *searchId;
@property (nonatomic, strong, nullable) NSArray<FHDetailNeighborhoodDataModel *> *historyItems;

@end

/**
 浏览历史页面小区model
*/
@interface FHBrowseHistoryNeighborhoodResultModel : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy, nullable) NSString *status;
@property (nonatomic, copy, nullable) NSString *message;
@property (nonatomic, strong, nullable) FHBrowseHistoryHouseDataModel *data;

@end

NS_ASSUME_NONNULL_END
