//
//  FHDetailBaseModel.h
//  Pods
//
//  Created by 张静 on 2019/1/31.
//

#import <Foundation/Foundation.h>
#import "FHHouseListModel.h"
#import "FHBaseModelProtocol.h"
#import "FHHouseType.h"
#import "FHHouseShadowImageType.h"
#import <FHHouseBase/FHFillFormAgencyListItemModel.h>
#import <FHHouseBase/FHImageModel.h>
#import <FHHouseBase/FHHouseCoreInfoModel.h>
#import <UIKit/UIKit.h>

@class FHDetailHouseTitleModel;
@class FHHouseDetailImageGroupModel;
@class FHClueAssociateInfoModel;

NS_ASSUME_NONNULL_BEGIN

@protocol FHDetailPhotoHeaderModelProtocol <AbstractJSONModelProtocol>

@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, strong , nullable) NSArray *urlList;

@end

//@protocol FHDetailHouseDataItemsHouseImageModel<NSObject>
//@end
//
//@interface  FHDetailHouseDataItemsHouseImageModel  : JSONModel<FHDetailPhotoHeaderModelProtocol>
//
//@property (nonatomic, copy , nullable) NSString *url;
//@property (nonatomic, copy , nullable) NSString *width;
//@property (nonatomic, strong , nullable) NSArray *urlList;
//@property (nonatomic, copy , nullable) NSString *uri;
//@property (nonatomic, copy , nullable) NSString *height;
//
//@end

@interface FHDetailBaseModel : NSObject
@property (nonatomic, assign) FHHouseShdowImageType shadowImageType;
//是否裁剪阴影图
@property (nonatomic, assign) FHHouseShdowImageScopeType shdowImageScopeType;
//根据houseModelType将多个cell分为一个模块
@property (nonatomic, assign)FHHouseModelType houseModelType;
@property (nonatomic, strong) UIImage *shadowImage;
@end

@interface FHDetailPhotoHeaderModel : FHDetailBaseModel
@property (nonatomic,assign)BOOL isNewHouse;
@property (nonatomic, strong , nullable) NSArray<FHHouseDetailImageGroupModel *> *smallImageGroup;
@property (nonatomic, strong , nullable) NSArray<FHImageModel *> *houseImage;
@property (nonatomic, strong , nullable) NSArray<FHImageModel *> *instantHouseImages;//列表页小图
@property (strong, nonatomic, nullable) FHDetailHouseTitleModel *titleDataModel;//标题，标签模型
@property (nonatomic, assign) BOOL isInstantData;
@end

@interface FHDetailShareInfoModel : JSONModel

@property (nonatomic, copy , nullable) NSString *coverImage;
@property (nonatomic, copy , nullable) NSString *isVideo;
@property (nonatomic, copy , nullable) NSString *desc;
@property (nonatomic, copy , nullable) NSString *shareUrl;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;
@end

@interface FHDetailContactImageTagModel : JSONModel

@property (nonatomic, copy , nullable) NSString *imageUrl;

@end


typedef NS_ENUM(NSUInteger, FHRealtorType){
    FHRealtorTypeNormal = 0,
    FHRealtorTypeExpert = 1
};

typedef NS_ENUM(NSUInteger, FHRealtorCellShowStyle) {
    FHRealtorCellShowStyle0,
    FHRealtorCellShowStyle1,
    FHRealtorCellShowStyle2,
    FHRealtorCellShowStyle3,
};

@protocol FHRealtorTag<NSObject>
@end

@interface FHRealtorTag: JSONModel
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *backgroundColor;
@property (nonatomic, copy , nullable) NSString *fontColor;
@property (nonatomic, copy , nullable) NSString *borderColor;
@property (nonatomic, copy , nullable) NSString *prefixIconUrl;
@end

