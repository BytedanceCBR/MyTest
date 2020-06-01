//
//  FHRelevantDurationTracker.m
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/10.
//

#import "FHRelevantDurationTracker.h"

#import "FHUserTracker.h"

@interface FHRelevantDurationTracker ()

@property (nonatomic, strong) NSMutableArray *eventArray;
@property (nonatomic, assign) BOOL tracking;

@end

@implementation FHRelevantDurationTracker

- (instancetype)init
{
    if (self = [super init]) {
        _eventArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

+ (instancetype)sharedTracker
{
    static FHRelevantDurationTracker *_sharedTracker;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedTracker = [[FHRelevantDurationTracker alloc] init];
    });
    
    return _sharedTracker;
}

- (void)appendRelevantDurationWithGroupID:(NSString *)groupID
                                   itemID:(NSString *)itemID
                                enterFrom:(NSString *)enterFrom
                             categoryName:(NSString *)categoryName
                                 stayTime:(NSInteger)stayTime
                                    logPb:(NSDictionary *)logPb
{
    NSParameterAssert(groupID);
    NSAssert([NSThread isMainThread], @"Must be on main thread");

    NSDictionary *event = @{
                            @"group_id": groupID ?: @"",
                            @"item_id": itemID ?: @"",
                            @"enter_from": enterFrom ?: @"",
                            @"cagetory_name": categoryName ?: @"",
                            @"stay_time": @(stayTime),
                            @"log_pb": logPb ?: @"",
                            @"link_position": @([self.eventArray count] + 1),
                            };
    [self appendRelevantDurationWithDictionary:event];
}

- (void)appendRelevantDurationWithDictionary:(NSDictionary *)eventDictionary
{
    if (!self.tracking) {
        return;
    }
    NSDate *beforeDate = [NSDate date];
    NSInteger currentIndex = -1;
    NSInteger totalDuration = [eventDictionary[@"stay_time"] integerValue];
    NSMutableDictionary *filteredDictionary = @{}.mutableCopy;

    if (self.eventArray.count > 0) {

        NSString *newGroupId = eventDictionary[@"group_id"];
        for (NSInteger index = 0; index < self.eventArray.count; index++) {
            NSDictionary *itemDict = self.eventArray[index];
            NSString *groupId = itemDict[@"group_id"];
            if ([groupId isEqualToString:newGroupId]) {
                [filteredDictionary addEntriesFromDictionary:itemDict];
                totalDuration += [itemDict[@"stay_time"] integerValue];
                currentIndex = index;
                break;
            }
        }
    }
    if (currentIndex != -1 && self.eventArray.count > currentIndex) {
         filteredDictionary[@"stay_time"] = @(totalDuration);
         [self.eventArray replaceObjectAtIndex:currentIndex withObject:filteredDictionary];
    }else {
        for (NSString *key in eventDictionary) {
            if ([eventDictionary[key] isKindOfClass:[NSString class]]) {
                if ([eventDictionary[key] length]) {
                    filteredDictionary[key] = eventDictionary[key];
                }
            } else {
                filteredDictionary[key] = eventDictionary[key];
            }
        }
        [self.eventArray addObject:filteredDictionary];
    }

    NSDate *endDate = [NSDate date];
}

- (void)beginRelevantDurationTracking
{
    NSAssert(!self.tracking, @"Relevant duration tracking already started");
    self.tracking = YES;
}

- (void)sendRelevantDuration
{
    NSAssert([NSThread isMainThread], @"Must be on main thread");

    if ([self.eventArray count]) {
        NSString *entranceGroupID = [self.eventArray firstObject][@"group_id"];
        NSAssert(entranceGroupID, @"groupID must exist");
        NSInteger totalDuration = 0;
        for (NSDictionary *event in self.eventArray) {
            totalDuration += [event[@"stay_time"] integerValue];
        }

        NSDictionary *params = @{
                                 @"link_list": [self.eventArray copy],
                                 @"group_id_first": entranceGroupID ?: @"",
                                 @"stay_time_all": @(totalDuration),
                                 @"link_cnt": @([self.eventArray count]),
                                 };
        [FHUserTracker writeEvent:@"stay_page_link" params:params];

        [self.eventArray removeAllObjects];
    }
    self.tracking = NO;
}

@end
