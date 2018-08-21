//
//  NSObject+TTDataAdapter.m
//  CSDoubleBindModel
//
//  Created by SongChai on 2017/5/4.
//  Copyright © 2017年 SongChai. All rights reserved.
//

#import "NSObject+TTDataAdapter.h"
#import <objc/message.h>
#import "NSTimer+Additions.h"

@implementation TTTimeScheduleModel {
    NSTimer* _timer;
}

- (instancetype)init {
    self = [super init];
    self.currentTimeInterval = [NSDate timeIntervalSinceReferenceDate];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(onTimer) userInfo:nil repeats:YES];
    
    return self;
}

- (void)onTimer {
    self.currentTimeInterval = [NSDate timeIntervalSinceReferenceDate];
}

+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static TTTimeScheduleModel* instance;
    dispatch_once(&onceToken, ^{
        instance = [[TTTimeScheduleModel alloc] init];
    });
    return instance;
}

@end


static void *NSObjectKVOControllerKey = &NSObjectKVOControllerKey;
static void *NSObjectKVOControllerNonRetainingKey = &NSObjectKVOControllerNonRetainingKey;

@implementation NSObject (TTDataAdapter)

- (TTDataAdapter *)_TTDataAdapter {
    return objc_getAssociatedObject(self, NSObjectKVOControllerKey);
}

- (void)set_TTDataAdapter:(TTDataAdapter *)adapter {
    objc_setAssociatedObject(self, NSObjectKVOControllerKey, adapter, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)setTTDataAdapter:(TTDataAdapter *)adapter {
    [self set_TTDataAdapter:adapter];
    [adapter prepareWithViewData:self];
}

- (TTDataAdapter *)TTDataAdapter {
    return [self _TTDataAdapter];
}

- (void)setTimeScheduleModel:(TTTimeScheduleModel *)model {
    objc_setAssociatedObject(self, @selector(timeScheduleModel), model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TTTimeScheduleModel *)timeScheduleModel {
    TTTimeScheduleModel* model = objc_getAssociatedObject(self, @selector(timeScheduleModel));
    if (model == nil) {
        model = [TTTimeScheduleModel shareInstance];
        [self setTimeScheduleModel:model];
    }
    return model;
}
@end


