//
//  FHFeedOperationWord.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/16.
//

#import "FHFeedOperationWord.h"

@implementation FHFeedOperationWord

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        if(dict[@"id"]){
            self.ID = [NSString stringWithFormat:@"%@", dict[@"id"]];
        }
        self.title = dict[@"title"];
        self.subTitle = dict[@"subTitle"];
        self.items = dict[@"items"];
        self.serverType = dict[@"serverType"];
    }
    return self;
}

- (FHFeedOperationWordType)type {
    if([self.ID containsString:@":"]){
        NSString *typeValue = [self.ID substringToIndex:[self.ID rangeOfString:@":"].location];
        return (FHFeedOperationWordType)[typeValue intValue];
    }else{
        return (FHFeedOperationWordType)[self.ID intValue];
    }
}

@end
