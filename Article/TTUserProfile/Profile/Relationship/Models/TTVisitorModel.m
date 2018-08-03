//
//  TTVisitorModel.m
//  Article
//
//  Created by liuzuopeng on 8/10/16.
//
//

#import "TTVisitorModel.h"
#import "TTVerifyIconHelper.h"



/**
 * TTVisitorFormattedModelItem
 */
@implementation TTVisitorFormattedModelItem
- (instancetype)init {
    if ((self = [super init])) {
        _isFirstVisitorOfDay = NO;
        _list_count = 0;
        _visit_device_count = 0;
        _visit_count_recent = 0;
        _visit_count_total  = 0;
    }
    return self;
}


- (NSString *)formattedTimeLabel {
    //    NSDate *curDate  = [NSDate date];
    NSDate *lastDate = [NSDate dateWithTimeIntervalSince1970:[self.last_visit_time doubleValue]];
    //    NSDateComponents *diffComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth|NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:lastDate toDate:curDate options:0];
    NSDateComponents *lastDateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth|NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute fromDate:lastDate];
    
    //fix 0:8 要改成 00:08
    NSString *hourString = [lastDateComponents hour] < 10 ? [NSString stringWithFormat:@"0%ld",(long)[lastDateComponents hour]] : [NSString stringWithFormat:@"%ld",(long)[lastDateComponents hour]];
    
    NSString *miniteString = [lastDateComponents minute] < 10 ? [NSString stringWithFormat:@"0%ld",(long)[lastDateComponents minute]] : [NSString stringWithFormat:@"%ld",(long)[lastDateComponents minute]];
    
    NSString *timeString = [NSString stringWithFormat:@"%@:%@ 来访", hourString, miniteString];
    //    if ([diffComponents year] > 0) {
    //        timeString = [NSString stringWithFormat:@"%ld年前 来访", [diffComponents year]];
    //    } else if ([diffComponents month]) {
    //        timeString = [NSString stringWithFormat:@"%ld月前 来访", [diffComponents month]];
    //    } else if ([diffComponents day]) {
    //        timeString = [NSString stringWithFormat:@"%ld天前 来访", [diffComponents day]];
    //    } else {
    //        timeString = [NSString stringWithFormat:@"%ld:%ld 来访", [lastDateComponents hour], [lastDateComponents minute]];
    //    }
    return timeString;
}

- (NSString *)formattedDateLabel {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:[self.last_visit_time doubleValue]];
    NSDateComponents *dateComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth|NSCalendarUnitDay | NSCalendarUnitHour fromDate:date];
    return [NSString stringWithFormat:@"%ld月%ld日", (long)[dateComponents month], (long)[dateComponents day]];
}

- (BOOL)isVerifiedUser
{
    return [TTVerifyIconHelper isVerifiedOfVerifyInfo:self.userAuthInfo];
}

- (BOOL)isToutiaohaohaoUser {
    return (!isEmptyString(self.media_id) && ![self.media_id isEqualToString:@"0"]);
}

+ (instancetype)modelWithVisitorItem:(TTVisitorItemModel *)obj {
    TTVisitorFormattedModelItem *aModel = [self.class new];
    aModel.status = obj.status;
    aModel.type   = obj.type;
    aModel.gender = obj.gender;
    aModel.user_id = obj.user_id;
    aModel.media_id = obj.media_id;
    aModel.screen_name = obj.screen_name;
    aModel.verified_content = obj.verified_content;
    aModel.avatar_url  = obj.avatar_url;
    aModel.userDescription = obj.userDescription;
    aModel.userAuthInfo = obj.userAuthInfo;
    
    aModel.is_following  = obj.is_following;
    aModel.is_followed   = obj.is_followed;
    aModel.ban_comment   = obj.ban_comment;
    
    if ([obj.create_time isKindOfClass:[NSNumber class]]) {
        aModel.create_time = obj.create_time;
    } else if (![obj.create_time isKindOfClass:[NSObject class]]) {
        aModel.create_time = @((unsigned long)obj.create_time);
    }
    if ([obj.last_visit_time isKindOfClass:[NSNumber class]]) {
        aModel.last_visit_time = obj.last_visit_time;
    } else if (![obj.last_visit_time isKindOfClass:[NSObject class]]) {
        aModel.last_visit_time = @((unsigned long)obj.last_visit_time);
    }
    
    return aModel;
}
@end


/**
 * TTVisitorFormattedModel
 */
@implementation TTVisitorFormattedModel
- (instancetype)init {
    if ((self = [super init])) {
        _list_count = 0;
        _visit_device_count = 0;
        _visit_count_recent = 0;
        _visit_count_total  = 0;
        _cursor = @(0);
    }
    return self;
}

+ (instancetype)formattedModelFromVisitorModel:(TTVisitorModel *)aModel {
    if (aModel || [aModel isRecentEmpty]) return nil;
    
    TTVisitorFormattedModel *formattedModel = [TTVisitorFormattedModel new];
    formattedModel.has_more = aModel.data.has_more;
    formattedModel.cursor   = aModel.cursor;
    formattedModel.list_count = [aModel listCount];
    formattedModel.visit_device_count = [aModel anonymousTotalCount];
    formattedModel.visit_count_recent = [aModel recentTotalCount];
    formattedModel.visit_count_total  = [aModel totalCount];
    
    NSArray<TTVisitorItemModel *> *sortedUsers = [aModel.data.users sortedArrayUsingComparator:^NSComparisonResult(TTVisitorItemModel *obj1, TTVisitorItemModel *obj2) {
        return [obj1.last_visit_time doubleValue] >= [obj2.last_visit_time doubleValue] ? NSOrderedAscending : NSOrderedDescending;
    }];
    
    __block TTVisitorItemModel *prevItem = nil;
    NSMutableArray *formattedModelItems = [NSMutableArray<TTVisitorFormattedModelItem *> array];
    [sortedUsers enumerateObjectsUsingBlock:^(TTVisitorItemModel * obj, NSUInteger idx, BOOL * _Nonnull stop) {
        TTVisitorFormattedModelItem *aModelItem = [TTVisitorFormattedModelItem modelWithVisitorItem:obj];
        aModelItem.isFirstVisitorOfDay = !(tt_isSameDayOfVisitorItemModel(prevItem, obj));
        aModelItem.list_count = [aModel listCount];
        aModelItem.visit_device_count = [aModel anonymousTotalCount];
        aModelItem.visit_count_recent = [aModel recentTotalCount];
        aModelItem.visit_count_total  = [aModel totalCount];
        
        [formattedModelItems addObject:aModel];
        
        prevItem = obj;
    }];
    formattedModel.users = formattedModelItems;
    
    return formattedModel;
}

- (BOOL)hasHistoryVisitor {
    return (self.visit_count_recent != 0 || self.visit_count_total != 0);
}

- (BOOL)hasNotLoginVisitor {
    return (self.visit_device_count > 0);
}
@end
