//
//  FHLynxManager.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

static NSString * kFHLynxUGCOperationChannel = @"lynx_test"; //UGC 运营位

@interface FHLynxManager : NSObject

+ (instancetype)sharedInstance;

- (NSData *)lynxDataForChannel:(NSString *)channel templateKey:(NSString *)templateKey version:(NSUInteger)version;

+ (NSString *)defaultJSFileName;

+ (NSString *)debugUrlStringConvert:(NSString *)url;

- (BOOL)checkChannelTemplateIsAvalable:(NSString *)channel templateKey:(NSString *)templateKey;

@end

NS_ASSUME_NONNULL_END
