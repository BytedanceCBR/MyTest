//
//  TTEditUserProfileViewModel+Network.h
//  Article
//
//  Created by liuzuopeng on 8/25/16.
//
//

#import "TTEditUserProfileViewModel.h"



/**
 *  账号合并，长度描述
 *  @Wiki: https://wiki.bytedance.com/pages/viewpage.action?pageId=59712405
 */
/**
 *  该模块主要是针对编辑PGC用户信息的网络处理 [OLD: ERROR}
 *
 *  现已更新所有的用户信息更新都走新的接口，流程如下：
 *      1. 图片的信息更新分两步（先上传图片得到uri（接口：uploadUserPhoto），然后上传uri得到成功后的uri（接口：uploadUserProfileInfo））
 *      2. 其他信息更新直接用接口uploadUserProfileInfo
 */
@interface TTEditUserProfileViewModel (Network)
/**
 *  上传图片，仅仅返回URI
 *
 *  @param image      图片
 *  @param startBlock 发送网络前回调
 *  @param completion 完成回调
 */
- (void)uploadUserPhoto:(UIImage *)image
             startBlock:(void (^)())aCallback
             completion:(void (^)(NSString *imageURIString, NSError *error))completion;

/**
 *  上传其他信息
 *
 *  @param params     上传文本信息
 *  @param startBlock 发送网络前回调
 *  @param completion 完成回调
 */
- (void)uploadUserProfileInfo:(NSDictionary *)params
                   startBlock:(void (^)())aCallback
                   completion:(void (^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;

/**
 *  上传所有信息，从editableAuditInfo中获取
 *
 *  @param startBlock 发送网络前回调
 *  @param completion 完成回调
 */
- (void)uploadAllUserProfileInfoWithStartBlock:(void (^)())aCallback
                                    completion:(void (^)(TTAccountUserEntity *userEntity, NSError *error))completedBlock;
@end
