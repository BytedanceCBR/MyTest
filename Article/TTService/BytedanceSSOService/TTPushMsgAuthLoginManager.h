//
//  TTPushMsgAuthLoginManager.h
//  Article
//
//  Created by zuopengliu on 26/11/2017.
//

#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

/**
 *  火山or抖音APP通过消息推送，引导其用户进入头条进行激活和互动
 */
@interface TTPushMsgAuthLoginManager : NSObject

+ (BOOL)handleOpenURL:(NSURL * _Nonnull)url;

@end

NS_ASSUME_NONNULL_END
