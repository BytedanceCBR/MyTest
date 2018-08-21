//
//  SSMyUserModel.m
//  Article
//
//  Created by Dianwei on 14-5-21.
//
//

#import "SSMyUserModel.h"
#import "TTAccountManager.h"



@implementation SSMyUserModel

- (void)dealloc
{
    self.phoneNumberString = nil;
    self.accounts = nil;
    self.email = nil;
}

- (instancetype)initWithAccountUser:(TTAccountUserEntity *)userEntity
{
    if (!userEntity || ![userEntity isKindOfClass:[TTAccountUserEntity class]]) {
        return nil;
    }
    
    if ((self = [super init])) {
        self.ID = [userEntity userIDString];
        self.name = userEntity.name;
        self.screen_name = userEntity.screenName;
        self.avatarURLString = userEntity.avatarURL;
        self.avatarLargeURLString = userEntity.avatarLargeURL;
        self.bgImageURLString = userEntity.bgImgURL;
        self.userDescription = userEntity.userDescription;
        self.gender = [userEntity.gender stringValue];
        self.birthday = userEntity.birthday;
        self.area = userEntity.area;
        self.phoneNumberString = userEntity.mobile;
        self.email = userEntity.email;
        
        self.media_id = [userEntity mediaIDString];
        
        self.showInfo = [TTAccountManager showInfo];
        self.verifiedReason = userEntity.verifiedReason;
        self.userAuthInfo = userEntity.userAuthInfo;
        
        self.shareURL = userEntity.shareURL;
        
        self.followingCount = userEntity.followingsCount;
        self.followerCount = userEntity.followersCount;
        self.momnetCount = userEntity.momentsCount;
        
        self.isBlocking = userEntity.isBlocking;
        self.isBlocked = userEntity.isBlocked;
        self.isFollowing = userEntity.isFollowing;
        self.isFollowed = userEntity.isFollowed;
        
        if([userEntity.connects count] > 0) {
            
            NSMutableArray *connects = [NSMutableArray arrayWithCapacity:[userEntity.connects count]];
            
            for (TTAccountPlatformEntity *connectedAccount in userEntity.connects) {
                
                TTThirdPartyAccountInfoBase *accountInfo = [AccountInfoFactory accountInfoWithConnectedPlatformAccount:connectedAccount];
                
                if (accountInfo) {
                    [connects addObject:accountInfo];
                }
            }
            
            self.connects = connects;
        }
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    if((self = [super initWithDictionary:dict])) {
        if([dict objectForKey:@"mobile"]) {
            self.phoneNumberString = [dict objectForKey:@"mobile"];
        }
        if ([dict objectForKey:@"email"]){
            self.email = [dict objectForKey:@"email"];
        }
    }
    return self;
}

- (void)updateWithDictionary:(NSDictionary *)dict
{
    [super updateWithDictionary:dict];
    
    if([dict objectForKey:@"media_id"]) {
        self.media_id = [dict objectForKey:@"media_id"];
    }
}

- (void)clear
{
    self.accounts = nil;
    self.phoneNumberString = nil;
    self.email = nil;
}

@end
