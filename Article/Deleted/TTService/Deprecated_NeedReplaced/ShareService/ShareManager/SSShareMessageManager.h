//
//  SSShareMessageManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-9-22.
//
//

#import <Foundation/Foundation.h>
#import "TTActivityShareManager.h"
#import "TTGroupModel.h"

#define kShareMessageFinishedNotification @"kShareMessageFinishedNotification"


@interface SSShareMessageManager : NSObject

+ (id)shareManager;
- (void)shareMessageWithGroupModel:(TTGroupModel *)groupModel shareText:(NSString *)text platformKey:(NSString *)platform adID:(NSString *)adID sourceType:(TTShareSourceObjectType)source;
- (void)shareMessageWithGroupModel:(TTGroupModel *)groupModel shareText:(NSString *)text platformKey:(NSString *)platform uniqueId:(NSString *)uniqueId adID:(NSString *)adID sourceType:(TTShareSourceObjectType)source platform:(TTSharePlatformType)NType shareUrl:(NSString *)shareUrl shareImageUrl:(NSString *)shareImageUrl;

@end
