//
//  TTMonitorReporterResponse.m
//  Pods
//
//  Created by 苏瑞强 on 2017/7/20.
//
//

/*  返回示例
 {
 result =     {
 "debug_settings" =         {
 "should_upload_debugreal" = 0;
 };
 "is_crash" = 0;
 "magic_tag" = "ss_app_log";
 message = success;
 "server_time" = 1500544789;
 "stop_interval" = 3600;
 };
 "status_code" = 200;
 }

 */

#import "TTMonitorReporterResponse.h"

@implementation TTMonitorReporterResponse
 
- (instancetype)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        
        self.statusCode = [[dict valueForKey:@"status_code"] integerValue];
        NSDictionary * result = [dict valueForKey:@"result"];
        if (![result isKindOfClass:[NSDictionary class]]) {
            return nil;
        }
        NSDictionary * configs = [result valueForKey:@"configs"];
        if (configs && [configs isKindOfClass:[NSDictionary class]]) {
                NSDictionary * debugSettings = [configs valueForKey:@"debug_settings"];
                if (debugSettings && [debugSettings isKindOfClass:[NSDictionary class]]) {
                    if ([[debugSettings valueForKey:@"should_submit_debugreal"] integerValue]==1) {
                        self.uploadDebugrealCommands = [configs valueForKey:@"debug_settings"];
                    }
                }
                NSDictionary * uploadfilesSettings = [configs valueForKey:@"file_settings"];
                if (uploadfilesSettings && [uploadfilesSettings isKindOfClass:[NSDictionary class]]) {
                    if ([[uploadfilesSettings valueForKey:@"should_upload_file"] integerValue]==1) {
                        self.uploadFileCommands = [configs valueForKey:@"file_settings"];
                    }
                }
        }
        
        self.serverCrashed = [[result valueForKey:@"is_crash"] boolValue];
        self.message = [result valueForKey:@"message"];
    }
    return self;
}
@end
