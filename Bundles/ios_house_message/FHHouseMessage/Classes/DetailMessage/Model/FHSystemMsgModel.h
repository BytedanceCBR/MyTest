//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FHSystemMsgDataItemsModel<NSObject>
@end

@interface FHSystemMsgDataItemsImagesModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHSystemMsgDataItemsModel : JSONModel 

@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *buttonName;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *timestamp;
@property (nonatomic, copy , nullable) NSString *moreDetail;
@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, strong , nullable) FHSystemMsgDataItemsImagesModel *images ;  
@property (nonatomic, copy , nullable) NSString *dateStr;
@property (nonatomic, copy , nullable) NSString *id;
@end

@interface FHSystemMsgDataModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHSystemMsgDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *minCursor;
@property (nonatomic, copy , nullable) NSString *searchId;
@end

@interface FHSystemMsgModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHSystemMsgDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER