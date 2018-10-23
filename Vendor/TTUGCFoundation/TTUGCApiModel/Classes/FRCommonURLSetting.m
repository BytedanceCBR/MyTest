//
//  FRCommonURLSetting.m
//  Article
//
//  Created by 王霖 on 16/1/13.
//
//

#import "FRCommonURLSetting.h"
#import "TTURLDomainHelper.h"

@implementation FRCommonURLSetting

+ (NSString *)ugcCommentRepostDetailURL{    
    return [NSString stringWithFormat:@"%@/ugc/comment/repost_detail/v2/info/",[self baseURL]];
}

+ (NSString *)ugcThreadDetailV3InfoURL
{
    return [NSString stringWithFormat:@"%@/ugc/thread/detail/v3/info/",[self baseURL]];
}

+ (NSString *)uploadImageURL {
    return [NSString stringWithFormat:@"%@/ttdiscuss/v1/upload/image/", [FRCommonURLSetting baseURL]];
}

+ (NSString *)baseURL {
    return [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
}

@end
