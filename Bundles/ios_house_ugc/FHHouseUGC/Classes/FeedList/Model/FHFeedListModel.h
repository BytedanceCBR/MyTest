//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHFeedListDataModel<NSObject>
@end

@interface FHFeedListDataModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *code;
@end

@interface FHFeedListTipsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *appName;
@property (nonatomic, copy , nullable) NSString *packageName;
@property (nonatomic, copy , nullable) NSString *displayTemplate;
@property (nonatomic, copy , nullable) NSString *displayDuration;
@property (nonatomic, copy , nullable) NSString *downloadUrl;
@property (nonatomic, copy , nullable) NSString *displayInfo;
@property (nonatomic, copy , nullable) NSString *webUrl;
@property (nonatomic, copy , nullable) NSString *type;
@end

@interface FHFeedListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *loginStatus;
@property (nonatomic, copy , nullable) NSString *totalNumber;
@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, copy , nullable) NSString *postContentHint;
@property (nonatomic, copy , nullable) NSString *showEtStatus;
@property (nonatomic, assign) BOOL isUseBytedanceStream;
@property (nonatomic, copy , nullable) NSString *feedFlag;
@property (nonatomic, copy , nullable) NSString *actionToLastStick;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, copy , nullable) NSString *lastOffset;
@property (nonatomic, copy , nullable) NSString *offset;
@property (nonatomic, assign) BOOL hasMoreToRefresh;
@property (nonatomic, strong , nullable) NSArray<FHFeedListDataModel> *data;
@property (nonatomic, strong , nullable) FHFeedListTipsModel *tips ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
