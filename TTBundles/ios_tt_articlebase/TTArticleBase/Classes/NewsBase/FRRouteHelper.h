//
//  FRRouteHelper.h
//  Article
//
//  Created by ZhangLeonardo on 15/7/22.
//
//

#import <Foundation/Foundation.h>

@interface FRRouteHelper : NSObject

+ (void)openArticleForGID:(int64_t)gid
               groupFlags:(int64_t)groupFlags
                   itemID:(int64_t)itemID
                 aggrType:(int64_t)aggrType;

+ (void)openWebViewForURL:(NSString * _Nullable)url;


//------------------------------
//
//      话题列表页面
//
//------------------------------

/**
 *  打开话题列表页
 *
 *  @param fid       话题id，必须传
 *  @param enterFrom 来源，选传
 *  @param threadID  帖子id， 选传
 *  @param groupID   文章id，选传
 */
+ (void)openForumDetailByForumID:(int64_t)fid
                       enterFrom:(NSString * _Nullable)enterFrom
                        threadID:(int64_t)threadID
                           group:(int64_t)groupID;

+ (void)openForumDetailByForumID:(int64_t)fid
                       enterFrom:(NSString * _Nullable)enterFrom
                        threadID:(int64_t)threadID
                            dict:(NSDictionary * _Nullable)dict;



//------------------------------
//
//      帖子详情页面
//
//------------------------------

/**
 *  进入帖子详情页面
 *
 *  @param tid       帖子id（必须传）
 *  @param gid       gid（选传）
 *  @param enterFrom 来源（选传）
 */
+ (void)openThreadDetailByThreadID:(int64_t)tid
                           groupID:(int64_t)gid
                         enterFrom:(NSString * _Nullable)enterFrom;

//------------------------------
//
//      用户页面
//
//------------------------------
+ (void)openProfileForUserID:(int64_t)uid;

//------------------------------
//
//      管理员删帖页面
//
//------------------------------
+ (void)openThreadDeleteWithTid:(int64_t)tid fid:(int64_t)fid userId:(int64_t)uid;

//------------------------------
//
//      关心主页页面
//
//------------------------------
/**
 *  进入关心主页
 *
 *  @param cid              关心id
 *  @param enterShowTabName 展示置顶tab
 *  @param baseCondition    统计需要的dic
 *  @param apiParameter     请求参数拼接
 */
+ (void)openConcernHomePageWithConcernID:(NSString * __nonnull)cid
                        enterShowTabName:(NSString * _Nullable)enterShowTabName
                           baseCondition:(NSDictionary * _Nullable)baseCondition
                            apiParameter:(NSString * _Nullable)apiParameter;

@end
