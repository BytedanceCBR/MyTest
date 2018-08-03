//
//  TTSocialBaseViewController.m
//  Article
//
//  Created by liuzuopeng on 8/9/16.
//
//

#import "TTSocialBaseViewController.h"



@interface TTSocialBaseViewController <ModelType : TTFriendModel *> ()

@property (nonatomic, assign) NSUInteger hasMore; // 是否存在更多的数据
@property (nonatomic, strong, readwrite) FriendDataManager *friendDataManager;
@property (nonatomic, strong, readwrite) NSMutableArray<ModelType> *friendModels;
@end


@implementation TTSocialBaseViewController
- (instancetype)initWithUserID:(NSString *)userID {
    ArticleFriend *aFriend = [ArticleFriend new];
    aFriend.userID = userID;
    return [self initWithArticleFriend:aFriend];
}

- (instancetype)initWithArticleFriend:(ArticleFriend *)aFriend {
    if ((self = [self init])) {
        _currentFriend = aFriend;
    }
    return self;
}

- (instancetype)init {
    if ((self = [super init])) {
        self.reloadEnabled = YES;
        
        _umengEventName = @"add_friends";
        _relationType = FriendDataListTypeNone;
        _friendModels = [NSMutableArray array];
        
        _offset = 0;
        _hasMore = NO;
    }
    return self;
}

- (void)dealloc {
    _friendDataManager.delegate = nil;
    _friendDataManager = nil;
    _currentFriend = nil;
}

- (void)triggerReload {
    if (self.reloadEnabled) {
        _offset = 0;
        
        [super triggerReload];
    }
}

- (void)triggerLoadMore {
    if (self.loadMoreEnabled) {
        [super triggerLoadMore];
    }
}

- (BOOL)hasMoreData {
    return _hasMore;
}

#pragma mark - UIViewControllerErrorHandler delegate

- (BOOL)tt_hasValidateData {
    return [_friendModels count] > 0;
}

#pragma mark - FriendDataManagerDelegate

- (void)friendDataManager:(FriendDataManager*)dataManager finishGotListWithType:(FriendDataListType)type error:(NSError *)error result:(NSArray *)result totalNumber:(unsigned long long)totalNumber anonymousNumber:(unsigned long long)anonymousNumber hasMore:(BOOL)hasMore offset:(int)offset {
    _hasMore = [result count] > 0 && !error && hasMore;
    _offset += [result count];
    //    self.tableView.hasMore = _hasMore;
    if (!_friendModels) {
        _friendModels = [NSMutableArray array];
    } else if ([self isRefreshing]) {
        [_friendModels removeAllObjects];
    }
    
    if (!error) {
        for (id friendModel in result) {
            @try {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
                if ([friendModel respondsToSelector:@selector(totalNumber)]) {
                    [friendModel setValue:@(totalNumber) forKey:@"totalNumber"];
                }
                
                if ([friendModel respondsToSelector:@selector(hasMore)]) {
                    [friendModel setValue:[NSNumber numberWithBool:hasMore] forKey:@"hasMore"];
                }
                
                if ([friendModel respondsToSelector:@selector(visitorUID)]) {
                    [friendModel setValue:_currentFriend.userID forKey:@"visitorUID"];
                }
#pragma clang diagnostic pop
            } @catch (NSException *exception) {
            } @finally {
            }
            
            [_friendModels addObject:friendModel];
        }
    }
    
    // set view error type
    if ([result count] <= 0 && [self.currentFriend isAccountUser]) {
        if (type == FriendDataListTypeFollower) {
            self.ttViewType = TTFullScreenErrorViewTypeNoFollowers;
        } else if (type == FriendDataListTypeFowllowing) {
            self.ttViewType = TTFullScreenErrorViewTypeNoFriends;
        } else {
            self.ttViewType = TTFullScreenErrorViewTypeEmpty;
        }
    } else if ([result count] <= 0 && ![self.currentFriend isAccountUser]) {
        if (type == FriendDataListTypeFollower) {
            self.ttViewType = TTFullScreenErrorViewTypeOtherNoFollowers;
        } else if (type == FriendDataListTypeFowllowing) {
            self.ttViewType = TTFullScreenErrorViewTypeOtherNoFriends;
        } else {
            self.ttViewType = TTFullScreenErrorViewTypeEmpty;
        }
    } else {
        self.ttViewType = TTFullScreenErrorViewTypeEmpty;
    }
    
    [self reloadWithError:error];
}

#pragma mark - properties

- (FriendDataManager *)friendDataManager {
    if (!_friendDataManager) {
        _friendDataManager = [[FriendDataManager alloc] init];
        _friendDataManager.delegate = self;
    }
    return _friendDataManager;
}

- (void)setCurrentFriend:(ArticleFriend *)currentFriend {
    if (_currentFriend != currentFriend)  {
        _currentFriend = currentFriend;
        
        [self triggerReload];
    }
}

- (UIEdgeInsets)tableViewOriginalContentInset {
    return UIEdgeInsetsZero;
}

- (UITableViewCellSeparatorStyle)tableViewSeparatorStyle {
    return UITableViewCellSeparatorStyleSingleLine;
}

- (UITableViewStyle)tableViewStyle {
    return UITableViewStyleGrouped;
}

+ (CGFloat)insetRightOfSeparator {
    return [TTDeviceUIUtils tt_padding:30.f/2];
}
@end
