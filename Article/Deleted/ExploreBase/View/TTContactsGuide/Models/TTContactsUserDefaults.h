//
//  TTContactsUserDefaults.h
//  Article
//
//  Created by Zuopeng Liu on 7/24/16.
//
//

#import <Foundation/Foundation.h>
#import "TTABAuthorizationManager.h"



/**
 * Text keys of dialog style
 */
extern NSString * const TTContactsDialogStyleMajorTextKey;
extern NSString * const TTContactsDialogStyleMinorTextKey;
extern NSString * const TTContactsDialogStyleButtonTextKey;
extern NSString * const TTContactsDialogStyleImageURLKey;
extern NSString * const TTContactsDialogStyleNightImageURLKey;
extern NSString * const TTContactsDialogStyleImageNameKey;
extern NSString * const TTContactsDialogStylePrivacyTextKey;

extern NSString * const kTTFollowCategoryUploadedContactsCardStatusChangeNotification;
/**
 *  @Wiki: https://wiki.bytedance.com/pages/viewpage.action?pageId=62439223
 *         https://wiki.bytedance.com/pages/viewpage.action?pageId=52048414
 *
 */
@interface TTContactsUserDefaults : NSObject

/**
 *  默认值是YES，请求服务端接口判断是否上传过通讯录，然后保存下来
 *
 *  @return 是否成功上传过“通讯录”
 */
+ (BOOL)hasUploadedContacts;

/**
 *  通讯录成功上传后或者请求服务端接口判断为已上传过，设置为YES
 *
 *  @param flag 是否成功上传的标记
 */
+ (void)setHasUploadedContacts:(BOOL)flag;

/**
 * 从setting接口解析通讯录弹窗配置信息
 */
+ (void)parseContactConfigsFromSettings:(NSDictionary *)settings;

/**
 * 获取最近一次弹出通讯录弹窗的时间戳，不区分类型
 * @return
 */
+ (NSTimeInterval)contactsGuidePresentTimestamp;

/**
 * 记录最近一次弹出通讯录弹窗的时间，不区分类型
 * @param timestamp 时间戳
 */
+ (void)setContactsGuidePresentTimestamp:(NSTimeInterval)timestamp;

/**
 * 获取最近一次检查服务端接口请求时间
 * @return
 */
+ (NSTimeInterval)contactsGuideCheckTimestamp;

/**
 * 记录最近一次检查服务端接口的时间
 * @param timestamp 时间戳
 */
+ (void)setContactsGuideCheckTimestamp:(NSTimeInterval)timestamp;

/**
 * 通讯录弹窗文案，若从服务端获取到新的文档并且图片下载成功则使用新的文案，否则弹窗使用默认文案
 */
+ (NSDictionary *)contactDialogTexts;

/**
 * 完成用户通讯录上传，记录状态
 */
+ (void)setUserCompleteUploadContacts;

/**
 * 是否需要在关注频道展现上传通讯录按钮
 * @return
 */
+ (BOOL)needShowUploadContactsInFollowCategory;

/**
 * 用户关闭了关注频道的上传通讯录按钮，记录状态
 */
+ (void)userCloseUploadContactsInFollowCategory;

/**
 * 从setting接口解析通讯录弹窗配置信息
 */
+ (void)parseContactRedPacketConfigurationsFromSettings:(NSDictionary *)settings;

/**
 * 通讯录红包配置文案
 * @return
 */
+ (NSDictionary *)dictionaryOfContactsRedPacketContents;

/**
 * 通讯录红包授权发起时间
 * @return
 */
+ (NSTimeInterval)contactsAuthorizationTimestamp;
+ (void)setContactsAuthorizationTimestamp:(NSTimeInterval)timestamp;

@end
