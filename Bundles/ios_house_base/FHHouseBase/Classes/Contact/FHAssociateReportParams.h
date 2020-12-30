//
//  FHAssociateReportParams.h
//  FHHouseBase
//
//  Created by 张静 on 2020/4/2.
//

#import "JSONModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHAssociateReportParams : JSONModel

/*
 * 总入口配置
 */
@property(nonatomic, copy) NSString *originFrom;
/*
 * 上级页面配置
 */
@property(nonatomic, copy) NSString *elementFrom; //上级页面 组件名称
@property(nonatomic, copy) NSString *elementType; //上级页面 组件名称
@property(nonatomic, copy) NSString *enterFrom; //上级页面名称
@property(nonatomic, copy) NSString *enterType; //上级页面名称

/*
 * 当前页面
 */
@property(nonatomic, copy) NSString *categoryName; //当前页面名称
@property(nonatomic, strong) NSDictionary *logPb;
@property(nonatomic, copy) NSString *searchId;
@property(nonatomic, copy) NSString *originSearchId;
@property(nonatomic, copy) NSString *groupId;
@property (nonatomic, strong) NSDictionary *extra; // 埋点参数

#pragma mark 其他埋点
// 必填
@property (nonatomic, copy) NSString *pageType;
@property (nonatomic, copy) NSString *cardType;
@property (nonatomic, copy) NSString *rank;
@property (nonatomic, strong) NSDictionary *realtorLogpb;
@property (nonatomic, copy) NSString *realtorId;

// 选填
@property (nonatomic, copy) NSString *itemId;// 表单和电话都有用到
//@property (nonatomic, assign) FHRealtorType realtorType;
@property (nonatomic, strong) NSNumber *realtorRank;
@property (nonatomic, copy) NSString *realtorPosition;
@property (nonatomic, copy) NSString *conversationId;
@property(nonatomic ,copy) NSString *position;
@property(nonatomic ,copy) NSString *houseType;


// 选填
@property(nonatomic, copy) NSString *sourceFrom;

// 帖子/视频id
@property(nonatomic, copy) NSString *fromGid;

@end

NS_ASSUME_NONNULL_END
