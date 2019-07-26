//
//  FHHouseDislikeWord.m
//  FHHouseHome
//
//  Created by 谢思铭 on 2019/7/23.
//

//#import "FHHouseDislikeWord.h"
//
//@implementation FHHouseDislikeWord
//
//@end

#import "FHHouseDislikeWord.h"

@implementation FHHouseDislikeWord

- (instancetype)initWithDict:(NSDictionary *)dict {
    self = [super init];
    if (self) {
        self.ID = [NSString stringWithFormat:@"%@", dict[@"id"]];
        self.name = dict[@"name"];
        self.isSelected = [dict[@"is_selected"] boolValue];
        self.exclusiveIds = dict[@"mutual_exclusive_ids"];
    }
    return self;
}

@end
