//
//  FHSearchConfigModel.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/28.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHSearchConfigSearchTabNeighborhoodFilterModel<NSObject>

@end


@protocol FHSearchConfigSearchTabNeighborhoodFilterOptionsModel<NSObject>

@end


@protocol FHSearchConfigSearchTabNeighborhoodFilterOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigSearchTabNeighborhoodFilterOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigSearchTabNeighborhoodFilterOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSearchTabNeighborhoodFilterOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigSearchTabNeighborhoodFilterModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *rate;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSearchTabNeighborhoodFilterOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@protocol FHSearchConfigRentFilterOrderModel<NSObject>

@end


@protocol FHSearchConfigRentFilterOrderOptionsModel<NSObject>

@end


@protocol FHSearchConfigRentFilterOrderOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigRentFilterOrderOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *rankType;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigRentFilterOrderOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigRentFilterOrderOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigRentFilterOrderModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigRentFilterOrderOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@protocol FHSearchConfigSearchTabCourtFilterModel<NSObject>

@end


@protocol FHSearchConfigSearchTabCourtFilterOptionsModel<NSObject>

@end


@protocol FHSearchConfigSearchTabCourtFilterOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigSearchTabCourtFilterOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigSearchTabCourtFilterOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSearchTabCourtFilterOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigSearchTabCourtFilterModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *rate;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSearchTabCourtFilterOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@protocol FHSearchConfigNeighborhoodFilterModel<NSObject>

@end


@protocol FHSearchConfigNeighborhoodFilterOptionsModel<NSObject>

@end


@protocol FHSearchConfigNeighborhoodFilterOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigNeighborhoodFilterOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigNeighborhoodFilterOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigNeighborhoodFilterOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigNeighborhoodFilterModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *rate;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigNeighborhoodFilterOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@protocol FHSearchConfigSearchTabRentFilterModel<NSObject>

@end


@protocol FHSearchConfigSearchTabRentFilterOptionsModel<NSObject>

@end


@protocol FHSearchConfigSearchTabRentFilterOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigSearchTabRentFilterOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigSearchTabRentFilterOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSearchTabRentFilterOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigSearchTabRentFilterModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *rate;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSearchTabRentFilterOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@protocol FHSearchConfigFilterModel<NSObject>

@end


@protocol FHSearchConfigFilterOptionsModel<NSObject>

@end


@protocol FHSearchConfigFilterOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigFilterOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigFilterOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigFilterOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigFilterModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *rate;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigFilterOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@protocol FHSearchConfigSearchTabFilterModel<NSObject>

@end


@protocol FHSearchConfigSearchTabFilterOptionsModel<NSObject>

@end


@protocol FHSearchConfigSearchTabFilterOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigSearchTabFilterOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigSearchTabFilterOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSearchTabFilterOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigSearchTabFilterModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *rate;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSearchTabFilterOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@protocol FHSearchConfigCourtFilterModel<NSObject>

@end


@protocol FHSearchConfigCourtFilterOptionsModel<NSObject>

@end


@protocol FHSearchConfigCourtFilterOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigCourtFilterOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigCourtFilterOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigCourtFilterOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigCourtFilterModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *rate;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigCourtFilterOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@protocol FHSearchConfigHouseFilterOrderModel<NSObject>

@end


@protocol FHSearchConfigHouseFilterOrderOptionsModel<NSObject>

@end


@protocol FHSearchConfigHouseFilterOrderOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigHouseFilterOrderOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *rankType;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigHouseFilterOrderOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigHouseFilterOrderOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigHouseFilterOrderModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigHouseFilterOrderOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@protocol FHSearchConfigRentFilterModel<NSObject>

@end


@protocol FHSearchConfigRentFilterOptionsModel<NSObject>

@end


@protocol FHSearchConfigRentFilterOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigRentFilterOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigRentFilterOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigRentFilterOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigRentFilterModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *rate;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigRentFilterOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@protocol FHSearchConfigNeighborhoodFilterOrderModel<NSObject>

@end


@protocol FHSearchConfigNeighborhoodFilterOrderOptionsModel<NSObject>

@end


@protocol FHSearchConfigNeighborhoodFilterOrderOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigNeighborhoodFilterOrderOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *rankType;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigNeighborhoodFilterOrderOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigNeighborhoodFilterOrderOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigNeighborhoodFilterOrderModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigNeighborhoodFilterOrderOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@protocol FHSearchConfigSaleHistoryFilterModel<NSObject>

@end


@protocol FHSearchConfigSaleHistoryFilterOptionsModel<NSObject>

@end


@protocol FHSearchConfigSaleHistoryFilterOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigSaleHistoryFilterOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigSaleHistoryFilterOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSaleHistoryFilterOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigSaleHistoryFilterModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *rate;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSaleHistoryFilterOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@protocol FHSearchConfigCourtFilterOrderModel<NSObject>

@end


@protocol FHSearchConfigCourtFilterOrderOptionsModel<NSObject>

@end


@protocol FHSearchConfigCourtFilterOrderOptionsOptionsModel<NSObject>

@end


@interface  FHSearchConfigCourtFilterOrderOptionsOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *rankType;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *isEmpty;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, copy , nullable) NSString *value;

@end


@interface  FHSearchConfigCourtFilterOrderOptionsModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, assign) BOOL supportMulti;
@property (nonatomic, copy , nullable) NSString *type;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigCourtFilterOrderOptionsOptionsModel> *options;

@end


@interface  FHSearchConfigCourtFilterOrderModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigCourtFilterOrderOptionsModel> *options;
@property (nonatomic, copy , nullable) NSString *tabStyle;
@property (nonatomic, copy , nullable) NSString *tabId;

@end


@interface  FHSearchConfigModel  : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSearchTabNeighborhoodFilterModel> *searchTabNeighborhoodFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigRentFilterOrderModel> *rentFilterOrder;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSearchTabCourtFilterModel> *searchTabCourtFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigNeighborhoodFilterModel> *neighborhoodFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSearchTabRentFilterModel> *searchTabRentFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigFilterModel> *filter;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSearchTabFilterModel> *searchTabFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigCourtFilterModel> *courtFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigHouseFilterOrderModel> *houseFilterOrder;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigRentFilterModel> *rentFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigNeighborhoodFilterOrderModel> *neighborhoodFilterOrder;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigSaleHistoryFilterModel> *saleHistoryFilter;
@property (nonatomic, strong , nullable) NSArray<FHSearchConfigCourtFilterOrderModel> *courtFilterOrder;

@end

NS_ASSUME_NONNULL_END
