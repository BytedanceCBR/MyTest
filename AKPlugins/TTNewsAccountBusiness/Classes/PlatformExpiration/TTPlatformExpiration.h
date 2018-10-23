//
//  TTPlatformExpiration.h
//  Article
//
//  Created by 刘廷勇 on 16/1/26.
//
//

#import <Foundation/Foundation.h>



@interface TTPlatformExpiration : NSObject

// 微博token是否过期,默认没有过期,只有绑定了微博的情况下，这两个变量才有用。
@property (nonatomic, assign, getter=isWeiboExpired) BOOL weiboExpired;

// 需求是微博过期只弹一次提示框，如果已经弹过，则等待下次弹框， 默认弹框
@property (nonatomic, assign, getter=hasAlertWeiboExpired) BOOL alertWeiboExpired;

+ (instancetype)sharedInstance;

- (void)platformsExpired:(NSArray *)platforms error:(NSError *)error;

@end
