//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
#import "TTCommentDetailReplyCommentModel.h"
#import "FHUGCScialGroupModel.h"
#import "FHFeedUGCContentModel.h"
#import "FHFeedContentModel.h"
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

@property (nonatomic, copy , nullable) NSString *comment_type;
@property (nonatomic, copy , nullable) NSString *comment_id;
@property (nonatomic, strong , nullable) NSDictionary * comment_base ;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *thumbImageList;
@property (nonatomic, strong , nullable) NSArray<FHFeedContentImageListModel> *largeImageList;
@property (nonatomic, strong , nullable) FHFeedContentRawDataOriginGroupModel *originGroup ;
//帖子
@property (nonatomic, strong , nullable) FHFeedContentRawDataOriginThreadModel *originThread ;
//小视频
@property (nonatomic, strong , nullable) FHFeedContentRawDataOriginUgcVideoModel *originUgcVideo ;
@property (nonatomic, strong , nullable) FHFeedContentRawDataOriginCommonContentModel *originCommonContent ;
@property (nonatomic, copy , nullable) NSString *originType;

@end

@interface FHUGCSocialGroupCommentDetailModel : JSONModel

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHUGCCommentDetailModel *commentDetail;
@property (nonatomic, strong , nullable) NSDictionary *logPb ;
@property (nonatomic, strong , nullable) FHUGCScialGroupDataModel *social_group ;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
