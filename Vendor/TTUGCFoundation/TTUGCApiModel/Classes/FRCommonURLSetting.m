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
    return [NSString stringWithFormat:@"%@/ugc/comment/repost_detail/v3/info/", [self baseURL]];
}

+ (NSString *)ugcThreadDetailV3InfoURL
{
    return [NSString stringWithFormat:@"%@/ugc/thread/detail/v3/info/",[self baseURL]];
}

+ (NSString *)uploadImageURL {

    return [NSString stringWithFormat:@"%@/ugc/publish/image/v1/upload/", [FRCommonURLSetting baseURL]];
}

+ (NSString *)uploadWithUrlOfImageURL {
    return [NSString stringWithFormat:@"%@/ugc/publish/image/v1/upload_url/", [FRCommonURLSetting baseURL]];
}

+ (NSString *)actionCountInfoURL {
    return [NSString stringWithFormat:@"%@/ugc/action/count/info/", [FRCommonURLSetting baseURL]];
}

+ (NSString *)baseURL {
    return [[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal];
}

+ (NSString *)hotBoardUrl {
    return [NSString stringWithFormat:@"%@/api/feed/hot_board/v1/", [FRCommonURLSetting baseURL]];
}

+ (NSString *)hotBoardClientImprUrl {
    return [NSString stringWithFormat:@"%@/client_impr/impr_report/v1/", [FRCommonURLSetting baseURL]];
}


@end
