//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FHHouseMsgDataItemsModel<NSObject>
@end

@protocol FHHouseMsgDataItemsItemsModel<NSObject>
@end

@protocol FHHouseMsgDataItemsItemsTagsModel<NSObject>
@end

@interface FHHouseMsgDataItemsItemsTagsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@protocol FHHouseMsgDataItemsItemsImagesModel<NSObject>
@end

@interface FHHouseMsgDataItemsItemsImagesModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHHouseMsgDataItemsItemsHouseImageTagModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@interface FHHouseMsgDataItemsItemsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *salesInfo;
@property (nonatomic, copy , nullable) NSString *price;
@property (nonatomic, strong , nullable) NSArray<FHHouseMsgDataItemsItemsTagsModel> *tags;
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *pricePerSqm;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, strong , nullable) NSArray<FHHouseMsgDataItemsItemsImagesModel> *images;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong , nullable) FHHouseMsgDataItemsItemsHouseImageTagModel *houseImageTag ;  
@property (nonatomic, copy , nullable) NSString *id;
@end

@interface FHHouseMsgDataItemsModel : JSONModel 

@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *moreDetail;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) NSArray<FHHouseMsgDataItemsItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *timestamp;
@property (nonatomic, copy , nullable) NSString *moreLabel;
@property (nonatomic, copy , nullable) NSString *dateStr;
@property (nonatomic, copy , nullable) NSString *id;
@end

@interface FHHouseMsgDataModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHHouseMsgDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *minCursor;
@property (nonatomic, copy , nullable) NSString *searchId;
@end

@interface FHHouseMsgModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseMsgDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
