//
//  FRPageStayManager.m
//  Article
//
//  Created by 王霖 on 15/8/9.
//
//

#import "FRPageStayManager.h"
#import "FRPageStayModel.h"
#import <objc/runtime.h>

#define kPageAssociatedModelKey @"pageAssociatedModelKey"

@interface FRPageStayManager ()

@property (nonatomic, strong) NSMutableArray *pageStayModels;

@end

@implementation FRPageStayManager

static FRPageStayManager *pageStayManager;
+ (instancetype)sharePageStayManager {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        pageStayManager = [[FRPageStayManager alloc] init];
    });
    return pageStayManager;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.pageStayModels = [NSMutableArray array];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:) name:UIApplicationWillResignActiveNotification object:nil];
    }
    return self;
}

- (void)startPageStayWithPage:(id<FRPageStayManagerDelegate>)page {
    for (FRPageStayModel *model in _pageStayModels) {
        if ([model isModelPage:page]) {
            return;
        }
    }
    FRPageStayModel *model = [[FRPageStayModel alloc] initWithPage:page];
    objc_setAssociatedObject(page, kPageAssociatedModelKey, model, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [_pageStayModels addObject:model];
}

- (void)endPageStayWithPage:(id<FRPageStayManagerDelegate>)page {
    FRPageStayModel *targetModel = objc_getAssociatedObject(page, kPageAssociatedModelKey);
    if (targetModel) {
        [_pageStayModels removeObject:targetModel];
    }
}

- (void)enterPageStayWithPage:(id<FRPageStayManagerDelegate>)page {
    FRPageStayModel *targetModel = nil;
    for (FRPageStayModel *model in _pageStayModels) {
        if ([model isModelPage:page]) {
            targetModel = model;
        }
    }
    if (targetModel == nil) {
        return;
    }
    
    //页面展示
    [targetModel enterPage];
}

- (void)leavePageStayWithPage:(id<FRPageStayManagerDelegate>)page {
    FRPageStayModel *targetModel = nil;
    for (FRPageStayModel *model in _pageStayModels) {
        if ([model isModelPage:page]) {
            targetModel = model;
            break;
        }
    }
    if (targetModel == nil) {
        return;
    }
    
    //页面隐藏
    [targetModel leavePage];
    if (page && [page respondsToSelector:@selector(pageStayRecorderWithTimeInterval:pageDisappearType:)]) {
        int64_t pageStayTimeInterval = targetModel.pageStayTimeInterval * 1000;
        [page pageStayRecorderWithTimeInterval:pageStayTimeInterval pageDisappearType:FRPageDisappearTypeLeave];
    }
    [targetModel resetPageStayTimeInterval];
}

#pragma mark - Notification

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    for (FRPageStayModel *model in _pageStayModels) {
        [model resumePageStay];
    }
}

- (void)applicationWillResignActive:(NSNotification *)notification {
    for (FRPageStayModel *model in _pageStayModels) {
        [model suspendPageStay];
        id page = model.page;
        if (page && [page respondsToSelector:@selector(pageStayRecorderWithTimeInterval:pageDisappearType:)]) {
            int64_t pageStayTimeInterval = model.pageStayTimeInterval * 1000;
            [page pageStayRecorderWithTimeInterval:pageStayTimeInterval pageDisappearType:FRPageDisappearTypeSuspend];
        }
        [model resetPageStayTimeInterval];
    }
}

@end
