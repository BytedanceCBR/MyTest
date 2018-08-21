//
//  TTAccountUserProfileTask.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/26/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIImage.h>
#import "TTAccountDefine.h"



@interface TTAccountUserProfileTask : NSObject

/**
 *  获取用户信息
 *
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startGetUserInfoWithCompletion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;

+ (id<TTAccountSessionTask>)startGetUserInfoIgnoreDispatchWithCompletion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;


/**
 *  获取用户绑定的第三方平台连接信息
 *
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startGetConnectedAccountsWithCompletion:(void(^)(NSArray<TTAccountPlatformEntity *> *connects, NSError *error))completedBlock;


#pragma mark - 上传用户照片[deprecated]
/**
 *  @Wiki: https://wiki.bytedance.net/pages/viewpage.action?pageId=62424459
 */
/**
 *  上传图像
 *
 *  @param  photo           图片对象
 *  @param  progress        上传图片进度回调
 *  @param  completedBlock  上传图片完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startUploadUserPhoto:(UIImage *)photo
                                        progress:(NSProgress * __autoreleasing *)progress
                                      completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock __deprecated_msg("Method deprecated. Use `startUploadImage:progress:finishBlock:`");


/**
 *  @Wiki: https://wiki.bytedance.net/pages/viewpage.action?pageId=62424459
 */
/**
 *  上传图像
 *
 *  @param  image           图片对象
 *  @param  progress        上传图片进度回调
 *  @param  completedBlock  上传图片完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startUploadImage:(UIImage *)image
                                    progress:(NSProgress * __autoreleasing *)progress
                                  completion:(void(^)(TTAccountImageEntity *imageEntity, NSError *error))completedBlock;


/**
 *  上传封面背景图
 *
 *  @param  image           图片对象
 *  @param  progress        上传图片进度回调
 *  @param  completedBlock  上传图片完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startUploadBgImage:(UIImage *)image
                                      progress:(NSProgress * __autoreleasing *)progress
                                    completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;


/**
 *  检查用户名是否冲突，返回推荐的名字
 *
 *  @param  nameString      用户名字符串
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startCheckName:(NSString *)nameString
                                completion:(void(^)(NSString *availableName, NSError *error))completedBlock;


/**
 *  获取用户审核相关信息
 *
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startGetUserAuditInfoWithCompletion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;


+ (id<TTAccountSessionTask>)startGetUserAuditInfoIgnoreDispatchWithCompletion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;


#pragma mark - 更新用户Profile
/**
 *  update/v3接口
 *  {
 *      dict: {
 *          TTAccountUserNameKey: ***,
 *          TTAccountUserDescriptionKey: ***,
 *          TTAccountUserAvatarKey: ***,
 *      }
 *  }
 */
/**
 *  更新用户信息
 *
 *  @param  dict            用户信息字段，字段如上
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startUpdateUserProfileWithDict:(NSDictionary *)dict
                                                completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;

/**
 *  update_extra接口
 *  {
 *      dict: {
 *          TTAccountUserGenderKey: ***,
 *          TTAccountUserBirthdayKey: ***,
 *          TTAccountUserProvinceKey: ***,
 *          TTAccountUserCityKey: ***,
 *          TTAccountUserIndustryKey: ***,
 *      }
 *  }
 */
/**
 *  更新用户信息
 *
 *  @param  dict            用户信息字段，字段如上
 *  @param  completedBlock  完成回调
 *  @return HTTP请求任务
 */
+ (id<TTAccountSessionTask>)startUpdateUserExtraProfileWithDict:(NSDictionary *)dict
                                                     completion:(void(^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;
@end
