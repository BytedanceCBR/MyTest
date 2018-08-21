//
//  TTAppLinkManager.h
//  Article
//
//  Created by muhuai on 16/7/21.
//
//

#import <Foundation/Foundation.h>

extern NSString *const kAppLinkHost;
extern NSString *const kAppLinkBackFlow;
extern NSString *const kAppLinkAdSourceTag;
extern NSString *const kAppLinkChannel;
extern NSString *const kAppLinkBackURLPlaceHolder;

@interface TTAppLinkManager : NSObject

+ (instancetype)sharedInstance;

//判断scheme是否在白名单中
- (BOOL)containsScheme:(NSString *)scheme;

//制作返回按钮
+ (NSString *)escapesBackURL:(NSString *)sourceTag value:(NSString *)value extraDic:(NSDictionary *)extraDic;

//applink回流判断
- (BOOL)handOpenURL:(NSURL *)url;
@end

@interface TTAppLinkManager (AD)

//只处理 淘宝 🐶东 和 外部可以打开的openURL, 其他情况返回NO;
+ (BOOL)dealWithWebURL:(NSString *)webURLStr openURL:(NSString *)openURLStr sourceTag:(NSString *)sourceTag value:(NSString *)value extraDic:(NSDictionary *)extraDic;

@end
