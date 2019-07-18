//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "TTCommentDetailReplyCommentModel.h"
NS_ASSUME_NONNULL_BEGIN

@protocol TTCommentDetailReplyCommentModel <NSObject>

@end

@interface FHDetailReplyCommentDataModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy , nullable) NSString *totalCount;
@property (nonatomic, copy , nullable) NSString *stickTotalNumber;
@property (nonatomic, copy , nullable) NSString *offset;
@property (nonatomic, assign) BOOL stickHasMore;
@property (nonatomic, copy , nullable) NSString *groupId;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, strong, nullable)   NSArray<TTCommentDetailReplyCommentModel> *allCommentModels;
@property (nonatomic, strong, nullable)   NSArray<TTCommentDetailReplyCommentModel> *stickCommentModels;
@property (nonatomic, strong, nullable)   NSArray<TTCommentDetailReplyCommentModel> *hotCommentModels;
@end

@interface FHDetailReplyCommentModel : JSONModel 

@property (nonatomic, assign) BOOL banFace;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, copy , nullable) NSString *errNo;
@property (nonatomic, strong , nullable) FHDetailReplyCommentDataModel *data ;  
@property (nonatomic, assign) BOOL stable;
@end

@interface FHUGCCommentDetailModel :JSONModel

@property (nonatomic, assign) BOOL banFace;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, copy , nullable) NSString *errNo;
@property (nonatomic, strong , nullable) NSDictionary * data ;
@property (nonatomic, assign) BOOL stable;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
