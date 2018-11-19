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

// https://wiki.bytedance.net/pages/viewpage.action?pageId=62439223
typedef enum : NSUInteger {
    TTContactsUploadSourceUnknow = 0,
    TTContactsUploadSourceGuide = 1,
    TTContactsUploadSourceGuideRedPacket = 2,
    TTContactsUploadSourceAddFriends = 3,
    TTContactsUploadSourceSilent = 4,
} TTContactsUploadSource;

@interface TTContactsNetworkManager : NSObject

/**
 * 上传通讯录
 * @param contacts
 * @param userActive 是否用户主动操作，还是后台上传
 * @param source 该通讯录上传动作的来源，写在"from"中,
 * @param completion
 */
+ (void)postContacts:(NSArray<TTABContact *> *)contacts
              source:(TTContactsUploadSource)source
          userActive:(BOOL)userActive
          completion:(void (^)(NSError *error, id jsonObj))completion;

@end
