//
//  AWEVideoDetailManager.m
//  Pods
//
//  Created by 01 on 17/5/8.
//
//

#import "AWEVideoDetailManager.h"
#import "AWEVideoPlayNetworkManager.h"
#import "BTDMacros.h"
#import "TTModuleBridge.h"
#import "DetailActionRequestManager.h"
#import "FHURLSettings.h"
#import "CommonURLSetting.h"

@implementation AWEVideoDetailManager

+ (void)diggVideoItemWithID:(NSString *)groupID groupSource:(NSString *)groupSource completion:(AWEVideoDiggBlock)block
{
    NSString *url = [FHURLSettings shortVideoDiggUpURL];
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"group_id"] = groupID;
    params[@"group_source"] = groupSource;
    
    [self diggRequestWithParam:params withUrl:url completion:block];
}

+ (void)cancelDiggVideoItemWithID:(NSString *)groupID completion:(AWEVideoDiggBlock)block
{
    NSString *url = [FHURLSettings shortVideoCancelDiggURL];
    NSMutableDictionary *params = @{}.mutableCopy;
    params[@"group_id"] = groupID;
    [self diggRequestWithParam:params withUrl:url completion:block];
}

+ (void)diggRequestWithParam:(NSDictionary *)params withUrl:(NSString *)url completion:(AWEVideoDiggBlock)block
{
    [[AWEVideoPlayNetworkManager sharedInstance] requestJSONFromURL:url params:params method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        BOOL succeed = YES;
        
        if (error || [jsonObj[@"message"] isEqualToString:@"error"]) {
            succeed = NO;
        }
        
        if (block) {
            block(succeed);
        }
    }];
}


+ (void)startReportVideo:(NSString *)reportType
           userInputText:(NSString *)inputText
                 groupID:(NSString *)groupID
                 videoID:(NSString *)videoID
              completion:(AWEVideoDetailCommonBlock)block {
    
    if (!groupID || !reportType || !videoID) {
        return;
    }
    
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithCapacity:10];
    [params setValue:groupID forKey:@"group_id"];
    [params setValue:videoID forKey:@"video_id"];
    [params setValue:reportType forKey:@"report_type"];
    [params setValue:inputText forKey:@"report_content"];
    [params setValue:@1 forKey:@"source"];
    
    NSString * url = [CommonURLSetting reportVideoURLString];
    
    [[AWEVideoPlayNetworkManager sharedInstance] requestJSONFromURL:url params:params method:@"POST" needCommonParams:YES callback:^(NSError *error, id jsonObj) {
        !block ?: block(jsonObj, error);
    }];
}

@end
