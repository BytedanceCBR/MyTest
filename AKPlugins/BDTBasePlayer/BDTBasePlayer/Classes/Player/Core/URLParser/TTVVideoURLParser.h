//
//  TTVVideoURLParser.h
//  Article
//
//  Created by 潘祥
//
//

#import <Foundation/Foundation.h>
#import "TTVPlayerControllerState.h"

//https://wiki.bytedance.net/pages/viewpage.action?pageId=55939299

@interface TTVVideoURLParser : NSObject

+ (NSString *)urlWithVideoID:(NSString *)videoID categoryID:(NSString *)categoryID itemId:(NSString *)itemId adID:(NSString *)adID sp:(TTVPlayerSP)sp base:(NSDictionary *)base;

@end
