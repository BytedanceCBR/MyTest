//
//  TTVisitorResponseModel.m
//  Article
//
//  Created by liuzuopeng on 9/5/16.
//
//

#import "TTVisitorResponseModel.h"
#import "TTVisitorModel.h"


@implementation TTVisitorItemModel
- (instancetype)init {
    if ((self = [super init])) {
    }
    return self;
}

+ (JSONKeyMapper*)keyMapper {
    return [[JSONKeyMapper alloc] initWithDictionary:@{@"description": @"userDescription",
                                                       @"user_auth_info": @"userAuthInfo",
                                                       @"user_decoration":@"userDecoration"
                                                       }];
}

+(BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end



@implementation TTVisitorDataModel
- (instancetype)init {
    if ((self = [super init])) {
        _has_more = NO;
        _cursor   = @(0);
        _list_count = @(0);
        _visit_device_count = @(0);
        _visit_count_recent = @(0);
        _visit_count_total  = @(0);
    }
    return self;
}

+(BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end



@implementation TTVisitorModel
- (instancetype)init {
    if ((self = [super init])) {
    }
    return self;
}

+(BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}

- (void)appendVisitorModel:(TTVisitorModel *)aModel {
    if ([aModel isRecentEmpty]) return;
    
    @try {
        self.data.cursor = aModel.data.cursor;
        self.data.has_more = aModel.hasMore;
        NSArray *newUsers = [self.data.users arrayByAddingObjectsFromArray:aModel.data.users];
        self.data.users = (NSArray<Optional, TTVisitorItemModel> *)newUsers;
    } @catch (NSException *exception) {
    } @finally {
    }
}

- (NSInteger)anonymousTotalCount {
    return [_data.visit_device_count integerValue];
}

- (NSInteger)listCount {
    return [_data.list_count integerValue];
}

- (NSInteger)totalCount {
    return [_data.visit_count_total integerValue];
}

- (NSInteger)recentTotalCount {
    return [_data.visit_count_recent integerValue];
}

/**
 *  最近七天的访客数
 *
 *  @return 最近7内天访客数目
 */
- (NSInteger)countOfNearest7Day {
    __block NSUInteger countOf7Day = 0;
    __block NSUInteger visitedDays = 0;  // 计数
    __block TTVisitorItemModel *prevItem = nil;
    NSArray<TTVisitorItemModel *> *sortedUsers = [self.data.users sortedArrayUsingComparator:^NSComparisonResult(TTVisitorItemModel *obj1, TTVisitorItemModel *obj2) {
        return [obj1.last_visit_time doubleValue] >= [obj2.last_visit_time doubleValue] ? NSOrderedAscending : NSOrderedDescending;
    }];
    [sortedUsers enumerateObjectsUsingBlock:^(TTVisitorItemModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        countOf7Day++;
        
        if (![self isSameDayOfObj1:prevItem obj2:obj]) visitedDays++;
        if (visitedDays > 7)  *stop = YES;
        
        prevItem = obj;
    }];
    
    return countOf7Day;
}

- (BOOL)hasMore {
    return _data.has_more;
}

- (NSNumber *)cursor {
    return _data.cursor;
}

- (BOOL)isRecentAnonymousEmpty {
    return (!_data || _data.visit_device_count.integerValue <=0);
}

- (BOOL)isRecentEmpty {
    return (!_data || ([_data.users count] <= 0 && _data.visit_count_recent.integerValue <=0));
}

- (BOOL)isHistoryEmpty {
    return (!_data || ([_data.users count] <= 0 && _data.visit_count_total.integerValue <=0));
}

- (TTVisitorFormattedModel *)toFormattedModel {
    if ([self isHistoryEmpty]) return nil;
    
    TTVisitorFormattedModel *formattedModel = [TTVisitorFormattedModel new];
    formattedModel.has_more = self.data.has_more;
    formattedModel.cursor   = self.cursor;
    formattedModel.list_count = [self listCount];
    formattedModel.visit_device_count = [self anonymousTotalCount];
    formattedModel.visit_count_recent = [self recentTotalCount];
    formattedModel.visit_count_total  = [self totalCount];
    NSArray<TTVisitorItemModel *> *sortedUsers = [self.data.users sortedArrayUsingComparator:^NSComparisonResult(TTVisitorItemModel *obj1, TTVisitorItemModel *obj2) {
        return [obj1.last_visit_time doubleValue] >= [obj2.last_visit_time doubleValue] ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    __block TTVisitorItemModel *prevItem = nil;
    NSMutableArray *formattedModelItems = [NSMutableArray<TTVisitorFormattedModelItem *> array];
    [sortedUsers enumerateObjectsUsingBlock:^(TTVisitorItemModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTVisitorFormattedModelItem *aModelItem = [TTVisitorFormattedModelItem modelWithVisitorItem:obj];
        aModelItem.isFirstVisitorOfDay = ![self isSameDayOfObj1:prevItem obj2:obj];
        aModelItem.list_count = [self listCount];
        aModelItem.visit_device_count = [self anonymousTotalCount];
        aModelItem.visit_count_recent = [self recentTotalCount];
        aModelItem.visit_count_total  = [self totalCount];
        aModelItem.userDecoration = obj.userDecoration;
        [formattedModelItems addObject:aModelItem];
        
        prevItem = obj;
    }];
    formattedModel.users = formattedModelItems;
    
    return formattedModel;
}

/**
 *  返回最近n天的访客model
 *
 *  @param days 天数
 *
 *  @return 最近n天的访客model
 */
- (TTVisitorFormattedModel *)toFormattedModelForNearestNDays:(NSUInteger)days {
    if (days <= 0 || [self isRecentEmpty]) return nil;
    
    
    TTVisitorFormattedModel *formattedModel = [TTVisitorFormattedModel new];
    formattedModel.has_more = self.data.has_more;
    formattedModel.cursor   = self.cursor;
    formattedModel.list_count = [self listCount];
    formattedModel.visit_device_count = [self listCount];
    formattedModel.visit_count_recent = [self anonymousTotalCount];
    formattedModel.visit_count_total  = [self recentTotalCount];
    
    NSArray<TTVisitorItemModel *> *sortedUsers = [self.data.users sortedArrayUsingComparator:^NSComparisonResult(TTVisitorItemModel *obj1, TTVisitorItemModel *obj2) {
        return [obj1.last_visit_time doubleValue] >= [obj2.last_visit_time doubleValue] ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    NSMutableArray<TTVisitorFormattedModelItem *> *formattedModelItems = [NSMutableArray<TTVisitorFormattedModelItem *> array];
    __block NSUInteger visitedDays = 0;
    __block TTVisitorItemModel *prevItem = nil;
    [sortedUsers enumerateObjectsUsingBlock:^(TTVisitorItemModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTVisitorFormattedModelItem *aModelItem = [TTVisitorFormattedModelItem modelWithVisitorItem:obj];
        aModelItem.isFirstVisitorOfDay = ![self isSameDayOfObj1:prevItem obj2:obj];
        aModelItem.list_count = [self listCount];
        aModelItem.visit_device_count = [self anonymousTotalCount];
        aModelItem.visit_count_recent = [self recentTotalCount];
        aModelItem.visit_count_total  = [self totalCount];
        
        [formattedModelItems addObject:aModelItem];
        if (![self isSameDayOfObj1:prevItem obj2:obj]) visitedDays++;
        if (visitedDays > days) *stop = YES;
        
        prevItem = obj;
    }];
    formattedModel.users = formattedModelItems;
    
    return formattedModel;
}

- (BOOL)isSameDayOfObj1:(TTVisitorItemModel *)obj1 obj2:(TTVisitorItemModel *)obj2 {
    return tt_isSameDayOfVisitorItemModel(obj1, obj2);
}
@end


BOOL tt_isSameDayOfVisitorItemModel(TTVisitorItemModel *aModel1, TTVisitorItemModel *aModel2) {
    if (!aModel1 || !aModel2) return NO;
    
    NSDate *date1 = [NSDate dateWithTimeIntervalSince1970:[aModel1.last_visit_time doubleValue]];
    NSDate *date2 = [NSDate dateWithTimeIntervalSince1970:[aModel2.last_visit_time doubleValue]];
    NSCalendar *aCalendar = [NSCalendar currentCalendar];
    NSDateComponents *date1Components = [aCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:date1];
    NSDateComponents *date2Components = [aCalendar components:NSCalendarUnitYear | NSCalendarUnitMonth|NSCalendarUnitDay fromDate:date2];
    
    return ([date1Components day] == [date2Components day] && [date1Components month] == [date2Components month] && [date1Components year] == [date2Components year]);
}
