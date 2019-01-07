//
//  TTJSBAuthManager.m
//  Article
//
//  Created by muhuai on 2017/6/27.
//
//

#import "TTJSBAuthManager.h"
#import "TTURLDomainHelper.h"
#import <TTRexxar/TTRexxarEngine.h>
#import <TTRexxar/TTRJSBForwarding.h>
#import <TTNetworkManager.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>

NSString *const kTTRemoteInnerDomainsKey = @"kTTRemoteInnerDomainsKey";
@interface TTJSBAuthManager()
@property (nonatomic, strong) NSMutableDictionary *configData;
@property (nonatomic, strong) NSDictionary *publicJSBDict;
@property (nonatomic, strong) NSDictionary *publicEventDict;
@property (nonatomic, strong) NSArray<NSString *> *innerDomains;
//从settings下发的域名白名单
@property (nonatomic, strong) NSArray<NSString *> *remoteInnerDomains;
@end

@implementation TTJSBAuthManager
+ (instancetype)sharedManager {
    static TTJSBAuthManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[TTJSBAuthManager alloc] init];
    });
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.configData = [NSMutableDictionary dictionary];
        NSDictionary *plist = [[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"TTJSBAuthInfo" ofType:@"plist"]];
        
        self.publicJSBDict = [plist dictionaryValueForKey:@"bridge" defalutValue:nil];
        self.publicEventDict = [plist dictionaryValueForKey:@"event" defalutValue:nil];
        self.remoteInnerDomains = [[NSUserDefaults standardUserDefaults] objectForKey:kTTRemoteInnerDomainsKey];
        self.innerDomains = @[@"toutiao.com",      // 头条
                              @"toutiaopage.com",  // 头条
                              @"snssdk.com",       // 头条
                              @"neihanshequ.com",  // 内涵
                              @"youdianyisi.com",  // 内涵
                              @"huoshanzhibo.com", // 火山
                              @"huoshan.com",      //火山
                              @"wukong.com",        //悟空
                              @"zjurl.cn",           //汽车
                              @"m.quduzixun.com",    //爱看
                              @"m.haoduofangs.com",  //好多房
                              @"i.haoduofangs.com"]; //好多房
        
        [[TTRJSBForwarding sharedInstance] registeJSBAlias:@"TTRGallery.gallery" for:@"gallery"];
    }
    return self;
}


- (BOOL)engine:(id<TTRexxarEngine>)engine isAuthorizedJSB:(TTRJSBCommand *)command domain:(NSString *)domain {
    if ([self isInnerDomain:domain]) {
        return YES;
    }
    
    if ([self.publicJSBDict objectForKey:command.fullName]) {
        return YES;
    }
    
    if ([self.publicJSBDict objectForKey:command.origName]) {
        return YES;
    }
    
    JSAuthInfoModel *authInfoModel = [self.configData objectForKey:domain];
    
    if (!authInfoModel) {
        return NO;
    }
    
    if ([authInfoModel.callList containsObject:command.fullName]) {
        return YES;
    }
    
    if ([authInfoModel.callList containsObject:command.origName]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)engine:(id<TTRexxarEngine>)engine isAuthorizedEvent:(NSString *)eventName domain:(NSString *)domain {
    if ([self isInnerDomain:domain]) {
        return YES;
    }
    
    if ([self.publicEventDict objectForKey:eventName]) {
        return YES;
    }
    
    JSAuthInfoModel *authInfoModel = [self.configData objectForKey:domain];
    
    if (!authInfoModel) {
        return NO;
    }
    
    if ([authInfoModel.eventList containsObject:eventName]) {
        return YES;
    }
    
    return NO;
}

- (BOOL)engine:(id<TTRexxarEngine>)engine isAuthorizedMeta:(NSString *)meta domain:(NSString *)domain {
    if ([self isInnerDomain:domain]) {
        return YES;
    }
    
    JSAuthInfoModel *authInfoModel = [self.configData objectForKey:domain];
    
    if (!authInfoModel) {
        return NO;
    }
    
    if ([authInfoModel.infolist containsObject:meta]) {
        return YES;
    }
    
    return NO;
}

- (void)startGetAuthConfigWithPartnerClientKey:(NSString*)clientKey
                                 partnerDomain:(NSString*)domain
                                     secretKey:(NSString*)secretKey
                                   finishBlock:(void(^)(JSAuthInfoModel *infoModel))finishBlock
{
    if(isEmptyString(domain)) {
        if(finishBlock) {
            finishBlock(nil);
        }
        return;
    }
    
    if([_configData objectForKey:domain]) {
        if(finishBlock) {
            finishBlock([_configData objectForKey:domain]);
        }
        return;
    }
    NSMutableDictionary * getParam = [NSMutableDictionary dictionary];
    [getParam setValue:clientKey forKey:@"client_id"];
    [getParam setValue:domain forKey:@"partner_domain"];

    [[TTNetworkManager shareInstance] requestForJSONWithURL:[[[TTURLDomainHelper shareInstance] domainFromType:TTURLDomainTypeNormal] stringByAppendingString:@"/client_auth/js_sdk/config/v1/"] params:getParam method:@"GET" needCommonParams:NO callback:^(NSError *error, id jsonObj) {
        if (error) {
            if (finishBlock) {
                finishBlock(nil);
            }
            return;
        }
        
        NSDictionary *data = [jsonObj tt_dictionaryValueForKey:@"data"];
        JSAuthInfoModel *infoModel = [[JSAuthInfoModel alloc] init];
        infoModel.callList = [data arrayValueForKey:@"call" defaultValue:nil];
        infoModel.eventList = [data arrayValueForKey:@"event" defaultValue:nil];
        infoModel.infolist = [data arrayValueForKey:@"info" defaultValue:nil];

        [self.configData setValue:infoModel forKey:domain];
        if(finishBlock) {
            finishBlock(infoModel);
        }
        return;
    }];
}

- (BOOL)isInnerDomain:(NSString *)host {
    
    for(NSString *innerDomain in self.innerDomains) {
        if([host rangeOfString:[innerDomain lowercaseString]].location != NSNotFound) {
            return YES;
        }
    }
    
    for(NSString *innerDomain in self.remoteInnerDomains) {
        if([host rangeOfString:[innerDomain lowercaseString]].location != NSNotFound) {
            return YES;
        }
    }
   return NO;
}

- (void)updateInnerDomainsFromRemote:(NSArray<NSString *> *)domains {
    if (![domains isKindOfClass:[NSArray class]]) {
        return;
    }
    
    self.remoteInnerDomains = domains;
}

- (void)setRemoteInnerDomains:(NSArray<NSString *> *)remoteInnerDomains {
    if (remoteInnerDomains && ![remoteInnerDomains isKindOfClass:[NSArray class]]) {
        return;
    }
    
    _remoteInnerDomains = remoteInnerDomains;
    [[NSUserDefaults standardUserDefaults] setValue:_remoteInnerDomains forKey:kTTRemoteInnerDomainsKey];
}
@end
