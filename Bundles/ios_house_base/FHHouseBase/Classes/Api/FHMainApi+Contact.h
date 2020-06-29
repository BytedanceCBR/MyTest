//
//  FHMainApi+Contact.h
//  FHHouseBase
//
//  Created by 张静 on 2019/4/25.
//

#import "FHMainApi.h"
#import "FHHouseContactBaseModel.h"
#import "FHHouseType.h"
#import "FHHouseContactDefines.h"
#import "FHURLSettings.h"

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSUInteger, FHClueErrorType) {
    FHClueErrorTypeNone = 0,
    FHClueErrorTypeNetFailure,
    FHClueErrorTypeHttpFailure,
    FHClueErrorTypeServerFailure,
};

@class FHFillFormAgencyListItemModel;
@interface FHMainApi (Contact)

//快速问答 表单
+ (TTHttpTask*)requestQuickQuestionByHouseId:(NSString*)houseId
                                       phone:(NSString*)phone
                                        from:(NSString*)from
                                        type:(NSNumber*)type
                                  extraInfo:(NSDictionary*)extra
                                  completion:(void(^)(FHDetailResponseModel * _Nullable model , NSError * _Nullable error))completion;

// 详情页线索提交表单
+ (TTHttpTask*)requestSendPhoneNumbserByHouseId:(NSString*)houseId
                                          phone:(NSString*)phone
                                           from:(NSString*)from
                                       cluePage:(NSNumber*)cluePage
                                   clueEndpoint:(NSNumber*)clueEndpoint
                                     targetType:(NSNumber *)targetType
                                    extraInfo:(NSDictionary*)extra
                                     agencyList:(NSArray<FHFillFormAgencyListItemModel *> *)agencyList
                                     completion:(void(^)(FHDetailResponseModel * _Nullable model , NSError * _Nullable error))completion;

// 中介转接电话

+ (TTHttpTask*)requestVirtualNumber:(NSString*)realtorId
                            houseId:(NSString*)houseId
                          houseType:(FHHouseType)houseType
                           searchId:(NSString*)searchId
                             imprId:(NSString*)imprId
                               from:(NSString*)fromStr
                            extraInfo:(NSDictionary*)extra
                         completion:(void(^)(FHDetailVirtualNumResponseModel * _Nullable model , NSError * _Nullable error))completion; //DEPRECATED_MSG_ATTRIBUTE("建议用带cluePage的方法，后续不直接用from了");

+ (TTHttpTask*)requestVirtualNumber:(NSString*)realtorId
                            houseId:(NSString*)houseId
                          houseType:(FHHouseType)houseType
                           searchId:(NSString*)searchId
                             imprId:(NSString*)imprId
                               from:(NSString*)fromStr
                           cluePage:(NSNumber*)cluePage
                       clueEndpoint:(NSNumber*)clueEndpoint
                          extraInfo:(NSDictionary*)extra
                         completion:(void(^)(FHDetailVirtualNumResponseModel * _Nullable model , NSError * _Nullable error))completion;

#pragma mark - associate refactor
+ (TTHttpTask*)requestVirtualNumberWithAssociateInfo:(NSDictionary*)phoneAssociate
                          realtorId:(NSString*)realtorId
                            houseId:(NSString*)houseId
                          houseType:(FHHouseType)houseType
                           searchId:(NSString*)searchId
                             imprId:(NSString*)imprId
                         extraInfo:(NSDictionary*)extra
                         completion:(void(^)(FHDetailVirtualNumResponseModel * _Nullable model , NSError * _Nullable error))completion;
// 详情页线索提交表单
+ (TTHttpTask*)requestCallReportByHouseId:(NSString*)houseId
       phone:(NSString*)phone
        from:(NSString*)from
    cluePage:(NSNumber*)cluePage
clueEndpoint:(NSNumber*)clueEndpoint
  targetType:(NSNumber *)targetType
reportAssociate:(NSDictionary*)reportAssociate
agencyList:(NSArray<FHFillFormAgencyListItemModel *> *)agencyList
extraInfo:(NSDictionary*)extra
completion:(void(^)(FHDetailResponseModel * _Nullable model , NSError * _Nullable error))completion;

// 房源关注
+ (TTHttpTask*)requestFollow:(NSString*)followId
                   houseType:(FHHouseType)houseType
                  actionType:(FHFollowActionType)actionType
                  completion:(void(^)(FHDetailUserFollowResponseModel * _Nullable model , NSError * _Nullable error))completion;

// 房源取消关注
+ (TTHttpTask*)requestCancelFollow:(NSString*)followId
                         houseType:(FHHouseType)houseType
                        actionType:(FHFollowActionType)actionType
                        completion:(void(^)(FHDetailUserFollowResponseModel * _Nullable model , NSError * _Nullable error))completion;


/// 请求线索信息
/// @param params 接口参数
+ (TTHttpTask *)requestAssoicateEntrance:(NSDictionary *)params completion:(void (^)(NSError *error, id jsonObj))completion;
@end

NS_ASSUME_NONNULL_END
