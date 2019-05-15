//
//  TTURLDomainHelper.m
//  Article
//
//  Created by Chen Hong on 2017/6/15.
//
//

#import "TTURLDomainHelper.h"

@interface TTURLDomainHelper ()
@property (nonatomic, copy) TTURLDomainFromTypeBlock domainFromTypeBlock;
@end

@implementation TTURLDomainHelper

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TTURLDomainHelper *instance;
    dispatch_once(&onceToken, ^{
        instance = [[TTURLDomainHelper alloc] init];
    });
    return instance;
}

- (void)setDomainFromTypeBlock:(TTURLDomainFromTypeBlock)block {
    _domainFromTypeBlock = block;
}

- (NSString *)domainFromType:(TTURLDomainType)type {
    if (_domainFromTypeBlock) {
        return _domainFromTypeBlock(type);
    }
    
    switch (type) {
        case TTURLDomainTypeNormal:
            return @"ib.snssdk.com";   //@"i"
            break;
            
        case TTURLDomainTypeSecurity:  //@"si"
            return @"security.snssdk.com";
            break;
            
        case TTURLDomainTypeSNS:     //@"isub"
            return @"isub.snssdk.com";
            break;
    
        case TTURLDomainTypeLog:     //@"log"
            return @"log.snssdk.com";
            break;

        case TTURLDomainTypeChannel: //@"ichannel"
            return @"ichannel.snssdk.com";
            break;

        case TTURLDomainTypeAppMonitor: //@"mon"
            return @"mon.snssdk.com";
            break;

        default:
            break;
    }
    
    return @"ib.snssdk.com";   //@"i"
}

@end
