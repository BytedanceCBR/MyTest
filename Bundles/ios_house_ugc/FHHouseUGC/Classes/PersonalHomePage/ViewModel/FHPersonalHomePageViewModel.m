//
//  FHPersonalHomePageViewModel.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/6.
//

#import "FHPersonalHomePageViewModel.h"
#import "FHPersonalHomePageProfileInfoModel.h"
#import "FHPersonalHomePageTabListModel.h"
#import "FHHouseUGCAPI.h"
#import "FHCommonDefines.h"


@interface FHPersonalHomePageViewModel () 
@property(nonatomic,weak) FHPersonalHomePageViewController *viewController;
@property(nonatomic,strong) FHPersonalHomePageProfileInfoModel *profileInfoModel;
@property(nonatomic,strong) FHPersonalHomePageTabListModel *tabListModel;
@property(nonatomic,strong) dispatch_group_t personalHomePageGroup;
@end

@implementation FHPersonalHomePageViewModel

-(instancetype)initWithController:(FHPersonalHomePageViewController *)viewController {
    if(self = [super init]) {
        self.viewController = viewController;
        self.personalHomePageGroup = dispatch_group_create();
    }
    return self;
}

- (void)startLoadData {
    [self requestProfileInfo];
    [self requestFeedTabList];
    
    dispatch_group_notify(self.personalHomePageGroup, dispatch_get_main_queue(), ^{
        [self.viewController endLoading];
        [self.viewController updateProfileInfoWithMdoel:self.profileInfoModel tabListWithMdoel:self.tabListModel];
    });
}

- (void)requestProfileInfo {
    dispatch_group_enter(self.personalHomePageGroup);
    WeakSelf;
   [FHHouseUGCAPI requestHomePageInfoWithUserId:self.userId completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
       StrongSelf;
       if(!error && [model isKindOfClass:[FHPersonalHomePageProfileInfoModel class]]) {
           FHPersonalHomePageProfileInfoModel *profileInfoModel = (FHPersonalHomePageProfileInfoModel *) model;
           if([profileInfoModel.message isEqualToString:@"success"] && [profileInfoModel.errorCode integerValue] == 0) {
               self.profileInfoModel = profileInfoModel;
           }
       }
       dispatch_group_leave(self.personalHomePageGroup);
    }];
}

- (void)requestFeedTabList {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"channel_id"] = @"94349558589";
    params[@"user_id"] = self.userId;
    
    dispatch_group_enter(self.personalHomePageGroup);
    WeakSelf;
    [FHHouseUGCAPI requestPersonalHomePageTabList:params completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        if(!error && [model isKindOfClass:[FHPersonalHomePageTabListModel class]]) {
            FHPersonalHomePageTabListModel *tabListModel = (FHPersonalHomePageTabListModel *) model;
            self.tabListModel = tabListModel;
        }
        dispatch_group_leave(self.personalHomePageGroup);
    }];

}

@end
