//
//  TTGuideDispatchManager.m
//  Article
//
//  Created by fengyadong on 16/6/2.
//
//

#import "TTGuideDispatchManager.h"
#import "TTBaseMacro.h"

@interface TTGuideDispatchManager()

@property (nonatomic, strong) NSMutableArray <id<TTGuideProtocol>> *guideItems;
@property (nonatomic, strong) id<TTGuideProtocol> currentItem;/*防止当前任务还没有结束就开始又被执行*/

@end

@implementation TTGuideDispatchManager

- (instancetype)init {
    if (self = [super init]) {
        self.guideItems = [NSMutableArray array];
    }
    return self;
}

- (void)addGuideViewItem:(id<TTGuideProtocol>)item withContext:(id)context {
    item.context = context;
    [self.guideItems addObject:item];
    
    NSMutableArray <id<TTGuideProtocol>> *copiedGuideItems = [self.guideItems mutableCopy];
    NSMutableArray <id<TTGuideProtocol>> *normalGuideItems = [NSMutableArray array];
    NSMutableArray <id<TTGuideProtocol>> *highGuideItems = [NSMutableArray array];
    NSMutableArray <id<TTGuideProtocol>> *lowGuideItems = [NSMutableArray array];
    [copiedGuideItems enumerateObjectsUsingBlock:^(id<TTGuideProtocol>  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj respondsToSelector:@selector(priority)]) {
            TTGuidePriority priority = [obj priority];
            switch (priority) {
                case kTTGuidePriorityHigh:
                    [highGuideItems addObject:obj];
                    break;
                case kTTGuidePriorityLow:
                    [lowGuideItems addObject:obj];
                    break;
                default:
                    [normalGuideItems addObject:obj];
                    break;
            }
        } else {
            [normalGuideItems addObject:obj];
        }
    }];
    [self.guideItems removeAllObjects];
    [self.guideItems addObjectsFromArray:highGuideItems];
    [self.guideItems addObjectsFromArray:normalGuideItems];
    [self.guideItems addObjectsFromArray:lowGuideItems];
    
    [self showNextItemIfNeed];
}

- (void)removeGuideViewItem:(id<TTGuideProtocol>)item {
    if (self.currentItem == item) {
        self.currentItem = nil;
    }
    if ([self.guideItems containsObject:item]) {
        [self.guideItems removeObject:item];
    }
    [self showNextItemIfNeed];
}

- (void)showNextItemIfNeed {
    if (SSIsEmptyArray(self.guideItems) || self.currentItem) {
        return;
    }
    
    id<TTGuideProtocol> currentItem = [self.guideItems firstObject];
    
    if ([currentItem shouldDisplay:currentItem.context] && [currentItem respondsToSelector:@selector(showWithContext:)]) {
        self.currentItem = currentItem;
        if ([NSThread isMainThread]) {
            [currentItem showWithContext:currentItem.context];
        } else{
            dispatch_sync(dispatch_get_main_queue(), ^{
                [currentItem showWithContext:currentItem.context];
            });
        }
    }
    else {
        [self removeGuideViewItem:currentItem];
    }
}

- (BOOL)isQueueEmpty {
    return SSIsEmptyArray(self.guideItems);
}

- (void)insertGuideViewItem:(id<TTGuideProtocol>)item beforeClassName:(NSString *)className withContext:(id)context {
    NSUInteger currentIdex = 0;
    for (NSInteger index = self.guideItems.count - 1; index >= 0; index--) {
        if ([[self.guideItems objectAtIndex:index] isKindOfClass:NSClassFromString(className)]) {
            currentIdex = index;
            break;
        }
    }
    if ([self.guideItems objectAtIndex:currentIdex] == self.currentItem) {
        return;
    }
    item.context = context;
    [self.guideItems insertObject:item atIndex:currentIdex];
    [self showNextItemIfNeed];
}

- (void)removeItemWithClassName:(NSString *)className {
    NSMutableArray *copyArray = [NSMutableArray arrayWithArray:self.guideItems];
    for(id<TTGuideProtocol> item in copyArray) {
        if ([item isKindOfClass:NSClassFromString(className)] && item != self.currentItem) {
            [self removeGuideViewItem:item];
        }
    }
}

- (BOOL)containItemForClass:(Class)aClass {
    __block BOOL bContain = NO;
    NSMutableArray *copyArray = [NSMutableArray arrayWithArray:self.guideItems];
    [copyArray enumerateObjectsUsingBlock:^(id<TTGuideProtocol>  _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([item isKindOfClass:aClass]) {
            bContain = YES;
            *stop = YES;
        }
    }];
    return bContain;
}
@end
