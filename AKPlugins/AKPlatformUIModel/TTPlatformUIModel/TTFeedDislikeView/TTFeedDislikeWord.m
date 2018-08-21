//
//  ExploreDislikeWord.m
//  Article
//
//  Created by Chen Hong on 14/11/23.
//
//

#import "TTFeedDislikeWord.h"

@implementation TTFeedDislikeWord

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.ID = [NSString stringWithFormat:@"%@", dict[@"id"]];
        self.name = dict[@"name"];
        self.isSelected = [dict[@"is_selected"] boolValue];
    }
    return self;
}

@end
