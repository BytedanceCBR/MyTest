//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
#import "FHBaseModelProtocol.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHTopicListResponseDataListModel<NSObject>
@end

@interface FHTopicListResponseDataListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *forumName;
@property (nonatomic, copy , nullable) NSString *forumId;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *talkCountStr;
@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *talkCount;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *rank;
@property (nonatomic, copy , nullable) NSDictionary *logPb;
@end

@interface FHTopicListResponseDataModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHTopicListResponseDataListModel> *list;
@end

@interface FHTopicListResponseModel : JSONModel<FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHTopicListResponseDataModel *data ;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER

