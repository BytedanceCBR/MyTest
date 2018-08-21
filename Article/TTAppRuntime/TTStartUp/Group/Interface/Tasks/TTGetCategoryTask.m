//
//  TTGetCategoryTask.m
//  Article
//
//  Created by fengyadong on 17/1/22.
//
//

#import "TTGetCategoryTask.h"
#import "TTArticleCategoryManager.h"
#import <TTTrackerWrapper.h>

static BOOL kTTHasReceivedGotCategoryNotification = NO;

@implementation TTGetCategoryTask

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(categoryGotFinished:) name:kAritlceCategoryGotFinishedNotification object:nil];
    }
    return self;
}

- (NSString *)taskIdentifier {
    return @"GetCategory";
}

- (BOOL)isResident {
    return YES;
}

#pragma mark - UIApplicationDelegate Method
- (void)applicationDidBecomeActive:(UIApplication *)application {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([SSCommonLogic couldRequestForKey:SSCommonLogicTimeDictRequestCategoryKey]) {
            [[TTArticleCategoryManager sharedManager] startGetCategory];
            [SSCommonLogic updateRequestTimeForKey:SSCommonLogicTimeDictRequestCategoryKey];
        }
    });
}

- (void)categoryGotFinished:(NSNotification *)notification {
    if (!kTTHasReceivedGotCategoryNotification) {
        kTTHasReceivedGotCategoryNotification = YES;

        NSArray *categories = [[TTArticleCategoryManager sharedManager] preFixedAndSubscribeCategories];
        [categories enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if (obj && [obj isKindOfClass:[TTCategory class]]) {
                TTCategory *category = (TTCategory *)obj;
                if ([category.categoryID isEqualToString:kTTFollowCategoryID]) {
                    [TTTrackerWrapper eventV3:@"follow_channel_launch" params:@{@"rank" : [NSNumber numberWithUnsignedInteger:category.orderIndex]}];
                    *stop = YES;
                }
            }
        }];
    }
}

@end