@interface FHClueAssociateInfoModel: JSONModel
@property (nonatomic, strong, nullable) NSDictionary *imInfo;
@property (nonatomic, strong, nullable) NSDictionary *phoneInfo;
@property (nonatomic, strong, nullable) NSDictionary *reportFormInfo;
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
@property (nonatomic, copy , nullable) NSString *agencyDescription;

//1.0.2 技术需求：明文手机号隐藏
//@property (nonatomic, copy , nullable) NSString *phone;
@property (nonatomic, assign) BOOL enablePhone;
@property (nonatomic, copy , nullable) NSString *agencyName;
@property (nonatomic, copy , nullable) NSString *realtorName;
@property (nonatomic, copy , nullable) NSString *imOpenUrl;
@property (nonatomic, copy , nullable) NSString *imLabel;
@property (nonatomic, copy , nullable) NSString *realtorDetailUrl;
@property (nonatomic, copy , nullable) NSString *realtorScoreDisplay;
@property (nonatomic, copy , nullable) NSString *realtorScoreDescription;
@property (nonatomic, copy , nullable) NSString *realtorDescription;
@property (nonatomic, assign) NSInteger showRealtorinfo;
@property (nonatomic, copy , nullable) NSString *callButtonText;
@property (nonatomic, copy , nullable) NSString *reportButtonText;
@property (nonatomic, assign) FHRealtorType realtorType;
@property (nonatomic, assign) FHRealtorCellShowStyle realtorCellShow;
@property (nonatomic, copy , nullable) NSString *realtorEvaluate;
@property (nonatomic, strong , nullable) NSArray<FHRealtorTag> *realtorTags;

@property (nonatomic, assign) BOOL unregistered; //是否是注册经济人
@property (nonatomic, assign) BOOL isFormReport; //是否包含填表单
@property (nonatomic, copy , nullable) NSString *searchId;
@property (nonatomic, copy , nullable) NSString *imprId;
@property (nonatomic, copy, nullable) NSString *bizTrace;

@property (nonatomic, copy , nullable) NSString *noticeDesc;
@property (nonatomic, strong , nullable) FHDetailContactImageTagModel *imageTag;

@property (nonatomic, assign) BOOL isInstantData;//是否是列表页带入的
@property (nonatomic, strong , nullable) NSDictionary *realtorLogpb;
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
//@protocol FHDetailDataBaseInfoModel<NSObject>
//@end

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

@interface FHDetailDataBaseExtraDialogsModel : JSONModel

@property (nonatomic, copy , nullable) NSString *feedbackContent;
@property (nonatomic, copy , nullable) NSString *title;
@property (nonatomic, copy , nullable) NSString *subTitle;
@property (nonatomic, copy , nullable) NSString *icon;
@property (nonatomic, copy , nullable) NSString *reportUrl;
@end

@interface FHDetailCommunityEntryActiveCountInfoModel : JSONModel
@property (nonatomic, copy , nullable) NSNumber *count;
@property (nonatomic, copy , nullable) NSString *numColor;
@property (nonatomic, copy , nullable) NSString *text;
@property (nonatomic, copy , nullable) NSString *textColor;
@end


@interface FHDetailCommunityEntryActiveInfoModel : JSONModel
@property (nonatomic, copy , nullable) NSString *activeUserAvatar;
@property (nonatomic, copy , nullable) NSString *suggestInfo;
@property (nonatomic, copy , nullable) NSString *suggestInfoColor;
@end

@protocol FHDetailCommunityEntryActiveInfoModel;

@interface FHDetailGaodeImageModel : JSONModel
@property (nonatomic, copy , nullable) NSString *url;
@property (nonatomic, assign) NSInteger width;
@property (nonatomic, assign) NSInteger height;
@property (nonatomic, copy , nullable) NSString *latRatio;
@property (nonatomic, copy , nullable) NSString *lngRatio;
@end

@protocol FHVideoHouseVideoVideoInfosModel<NSObject>
@end

@interface FHVideoHouseVideoVideoInfosModel : JSONModel

