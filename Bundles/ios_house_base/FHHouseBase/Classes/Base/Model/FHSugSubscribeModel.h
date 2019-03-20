//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "FHBaseModelProtocol.h"
NS_ASSUME_NONNULL_BEGIN

// 搜索列表页面返回的是否订阅模型
@interface FHSugSubscribeDataDataSubscribeInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *subscribeId;
@property (nonatomic, assign) BOOL isSubscribe;
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

@interface FHSugSubscribeDataModel : JSONModel

@property (nonatomic, strong , nullable) FHSugSubscribeDataDataModel *data ;  
@end

@interface FHSugSubscribeModel : JSONModel <FHBaseModelProtocol>
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSugSubscribeDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
