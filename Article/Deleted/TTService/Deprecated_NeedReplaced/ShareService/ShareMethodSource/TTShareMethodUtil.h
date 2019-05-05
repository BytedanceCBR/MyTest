//
//  TTShareMethodUtil.h
//  Article
//
//  Created by 延晋 张 on 2017/1/25.
//
//

#import <Foundation/Foundation.h>
#import "DetailActionRequestManager.h"
#import <TTShareActivity.h>
#import "TTIndicatorView.h"

@class Article;
@class TTVVideoArticle;
@interface TTShareMethodUtil : NSObject

+ (BOOL)isQQFriendShare:(id<TTActivityContentItemProtocol>)contentItem;
+ (BOOL)isQQZoneShare:(id<TTActivityContentItemProtocol>)contentItem;
+ (BOOL)isWeChatShare:(id<TTActivityContentItemProtocol>)contentItem;
+ (BOOL)isWeChatTimeLineShare:(id<TTActivityContentItemProtocol>)contentItem;
//+ (BOOL)isWeiboShare:(id<TTActivityContentItemProtocol>)contentItem;
//+ (BOOL)isDingTalkShare:(id<TTActivityContentItemProtocol>)contentItem;
//+ (BOOL)isAliShare:(id<TTActivityContentItemProtocol>)contentItem;

#pragma mark - ShareLabel

+ (NSString *)labelNameForShareActivity:(id<TTActivityProtocol>)activity shareState:(BOOL)success;
+ (NSString *)labelNameForShareActivity:(id<TTActivityProtocol>)activity;

#pragma mark - RequestType

+ (DetailActionRequestType)requestTypeForShareActivityType:(id<TTActivityProtocol>)activity;


#pragma mark - 根据Article分享内容

+ (NSString *)weixinSharedImageURLForArticle:(Article *)article;
+ (UIImage *)weixinSharedImageForArticle:(Article *)article;
+ (UIImage *)weixinSharedImageForWendaShareImg:(NSDictionary *)wendaShareInfo;
+ (UIImage *)weixinSharedImageForVideoArticle:(TTVVideoArticle *)article;

#pragma mark - toast 展示在分享面板上
+ (void)showIndicatorViewInActivityPanelWindowWithTip:(NSString *)tipMsg andImage:(UIImage *)indicatorImage dismissHandler:(DismissHandler)handler;
@end
