//
//  TTAppLogConfigResponseModel.m
//  Article
//
//  Created by chenjiesheng on 16/12/14.
//
//

#import "TTAppLogConfigResponseModel.h"

@implementation TTConfigModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                      @"send_policy":@"sendPolicy",
                                                      @"session_interval":@"sessionInterval",
                                                      @"hp_stat_sampling_ratio":@"hpStatSamplingRatio",
                                                      @"image_sampling_ratio":@"imageSamplingRatio",
                                                      @"image_error_report":@"imageErrorReport",
                                                          @"image_error_codes":@"imageErrorCodes",
                                                          @"dns_report_list":@"dnsReportList",
                                                          @"dns_report_interval":@"dnsReportInterval",
                                                          @"api_report":@"apiReport",
                                                          @"bd_loc_key":@"bdLocKey",
                                                          @"allow_keep_alive":@"allowKeepAlive",
                                                          @"allow_push_service":@"allowPushService",
                                                          @"allow_push_list":@"allowPushList",
                                                          @"fingerprint_codes":@"fingerPrintCodes",
                                                          @"batch_event_interval":@"batchEventInterval",
                                                          @"http_monitor_port":@"httpMonitorPort",
                                                       }];
}

@end

@implementation TTAppLogConfigResponseModel

+ (JSONKeyMapper *)keyMapper{
    return [[JSONKeyMapper alloc] initWithDictionary:@{
                                                      @"magic_tag":@"magicTag",
                                                      @"install_id":@"installID",
                                                      @"device_id":@"deviceID",
                                                      @"server_time":@"serverTime",
                                                      @"config":@"config",
                                                       }];
}
@end
