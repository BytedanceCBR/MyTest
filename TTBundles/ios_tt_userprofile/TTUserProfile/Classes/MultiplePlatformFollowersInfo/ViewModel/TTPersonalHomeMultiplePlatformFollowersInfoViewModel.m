//
//  TTPersonalHomeMultiplePlatformFollowersInfoViewModel.m
//  Article
//
//  Created by 邱鑫玥 on 2018/1/9.
//

#import "TTPersonalHomeMultiplePlatformFollowersInfoViewModel.h"
#import "TTPersonalHomeSinglePlatformFollowersInfoViewModel.h"
#import <ReactiveObjC.h>
#import "TTAccountManager.h"

@interface TTPersonalHomeMultiplePlatformFollowersInfoViewModel()

@property (nonatomic, strong) NSArray<TTPersonalHomeSinglePlatformFollowersInfoModel *> *itemModels;
@property (nonatomic, assign) TTPersonalHomePlatformFollowersInfoViewStyle uiStyle;
@property (nonatomic, strong) NSArray<TTPersonalHomeSinglePlatformFollowersInfoViewModel *> *itemViewModels;
@property (nonatomic, assign) BOOL expanded;
@property (nonatomic, copy) NSString *userID;

@end

@implementation TTPersonalHomeMultiplePlatformFollowersInfoViewModel

- (instancetype)initWithUserID:(NSString *)userID items:(NSArray<TTPersonalHomeSinglePlatformFollowersInfoModel *> *)items
{
    if (self = [super init]) {
        self.userID = userID;
        self.itemModels = items;
        
        self.expanded = [self.userID isEqualToString:[TTAccountManager userID]];
        
        [self bindRAC];
    }
    
    return self;
}

- (void)bindRAC
{
    @weakify(self);
    [RACObserve(self, itemModels) subscribeNext:^(NSArray<TTPersonalHomeSinglePlatformFollowersInfoModel *> *itemModels) {
        @strongify(self);
        NSMutableArray *mutArr = [NSMutableArray array];
        
        for (TTPersonalHomeSinglePlatformFollowersInfoModel *item in itemModels) {
            TTPersonalHomeSinglePlatformFollowersInfoViewModel *itemViewModel = [[TTPersonalHomeSinglePlatformFollowersInfoViewModel alloc] initWithItemModel:item];
            
            if (itemViewModel) {
                [mutArr addObject:itemViewModel];
            }
        }
        
        self.itemViewModels = [mutArr copy];
        
        self.uiStyle = self.itemViewModels.count > 2 ? TTPersonalHomePlatformFollowersInfoViewStyle2 : TTPersonalHomePlatformFollowersInfoViewStyle1;
        
        for (TTPersonalHomeSinglePlatformFollowersInfoViewModel *itemViewModel in self.itemViewModels) {
            itemViewModel.uiStyle = self.uiStyle;
        }
    }];
    
    [[RACObserve(self, expanded) filter:^BOOL(NSNumber *isExpanded) {
        return [isExpanded boolValue];
    }] subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self trackShowEvent];
    }];
}

- (void)refreshWithItems:(NSArray<TTPersonalHomeSinglePlatformFollowersInfoModel *> *)platformFollowersItemModels
{
    self.itemModels = platformFollowersItemModels;
}

- (BOOL)canExpand
{
    return self.itemViewModels.count >= 2;
}

- (void)changeExpandStatus
{
    self.expanded = !self.expanded;
}

- (void)trackShowEvent
{
    [TTTrackerWrapper eventV3:@"followers_show" params:@{@"position" : @"profile"}];
}

@end
