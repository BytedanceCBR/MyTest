//
//  FHLynxManager.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/22.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHLynxManager : NSObject

+ (instancetype)sharedInstance;

- (NSData *)lynxDataForChannel:(NSString *)channel templateKey:(NSString *)templateKey version:(NSUInteger)version;

+ (NSString *)defaultJSFileName;

@end

NS_ASSUME_NONNULL_END
