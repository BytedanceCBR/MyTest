//
//  WDAccountService.h
//  TTWenda
//
//  Created by 延晋 张 on 2017/10/29.
//

#import <Foundation/Foundation.h>
#import <TTAccountSDK/TTAccount+Multicast.h>

@protocol TTAccountMulticastProtocol;

@interface WDAccountService : NSObject <TTAccountMulticastProtocol>

@end
