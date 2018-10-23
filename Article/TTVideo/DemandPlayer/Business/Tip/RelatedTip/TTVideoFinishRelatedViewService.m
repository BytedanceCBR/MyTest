//
//  TTVideoFinishRelatedViewService.m
//  Article
//
//  Created by lishuangyang on 2017/10/17.
//

#import "TTVideoFinishRelatedViewService.h"
#import <TTNetworkManager/TTNetworkManager.h>

#define kSchemaDouyin @"snssdk1128"
#define kSchemaDuanzi @"snssdk51"
#define kSchemaXigua @"snssdk32"
#define kSchemaHuoshan @"snssdk1112"

@implementation TTVPlayerRelatedRequestSerializer

- (TTHttpRequest *)URLRequestWithURL:(NSString *)URL
                              params:(NSDictionary *)parameters
                              method:(NSString *)method
               constructingBodyBlock:(TTConstructingBodyBlock)bodyBlock
                        commonParams:(NSDictionary *)commonParam
{
    TTHttpRequest * request = [super URLRequestWithURL:URL params:parameters method:method constructingBodyBlock:bodyBlock commonParams:commonParam];
    
    [request setValue:@"application/json; encoding=utf-8" forHTTPHeaderField:@"Content-Type"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    if (parameters) {
        NSData * postDate = [NSJSONSerialization dataWithJSONObject:parameters options:NSJSONWritingPrettyPrinted error:nil];
        [request setHTTPBody:postDate];
    }
    return request;
}

@end


@implementation TTVideoFinishRelatedRecommondURLRequestInfo

@end

@interface TTVideoFinishRelatedViewService ()
@property (nonatomic, copy) NSString *parentRid;
@property (nonatomic,strong )fetchRelatedRecommondInfoCompletion fetchRelatedInfoCompletion;
@end

@implementation TTVideoFinishRelatedViewService

- (void)fetchRelatedRecommondInfoWithRequestInfo:(TTVideoFinishRelatedRecommondURLRequestInfo *)requestInfo completion:(fetchRelatedRecommondInfoCompletion)completion
{
    self.fetchRelatedInfoCompletion = completion;
    NSString *installed_pkg = [self getInstalledPKG];
    NSString *urlPre = [NSString stringWithFormat:@"%@?installed_pkg=%@",[self getRequestAPIPrefix],isEmptyString(installed_pkg) ? @"" : installed_pkg];
    
    NSMutableDictionary *parameters = [[NSMutableDictionary alloc] initWithCapacity:0];
    parameters[@"group_id"] = requestInfo.groupID;
    parameters[@"code_id"] = requestInfo.codeId;
    parameters[@"parent_rid"] = requestInfo.parentRID;
    parameters[@"page_type"] = requestInfo.pageType;
    parameters[@"style"] = requestInfo.style;
    parameters[@"site_id"] = requestInfo.siteID;
    @weakify(self);
    [[TTNetworkManager shareInstance] requestForJSONWithURL:urlPre params:parameters method:@"GET" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        @strongify(self);
        
        if (!self) {
            return;
        }
            
        if (completion) {
            completion(jsonObj, error);
        }
        
    }];
}

- (NSString *)getRequestAPIPrefix {
    
    return [NSString stringWithFormat:@"%@/2/related/open/v1/", [CommonURLSetting baseURL]];
    
}

- (BOOL)isDouyinAppInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://",kSchemaDouyin]]];
}

- (BOOL)isDuanziAppInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://",kSchemaDuanzi]]];
}

- (BOOL)isXiguaAppInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://",kSchemaXigua]]];
}

- (BOOL)isHuoshanAppInstalled
{
    return [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@://",kSchemaHuoshan]]];
}

- (BOOL)isAllInstalled
{
    return [self isHuoshanAppInstalled] &&
    [self isDouyinAppInstalled] &&
    [self isDuanziAppInstalled] &&
    [self isXiguaAppInstalled];
}

- (NSString *)getInstalledPKG{
    NSMutableString *installedPKG = [NSMutableString string];
    if ([self isHuoshanAppInstalled]) {
        [installedPKG appendString:[NSString stringWithFormat:@"&installed_pkg=%@",kSchemaHuoshan]];
    }
    if ([self isDouyinAppInstalled]) {
        [installedPKG appendString:[NSString stringWithFormat:@"&installed_pkg=%@",kSchemaDouyin]];
    }
    if ([self isDuanziAppInstalled]) {
        [installedPKG appendString:[NSString stringWithFormat:@"&installed_pkg=%@",kSchemaDuanzi]];
    }
    if ([self isXiguaAppInstalled]) {
        [installedPKG appendString:[NSString stringWithFormat:@"&installed_pkg=%@",kSchemaXigua]];
    }
    if (installedPKG.length > 2) {
        [installedPKG deleteCharactersInRange:NSMakeRange(0, 15)];
    }
    return [installedPKG copy];
}

- (void)postRelatedRecommondInfoWithPostInfo:(id)postInfo completion:(void (^)(id response,NSError *error))completion;
{
    @weakify(self);
    [[TTNetworkManager shareInstance] requestForJSONWithURL:[self getPostRecommondAPIPrex] params:postInfo method:@"POST" needCommonParams:YES requestSerializer:[TTVPlayerRelatedRequestSerializer class] responseSerializer:nil autoResume:YES callback:^(NSError *error, id jsonObj) {
        @strongify(self);
        if (!self) {
            return;
        }
        if (completion) {
            completion(jsonObj, error);
        }

    }];
}


- (void)requestDownloadUrl:(NSString *)url completion:(void (^)(id response,NSError *error))completion
{
    @weakify(self);
    [[TTNetworkManager shareInstance] requestForJSONWithURL:url params:nil method:@"GET" needCommonParams:YES requestSerializer:[TTDefaultHTTPRequestSerializer class] responseSerializer:nil autoResume:YES callback:^(NSError *error, id jsonObj) {
        @strongify(self);
        if (!self) {
            return;
        }
        if (completion) {
            completion(jsonObj, error);
        }
        
    }];
}


- (NSString *)getPostRecommondAPIPrex
{
    return  @"http://m.toutiao.com/log/event/";
}

@end
