//
//  AccountInfoFactory.m
//  Article
//
//  Created by Dianwei on 14-7-20.
//
//

#import "AccountInfoFactory.h"
//#import "SinaUserAccount.h"
//#import "RenrenUserAccount.h"
//#import "KaixinUserAccount.h"
//#import "TencentWBUserAccount.h"
//#import "QZoneUserAccount.h"
//#import "FacebookUserAccount.h"
//#import "TwitterUserAccount.h"
//#import "TianYiUserAccount.h"
#import "WeixinUserAccount.h"
//#import "HuoShanUserAccount.h"
//#import "DouYinUserAccount.h"



@implementation AccountInfoFactory

+ (TTThirdPartyAccountInfoBase *)accountInfoByType:(TTAccountAuthType)type
{
    NSString *className = nil;
    switch (type) {
//        case TTAccountAuthTypeSinaWeibo: {
//            className = NSStringFromClass([SinaUserAccount class]);
//        }
//            break;
//        case TTAccountAuthTypeRenRen: {
//            className = NSStringFromClass([RenrenUserAccount class]);
//        }
//            break;
//        case TTAccountAuthTypeKaixin: {
//            className = NSStringFromClass([KaixinUserAccount class]);
//        }
//            break;
//        case TTAccountAuthTypeTencentWB: {
//            className = NSStringFromClass([TencentWBUserAccount class]);
//        }
//            break;
//        case TTAccountAuthTypeTencentQQ: {
//            className = NSStringFromClass([QZoneUserAccount class]);
//        }
//            break;
//        case TTAccountAuthTypeFacebook: {
//            className = NSStringFromClass([FacebookUserAccount class]);
//        }
//            break;
//        case TTAccountAuthTypeTwitter: {
//            className = NSStringFromClass([TwitterUserAccount class]);
//        }
//            break;
        case TTAccountAuthTypeWeChat: {
            className = NSStringFromClass([WeixinUserAccount class]);
        }
            break;
//        case TTAccountAuthTypeTianYi: {
//            className = NSStringFromClass([TianYiUserAccount class]);
//        }
//            break;
//        case TTAccountAuthTypeHuoshan: {
//            className = NSStringFromClass([HuoShanUserAccount class]);
//        }
//            break;
//        case TTAccountAuthTypeDouyin: {
//            className = NSStringFromClass([DouYinUserAccount class]);
//        }
//            break;
        default:
            break;
    }
    
    TTThirdPartyAccountInfoBase *info = [[NSClassFromString(className) alloc] init];
    return info;
}

+ (TTThirdPartyAccountInfoBase *)accountInfoWithDictionary:(NSDictionary *)dict
{
    NSString *platformName = [dict objectForKey:@"platform"];
    TTAccountAuthType accountAuthType = TTAccountGetPlatformTypeByName(platformName);
    TTThirdPartyAccountInfoBase *accountInfo = [AccountInfoFactory accountInfoByType:accountAuthType];
    if (accountInfo) {
        accountInfo.screenName = [dict objectForKey:@"platform_screen_name"];
        accountInfo.profileImageURLString = [dict objectForKey:@"profile_image_url"];
        accountInfo.platformUid = [dict objectForKey:@"platform_uid"];
    }
    
    return accountInfo;
}

+ (TTThirdPartyAccountInfoBase *)accountInfoWithConnectedPlatformAccount:(TTAccountPlatformEntity *)connectedAccount
{
    NSString *platformName = connectedAccount.platform;
    TTAccountAuthType accountAuthType = TTAccountGetPlatformTypeByName(platformName);
    TTThirdPartyAccountInfoBase *accountInfo = [AccountInfoFactory accountInfoByType:accountAuthType];
    if (accountInfo) {
        accountInfo.screenName = connectedAccount.platformScreenName;
        accountInfo.profileImageURLString = connectedAccount.profileImageURL;
        accountInfo.platformUid = connectedAccount.platformUID;
        accountInfo.expiredIn = [connectedAccount.expiredIn doubleValue];
        accountInfo.accountStatus = TTThirdPartyAccountStatusBounded;
    }
    
    return accountInfo;
}

@end
