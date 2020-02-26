//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHUGCCommentListDataModel<NSObject>
@end

@interface FHUGCCommentListDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *code;
@end

@interface FHUGCCommentListModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) NSArray<FHUGCCommentListDataModel> *data;
@property (nonatomic, copy , nullable) NSString *tail;
@property (nonatomic, copy , nullable) NSString *offset;
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
