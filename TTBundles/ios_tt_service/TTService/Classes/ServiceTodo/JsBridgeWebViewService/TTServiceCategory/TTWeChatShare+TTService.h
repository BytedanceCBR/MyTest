//
//  TTWeChatShare+TTService.h
//  News
//
//  Created by ShySun on 2018/2/4.
//

#import "TTWeChatShare.h"

@protocol TTWeChatShareTTServiceDelegate<NSObject>
/**
 *  旧接口微信分享回调
 *  @param weChatShare TTWeChatShare实例
 *  @param error 分享错误
 *  @param customCallbackUserInfo 用户自定义的分享回调信息
 */
- (void)weChatShare:(TTWeChatShare *)weChatShare oldSharedWithError:(NSError *)error customCallbackUserInfo:(NSDictionary *)customCallbackUserInfo;

@end


@interface TTWeChatShare (TTService)

@property (nonatomic, weak) id<TTWeChatShareTTServiceDelegate> ttServiceDelegate;
@end
