//
//  TTCategory+ConfigDisplayName.m
//  Article
//
//  Created by zengzhihui on 2018/1/17.
//

#import "TTVideoCategory.h"
#import "TTCategory+ConfigDisplayName.h"

@implementation TTCategory (ConfigDisplayName)

//频道名称显示优先级：setting>displayName>name
- (NSString *)adjustDisplayName{
    if ([self isKindOfClass:[TTVideoCategory class]] && [self.displayName isEqualToString:@"推荐"] && !isEmptyString([SSCommonLogic videoTabMainCategoryName])) {
        return [SSCommonLogic videoTabMainCategoryName];
    }
    if ([self.categoryID isEqualToString:kTTMainCategoryID] &&
        !isEmptyString([SSCommonLogic homeTabMainCategoryName])) {
        return [SSCommonLogic homeTabMainCategoryName];
    }
    if (!isEmptyString(self.displayName)) {
        return self.displayName;
    }
    if (!isEmptyString(self.name)) {
        return self.name;
    }
    return @"";
}
@end
