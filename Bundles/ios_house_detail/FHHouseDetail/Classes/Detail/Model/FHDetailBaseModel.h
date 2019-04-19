//
//  FHDetailBaseModel.h
//  Pods
//
//  Created by 张静 on 2019/1/31.
//

#import <Foundation/Foundation.h>
#import "FHHouseListModel.h"
#import "FHBaseModelProtocol.h"

@class FHDetailNewDataSmallImageGroupModel;

NS_ASSUME_NONNULL_BEGIN

@protocol FHDetailPhotoHeaderModelProtocol <AbstractJSONModelProtocol>

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray *urlList;

@end

@protocol FHDetailHouseDataItemsHouseImageModel<NSObject>
@end

@interface  FHDetailHouseDataItemsHouseImageModel  : JSONModel<FHDetailPhotoHeaderModelProtocol>

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, copy , nullable) NSString *width;
@property (nonatomic, strong , nullable) NSArray *urlList;
@property (nonatomic, copy , nullable) NSString *uri;
@property (nonatomic, copy , nullable) NSString *height;

@end

@interface FHDetailBaseModel : NSObject

@end

@interface FHDetailPhotoHeaderModel : FHDetailBaseModel
@property (nonatomic,assign)BOOL isNewHouse;
@property (nonatomic, strong , nullable) NSArray<FHDetailNewDataSmallImageGroupModel *> *smallImageGroup;
@property (nonatomic, strong , nullable) NSArray<FHDetailHouseDataItemsHouseImageModel *> *houseImage;
@end

@interface FHDetailShareInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *coverImage;
@property (nonatomic, copy , nullable) NSString *isVideo;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *title;
@end

@protocol FHDetailContactModel<NSObject>
@end

@interface FHDetailContactModel : JSONModel

@property (nonatomic, copy , nullable) NSString *style;
@property (nonatomic, copy , nullable) NSString *certificate;
@property (nonatomic, copy , nullable) NSString *avatarUrl;
@property (nonatomic, copy , nullable) NSString *homePage;
@property (nonatomic, copy , nullable) NSString *realtorId;
@property (nonatomic, copy , nullable) NSString *businessLicense;
@property (nonatomic, copy , nullable) NSString *agencyId;
@property (nonatomic, copy , nullable) NSString *phone;
@property (nonatomic, copy , nullable) NSString *agencyName;
@property (nonatomic, copy , nullable) NSString *realtorName;
@property (nonatomic, copy , nullable) NSString *imOpenUrl;
@property (nonatomic, copy , nullable) NSString *imLabel;
@property (nonatomic, copy , nullable) NSString *realtorDetailUrl;
@property (nonatomic, assign) NSInteger showRealtorinfo;
@property (nonatomic, copy , nullable) NSString *callButtonText;
@property (nonatomic, copy , nullable) NSString *reportButtonText;

@property (nonatomic, assign) BOOL unregistered; //是否是注册经济人

@property (nonatomic, copy , nullable) NSString *noticeDesc;

- (nonnull id)copyWithZone:(nullable NSZone *)zone;

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder;

- (nullable instancetype)initWithCoder:(nonnull NSCoder *)aDecoder;

- (instancetype)initWithData:(NSData *)data error:(NSError *__autoreleasing *)error;

- (instancetype)initWithDictionary:(NSDictionary *)dict error:(NSError *__autoreleasing *)err;

- (NSDictionary *)toDictionary;

- (NSDictionary *)toDictionaryWithKeys:(NSArray *)propertyNames;

@end

@interface  FHDetailResponseModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;

@end

@interface  FHDetailVirtualNumModel  : JSONModel

@property (nonatomic, copy , nullable) NSString *realtorId;
@property (nonatomic, copy , nullable) NSString *virtualNumber;
@property (nonatomic, assign) NSInteger isVirtual;

@end

@interface  FHDetailVirtualNumResponseModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailVirtualNumModel *data;

@end

@interface  FHDetailUserFollowStatusModel  : JSONModel

@property (nonatomic, assign) NSInteger followStatus;

@end

@interface  FHDetailUserFollowResponseModel  : JSONModel <FHBaseModelProtocol>

@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHDetailUserFollowStatusModel *data;

@end


@protocol FHDisclaimerModelDisclaimerRichTextModel<NSObject>
@end

@interface FHDisclaimerModelDisclaimerRichTextModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<NSNumber*> *highlightRange;
@property (nonatomic, copy , nullable) NSString *linkUrl;
@end


@interface FHDisclaimerModel : JSONModel

@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, strong , nullable) NSArray<FHDisclaimerModelDisclaimerRichTextModel> *richText;

@end

@protocol FHDetailDataCertificateLabelsModel<NSObject>
@end

@interface FHDetailDataCertificateLabelsModel : JSONModel

@property (nonatomic, copy , nullable) NSString *fontColor;
@property (nonatomic, copy , nullable) NSString *tag;
@property (nonatomic, copy , nullable) NSString *icon;
@end

@interface FHDetailDataCertificateModel : JSONModel

@property (nonatomic, copy , nullable) NSString *bgColor;
@property (nonatomic, strong , nullable) NSArray<FHDetailDataCertificateLabelsModel> *labels;
@end


// 二手房、租房共用 协议
@protocol FHDetailDataBaseInfoModel<NSObject>
@end

@protocol FHDetailPriceTrendModel<NSObject>
@end

@protocol FHDetailPriceTrendValuesModel<NSObject>
@end

@interface FHDetailPriceTrendValuesModel : JSONModel

@property (nonatomic, copy , nullable) NSString *timestamp;
@property (nonatomic, copy , nullable) NSString *price;
@property (nonatomic, copy , nullable) NSString *timeStr;
@end

@interface FHDetailPriceTrendModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHDetailPriceTrendValuesModel> *values;
@property (nonatomic, copy , nullable) NSString *name;
@end


@protocol FHDetailDataNeighborhoodInfoSchoolInfoModel<NSObject>
@end

@interface FHDetailDataNeighborhoodInfoSchoolInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *schoolType;
@property (nonatomic, copy , nullable) NSString *schoolId;
@property (nonatomic, copy , nullable) NSString *schoolName;
@end

@protocol FHDetailDataNeighborhoodInfoSchoolItemModel<NSObject>
@end

@interface FHDetailDataNeighborhoodInfoSchoolItemModel : JSONModel

@property (nonatomic, copy , nullable) NSString *schoolTypeName;
@property (nonatomic, strong , nullable) NSArray<FHDetailDataNeighborhoodInfoSchoolInfoModel> *schoolList;
@end


NS_ASSUME_NONNULL_END
