//GENERATED CODE , DON'T EDIT
#import "JSONModel.h"
NS_ASSUME_NONNULL_BEGIN
@protocol FHHouseMsgDataItemsModel<NSObject>
@end

@protocol FHHouseMsgDataItemsItemsModel<NSObject>
@end

@protocol FHHouseMsgDataItemsItemsTagsModel<NSObject>
@end

@protocol FHMsgDataItemsReportButtonListModel<NSObject>
@end

@protocol FHMsgDataItemReportContentStyleModel <NSObject>

@end

@interface FHMsgDataItemReportContentStyleModel : JSONModel

@property (nonatomic, copy, nullable) NSString *fontColor;
@property (nonatomic, assign) NSInteger start;
@property (nonatomic, assign) NSInteger length;

@end

@interface FHMsgDataItemsReportButtonListModel : JSONModel

@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, copy , nullable) NSString *name;
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

@interface FHHouseMsgItemHouseVideo : JSONModel

@property (nonatomic, assign)   BOOL   hasVideo;
@end


@interface FHHouseMsgDataItemsItemsModel : JSONModel 

@property (nonatomic, assign) NSInteger status;
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
@property (nonatomic, strong, nullable) FHHouseMsgItemHouseVideo* houseVideo;
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
@property (nonatomic, assign) BOOL isSoldout;

/**
 109 新增举报消息类型
 */
@property (nonatomic, copy, nullable) NSString *content;

/// 对举报内容的格式化数据
@property (nonatomic, copy, nullable) NSArray<FHMsgDataItemReportContentStyleModel> *contentStyleList;

/// 按钮列表，有服务端下发
@property (nonatomic, copy, nullable) NSArray<FHMsgDataItemsReportButtonListModel> *buttonList;
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