@property (nonatomic, copy , nullable) NSString *vid;
@property (nonatomic, assign) NSInteger imageWidth;
@property (nonatomic, assign) NSInteger vHeight;
@property (nonatomic, assign) NSInteger imageHeight;
@property (nonatomic, assign) NSInteger vWidth;
@property (nonatomic, copy , nullable) NSString *coverImageUrl;
@end

@interface FHVideoHouseVideoModel : JSONModel

@property (nonatomic, strong , nullable) NSArray<FHVideoHouseVideoVideoInfosModel> *videoInfos;
@property (nonatomic, copy , nullable) NSString *infoSubTitle;
@property (nonatomic, copy , nullable) NSString *infoTitle;
@end

@protocol FHDetailHouseVRDataModel <NSObject>
@end

@interface FHDetailHouseVRDataModel: JSONModel
@property (nonatomic, assign) BOOL hasVr;
@property (nonatomic, strong , nullable) FHImageModel *vrImage;
@property (nonatomic, copy , nullable) NSString *openUrl;
@property (nonatomic, assign) NSInteger vrType;       //（售楼处：0  鸟瞰图：1   样板间：2）
@end

@protocol FHHouseDetailImageListDataModel<NSObject>
@end

// 房源详情图片类型
typedef enum : NSInteger {
    FHDetailHouseImageTypeOther             = 0, // 其他
    FHDetailHouseImageTypeApartment         = 2, // 户型
    FHDetailHouseImageTypeLivingroom        = 3, // 客厅
    FHDetailHouseImageTypeBedroom           = 4, // 卧室
    FHDetailHouseImageTypeKitchen           = 5, // 厨房
    FHDetailHouseImageTypeBathroom          = 6, // 卫生间
    
    FHDetailHouseImageTypeEffect            = 1001, // 效果图
    FHDetailHouseImageTypePrototyperoom     = 1002, // 样板间
    FHDetailHouseImageTypeLocation          = 1003, // 区位
    FHDetailHouseImageTypeSandbox           = 1004, // 沙盘
    FHDetailHouseImageTypePeripheral        = 1005, // 周边配套
    FHDetailHouseImageTypeRealistic         = 1006, // 实景图
    FHDetailHouseImageTypeBuildingLicenses  = 1007, //楼盘证照
} FHDetailHouseImageType;


typedef NS_ENUM (NSUInteger, FHHouseDetailImageListDataUsedSceneType) {
    FHHouseDetailImageListDataUsedSceneTypeUnknown = 0,
    FHHouseDetailImageListDataUsedSceneTypeOld = 1,
    FHHouseDetailImageListDataUsedSceneTypeNew = 2,
    FHHouseDetailImageListDataUsedSceneTypeNeighborhood = 3,
    FHHouseDetailImageListDataUsedSceneTypeRent = 4,
    FHHouseDetailImageListDataUsedSceneTypeFloorPan = 5
};

@interface FHHouseDetailImageListDataModel : JSONModel

@property (nonatomic, copy , nullable) NSString *houseImageTypeName;
@property (nonatomic, assign) FHDetailHouseImageType houseImageType;
@property (nonatomic, assign) FHHouseDetailImageListDataUsedSceneType usedSceneType; //使用场景，主要区分户型详情，type显示 户型&样板间
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *houseImageList;
@property (nonatomic, strong , nullable) NSArray<FHImageModel> *instantHouseImageList;
@end




@interface FHDetailNewTopBanner : JSONModel

@property (nonatomic, copy , nullable) NSString *businessTag;
@property (nonatomic, copy , nullable) NSString *advantage;

@end

@interface FHDetailNewUserStatusModel : JSONModel

@property (nonatomic, copy , nullable) NSString *courtOpenSubStatus;
@property (nonatomic, copy , nullable) NSString *pricingSubStatus;
@property (nonatomic, assign) NSInteger courtSubStatus;
@end


NS_ASSUME_NONNULL_END
