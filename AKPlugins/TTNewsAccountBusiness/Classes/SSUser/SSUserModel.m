//
//  SSUserModel.m
//  Article
//
//  Created by Dianwei on 14-5-21.
//
//

#import "SSUserModel.h"



@implementation SSUserRoleModel

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super init];
    if (self) {
        self.roleDisplayType = [[dict objectForKey:@"role_display_type"] integerValue];
        self.roleName = [dict objectForKey:@"role_name"];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if (self) {
        self.roleDisplayType = [aDecoder decodeIntegerForKey:@"role_display_type"];
        self.roleName = [aDecoder decodeObjectForKey:@"role_name"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInteger:_roleDisplayType forKey:@"role_display_type"];
    [aCoder encodeObject:_roleName forKey:@"role_name"];
}

@end

@implementation SSUserModel

- (instancetype)initWithDictionary:(NSDictionary *)dict
{
    self = [super initWithDictionary:dict];
    if(self)
    {
        if([dict objectForKey:@"is_friend"])
        {
            self.isFriend = [[dict objectForKey:@"is_friend"] boolValue];
        }
        
        if ([dict objectForKey:@"role"]) {
            self.role = [[dict objectForKey:@"role"] integerValue];
        }
        
        if ([dict objectForKey:@"user_role"]) {
            self.userRole = [[SSUserRoleModel alloc] initWithDictionary:[dict objectForKey:@"user_role"]];
        }
        
        if ([dict objectForKey:@"user_relation"]) {
            self.relation = [dict[@"user_relation"] integerValue];
        }
        if ([dict objectForKey:@"is_owner"]) {
            self.isOwner = [dict[@"is_owner"] boolValue];
        }
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if(self)
    {
        self.isFriend = [[aDecoder decodeObjectForKey:@"is_friend"] boolValue];
        self.role = [[aDecoder decodeObjectForKey:@"role"] integerValue];
        self.userRole = [aDecoder decodeObjectForKey:@"user_role"];
        self.relation = [[aDecoder decodeObjectForKey:@"user_relation"] integerValue];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:@(_isFriend) forKey:@"is_friend"];
    [aCoder encodeObject:@(_role) forKey:@"role"];
    [aCoder encodeObject:_userRole forKey:@"user_role"];
    [aCoder encodeObject:@(_relation) forKey:@"user_relation"];
}

+ (NSArray*)usersWithArray:(NSArray*)data
{
    NSMutableArray *result = [NSMutableArray arrayWithCapacity:data.count];
    for(NSDictionary *dict in data)
    {
        SSUserModel *model = [[SSUserModel alloc] initWithDictionary:dict];
        [result addObject:model];
    }
    
    return result;
}

@end
