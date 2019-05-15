//
//  TTVPlayerTokenManager.h
//  Article
//
//  Created by 戚宽 on 2018/8/7.
//

#import <Foundation/Foundation.h>

@interface TTVPlayerTokenManager : NSObject

+ (void)requestPlayTokenWithVideoID:(NSString *)videoID completion:(void (^)(NSError *error, NSString *authToken, NSString *bizToken))completion;

@end
