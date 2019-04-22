//
//  LastRead.m
//  Article
//
//  Created by 王双华 on 16/7/26.
//
//

#import "LastRead.h"

@implementation LastRead

+ (NSString *)dbName {
    return @"tt_news";
}

+ (NSArray *)persistentProperties {
    static NSArray *properties = nil;
    if (!properties) {
        properties = @[@"uniqueID",
                       @"refreshDate",
                       @"lastDate",
                       @"showRefresh",
                       ];
    }
    return properties;
}

- (void)updateWithDictionary:(NSDictionary *)dataDict
{
    [super updateWithDictionary:dataDict];
    
    if ([dataDict objectForKey:@"uniqueID"]) {
        self.uniqueID = [dataDict tt_longlongValueForKey:@"uniqueID"];
    }

    if ([dataDict objectForKey:@"showRefresh"]) {
        self.showRefresh = @([dataDict tt_boolValueForKey:@"showRefresh"]);
    }
    
    if ([dataDict objectForKey:@"lastDate"]) {
        NSDate *lastDate = [dataDict objectForKey:@"lastDate"];
        if ([lastDate isKindOfClass:[NSDate class]]) {
            self.lastDate = lastDate;
        }
    }
    
    if ([dataDict objectForKey:@"refreshDate"]) {
        NSDate *refreshDate = [dataDict objectForKey:@"refreshDate"];
        if ([refreshDate isKindOfClass:[NSDate class]]) {
            self.refreshDate = refreshDate;
        }
    }
}

- (void)updateWithShowRefresh:(BOOL)showRefresh
{
    if ([self.showRefresh isEqualToNumber:@(showRefresh)]){
        return;
    }
    self.showRefresh = @(showRefresh);
    [self save];
//    if ([self hasChanges]) {
//        [[SSModelManager sharedManager] save:nil];
//    }
}

- (void)updateWithLastReadDate:(NSDate *)lastReadDate refreshDate:(NSDate *)refreshDate
{
    if (!lastReadDate || !refreshDate) {
        return;
    }
    if ([self.lastDate isEqualToDate:lastReadDate] && [self.refreshDate isEqualToDate:refreshDate]){
        return;
    }
    self.lastDate = lastReadDate;
    self.refreshDate = refreshDate;
    [self save];
//    if ([self hasChanges]) {
//        [[SSModelManager sharedManager] save:nil];
//    }
}


@end
