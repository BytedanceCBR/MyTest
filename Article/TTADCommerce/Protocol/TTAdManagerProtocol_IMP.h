//
//  TTAdManagerProtocolIMP.h
//  Article
//
//  Created by yin on 2017/6/28.
//
//

#import <Foundation/Foundation.h>
#import "TTAdManagerProtocol.h"
#import <TTServiceKit/TTServiceCenter.h>

@interface TTAdManagerProtocol_IMP : NSObject<TTAdManagerProtocol, TTService>

+ (id)sharedInstance;


@end
