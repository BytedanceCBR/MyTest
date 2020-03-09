//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
#import "FHFeedContentModel.h"
NS_ASSUME_NONNULL_BEGIN
@interface FHSpecialTopicContentApiBaseInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *appExtraParams;
@end

@protocol FHSpecialTopicContentDataModel<NSObject>
@end

@interface FHSpecialTopicContentDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *code;
@end

@interface FHSpecialTopicContentModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy , nullable) NSString *tail;
@property (nonatomic, strong , nullable) FHSpecialTopicContentApiBaseInfoModel *apiBaseInfo ;  
@property (nonatomic, copy , nullable) NSString *offset;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) NSArray<FHSpecialTopicContentDataModel> *data;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentModel *> *dataContent;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
