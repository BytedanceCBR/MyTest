//
//  TTAppLogConfigResponseModel.h
//  Article
//
//  Created by chenjiesheng on 16/12/14.
//
//

#import "JSONModel.h"

@interface TTConfigModel : JSONModel

@property (nonatomic, copy)   NSString <Optional> *sendPolicy;
@property (nonatomic, strong) NSNumber<Optional> *sessionInterval;
@property (nonatomic, copy)   NSDictionary<Optional> *hpStatSamplingRatio;
@property (nonatomic, copy)   NSDictionary<Optional> *imageSamplingRatio;
@property (nonatomic, copy)   NSDictionary<Optional> *imageErrorReport;
@property (nonatomic, copy)   NSArray<Optional> *imageErrorCodes;
@property (nonatomic, copy)   NSArray<Optional> *dnsReportList;
@property (nonatomic, strong) NSNumber<Optional> *dnsReportInterval;
@property (nonatomic, copy)   NSDictionary<Optional> *apiReport;
@property (nonatomic, copy)   NSString <Optional> *bdLocKey;
@property (nonatomic, strong) NSNumber<Optional> *allowKeepAlive;
@property (nonatomic, strong) NSNumber<Optional> *allowPushService;
@property (nonatomic, copy)   NSArray<Optional> *allowPushList;
@property (nonatomic, copy)   NSArray<Optional> *fingerPrintCodes;
@property (nonatomic, copy)   NSString <Optional> *batchEventInterval;
@property (nonatomic, strong) NSNumber<Optional> *httpMonitorPort;

@end

@interface TTAppLogConfigResponseModel : JSONModel

@property (nonatomic, copy)   NSString <Optional> *magicTag;
@property (nonatomic, copy)   NSString <Optional> *installID;
@property (nonatomic, copy)   NSString <Optional> *deviceID;
@property (nonatomic, strong) NSNumber <Optional> *serverTime;
@property (nonatomic, strong) TTConfigModel <Optional> *config;
@end
