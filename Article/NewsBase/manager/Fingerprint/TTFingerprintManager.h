//
//  TTFingerprintManager.h
//  Article
//
//  Created by fengyadong on 2017/10/29.
//

#import <Foundation/Foundation.h>

typedef void(^TTFingerprintFetchBlock)(NSString *fingerprint);

@interface TTFingerprintManager : NSObject

@property (nonatomic, copy, readonly) NSString *fingerprint;

+ (instancetype)sharedInstance;

- (void)startFetchFingerprintIfNeeded;

//===========================================设备指纹获取回调方法================================================
/**
 设备指纹获取完成的回调
 
 @param didFetchBlock 设备指纹接口完成回调，最多回调一次，没有超时时间。如果已经注册则立马回调，如果还没有则等接口请求解析完成回调。对fingerprint有依赖的接口可以在这里发送
 */
- (void)setDidFetchFingerprintBlock:(TTFingerprintFetchBlock)didFetchBlock;

@end
