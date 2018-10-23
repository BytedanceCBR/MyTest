//
//  TTGroupModel.m
//  Article
//
//  Created by SunJiangting on 15/6/29.
//
//

#import "TTGroupModel.h"
#import "TTURLUtils.h"

@interface TTGroupModel ()

@property(nonatomic, copy) NSString *itemID;
@property(nonatomic, copy) NSString *groupID;
@property(nonatomic, copy) NSString *impressionID;
@property(nonatomic, assign) NSInteger aggrType;
@property(nonatomic, assign) NSInteger style;       // 展示样式
@property(nonatomic, assign) NSInteger subStyle;

@end
@implementation TTGroupModel

- (instancetype)initWithGroupID:(NSString *)groupID
{
    return [self initWithGroupID:groupID itemID:nil impressionID:nil aggrType:0];
}

- (instancetype)initWithGroupID:(NSString *)groupID itemID:(NSString *)itemID impressionID:(NSString *)impressionID aggrType:(NSInteger)aggrType {
    self = [super init];
    if (self) {
        [self refreshGroupID:groupID itemID:itemID impressionID:impressionID aggrType:aggrType];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        self.groupID = [aDecoder decodeObjectForKey:@"groupID"];
        self.itemID = [aDecoder decodeObjectForKey:@"itemID"];
        self.aggrType = [aDecoder decodeIntegerForKey:@"aggrType"];
        self.impressionID = [aDecoder decodeObjectForKey:@"impressionID"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.groupID forKey:@"groupID"];
    [aCoder encodeObject:self.itemID forKey:@"itemID"];
    [aCoder encodeInteger:self.aggrType forKey:@"aggrType"];
    [aCoder encodeObject:self.impressionID forKey:@"impressionID"];
}

- (void)refreshGroupID:(NSString *)groupID itemID:(NSString *)itemID impressionID:(NSString *)impressionID aggrType:(NSInteger)aggrType
{
    if (groupID) {
        self.groupID = [NSString stringWithFormat:@"%@", groupID];
    }
    if (itemID) {
        self.itemID = [NSString stringWithFormat:@"%@", itemID];
    }
    if (impressionID) {
        self.impressionID = [NSString stringWithFormat:@"%@", impressionID];
    }
    self.aggrType = aggrType;
}

- (NSString *)impressionDescription {
    if (!self.groupID) {
        return nil;
    }
    NSMutableString *string = [NSMutableString stringWithCapacity:30];
    [string appendString:self.groupID];
    if (self.itemID) {
        [string appendFormat:@"|%@|%lld", self.itemID, (long long)self.aggrType];
    }
    return string;
}

- (NSString *)replyImpressionDescription {
    if (!self.groupID) {
        return nil;
    }
    NSMutableString *string = [NSMutableString stringWithCapacity:30];
    [string appendString:self.groupID];
    if (self.itemID) {
        [string appendFormat:@"||%@||%lld", self.itemID, (long long)self.aggrType];
    }else
    {
        [string appendFormat:@"||%@||%lld", self.groupID, (long long)self.aggrType];
    }
    return string;
}

- (NSString *)debugDescription {
    NSMutableString *debugDesc = [[NSMutableString alloc] initWithFormat:@"<%@ : %p", NSStringFromClass([self class]), self];
    [debugDesc appendFormat:@"groupID : %@", self.groupID];
    [debugDesc appendFormat:@"itemID  : %@", self.itemID];
    [debugDesc appendFormat:@"aggrType: %ld", self.aggrType];
    [debugDesc appendFormat:@"impressionID: %@", self.impressionID];
    [debugDesc appendString:@">"];
    return debugDesc;
}

@end
