//
//  FHFirstStartManager.m
//  FHHouseBase
//
//  Created by xubinbin on 2020/12/9.
//

#import "FHFirstPageManager.h"
#import <FHHouseBase/NSObject+FHOptimize.h>
#import "FHUserTracker.h"

@interface FHFirstPageManager()

@property (nonatomic, copy) NSMutableArray *array;

@end

@implementation FHFirstPageManager

+ (instancetype)sharedInstance {
    static FHFirstPageManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] init];
    });
    return manager;
}

- (NSMutableArray *)array {
    if (!_array) {
        _array = [[NSMutableArray alloc] init];
    }
    return _array;
}

- (void)addFirstPageModelWithPageType:(NSString *)pageType withUrl:(NSString *)url withTabName:(NSString *)tabName withPriority:(NSInteger)priorityIndex {
    FHFirstPageModel *model = [[FHFirstPageModel alloc] init];
    model.pageType = pageType;
    model.url = url;
    model.tabName = tabName;
    model.priorityIndex = priorityIndex;
    [self.array addObject:model];
}

- (void)sendTrace {
    __weak typeof(self) wSelf = self;
    [self executeOnce:^{
        if ([wSelf.array count] > 0) {
            NSArray *result = [wSelf.array sortedArrayUsingComparator:^NSComparisonResult(FHFirstPageModel *obj1, FHFirstPageModel *obj2) {
                if (obj1.priorityIndex < obj2.priorityIndex) {
                    return NSOrderedDescending;
                }
                return NSOrderedAscending;
            }];
            FHFirstPageModel *model = [result firstObject];
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            [dict setValue:model.pageType forKey:@"page_type"];
            if (model.url && model.url.length > 0) {
                [dict setValue:model.url forKey:@"url"];
            }
            if (model.tabName && model.tabName.length > 0) {
                [dict setValue:model.tabName forKey:@"tab_name"];
            }
            TRACK_EVENT(@"first_start_page", dict);
        }
    } token:FHExecuteOnceUniqueTokenForCurrentContext];
}

@end

@implementation FHFirstPageModel

@end

