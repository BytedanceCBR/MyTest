//
//  TTVPlayerBackgroundManager.m
//  Article
//
//  Created by panxiang on 2017/6/12.
//
//

#import "TTVPlayerBackgroundManager.h"

@interface TTVPlayerBackgroundManager()
@property (nonatomic ,copy)ActiveBlock becomeActive;
@property (nonatomic ,copy)ActiveBlock resignActive;
@end

@implementation TTVPlayerBackgroundManager
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self ttv_addAppNotification];
    }
    return self;
}

- (void)ttv_addAppNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
}

- (void)addDidBecomeActiveBlock:(ActiveBlock)becomeActive willResignActive:(ActiveBlock)resignActive
{
    self.becomeActive = becomeActive;
    self.resignActive = resignActive;
}

- (void)applicationDidBecomeActive:(NSNotification *)noti{
    if (self.becomeActive) {
        self.becomeActive();
    }
}

- (void)applicationWillResignActive:(NSNotification *)noti {
    if (self.resignActive) {
        self.resignActive();
    }
}
@end
