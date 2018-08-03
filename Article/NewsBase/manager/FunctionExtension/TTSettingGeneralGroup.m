//
//  TTSettingGeneralGroup.m
//  Article
//
//  Created by Dianwei on 14-9-26.
//
//

#import "TTSettingGeneralGroup.h"
#import "TTSettingMineTabEntry.h"

@implementation TTSettingGeneralGroup

- (instancetype)init {
    if (self = [super init]) {
        _key = nil;
        _items = [NSMutableArray array];
        _shouldBeDisplayed = NO;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.key = [aDecoder decodeObjectForKey:@"key"];
        self.items = [aDecoder decodeObjectForKey:@"items"];
        self.shouldBeDisplayed = [aDecoder decodeObjectForKey:@"should_be_displayed"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.key forKey:@"key"];
    [aCoder encodeObject:self.items forKey:@"items"];
    [aCoder encodeObject:@(self.shouldBeDisplayed) forKey:@"should_be_displayed"];
}

@end
