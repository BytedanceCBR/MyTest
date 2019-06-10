//
//  TTWidgetImpressionModel.m
//  Article
//
//  Created by Zhang Leonardo on 14-6-23.
//
//

#import "TTWidgetImpressionModel.h"
#import "TTBaseMacro.h"

@implementation TTWidgetImpressionParams
@end

@interface TTWidgetImpressionModel()
/**
 impression的状态, 此状态不用存储
 */
@property(nonatomic, assign, readwrite)TTWidgetImpressionStatus impressionStatus;
/**
 第一次展示时间
 */
@property(nonatomic, assign)NSTimeInterval startTime;

/**
 最近一次开始时间
 */
@property(nonatomic, assign)NSTimeInterval latelyStartTime;

/**
 单次最大展示时间
 */
@property(nonatomic, assign)CGFloat onceMaxDuration;

/**
 总展示时间
 */
@property(nonatomic, assign, readwrite)CGFloat totalDuration;
@property(nonatomic, assign, readwrite)TTWidgetImpressionModelType itemType;
@property(nonatomic, strong, readwrite)NSString * itemID;
@property(nonatomic, strong)NSString * modelPrimaryKey;
@property(nonatomic, assign)NSTimeInterval latelyPauseStartTime;
//@property(nonatomic, assign)CGFloat pauseDuration;

@end

@implementation TTWidgetImpressionModel

- (id)initWithItemID:(NSString *)itemID itemType:(TTWidgetImpressionModelType)itemType
{
    self = [super init];
    if (self) {
        
        self.itemID = itemID;
        self.itemType = itemType;
        self.modelPrimaryKey = [TTWidgetImpressionModel genImpressionModelPrimaryKeyForItemID:_itemID itemType:_itemType];
        [self clearRecord];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:@(_latelyPauseStartTime) forKey:@"latelyPauseStartTime"];
    //[aCoder encodeObject:@(_pauseDuration) forKey:@"pauseDuration"];
    [aCoder encodeObject:_modelPrimaryKey forKey:@"modelPrimaryKey"];
    [aCoder encodeObject:_itemID forKey:@"itemID"];
    [aCoder encodeObject:@(_itemType) forKey:@"itemType"];
    [aCoder encodeObject:_value forKey:@"value"];
    [aCoder encodeObject:@(_startTime) forKey:@"startTime"];
    [aCoder encodeObject:@(_latelyStartTime) forKey:@"latelyStartTime"];
    [aCoder encodeObject:@(_onceMaxDuration) forKey:@"onceMaxDuration"];
    [aCoder encodeObject:@(_totalDuration) forKey:@"totalDuration"];
    [aCoder encodeObject:@(_cellStyle) forKey:@"cellStyle"];
    [aCoder encodeObject:@(_cellSubStyle) forKey:@"cellSubStyle"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    if(self)
    {
        self.latelyPauseStartTime = [[aDecoder decodeObjectForKey:@"latelyPauseStartTime"] doubleValue];
        //self.pauseDuration = [[aDecoder decodeObjectForKey:@"pauseDuration"] doubleValue];
        self.modelPrimaryKey = [aDecoder decodeObjectForKey:@"modelPrimaryKey"];
        self.itemID = [aDecoder decodeObjectForKey:@"itemID"];
        self.itemType = [[aDecoder decodeObjectForKey:@"itemType"] intValue];
        self.value = [aDecoder decodeObjectForKey:@"value"];
        self.startTime = [[aDecoder decodeObjectForKey:@"startTime"] doubleValue];
        self.latelyStartTime = [[aDecoder decodeObjectForKey:@"latelyStartTime"] doubleValue];
        self.onceMaxDuration = [[aDecoder decodeObjectForKey:@"onceMaxDuration"] doubleValue];
        self.totalDuration = [[aDecoder decodeObjectForKey:@"totalDuration"] doubleValue];
        self.cellStyle = [[aDecoder decodeObjectForKey:@"cellStyle"] unsignedIntegerValue];
        self.cellSubStyle = [[aDecoder decodeObjectForKey:@"cellSubStyle"] unsignedIntegerValue];
    }
    return self;
}

- (void)clearRecord
{
    self.latelyPauseStartTime = 0;
    //self.pauseDuration = 0;
    self.startTime = 0;
    self.latelyStartTime = 0;
    self.onceMaxDuration = 0;
    self.totalDuration = 0;
}

- (void)setImpressionParams:(TTWidgetImpressionParams *)params {
    self.cellStyle = params.cellStyle;
    self.cellSubStyle = params.cellSubStyle;
    self.actionType = params.actionType;
}

#pragma mark -- public

+ (NSUInteger)sendCodeForImpressionModelType:(TTWidgetImpressionModelType)type
{
    if (type == TTWidgetImpressionModelTypeSubject) {
        return TTWidgetImpressionModelTypeGroup;
    }
    return type;
}

- (void)reuseImpressionModel:(NSTimeInterval)currentTimeInterval
{
    [self clearRecord];
    if (self.impressionStatus == TTWidgetImpressionStatusSuspend) {
        self.latelyStartTime = currentTimeInterval;
        self.latelyPauseStartTime = currentTimeInterval;
    }
    else if (self.impressionStatus == TTWidgetImpressionStatusRecording) {
        self.startTime = currentTimeInterval;
        self.latelyStartTime = currentTimeInterval;
    }
}

- (NSDictionary *)parseToDict:(NSTimeInterval)currentTime
{
    if (isEmptyString(_itemID)) {
        return nil;
    }
    
    if (_startTime == 0 || (_impressionStatus != TTWidgetImpressionStatusEnd && _latelyStartTime == 0)) {
 
        [self clearRecord];
        return nil;
    }
    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithCapacity:10];
    if ([_itemID rangeOfString:@"|"].location == NSNotFound) {
        [dict setValue:_itemID forKey:@"id"];
    } else {
        NSArray *groups = [_itemID componentsSeparatedByString:@"|"];
        NSString *groupId = [groups firstObject], *itemId = nil, *aggrType = nil;
        if (groups.count >= 2) {
            itemId = groups[1];
        }
        if (groups.count >= 3) {
            aggrType = groups[2];
        }
        
        [dict setValue:groupId forKey:@"id"];
        [dict setValue:@([itemId longLongValue]) forKey:@"item_id"];
        [dict setValue:@([aggrType longLongValue]) forKey:@"aggr_type"];
        
        if (_cellStyle > 0) [dict setValue:@(_cellStyle) forKey:@"style"];
        if (_cellSubStyle > 0) [dict setValue:@(_cellSubStyle) forKey:@"sub_style"];
    }
    [dict setValue:@([TTWidgetImpressionModel sendCodeForImpressionModelType:_itemType]) forKey:@"type"];
    [dict setValue:@((long long)_startTime) forKey:@"time"];
    
    if (_impressionStatus != TTWidgetImpressionStatusEnd) {
        if(_impressionStatus == TTWidgetImpressionStatusRecording){
            CGFloat latelyDuration = currentTime - _latelyStartTime;
        
            self.totalDuration += latelyDuration;
            self.onceMaxDuration = MAX(_onceMaxDuration, latelyDuration);
        }
        self.latelyStartTime = currentTime;
    }
    //专题没有duration
    if (_itemType != TTWidgetImpressionModelTypeSubject) {
        [dict setValue:@((long long)(_totalDuration * 1000)) forKey:@"duration"];
        [dict setValue:@((long long)(_onceMaxDuration * 1000)) forKey:@"max_duration"];
    }
    
    if(_itemType == TTWidgetImpressionModelTypeMessageNotification){
        [dict setValue:_actionType forKey:@"action_type"];
    }
    
    [dict setValue:_value forKey:@"value"];
    BOOL needReturnNil = NO;
    if (_totalDuration <= 0 && _itemType != TTWidgetImpressionModelTypeSubject) {//始终挂起状态并结束的会出现这个
        needReturnNil = YES;
    }
    
    [self clearRecord];
    
    if (needReturnNil) {
        return nil;
    }
 
    return dict;
}

