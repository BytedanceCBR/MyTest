//
//  FRGifAutoPlayManager.m
//  Pods
//
//  Created by lipeilun on 2018/6/22.
//

#import "FRGifAutoPlayManager.h"
#import <TTBaseLib/NetworkUtilities.h>
#import <TTBaseLib/NSDictionary+TTAdditions.h>

NSString * const kGifAutoPlayOverNotification = @"kGifAutoPlayOverNotification";
NSString * const kGifBeginBrowserNotification = @"kGifBeginBrowserNotification";
NSString * const kGifPlayAbortOverNotification = @"kGifPlayAbortOverNotification";

@interface FRGifAutoPlayManager()
@property (nonatomic, copy) NSArray<id<FRGifAutoPlayMethods>> *gifChainArray;
@property (nonatomic, weak) id<FRGifAutoPlayMethods> insertController;
@property (nonatomic, weak) UIScrollView *preScrollView;
@property (nonatomic, assign) CGFloat preOffsetY;
@property (nonatomic, assign) NSTimeInterval preTimeInterval;
@property (nonatomic, weak) id<FRGifAutoPlayMethods> playingController;
@end

@implementation FRGifAutoPlayManager

+ (FRGifAutoPlayManager *)sharedInstance {
    static dispatch_once_t onceToken;
    static FRGifAutoPlayManager *manager;
    dispatch_once(&onceToken, ^{
        manager = [FRGifAutoPlayManager new];
    });
    return manager;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init {
    if (self = [super init]) {
        self.gifChainArray = [NSArray array];
        self.preOffsetY = 0;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveGifAutoPlayOverNotification:)
                                                     name:kGifAutoPlayOverNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveGifBeginBrowserNotification:)
                                                     name:kGifBeginBrowserNotification
                                                   object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(receiveGifPlayAbortNotification:)
                                                     name:kGifPlayAbortOverNotification
                                                   object:nil];
    }
    return self;
}

- (void)startGifPlayInTableView:(UITableView *)tableView {
    if (!TTNetworkWifiConnected()) {
        return;
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self __refreshGifPlayStateInTableView:tableView];
    });
}

- (void)insertGifPlayHeader:(id<FRGifAutoPlayCellProtocol>)object {
    if (!TTNetworkWifiConnected()) {
        return;
    }
    if ([object respondsToSelector:@selector(ugc_gifPlayController)]) {
        NSObject<FRGifAutoPlayMethods> *gifController = [object ugc_gifPlayController];
        
        if (gifController) {
            self.insertController = gifController;
            [gifController ugc_startGifPlayWithNoScroll];
        }
    }
}

- (void)removeGifPlayHeader:(id<FRGifAutoPlayCellProtocol>)object {
    
    if ([object respondsToSelector:@selector(ugc_gifPlayController)]) {
        NSObject<FRGifAutoPlayMethods> *gifController = [object ugc_gifPlayController];
        
        if (gifController) {
            self.insertController = nil;
            [gifController ugc_stopGifPlayWithNoScroll];
        }
        
        if (!TTNetworkWifiConnected()) {
            return;
        }
        [self.playingController ugc_startGifPlay];
    }
}

#pragma mark - Notification

- (void)receiveGifAutoPlayOverNotification:(NSNotification *)notification {
    if (notification.object) {
        NSInteger index = [self.gifChainArray indexOfObject:notification.object];
        BOOL single = [notification.userInfo tt_boolValueForKey:@"single"];
        if ([notification.object isEqual:self.insertController]) {
            //非列表，播放完最后一个重头播
            [self.insertController ugc_startGifPlayWithNoScroll];
        } else {
            //列表
            if (index != NSNotFound && index + 1 < self.gifChainArray.count) {
                //当前cell播放完后自动播下一个
                id<FRGifAutoPlayMethods> nextController = [self.gifChainArray objectAtIndex:index + 1];
                [nextController ugc_startGifPlay];
                self.playingController = nextController;
            } else if (single) {
                //如果播放链后没有了，且当前是单图
                if ([self.gifChainArray containsObject:notification.object]) {
                    //当图片播放时，划出屏幕不到1/2，此时停止再判断，gifChain已经更新，要保护
                    [notification.object ugc_startGifPlay];
                    self.playingController = notification.object;
                } else {
                    [notification.object ugc_stopGifPlay];
                    self.playingController = nil;
                }
            } else {
                //如果不是单图，播第一个
                [self.gifChainArray.firstObject ugc_startGifPlay];
                self.playingController = self.gifChainArray.firstObject;
            }
        }
    }
}

- (void)receiveGifBeginBrowserNotification:(NSNotification *)notification {
    if (notification.object) {
        //如果去查看图片，先停止当前播放的，再定位到点击的，因为屏幕上可能有多个可以播放的Cell
        if (![self.playingController isEqualToDiffableObject:notification.object]) {
            [self.playingController ugc_stopGifPlay];
        }
        self.playingController = notification.object;
    }
}

- (void)receiveGifPlayAbortNotification:(NSNotification *)notification {
    if ([self.playingController isEqualToDiffableObject:notification.object]) {
        self.playingController = nil;
    }
}

#pragma makr - private

