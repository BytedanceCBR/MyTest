//
//  FHMessageCellTagModel.m
//  FHHouseMessage
//
//  Created by wangzhizhou on 2020/12/21.
//

#import "FHMessageCellTagModel.h"
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>

@implementation FHMessageCellTagModel

- (instancetype)initWithName:(NSString *)name {
    return [self initWithName:name priority:FHMessageCellTagPriorityNormal];
}
-(instancetype)initWithName:(NSString *)name priority:(FHMessageCellTagPriority)priority {
    if(self = [super init]) {
        self.name = name;
        self.priority = priority;
        // default ui settings
        self.font = [UIFont themeFontRegular:10];
        self.textColor = [UIColor themeGray2];
        self.backgroundColor = [UIColor themeGray7];
    }
    return self;
}
@end
