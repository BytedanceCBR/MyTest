//
//  TTSubEntranceObj.m
//  Article
//
//  Created by Chen Hong on 15/6/23.
//
//

#import "TTSubEntranceObj.h"
#import "NSDictionary+TTAdditions.h"

@implementation TTSubEntranceObj

- (instancetype)initWithDictionary:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.name = [dict stringValueForKey:@"name" defaultValue:nil];
        self.openUrl = [dict stringValueForKey:@"open_url" defaultValue:nil];
    }
    return self;
}

@end
