//
//  FRRouteHelper.m
//  Article
//
//  Created by ZhangLeonardo on 15/7/22.
//
//

#import "FRRouteHelper.h"
#import "TTRoute.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTURLUtils.h"
#import "TTStringHelper.h"
#import <TTBaseLib/TTBaseMacro.h>

@implementation FRRouteHelper

+ (void)openArticleForGID:(int64_t)gid
               groupFlags:(int64_t)groupFlags
                   itemID:(int64_t)itemID
                 aggrType:(int64_t)aggrType
{
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://detail?groupid=%lli&group_flags=%lli&item_id=%lli&aggr_type=%lli", gid, groupFlags, itemID, aggrType]];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

+ (void)openWebViewForURL:(NSString *)urlStr
{
    if (isEmptyString(urlStr)) {
        return;
    }
    NSURL * url = [TTURLUtils URLWithString:@"sslocal://webview" queryItems:@{@"url":urlStr}];
//    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://webview?url=%@&ttencoding=base64", [TTDeviceHelper encodingStrToBase64Str:urlStr]]];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

+ (void)openForumDetailByForumID:(int64_t)fid
                       enterFrom:(NSString *)enterFrom
                        threadID:(int64_t)threadID
                           dict:(NSDictionary *)dict
{
    NSString * urlStr = [NSString stringWithFormat:@"sslocal://forum?fid=%lli", fid];
    NSMutableDictionary * gdExtJson = [NSMutableDictionary dictionaryWithDictionary:dict];
    if (!isEmptyString(enterFrom)) {
        [gdExtJson setValue:enterFrom forKey:@"enter_from"];
    }
    if (threadID != 0) {
        [gdExtJson setValue:@(threadID) forKey:@"thread_id"];
    }
    if ([gdExtJson count] > 0) {
        NSString * gdExtJsonStr = [gdExtJson tt_JSONRepresentation];
        if (!isEmptyString(gdExtJsonStr)) {
            urlStr = [NSString stringWithFormat:@"%@&gd_ext_json=%@", urlStr, gdExtJsonStr];
        }
    }
    NSURL * url = [TTStringHelper URLWithURLString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:url];

}


+ (void)openForumDetailByForumID:(int64_t)fid
                       enterFrom:(NSString *)enterFrom
                        threadID:(int64_t)threadID
                           group:(int64_t)groupID
{
    NSDictionary * dict = nil;
    if (groupID > 0) {
        dict = @{@"group_id":@(groupID)};
    }
    [self openForumDetailByForumID:fid enterFrom:enterFrom threadID:threadID dict:dict];
}

+ (void)openThreadDetailByThreadID:(int64_t)tid
                           groupID:(int64_t)gid
                         enterFrom:(NSString *)enterFrom
{
    NSString * urlStr = [NSString stringWithFormat:@"sslocal://thread_detail?tid=%lli&show_forum=1", tid];
    NSMutableDictionary * gdExtJson = [NSMutableDictionary dictionaryWithCapacity:10];
    if (!isEmptyString(enterFrom)) {
        [gdExtJson setValue:enterFrom forKey:@"enter_from"];
    }
    if (gid != 0) {
        [gdExtJson setValue:@(gid) forKey:@"group_id"];
    }
    if ([gdExtJson count] > 0) {
        NSString * gdExtJsonStr = [gdExtJson tt_JSONRepresentation];
        if (!isEmptyString(gdExtJsonStr)) {
            urlStr = [NSString stringWithFormat:@"%@&gd_ext_json=%@", urlStr, gdExtJsonStr];
        }
    }
    NSURL * url = [TTStringHelper URLWithURLString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}


+ (void)openProfileForUserID:(int64_t)uid
{
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://profile?uid=%lli", uid]];
    [[TTRoute sharedRoute] openURLByPushViewController:url];

}

+ (void)openThreadDeleteWithTid:(int64_t)tid fid:(int64_t)fid userId:(int64_t)uid {
    NSString *urlStr = [NSString stringWithFormat:@"sslocal://thread_delete?tid=%lli&fid=%lli&uid=%lli", tid, fid, uid];
    NSURL *url = [TTStringHelper URLWithURLString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

+ (void)openConcernHomePageWithConcernID:(NSString * __nonnull)cid
                        enterShowTabName:(NSString * _Nullable)enterShowTabName
                           baseCondition:(NSDictionary * _Nullable)baseCondition
                            apiParameter:(NSString * _Nullable)apiParameter {
    NSString *urlString = [NSString stringWithFormat:@"sslocal://concern?cid=%@",cid];
    if (!isEmptyString(enterShowTabName)) {
        urlString = [urlString stringByAppendingFormat:@"&tab_sname=%@",enterShowTabName];
    }
    if (baseCondition.count > 0) {
        urlString = [urlString stringByAppendingFormat:@"&gd_ext_json=%@",[baseCondition tt_JSONRepresentation]];
    }
    if (!isEmptyString(apiParameter)) {
        urlString = [urlString stringByAppendingFormat:@"&api_param=%@",apiParameter];
    }
    NSURL *url = [TTURLUtils URLWithString:urlString];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

@end
