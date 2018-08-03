//
//  UnitStayTimeAccumulator.m
//  Article
//
//  Created by Huaqing Luo on 16/3/15.
//
//

#import "UnitStayTimeAccumulator.h"
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/TTUIResponderHelper.h>
typedef enum : NSUInteger {
    AccumulatorStateUnkown,
    AccumulatorStateRunning,
    AccumulatorStateSuspended,
    AccumulatorStateStopped,
} UnitStayTimeAccumulatorState;

@interface UnitStayTimeAccumulator()
{
    NSDate * _lastAccumulateTime;
    CGFloat _unitHeight;
    CGFloat _screenHeight;
    
    UnitStayTimeAccumulatorState _state;
}

@property (nonatomic, strong) NSMutableArray * internalTotalStayTimes;
@property (nonatomic, strong) NSMutableArray * internalMaxStayTimes;
@property (nonatomic, strong) NSMutableArray * internalRecordTimes;

@property (nonatomic, strong) NSMutableArray * visibleUnits;

@end

@implementation UnitStayTimeAccumulator

@synthesize currentOffset = _currentOffset;

+ (CGFloat)privateScreenHeight
{
    CGFloat screenHeight = 0;
    if ([TTDeviceHelper isPadDevice] && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        screenHeight = [TTUIResponderHelper screenSize].width;
    } else {
        screenHeight = [TTUIResponderHelper screenSize].height;
    }
    
    return screenHeight;
}

- (id)initWithUnitHeight:(CGFloat)unitHeight
{
    self = [super init];
    if (self) {
        _state = AccumulatorStateStopped;
        _unitHeight = unitHeight;
        _screenHeight = [UnitStayTimeAccumulator privateScreenHeight];
    }
    return self;
}

- (instancetype)init
{
    // default value for _unitHeight
    return [self initWithUnitHeight:[UnitStayTimeAccumulator privateScreenHeight]];
}

- (void)stopAccumulating
{
    if (_state == AccumulatorStateRunning) {
        [self accumulate];
    }
    
    _state = AccumulatorStateStopped;
}

- (void)suspendAccumulating
{
    if (_state == AccumulatorStateRunning) {
        [self accumulate];
        _state = AccumulatorStateSuspended;
    }
}

#pragma mark -- Setters, Getters

- (NSArray *)totalStayTimes
{
    return self.internalTotalStayTimes;
}

- (NSArray *)maxStayTimes
{
    return self.internalMaxStayTimes;
}

- (NSArray *)recordTimes
{
    return self.internalRecordTimes;
}

- (void)setCurrentOffset:(CGFloat)currentOffset
{
    _currentOffset = MIN(MAX(0, currentOffset), 100000);
    
    if (_state == AccumulatorStateStopped) {
        [self resetAccumulator];
    }
    
    CGFloat screenBottomOffset = MIN(_currentOffset + _screenHeight, _maxOffset);
    NSUInteger visibleUnit = (NSUInteger)floor(_currentOffset / _unitHeight);
    NSMutableArray * newVisibleUnits = [NSMutableArray arrayWithObject:@(visibleUnit)];
    for (NSUInteger unit = visibleUnit + 1; unit * _unitHeight < screenBottomOffset; ++unit) {
        [newVisibleUnits addObject:@(unit)];
    }
    
    BOOL needAccumulate = NO;
    BOOL needUpdateVisibleUnits = (_visibleUnits.count != newVisibleUnits.count || [_visibleUnits[0] intValue] != [newVisibleUnits[0] intValue]);
    if (_state == AccumulatorStateRunning) {
        needAccumulate = needUpdateVisibleUnits;
    } else if (_state == AccumulatorStateSuspended || _state == AccumulatorStateStopped) {
        _lastAccumulateTime = [NSDate date];
        _state = AccumulatorStateRunning;
    }
    
    if (needAccumulate) {
        [self accumulate];
    }
    
    if (needUpdateVisibleUnits) {
        [self setVisibleUnits:newVisibleUnits];
    }
}

- (void)setVisibleUnits:(NSMutableArray *)visibleUnits
{
    if (!_visibleUnits) {
        _visibleUnits = [NSMutableArray arrayWithCapacity:5];
    }
    
    [_visibleUnits removeAllObjects];
    for (NSUInteger i = 0; i < visibleUnits.count; ++i) {
        [self addVisibleUnit:visibleUnits[i]];
    }
}

- (void)addVisibleUnit:(NSNumber *)unit
{
    [_visibleUnits addObject:unit];
    NSUInteger nUnit = [unit intValue];
    if (nUnit >= [self.internalTotalStayTimes count]) {
        for (NSUInteger i = [self.internalTotalStayTimes count]; i <= nUnit; ++i) {
            [self.internalTotalStayTimes addObject:@(0)];
            [self.internalMaxStayTimes addObject:@(0)];
            [self.internalRecordTimes addObject:@(0)];
        }
    }
}

- (NSMutableArray *)internalTotalStayTimes
{
    if (!_internalTotalStayTimes) {
        _internalTotalStayTimes = [NSMutableArray arrayWithCapacity:20];
    }
    
    return _internalTotalStayTimes;
}

- (NSMutableArray *)internalMaxStayTimes
{
    if (!_internalMaxStayTimes) {
        _internalMaxStayTimes = [NSMutableArray arrayWithCapacity:20];
    }
    
    return _internalMaxStayTimes;
}

- (NSMutableArray *)internalRecordTimes
{
    if (!_internalRecordTimes) {
        _internalRecordTimes = [NSMutableArray arrayWithCapacity:20];
    }
    
    return _internalRecordTimes;
}

#pragma mark -- Private

- (void)accumulate
{
    NSDate * currentDate = [NSDate date];
    long long interval = (long long)([currentDate timeIntervalSinceDate:_lastAccumulateTime] * 1000);
    _lastAccumulateTime = currentDate;
    for (NSUInteger i = 0; i < _visibleUnits.count; ++i) {
        NSUInteger visibleUnit = [_visibleUnits[i] intValue];
        if (visibleUnit < self.internalTotalStayTimes.count) { // for protection
            self.internalTotalStayTimes[visibleUnit] = @([self.internalTotalStayTimes[visibleUnit] longLongValue] + interval);
            if ([self.internalMaxStayTimes[visibleUnit] longLongValue] < interval) {
                self.internalMaxStayTimes[visibleUnit] = @(interval);
            }
            self.internalRecordTimes[visibleUnit] = @(_lastAccumulateTime.timeIntervalSince1970);
        }
    }
}

- (void)resetAccumulator
{
    [self.internalTotalStayTimes removeAllObjects];
    [self.internalMaxStayTimes removeAllObjects];
    [self.internalRecordTimes  removeAllObjects];
    
    [self.visibleUnits removeAllObjects];
}

@end

