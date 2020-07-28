//
//  FHHouseRealtorDetailInfoModel.h
//  FHHouseRealtorDetail
//
//  Created by liuyu on 2020/7/13.
//

#import "JSONModel.h"
#import "FHDetailBaseModel.h"
NS_ASSUME_NONNULL_BEGIN



@interface FHHouseRealtorDetailrRgcModel: NSObject

@end


@interface FHHouseRealtorDetailInfoModel : JSONModel
///电话, string
@property (nonatomic, copy, nullable) NSString *phone;
///姓名, string
@property (nonatomic, copy, nullable) NSString *realtorName;
///头像, string
@property (nonatomic, copy, nullable) NSString *avatarUrl;
///经纪人id, string
@property (nonatomic, copy, nullable) NSString *realtorId;
/// 公司名称, string
@property (nonatomic, copy, nullable) NSString *agencyName;
///门店信息, string
@property (nonatomic, copy, nullable) NSString *agencyPosition;
/// 电话字段是否有值
@property (nonatomic, assign) BOOL enablePhone;
/// 图片标签
@property (nonatomic, strong, nullable) NSDictionary *imageTag;
@end

@protocol FHHouseRealtorDetailUserEvaluationItemTagModel

@end
@interface FHHouseRealtorDetailUserEvaluationItemTagModel : JSONModel
///tag id，类型 int64
@property (nonatomic, assign) NSInteger id;
///content 展示文本，类型 string
@property (nonatomic, copy, nullable) NSString *content;
///背景颜色，类型 string
@property (nonatomic, copy, nullable) NSString *backgroundColor;
///文本颜色，类型 string
@property (nonatomic, copy, nullable) NSString *textColor;
@end

@protocol FHHouseRealtorDetailUserEvaluationItemModel

@end
@interface FHHouseRealtorDetailUserEvaluationItemModel : JSONModel
///头像图片
@property (nonatomic, copy, nullable) NSString *avatarUrl;
///分数string
@property (nonatomic, copy, nullable) NSString *score;
///时间 string 格式:2020-05-01
@property (nonatomic, copy, nullable) NSString *time;
///评价内容 string
@property (nonatomic, copy, nullable) NSString *content;
///反馈标签  dict list
@property (nonatomic, strong, nullable) NSArray <FHHouseRealtorDetailUserEvaluationItemTagModel>*tags;
@end

@interface FHHouseRealtorDetailShopModel : JSONModel
///经纪人是否有认领房源（true为开  false为没开） 判断是否展示店铺信息
@property (nonatomic, assign) BOOL isShow;
///string 在售房源数量  eg：在售x套
@property (nonatomic, copy, nullable) NSString *houseCount;
///bool  满足条件评论数量 >5为true  否则为false
@property (nonatomic, strong, nullable) NSDictionary *houseImage;
@end

@protocol FHHouseRealtorDetailRgcTabModel
@end
@interface FHHouseRealtorDetailRgcTabModel: JSONModel
///客户端可展示便签 （eg微头条、小视频）
@property (nonatomic, copy, nullable) NSString *showName;
@property (nonatomic, copy, nullable) NSString *tabName;
@property (nonatomic, copy, nullable) NSString *count;
@property (nonatomic, assign) BOOL isDefault;
@end

@interface FHHouseRealtorDetailUserEvaluationModel : JSONModel
///是否展示该模块 bool，true:展示
@property (nonatomic, assign) BOOL isShow;
///评价人数 string xx人
@property (nonatomic, copy, nullable) NSString *evaCount;
///bool  满足条件评论数量 >5为true  否则为false
@property (nonatomic, assign) BOOL hasMore;
///经纪人服务分详情
@property (nonatomic, strong, nullable) NSArray <FHHouseRealtorDetailUserEvaluationItemModel>*commentInfo;
@end

@interface FHHouseRealtorDetailScoreModel : JSONModel
///经纪人认证信息页面schema
@property (nonatomic, copy, nullable) NSString *realtorScore;
///经纪人认证信息页面schema
@property (nonatomic, copy, nullable) NSString *realtorScoreRank;
///所在城市， string
@property (nonatomic, copy, nullable) NSString *cityName;
@end

@interface FHHouseRealtorDetailDataModel : JSONModel

///默认选中index
@property (nonatomic, copy, nullable) NSString *realtorTab;
///线索字段
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;
///经纪人认证信息页面schema
@property (nonatomic, copy, nullable) NSString *certificationPage;
///如果为空串，则主页不展示认证信息入口
@property (nonatomic, copy, nullable) NSString *certificationIcon;
///经纪人服务分详情
@property (nonatomic, strong, nullable) NSDictionary *scoreInfo;
///用户评价信息
@property (nonatomic, strong, nullable) NSDictionary *evaluation;
///经纪人信息
@property (nonatomic, strong, nullable) NSDictionary *realtor;
///类型 string，跳转im的schema
@property (nonatomic, copy, nullable) NSString *chatOpenUrl;
///经纪人店铺模块信息
@property (nonatomic, strong, nullable) NSDictionary *realtorShop;
/////经纪人rgc Tab内容
@property (nonatomic, strong, nullable) NSArray <FHHouseRealtorDetailRgcTabModel>*ugcTabList;
@end

@interface FHHouseRealtorDetailModel : JSONModel
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseRealtorDetailDataModel *data ;
@end

@interface FHHouseRealtorShopModel : JSONModel
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;
///经纪人认证信息页面schema
@property (nonatomic, copy, nullable) NSString *certificationPage;
///如果为空串，则主页不展示认证信息入口
@property (nonatomic, copy, nullable) NSString *certificationIcon;
///经纪人信息
@property (nonatomic, copy, nullable) NSString *chatOpenUrl;
@property (nonatomic, strong, nullable) NSDictionary *realtor;
@property (nonatomic, strong, nullable) NSDictionary *topNeighborhood;
@property (nonatomic, strong, nullable) NSDictionary *houseImage;
@property (nonatomic, copy, nullable) NSString *houseCount;

@end

@interface FHHouseRealtorShopDetailModel : JSONModel
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseRealtorShopModel *data ;
@end

NS_ASSUME_NONNULL_END
