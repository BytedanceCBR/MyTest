//
//  TTAccountAuthWeChat.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 2/9/17.
//  Copyright © 2017 com.bytedance.news. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TTAccountAuthProtocol.h"
#import "TTAccountWeChatAuthResp.h"



@interface TTAccountAuthWeChat : NSObject
<
TTAccountAuthProtocol
>

/** 是否是新平台 */
@property (nonatomic, assign, getter=isNewPlatform) BOOL newPlatform;

@end
