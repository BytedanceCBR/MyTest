//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface FHTopicFeedListApiBaseInfoModel : JSONModel
@property (nonatomic, copy , nullable) NSString *appExtraParams;
@end

@protocol FHTopicFeedListDataModel<NSObject>
@end

@interface FHTopicFeedListDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *code;
@end

@interface FHTopicFeedListModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy , nullable) NSString *tail;
@property (nonatomic, strong , nullable) FHTopicFeedListApiBaseInfoModel *apiBaseInfo ;  
@property (nonatomic, copy , nullable) NSString *offset;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) NSArray<FHTopicFeedListDataModel> *data;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
