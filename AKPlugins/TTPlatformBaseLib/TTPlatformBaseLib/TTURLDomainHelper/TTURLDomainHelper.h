//
//  TTURLDomainHelper.h
//  Article
//
//  Created by Chen Hong on 2017/6/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TTURLDomainType) {
    TTURLDomainTypeNormal,  //@"i"
    TTURLDomainTypeSecurity,  //@"si"
    TTURLDomainTypeSNS,     //@"isub"
    TTURLDomainTypeLog,     //@"log"
    TTURLDomainTypeChannel, //@"ichannel"
    TTURLDomainTypeAppMonitor, //@"mon"
};

typedef NSString *(^TTURLDomainFromTypeBlock)(TTURLDomainType);

@interface TTURLDomainHelper : NSObject

+ (instancetype)shareInstance;

- (void)setDomainFromTypeBlock:(TTURLDomainFromTypeBlock)block;

- (NSString *)domainFromType:(TTURLDomainType)type;

@end
