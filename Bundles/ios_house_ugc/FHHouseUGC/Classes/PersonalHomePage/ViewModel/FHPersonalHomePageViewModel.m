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
@end

@implementation FHPersonalHomePageViewModel

-(instancetype)initWithController:(FHPersonalHomePageViewController *)viewController {
    if(self = [super init]) {
        self.viewController = viewController;
        self.mutex = dispatch_semaphore_create(0);
    }
    return self;
}

- (void)startLoadData {
    [self requestProfileInfo];
    [self requestFeedTabList];
}

- (void)requestProfileInfo {
    WeakSelf;
   [FHHouseUGCAPI requestHomePageInfoWithUserId:self.userId completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
       StrongSelf;
       if(!error && [model isKindOfClass:[FHPersonalHomePageProfileInfoModel class]]) {
           FHPersonalHomePageProfileInfoModel *profileInfoModel = (FHPersonalHomePageProfileInfoModel *) model;
           if([profileInfoModel.message isEqualToString:@"success"] && [profileInfoModel.errorCode integerValue] == 0) {
               self.profileInfoModel = profileInfoModel;
               [self.viewController updateProfileInfoViewWithMdoel:self.profileInfoModel];
           }
       }
    }];
}

- (void)requestFeedTabList {
    WeakSelf;
    [FHHouseUGCAPI requestPersonalHomePageTabList:nil completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        if(!error && [model isKindOfClass:[FHPersonalHomePageTabListModel class]]) {
            FHPersonalHomePageTabListModel *tabListModel = (FHPersonalHomePageTabListModel *) model;
            self.tabListModel = tabListModel;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                dispatch_semaphore_wait(self.mutex, DISPATCH_TIME_FOREVER);
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self.viewController endLoading];
                    [self.viewController updateFeedViewControllerWithMdoel:self.tabListModel];
                });
            });
        }
    }];

}

@end
