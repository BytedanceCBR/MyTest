//
//  ExploreWidgetImpressionManager.m
//  Article
//
//  Created by Zhang Leonardo on 14-10-16.
//
//

#import "ExploreWidgetImpressionManager.h"
#import "ExploreWidgetItemModel.h"
#import "TTWidgetImpressionModel.h"
#import "ExploreExtenstionDataHelper.h"

#define kMinValideInterval 0.5      //最小停留0.5秒以上有效

#define kMaxValideDuration 120
#define kMinValideDuration 0.5f

@interface ExploreWidgetImpressionManager()

@property(nonatomic, retain)NSMutableDictionary * impressionPool;

@end

@implementation ExploreWidgetImpressionManager

- (id)init
{
    self = [super init];
    if (self) {
        self.impressionPool = [[NSMutableDictionary alloc] init];
    }
    return self;
}


- (void)startRecordItems:(NSArray *)items
{
    [self endRecord];
    
    if ([items count] == 0) {
        return;
    }
    
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];;
    for (ExploreWidgetItemModel * itemModel in items) {
        if ([itemModel.uniqueID longLongValue] != 0) {
            NSString * idStr = [NSString stringWithFormat:@"%@", itemModel.uniqueID];
            TTWidgetImpressionModel * impressionModel =[self impressionModelForID:idStr];
            [impressionModel startRecoderInterval:now];
        }
    }
}

- (void)endRecord
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];;
    [_impressionPool enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        TTWidgetImpressionModel * model = (TTWidgetImpressionModel *)obj;
        if (model.impressionStatus != TTWidgetImpressionStatusEnd) {
            [model endRecoderInterval:now];
        }
    }];
}

- (void)save
{
    NSTimeInterval now = [[NSDate date] timeIntervalSince1970];;
    NSMutableArray * results = [NSMutableArray arrayWithCapacity:10];
    
    for (NSString * keyStr in _impressionPool.allKeys) {
        TTWidgetImpressionModel * model = [_impressionPool objectForKey:keyStr];
        if (model.totalDuration >= kMaxValideDuration || model.totalDuration < kMinValideDuration) {//过长时间，有问题， 先过滤。
            continue;
        }
        NSDictionary * dict = [model parseToDict:now];
        if ([dict count] > 0) {
            [results addObject:dict];
        }
    }
    
    [_impressionPool removeAllObjects];
    
    [ExploreExtenstionDataHelper appendTodayExtenstionImpression:results];
}


- (TTWidgetImpressionModel *)impressionModelForID:(NSString *)IDStr
{
    TTWidgetImpressionModel * model = [_impressionPool objectForKey:IDStr];
    if (!model) {
        model = [[TTWidgetImpressionModel alloc] initWithItemID:IDStr itemType:TTWidgetImpressionModelTypeGroup];
        [_impressionPool setValue:model forKey:IDStr];
    }
    return model;
}

@end
