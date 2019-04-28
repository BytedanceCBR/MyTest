//
//  PreloadManager.h
//  Article
//
//  Created by 朱斌 on 16/8/10.
//
//

#import <Foundation/Foundation.h>
#import "Article.h"

extern void tt_ad_adSiteWebPreload(Article *article, UIView *listView);

@interface TTAdSiteWebPreloadManager : NSObject

@property (nonatomic, strong) NSMutableSet *preloadURLSet;

+ (instancetype)sharedManager;

- (void)adSiteWebPreload:(Article*)article listView:(UIView *)listView;

@end
