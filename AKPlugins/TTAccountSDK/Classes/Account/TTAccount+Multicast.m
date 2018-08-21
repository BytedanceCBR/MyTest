//
//  TTAccount+Multicast.m
//  TTAccountSDK
//
//  Created by liuzuopeng on 4/25/17.
//
//

#import "TTAccount+Multicast.h"



@implementation TTAccount (Multicast)

+ (void)addMulticastDelegate:(NSObject<TTAccountMulticastProtocol> *)delegate
{
    [[TTAccountMulticast sharedInstance] registerDelegate:delegate];
}

+ (void)removeMulticastDelegate:(NSObject<TTAccountMulticastProtocol> *)delegate
{
    [[TTAccountMulticast sharedInstance] unregisterDelegate:delegate];
}

@end

