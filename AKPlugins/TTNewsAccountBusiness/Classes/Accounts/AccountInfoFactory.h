//
//  AccountInfoFactory.h
//  Article
//
//  Created by Dianwei on 14-7-20.
//
//

#import <Foundation/Foundation.h>
#import <TTBaseMacro.h>
#import "TTThirdPartyAccountInfoBase.h"



@interface AccountInfoFactory : NSObject

+ (TTThirdPartyAccountInfoBase *)accountInfoByType:(TTAccountAuthType)type;

+ (TTThirdPartyAccountInfoBase *)accountInfoWithDictionary:(NSDictionary *)dict;

+ (TTThirdPartyAccountInfoBase *)accountInfoWithConnectedPlatformAccount:(TTAccountPlatformEntity *)connectedAccount;

@end
