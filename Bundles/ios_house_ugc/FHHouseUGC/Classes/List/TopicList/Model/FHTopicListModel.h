//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import <FHBaseModelProtocol.h>

NS_ASSUME_NONNULL_BEGIN

@protocol FHTopicListResponseDataSuggestModel <NSObject>
@end

@interface FHTopicListResponseDataSuggestHighlightModel : JSONModel

@property (nonatomic, strong , nullable) NSArray *forumName;
@end

@interface FHTopicListResponseDataSuggestForumModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *forumName;
@property (nonatomic, copy , nullable) NSString *concernId;
@property (nonatomic, copy , nullable) NSString *forumId;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *talkCountStr;
@property (nonatomic, copy , nullable) NSString *schema;
@property (nonatomic, copy , nullable) NSString *talkCount;
@property (nonatomic, copy , nullable) NSString *desc;
@end

@interface FHTopicListResponseDataSuggestModel : JSONModel

@property (nonatomic, strong , nullable) FHTopicListResponseDataSuggestHighlightModel *highlight ;
@property (nonatomic, strong , nullable) FHTopicListResponseDataSuggestForumModel *forum ;
@end

@interface FHTopicListResponseDataModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHTopicListResponseDataSuggestModel> *suggest;
@property (nonatomic, assign) BOOL accurateMatch;
@property (nonatomic, copy , nullable) NSString *offset;
@end

@interface FHTopicListResponseModel : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, copy , nullable) NSString *errNo;
@property (nonatomic, strong , nullable) FHTopicListResponseDataModel *data ;
@property (nonatomic, copy , nullable) NSString *errTips;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