- (void)__refreshGifPlayStateInTableView:(UITableView *)tableView {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    if ((timeInterval - self.preTimeInterval) * 1000 < 100) {
        return;
    }
    
    self.preTimeInterval = timeInterval;
    NSArray *visibleCells = tableView.visibleCells;
    BOOL startedPlay = NO;
    NSMutableArray<id<FRGifAutoPlayMethods>> *tempChainArray = [NSMutableArray array];
    for (UITableViewCell<FRGifAutoPlayCellProtocol> *cell in visibleCells) {
        if (![cell conformsToProtocol:@protocol(FRGifAutoPlayCellProtocol)]
            || ![cell respondsToSelector:@selector(ugc_gifPlayController)]) {
            continue;
        }
        
        NSObject<FRGifAutoPlayMethods> *gifController = [cell ugc_gifPlayController];
        if (!gifController || ![gifController ugc_gifEnoughToPlay]) {
            continue;
        }
        
        //此时存在的要么是展示完全的单图，要么是至少展示了一行的多图
        [tempChainArray addObject:gifController];
    }
    
    if (tempChainArray.count == 0) {
        //当前没有完整显示的单图gif或至少一行的多图
        self.gifChainArray = tempChainArray;
        self.preScrollView = tableView;
        self.preOffsetY = tableView.contentOffset.y;
        return;
    }
    
    IGListIndexPathResult *diffResult = IGListDiffPaths(0, 0, self.gifChainArray, tempChainArray, IGListDiffEquality);
    
    NSMutableArray *inserts = [diffResult.inserts mutableCopy];
    NSMutableArray *deletes = [diffResult.deletes mutableCopy];
    NSMutableArray *moves = [diffResult.moves mutableCopy];
    
    NSMutableArray *deleteCells = [NSMutableArray array];
    NSMutableArray *insertCells = [NSMutableArray array];

    {
        for (NSIndexPath *indexPath in deletes) {
            [deleteCells addObject:[self.gifChainArray objectAtIndex:indexPath.item]];
        }
    }
    
    {
        for (NSIndexPath *indexPath in inserts) {
            [insertCells addObject:[tempChainArray objectAtIndex:indexPath.item]];
        }
    }
    
    if ([tableView isEqual:self.preScrollView]) {
        BOOL moveUp = self.preOffsetY - tableView.contentOffset.y < 0;
        if (self.preOffsetY == tableView.contentOffset.y) {
            //页面切换，比如进入个人主页等
            [self.playingController ugc_startGifPlay];
        }
        
        id<FRGifAutoPlayMethods> nextCell = nil;
        if (tempChainArray.count > 1) {
            if (moveUp) {
                nextCell = tempChainArray.lastObject;
            } else {
                nextCell = tempChainArray.firstObject;
            }
        } else {
            nextCell = tempChainArray.firstObject;
        }
        
        if (inserts.count > 0 && deletes.count > 0) {
            //有进有出
            for (id<FRGifAutoPlayMethods> cell in deleteCells) {
                [cell ugc_stopGifPlay];
            }
            
            if (![deleteCells containsObject:self.playingController]) {
                if (![self.playingController isEqualToDiffableObject:nextCell]) {
                    [self.playingController ugc_stopGifPlay];
                    [nextCell ugc_startGifPlay];
                    self.playingController = nextCell;
                }
            } else {
                //如果当前播放的离开了，重新开始下一个
                [nextCell ugc_startGifPlay];
                self.playingController = nextCell;
            }
        } else if (inserts.count > 0 && deletes.count == 0) {
            //有进无出
            //如果当前不是下一个要播的，停止播下一个
            if (![self.playingController isEqualToDiffableObject:nextCell]) {
                [self.playingController ugc_stopGifPlay];
                [nextCell ugc_startGifPlay];
                self.playingController = nextCell;
            }
        } else if (inserts.count == 0 && deletes.count > 0) {
            //有出无进，先停止全部出的
            for (id<FRGifAutoPlayMethods> cell in deleteCells) {
                [cell ugc_stopGifPlay];
            }
            
            if (![deleteCells containsObject:self.playingController]) {
                //如果当前播放的没有离开，且不是下一个，切换下一个播，否则不处理
                if (![self.playingController isEqualToDiffableObject:nextCell]) {
                    [self.playingController ugc_stopGifPlay];
                    [nextCell ugc_startGifPlay];
                    self.playingController = nextCell;
                }
            } else {
                //如果当前播放的离开了，重新开始下一个
                [nextCell ugc_startGifPlay];
                self.playingController = nextCell;
            }
        } else {
            if (tempChainArray.count > 1) {
                if (![self.playingController isEqualToDiffableObject:nextCell]) {
                    for (id<FRGifAutoPlayMethods> cell in tempChainArray) {
                        [cell ugc_stopGifPlay];
                    }
                    
                    [nextCell ugc_startGifPlay];
                    self.playingController = nextCell;
                }
            } else {
                if (![tempChainArray.firstObject isEqualToDiffableObject:self.playingController]) {
                    [tempChainArray.firstObject ugc_startGifPlay];
                    self.playingController = tempChainArray.firstObject;
                }
            }
        }
    } else {
        //换scrollView了
        for (id<FRGifAutoPlayMethods> cell in tempChainArray) {
            [cell ugc_stopGifPlay];
        }
        
        [tempChainArray.firstObject ugc_startGifPlay];
        self.playingController = tempChainArray.firstObject;
    }
   
    
    self.preScrollView = tableView;
    self.preOffsetY = tableView.contentOffset.y;
    self.gifChainArray = tempChainArray;
}

@end
