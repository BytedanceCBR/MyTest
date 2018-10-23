//
//  WDServiceHelper.m
//  Article
//
//  Created by xuzichao on 2016/11/15.
//
//

#import "WDServiceHelper.h"
#import "WDDefines.h"
#import <TTBaseLib/JSONAdditions.h>
#import "TTRoute.h"
#import "NSString+URLEncoding.h"
#import "TTStringHelper.h"
#import "TTNetworkManager.h"

@implementation WDServiceHelper

#pragma mark -- Route

+ (void)openProfileForUserID:(int64_t)uid
{
    
    // add by zjing 去掉个人主页跳转
    return;
    
    NSURL * url = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://profile?uid=%lli&refer=wenda", uid]];
    [[TTRoute sharedRoute] openURLByViewController:url userInfo:nil];
}

+ (void)openWendaListForQID:(NSString *)qID
                  gdExtJson:(NSDictionary *)gdExtJsonDict
                   apiParam:(NSDictionary *)apiParam
{
    NSMutableString * urlStr = [NSMutableString stringWithFormat:@"sslocal://wenda_list?qid=%@", qID];
    if ([gdExtJsonDict isKindOfClass:[NSDictionary class]] && [gdExtJsonDict count] > 0) {
        [urlStr appendFormat:@"&gd_ext_json=%@", [gdExtJsonDict tt_JSONRepresentation]];
    }
    if ([apiParam isKindOfClass:[NSDictionary class]] && [apiParam count] > 0) {
        [urlStr appendFormat:@"&api_param=%@", [apiParam tt_JSONRepresentation]];
    }
    NSURL *url = [TTStringHelper URLWithURLString:urlStr];
    [[TTRoute sharedRoute] openURLByViewController:url userInfo:nil];
}

+ (void)openWendaDetailForAID:(NSString *)aID
                    gdExtJson:(NSDictionary *)gdExtJsonDict
                     apiParam:(NSDictionary *)apiParam
{
    NSMutableString * urlStr = [NSMutableString stringWithFormat:@"sslocal://wenda_detail?ansid=%@", aID];
    if ([gdExtJsonDict isKindOfClass:[NSDictionary class]] && [gdExtJsonDict count] > 0) {
        [urlStr appendFormat:@"&gd_ext_json=%@", [gdExtJsonDict tt_JSONRepresentation]];
    }
    if ([apiParam isKindOfClass:[NSDictionary class]] && [apiParam count] > 0) {
        [urlStr appendFormat:@"&api_param=%@", [apiParam tt_JSONRepresentation]];
    }
    [[TTRoute sharedRoute] openURLByViewController:[TTStringHelper URLWithURLString:urlStr] userInfo:nil];
}

+ (void)openPostQuestionForTitle:(NSString *)title
                       gdExtJson:(NSDictionary *)gdExtJsonDict
                        apiParam:(NSDictionary *)apiParam
{
    NSMutableString * urlStr = [NSMutableString stringWithFormat:@"sslocal://wenda_question_post"];
    NSString *component = @"?";
    if (!isEmptyString(title)) {
        [urlStr appendFormat:@"%@title=%@", component, [title URLEncodedString]];
        component = @"&";
    }
    if ([gdExtJsonDict isKindOfClass:[NSDictionary class]] && [gdExtJsonDict count] > 0) {
        [urlStr appendFormat:@"%@gd_ext_json=%@", component, [gdExtJsonDict tt_JSONRepresentation]];
        component = @"&";
    }
    if ([apiParam isKindOfClass:[NSDictionary class]] && [apiParam count] > 0) {
        [urlStr appendFormat:@"%@api_param=%@", component, [apiParam tt_JSONRepresentation]];
    }
    [[TTRoute sharedRoute] openURLByViewController:[TTStringHelper URLWithURLString:urlStr] userInfo:nil];
}

+ (void)openPostAnswerForQID:(NSString *)qID
                   gdExtJson:(NSDictionary *)gdExtJsonDict
                    apiParam:(NSDictionary *)apiParam
{
    NSMutableString * urlStr = [NSMutableString stringWithFormat:@"sslocal://wenda_post?qid=%@", qID];
    if ([gdExtJsonDict isKindOfClass:[NSDictionary class]] && [gdExtJsonDict count] > 0) {
        [urlStr appendFormat:@"&gd_ext_json=%@", [gdExtJsonDict tt_JSONRepresentation]];
    }
    if ([apiParam isKindOfClass:[NSDictionary class]] && [apiParam count] > 0) {
        [urlStr appendFormat:@"&api_param=%@", [apiParam tt_JSONRepresentation]];
    }
    NSURL *url = [TTStringHelper URLWithURLString:urlStr];
    [[TTRoute sharedRoute] openURLByViewController:url userInfo:nil];
}

@end

