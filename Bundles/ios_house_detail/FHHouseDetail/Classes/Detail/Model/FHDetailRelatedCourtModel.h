//GENERATED CODE , DON'T EDIT
#import <JSONModel.h>
NS_ASSUME_NONNULL_BEGIN
@protocol FHDetailRelatedCourtDataItemsModel<NSObject>
@end

@protocol FHDetailRelatedCourtDataItemsCommentListModel<NSObject>
@end

@interface FHDetailRelatedCourtDataItemsCommentListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *source;
@property (nonatomic, copy , nullable) NSString *createdTime;
@property (nonatomic, copy , nullable) NSString *fromUrl;
@property (nonatomic, copy , nullable) NSString *userName;
@property (nonatomic, copy , nullable) NSString *id;
@end

@interface FHDetailRelatedCourtDataItemsCommentModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedCourtDataItemsCommentListModel> *list;
@end

@interface FHDetailRelatedCourtDataItemsUserStatusModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *CourtOpenSubscribeStatus;
@property (nonatomic, copy , nullable) NSString *pricingSubStauts;
@property (nonatomic, copy , nullable) NSString *courtSubStatus;
@end

@interface FHDetailRelatedCourtDataItemsGlobalPricingModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@end

@protocol FHDetailRelatedCourtDataItemsTimelineListModel<NSObject>
@end

@interface FHDetailRelatedCourtDataItemsTimelineListModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *createdTime;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *desc;
@end

@interface FHDetailRelatedCourtDataItemsTimelineModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedCourtDataItemsTimelineListModel> *list;
@end

@protocol FHDetailRelatedCourtDataItemsTagsModel<NSObject>
@end

@interface FHDetailRelatedCourtDataItemsTagsModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@interface FHDetailRelatedCourtDataItemsContactModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *phone;
@property (nonatomic, copy , nullable) NSString *noticeDesc;
@end

@protocol FHDetailRelatedCourtDataItemsFloorpanListListModel<NSObject>
@end

@interface FHDetailRelatedCourtDataItemsFloorpanListListSaleStatusModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@protocol FHDetailRelatedCourtDataItemsFloorpanListListImagesModel<NSObject>
@end

@interface FHDetailRelatedCourtDataItemsFloorpanListListImagesModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHDetailRelatedCourtDataItemsFloorpanListListModel : JSONModel 

@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *roomCount;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) FHDetailRelatedCourtDataItemsFloorpanListListSaleStatusModel *saleStatus ;  
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *squaremeter;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedCourtDataItemsFloorpanListListImagesModel> *images;
@property (nonatomic, copy , nullable) NSString *searchId;
@end

@interface FHDetailRelatedCourtDataItemsFloorpanListModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedCourtDataItemsFloorpanListListModel> *list;
@end

@interface FHDetailRelatedCourtDataItemsCoreInfoSaleStatusModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *content;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, copy , nullable) NSString *textColor;
@end

@interface FHDetailRelatedCourtDataItemsCoreInfoModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *courtAddress;
@property (nonatomic, copy , nullable) NSString *name;
@property (nonatomic, strong , nullable) FHDetailRelatedCourtDataItemsCoreInfoSaleStatusModel *saleStatus ;  
@property (nonatomic, copy , nullable) NSString *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy , nullable) NSString *constructionOpendate;
@property (nonatomic, copy , nullable) NSString *aliasName;
@property (nonatomic, copy , nullable) NSString *gaodeImageUrl;
@end

@protocol FHDetailRelatedCourtDataItemsImagesModel<NSObject>
@end

@interface FHDetailRelatedCourtDataItemsImagesModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;
@end

@interface FHDetailRelatedCourtDataItemsModel : JSONModel 

@property (nonatomic, strong , nullable) FHDetailRelatedCourtDataItemsCommentModel *comment ;  
@property (nonatomic, strong , nullable) FHDetailRelatedCourtDataItemsUserStatusModel *userStatus ;  
@property (nonatomic, copy , nullable) NSString *displayTitle;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, strong , nullable) FHDetailRelatedCourtDataItemsGlobalPricingModel *globalPricing ;  
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong , nullable) FHDetailRelatedCourtDataItemsTimelineModel *timeline ;  
@property (nonatomic, copy , nullable) NSString *id;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedCourtDataItemsTagsModel> *tags;
@property (nonatomic, copy , nullable) NSString *uploadAt;
@property (nonatomic, copy , nullable) NSString *displayDescription;
@property (nonatomic, strong , nullable) FHDetailRelatedCourtDataItemsContactModel *contact ;  
@property (nonatomic, copy , nullable) NSString *displayPricePerSqm;
@property (nonatomic, strong , nullable) FHDetailRelatedCourtDataItemsFloorpanListModel *floorpanList ;  
@property (nonatomic, copy , nullable) NSString *cellStyle;
@property (nonatomic, strong , nullable) FHDetailRelatedCourtDataItemsCoreInfoModel *coreInfo ;  
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedCourtDataItemsImagesModel> *images;
@property (nonatomic, copy , nullable) NSString *houseType;
@property (nonatomic, strong , nullable) NSDictionary *logPb;
@property (nonatomic, copy , nullable) NSString *searchId;
@end

@interface FHDetailRelatedCourtDataModel : JSONModel 

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong , nullable) NSArray<FHDetailRelatedCourtDataItemsModel> *items;
@property (nonatomic, copy , nullable) NSString *total;
@property (nonatomic, copy , nullable) NSString *searchId;
@end

@interface FHDetailRelatedCourtModel : JSONModel 

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailRelatedCourtDataModel *data ;  
@end


NS_ASSUME_NONNULL_END
//END OF HEADER
