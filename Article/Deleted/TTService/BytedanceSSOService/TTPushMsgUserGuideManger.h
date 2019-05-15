//
//  TTPushMsgUserGuideManger.h
//  Article
//
//  Created by zuopengliu on 26/11/2017.
//

#import <Foundation/Foundation.h>
#import "TTMessageCenterRouter.h"



NS_ASSUME_NONNULL_BEGIN

/**
 *  通过消息推送引导作品用户进火山or抖音
 */
@interface TTPushMsgUserGuideManger : NSObject
<
TTMessageRouteProtocol
>

+ (void)handlePushMsgGuide:(NSDictionary * _Nonnull)msgDict;

@end

NS_ASSUME_NONNULL_END
