//
//  ArticleWebViewToAppStoreManager.h
//  Article
//
//  Created by Huaqing Luo on 26/8/15.
//
//

#import <Foundation/Foundation.h>

@interface ArticleWebViewToAppStoreManager : NSObject

+ (instancetype)sharedManager;
- (void)refreshWithSettingsDict:(NSDictionary *)dict;
- (BOOL)isAllowedURLStr:(NSString *)urlStr;

+ (BOOL)isToAppStoreRequestURLStr:(NSString *)urlStr;

@end
