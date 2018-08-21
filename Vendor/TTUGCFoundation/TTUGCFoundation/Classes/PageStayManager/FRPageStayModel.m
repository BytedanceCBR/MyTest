//
//  FRPageStayModel.m
//  Article
//
//  Created by 王霖 on 15/8/9.
//
//

#import "FRPageStayModel.h"

@interface FRPageStayModel ()

/**
 *  需要记录的页面
 */
@property (nonatomic, weak)id page;

/**
 *  页面是否挂起
 */
@property (nonatomic, assign)BOOL suspend;

/**
 *  页面是否展示
 */
@property (nonatomic, assign)BOOL show;

/**
 *  最新一次进入页面的时间
 */
@property (nonatomic, assign)NSTimeInterval lastEnterPageTimeInterval;

/**
 *  页面停留时间
 */
@property (nonatomic, assign)NSTimeInterval pageStayTimeInterval;

@end

@implementation FRPageStayModel

- (instancetype)init {    
    return [self initWithPage:0];
}

- (instancetype)initWithPage:(id)page {
    self = [super init];
    if (self) {
        self.page = page;
        self.suspend = NO;
        self.show = NO;
        self.lastEnterPageTimeInterval = 0;
        self.pageStayTimeInterval = 0;
    }
    return self;
}

- (BOOL)isModelPage:(id)page {
    if (page == nil || _page == page) {
        return YES;
    }
    return NO;
}

#pragma mark - 页面停留时间统计

- (void)resumePageStay {
    if (_suspend == NO) {
        return;
    }
    self.suspend = NO;
    
    if (_show) {
        self.lastEnterPageTimeInterval = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)suspendPageStay {
    if (_suspend) {
        return;
    }
    self.suspend = YES;
    
    if (_show) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970] - _lastEnterPageTimeInterval;
        self.pageStayTimeInterval = _pageStayTimeInterval + timeInterval;
    }
}

- (void)enterPage {
    if (_show) {
        return;
    }
    self.show = YES;
    
    if (_suspend == NO) {
        self.lastEnterPageTimeInterval = [[NSDate date] timeIntervalSince1970];
    }
}

- (void)leavePage {
    if (_show == NO) {
        return;
    }
    self.show = NO;
    
    if (_suspend == NO) {
        NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970] - _lastEnterPageTimeInterval;
        self.pageStayTimeInterval = _pageStayTimeInterval + timeInterval;
    }
}

#pragma mark - 重置时间

- (void)resetPageStayTimeInterval {
    self.pageStayTimeInterval = 0;
}

@end