- (void)endRecoderInterval:(NSTimeInterval)currentTimeInterval
{
    
    
    
    if (self.impressionStatus == TTWidgetImpressionStatusEnd) {
        //do nothing...
    }
    else {
        
        
        if (_latelyStartTime != 0) {
            NSTimeInterval latelyDuration = currentTimeInterval - _latelyStartTime;
            if (latelyDuration <= 0) {
                //冗错, 此时不更改totalDuration和onceMaxDuration
            }
            else {
                self.onceMaxDuration = MAX(latelyDuration, _onceMaxDuration);
                self.totalDuration += latelyDuration;
            }
        }
 
        
        self.latelyStartTime = 0;
        self.latelyPauseStartTime = 0;
        self.impressionStatus = TTWidgetImpressionStatusEnd;
    }
}

- (void)startRecoderInterval:(NSTimeInterval)currentTimeInterval
{
    //如果状态是suppend时候被调用了start,则计算出暂停的时间，并将暂定的开始时间重置
    if (self.impressionStatus == TTWidgetImpressionStatusSuspend) {
        self.latelyPauseStartTime = 0;
    }
    else if (self.impressionStatus == TTWidgetImpressionStatusRecording) {
        //如果状态是recording时候被调用了start,则重置所有值，正常不会出现
        [self clearRecord];
    }
    if (_startTime <= 0) {
        self.startTime = currentTimeInterval;
    }
    self.latelyStartTime = currentTimeInterval;
    self.impressionStatus = TTWidgetImpressionStatusRecording;
}

- (void)suspendRecoderInterval:(NSTimeInterval)currentTimeInterval
{
    if (self.impressionStatus == TTWidgetImpressionStatusRecording) {
        if (_latelyStartTime == 0) {
            self.latelyStartTime = currentTimeInterval;
        }
        
        //nick fix impression
        NSTimeInterval latelyDuration = currentTimeInterval - _latelyStartTime;
        if (latelyDuration <= 0) {
            //冗错, 此时不更改totalDuration和onceMaxDuration
        }
        else {
            self.onceMaxDuration = MAX(latelyDuration, _onceMaxDuration);
            self.totalDuration += latelyDuration;
        }
        
        self.impressionStatus = TTWidgetImpressionStatusSuspend;
        self.latelyPauseStartTime = currentTimeInterval;
        
    }
    else {
        //do nothing...
    }
}

- (NSString *)primaryKey
{
    return _modelPrimaryKey;
}

#pragma mark -- static public

+ (NSString *)genImpressionModelPrimaryKeyForItemID:(NSString *)itemID itemType:(TTWidgetImpressionModelType)itemType
{
    if (isEmptyString(itemID)) {
        return nil;
    }
    
    return [NSString stringWithFormat:@"%@%lu", itemID, (unsigned long)itemType];
}
@end




