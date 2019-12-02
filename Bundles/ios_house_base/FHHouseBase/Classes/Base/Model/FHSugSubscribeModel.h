//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "FHBaseModelProtocol.h"
#import "FHSearchBaseItemModel.h"
NS_ASSUME_NONNULL_BEGIN



// 搜索列表页面是否显示真假房源入口
@interface FHSugListRealHouseTopInfoModel : FHSearchBaseItemModel

@property (nonatomic, copy , nullable) NSString *fakeText;
@property (nonatomic, copy , nullable) NSString *fakeHouse;
@property (nonatomic, copy , nullable) NSString *fakeTitle;
@property (nonatomic, copy , nullable) NSString *enableFakeHouse;
@property (nonatomic, copy , nullable) NSString *fakeHouseTotal;
@property (nonatomic, copy , nullable) NSString *houseTotal;
@property (nonatomic, copy , nullable) NSString *totalTitle;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *trueHouseTotal;
@property (nonatomic, copy , nullable) NSString *trueTitle;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *subscribeId;

@property (nonatomic, strong)   NSDictionary   *tracerDict;
@property (nonatomic, strong)  NSString *searchQuery;

@end

// 搜索列表页面返回的是否订阅模型
@interface FHSugSubscribeDataDataSubscribeInfoModel : FHSearchBaseItemModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *subscribeId;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, assign) BOOL isSubscribe;
@property (nonatomic, assign) BOOL status;


@end

// 推荐列表返回的m数据模型（订阅成功时的）
@protocol FHSugSubscribeDataDataItemsModel<NSObject>
@end

@interface FHSugSubscribeDataDataItemsModel : JSONModel 

@property (nonatomic, assign) BOOL status;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *subscribeId;
@property (nonatomic, copy , nullable) NSString *title;
@end

@interface FHSugSubscribeDataDataModel : JSONModel 

@property (nonatomic, strong , nullable) NSArray<FHSugSubscribeDataDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *total;

@end

@interface FHSugSubscribeModel : JSONModel <FHBaseModelProtocol>
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSugSubscribeDataDataModel *data ;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
