//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
#import "FHBaseModelProtocol.h"
NS_ASSUME_NONNULL_BEGIN

@protocol FHUGCPostHistoryDataModel<NSObject>
@end

@interface FHUGCPostHistoryDataModel : JSONModel

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *code;
@end

@interface FHUGCPostHistoryModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy , nullable) NSString *tail;
@property (nonatomic, copy , nullable) NSString *offset;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, copy , nullable) NSString *status;// 这个数据服务端没有
@property (nonatomic, strong , nullable) NSArray<FHUGCPostHistoryDataModel> *data;
@end

NS_ASSUME_NONNULL_END
//END OF HEADER

