//
//  TTContactsNetworkManager.h
//  Article
//
//  Created by Zuopeng Liu on 7/26/16.
//
//

#import <Foundation/Foundation.h>
#import "TTABContact.h"


extern NSString * const kTTUploadContactsTimestampKey; // 记录上传时间
extern const TTContactProperty kTTContactsOfPropertiesV2;

@interface TTContactsNetworkManager : NSObject

/**
 * 检查是否上传过通讯录
 * @param completion
 */
+ (void)requestHasUploadedContactsWithCompletion:(void (^)(NSError *error, BOOL hasPostedContacts))completion;

/**
 * 上传通讯录
 * @param contacts
 * @param userActive 是否用户主动操作，还是后台上传
 * @param completion
 */
+ (void)postContacts:(NSArray<TTABContact *> *)contacts userActive:(BOOL)userActive completion:(void (^)(NSError *error, id jsonObj))completion;

@end
