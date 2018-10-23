//
//  TTAvatarDecoratorManager.h
//  TTAvatar
//
//  Created by lipeilun on 2018/1/3.
//

#import <Foundation/Foundation.h>

typedef void (^TTAvatarDecoratorCompletionBlock)(UIImage *img);

@interface TTAvatarDecoratorManager : NSObject

+ (TTAvatarDecoratorManager *)sharedManager;

- (void)setupDecoratorWithUrl:(NSString *)urlStr nightMode:(BOOL)enableNightMode completion:(TTAvatarDecoratorCompletionBlock)block;

- (void)setupDecoratorWithUserID:(NSString *)uid nightMode:(BOOL)enableNightMode completion:(TTAvatarDecoratorCompletionBlock)block;

@end
