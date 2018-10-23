//
//  TTAccountLoginDefine.h
//  TTAccountLogin
//
//  Created by liuzuopeng on 26/05/2017.
//
//

#ifndef TTAccountLoginDefine_h
#define TTAccountLoginDefine_h

#import <Foundation/Foundation.h>



typedef
NS_OPTIONS(NSUInteger, TTAccountLoginPlatformType) {
    TTAccountLoginPlatformTypeEmail     = 1 << 0,
    TTAccountLoginPlatformTypePhone     = 1 << 1,
    TTAccountLoginPlatformTypeWeChat    = 1 << 2,
    TTAccountLoginPlatformTypeWeChatSNS = 1 << 3,
    TTAccountLoginPlatformTypeQZone     = 1 << 4,
    TTAccountLoginPlatformTypeQQWeibo   = 1 << 5,
    TTAccountLoginPlatformTypeSinaWeibo = 1 << 6,
    TTAccountLoginPlatformTypeRenRen    = 1 << 7,
    TTAccountLoginPlatformTypeTianYi    = 1 << 8,
    TTAccountLoginPlatformTypeHuoshan   = 1 << 9,
    TTAccountLoginPlatformTypeDouyin    = 1 << 10,
    
    TTAccountLoginPlatformTypeInHouseOnly = TTAccountLoginPlatformTypePhone,
    TTAccountLoginPlatformTypeAll       = NSUIntegerMax,
};

#define kTTAccountLoginErrorDisplayMessageKey @"message"



#endif /* TTAccountLoginDefine_h */
