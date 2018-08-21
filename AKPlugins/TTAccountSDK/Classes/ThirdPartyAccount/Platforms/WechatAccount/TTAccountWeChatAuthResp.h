//
//  TTAccountWeChatAuthResp.h
//  TTAccountSDK
//
//  Created by liuzuopeng on 05/07/2017.
//
//

#import "TTAccountAuthResponse.h"
#import <Foundation/Foundation.h>



NS_ASSUME_NONNULL_BEGIN

@interface TTAccountWeChatAuthResp : TTAccountAuthResponse

/** 微信平台授权成功后，返回的临时授权码 */
@property (nonatomic,   copy, nonnull) NSString *code;

/** 第三方平台回传的状态state */
@property (nonatomic,   copy, nullable) NSString *state;

@end

NS_ASSUME_NONNULL_END
