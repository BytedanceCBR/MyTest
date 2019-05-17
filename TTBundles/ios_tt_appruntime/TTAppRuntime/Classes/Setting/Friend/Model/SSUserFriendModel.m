//
//  SSUserFriendModel.m
//  Article
//
//  Created by Dianwei on 14-7-20.
//
//

#import "SSUserFriendModel.h"

@implementation SSUserFriendModel
- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if(self)
    {
        self.isFollowed = [[dict objectForKey:@"is_followed"] boolValue];
        self.isFollowing = [[dict objectForKey:@"is_following"] boolValue];
        self.isNew = [[dict objectForKey:@"is_newer"] boolValue];
        self.displayInfo = [dict objectForKey:@"display_info"];
        self.verifiedAgency = [dict objectForKey:@"verified_agency"];
        self.verifiedContent = [dict objectForKey:@"verified_content"];
     }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.isFollowed = [[aDecoder decodeObjectForKey:@"is_followed"] boolValue];
        self.isFollowing = [[aDecoder decodeObjectForKey:@"is_following"] boolValue];
        self.isNew = [[aDecoder decodeObjectForKey:@"is_newer"] boolValue];
        self.displayInfo = [aDecoder decodeObjectForKey:@"display_info"];
        self.verifiedAgency = [aDecoder decodeObjectForKey:@"verified_agency"];
        self.verifiedContent = [aDecoder decodeObjectForKey:@"verified_content"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:@(_isNew) forKey:@"is_newer"];
    [aCoder encodeObject:_displayInfo forKey:@"display_info"];
    [aCoder encodeObject:_verifiedAgency forKey:@"verified_agency"];
    [aCoder encodeObject:_verifiedContent forKey:@"verified_content"];
}


@end
