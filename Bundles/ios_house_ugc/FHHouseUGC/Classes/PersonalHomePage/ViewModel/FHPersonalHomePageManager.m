//
//  FHPersonalHomePageManager.m
//  FHHouseUGC
//
//  Created by bytedance on 2020/12/8.
//

#import "FHPersonalHomePageManager.h"
#import "FHPersonalHomePageProfileInfoView.h"
#import "FHPersonalHomePageProfileInfoModel.h"
#import "FHPersonalHomePageTabListModel.h"
#import "FHPersonalHomePageFeedViewController.h"
#import "FHPersonalHomePageViewController.h"
#import "FHPersonalHomePageFeedListViewController.h"
#import "TTAccountManager.h"
#import "TTAccount+Multicast.h"
#import "FHHouseUGCAPI.h"
#import "FHEnvContext.h"
#import "FHNavBarView.h"
#import "UIImage+FIconFont.h"
#import "FHCommonDefines.h"
#import "UIViewAdditions.h"
#import "UIDevice+BTDAdditions.h"


@interface FHPersonalHomePageManager () <TTAccountMulticastProtocol>
@property(nonatomic,weak) FHPersonalHomePageProfileInfoView *profileInfoView;
@property(nonatomic,weak) UIScrollView *scrollView;
@property(nonatomic,weak) FHNavBarView *navBar;
@property(nonatomic,assign) BOOL scrollViewScrollEnable;
@property(nonatomic,assign) BOOL tableViewScrollEnable;
@property(nonatomic,weak) FHPersonalHomePageTabListModel *tabListModel;
@property(nonatomic,assign) CGFloat beginOffset;
@property(nonatomic,assign) CGFloat lastOffset;
@end

@implementation FHPersonalHomePageManager

-(instancetype)init {
    if(self = [super init]) {
        self.feedListVCArray = [NSMutableArray array];
        self.userId = @"";
        self.isNoFeed = YES;
        self.scrollViewScrollEnable = YES;
        self.tableViewScrollEnable = NO;
        self.viewController = nil;
        self.feedViewController = nil;
        self.tabListModel = nil;
        self.beginOffset = 0;
        self.lastOffset = 0;
        self.isOpen = YES;
        [TTAccount addMulticastDelegate:self];
    }
    return self;
}

-(void)dealloc {
    [TTAccount removeMulticastDelegate:self];
}

-(void)onAccountUserProfileChanged:(NSDictionary *)changedFields error:(NSError *)error {
    WeakSelf;
    [FHHouseUGCAPI requestHomePageInfoWithUserId:self.userId completion:^(id<FHBaseModelProtocol>  _Nonnull model, NSError * _Nonnull error) {
        StrongSelf;
        if(!error && [model isKindOfClass:[FHPersonalHomePageProfileInfoModel class]]) {
            FHPersonalHomePageProfileInfoModel *profileInfoModel = (FHPersonalHomePageProfileInfoModel *) model;
            if([profileInfoModel.message isEqualToString:@"success"] && [profileInfoModel.errorCode integerValue] == 0) {
                [self updateProfileInfoWithModel:profileInfoModel];
            }
        }
     }];
}

-(void)updateProfileInfoWithModel:(FHPersonalHomePageProfileInfoModel *)profileInfoModel tabListWithMdoel:(FHPersonalHomePageTabListModel *)tabListModel {
    if(!profileInfoModel) {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        return;
    }
    self.isOpen = [[TTAccountManager userID] isEqualToString:self.userId] || ![profileInfoModel.data.FHomePageAuth boolValue];
    self.tabListModel = tabListModel;
    
    NSArray *vwhiteList =  [FHEnvContext getUGCUserVWhiteList];
    BOOL isVerifyShow = [vwhiteList containsObject:self.userId];
    
    self.viewController.customNavBarView.title.text = profileInfoModel.data.name;
    [self.profileInfoView updateWithModel:profileInfoModel.data isVerifyShow:isVerifyShow];
    CGFloat profileInfoViewHeight = [self.profileInfoView viewHeight];
    self.profileInfoView.frame = CGRectMake(0, 0, SCREEN_WIDTH, profileInfoViewHeight);
    
    CGFloat feedViewControllerHeight = SCREEN_HEIGHT - self.navBar.height;
    self.feedViewController.view.frame = CGRectMake(0, profileInfoViewHeight, SCREEN_WIDTH, feedViewControllerHeight);
    
    [self initFeedListVCArray:tabListModel.data.tabList.count];
    
    [self.feedViewController updateWithHeaderViewMdoel:tabListModel];
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, profileInfoViewHeight + feedViewControllerHeight);
    
    self.profileInfoView.hidden = NO;
}

-(void)updateProfileInfoWithModel:(FHPersonalHomePageProfileInfoModel *)profileInfoModel {
    if(!profileInfoModel) {
        [self.viewController.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        return;
    }
    NSArray *vwhiteList =  [FHEnvContext getUGCUserVWhiteList];
    BOOL isVerifyShow = [vwhiteList containsObject:self.userId];
    
    self.viewController.customNavBarView.title.text = profileInfoModel.data.name;
    [self.profileInfoView updateWithModel:profileInfoModel.data isVerifyShow:isVerifyShow];
    CGFloat profileInfoViewHeight = [self.profileInfoView viewHeight];
    self.profileInfoView.frame = CGRectMake(0, 0, SCREEN_WIDTH, profileInfoViewHeight);
    
    CGFloat feedViewControllerHeight = SCREEN_HEIGHT - self.navBar.height;
    self.feedViewController.view.frame = CGRectMake(0, profileInfoViewHeight, SCREEN_WIDTH, feedViewControllerHeight);
    self.scrollView.contentSize = CGSizeMake(SCREEN_WIDTH, profileInfoViewHeight + feedViewControllerHeight);
}

-(void)initTracerDictWithParams:(NSDictionary *)params {
    NSMutableDictionary *tracerDict = [NSMutableDictionary dictionary];
    NSString *enter_from = params[@"from_page"];
    tracerDict[@"enter_from"] = enter_from;
    NSString *originFrom = params[@"origin_from"];
    tracerDict[@"origin_from"] = originFrom;
    tracerDict[@"user_id"] = self.userId;
    tracerDict[@"category_name"] = @"personal_homepage";
    tracerDict[@"page_type"] = @"personal_homepage_detail";
    tracerDict[@"enter_type"] = @"click";
    
    self.tracerDict = tracerDict;
}

- (void)initFeedListVCArray:(NSInteger)count {
    NSMutableArray *feedListVCArray = [NSMutableArray array];
    for(NSInteger i = 0;i < count;i++) {
        [feedListVCArray addObject:[NSNull null]];
    }
    self.feedListVCArray = feedListVCArray;
}

-(void)scrollViewScroll:(UIScrollView *)scrollView {
    CGFloat offset = scrollView.contentOffset.y;
    CGFloat tabListOffset = [self tabListOffset];
    CGFloat shadowViewHeight = 130 + self.safeArea;
    CGFloat backViewOffset = shadowViewHeight -  self.navBar.height;
    CGFloat nameLabelOffset = backViewOffset + 60;


    if(offset >= tabListOffset) {
        scrollView.contentOffset = CGPointMake(0, tabListOffset);
        self.scrollViewScrollEnable = NO;
        self.tableViewScrollEnable = YES;
    } else {
        if(!self.scrollViewScrollEnable) {
            scrollView.contentOffset = CGPointMake(0, tabListOffset);
        } else {
            
        }
    }

    offset = self.scrollView.contentOffset.y;
    if(offset < 0) {
        self.profileInfoView.shadowView.transform = CGAffineTransformMakeScale(1 + offset/(-shadowViewHeight), 1 + offset/(-shadowViewHeight));
        CGRect frame = self.profileInfoView.shadowView.frame;
        frame.origin.y = offset;
        self.profileInfoView.shadowView.frame = frame;
        
        self.navBar.bgView.alpha = 0;
        self.navBar.title.alpha = 0;
    } else if(offset <= backViewOffset) {
        self.navBar.bgView.alpha = offset / backViewOffset;
        self.navBar.title.alpha = offset / backViewOffset;
    } else {
        self.navBar.bgView.alpha = 1;
        self.navBar.title.alpha = 1;
    }
    if(self.navBar.title.alpha <= 0.1f) {
        [self.navBar.leftBtn setBackgroundImage:[UIImage imageNamed:@"fh_ugc_personal_page_back_arrow"] forState:UIControlStateNormal];
        [self.navBar.leftBtn setBackgroundImage:[UIImage imageNamed:@"fh_ugc_personal_page_back_arrow"] forState:UIControlStateHighlighted];
        [self.viewController.moreButton setBackgroundImage:[UIImage imageNamed:@"fh_ugc_personal_more_white"] forState:UIControlStateNormal];
        [self.viewController.moreButton setBackgroundImage:[UIImage imageNamed:@"fh_ugc_personal_more_white"] forState:UIControlStateHighlighted];
    } else {
        [self.navBar.leftBtn setBackgroundImage:FHBackBlackImage forState:UIControlStateNormal];
        [self.navBar.leftBtn setBackgroundImage:FHBackBlackImage forState:UIControlStateHighlighted];
        [self.viewController.moreButton setBackgroundImage:[UIImage imageNamed:@"fh_ugc_personal_more_black"] forState:UIControlStateNormal];
        [self.viewController.moreButton setBackgroundImage:[UIImage imageNamed:@"fh_ugc_personal_more_black"] forState:UIControlStateHighlighted];
    }
    
    if(offset > nameLabelOffset) {
        self.navBar.title.hidden = NO;
    } else {
        self.navBar.title.hidden = YES;
    }
    
}

-(void)tableViewScroll:(UIScrollView *)scrollView {
    if(!self.tableViewScrollEnable) {
        scrollView.contentOffset = CGPointZero;
    }
    CGFloat offset = scrollView.contentOffset.y;
    if(offset < 0){
        scrollView.contentOffset = CGPointZero;
        [self scrollsToTop];
    }
}

-(void)collectionViewBeginScroll:(UIScrollView *)scrollView {
    self.beginOffset = self.currentIndex * SCREEN_WIDTH;
    self.lastOffset = scrollView.contentOffset.x;
    self.scrollView.scrollEnabled = NO;
}

-(void)collectionViewDidScroll:(UIScrollView *)scrollView {
    CGFloat scrollDistance = scrollView.contentOffset.x - self.lastOffset;
    CGFloat diff = scrollView.contentOffset.x - self.beginOffset;

    CGFloat tabIndex = scrollView.contentOffset.x / SCREEN_WIDTH;
    if(diff >= 0){
        tabIndex = floorf(tabIndex);
    }else if (diff < 0){
        tabIndex = ceilf(tabIndex);
    }

    if(tabIndex != self.feedViewController.headerView.selectedSegmentIndex){
        self.currentIndex = tabIndex;
        self.feedViewController.headerView.selectedSegmentIndex = self.currentIndex;
    } else {
        CGFloat value = scrollDistance / SCREEN_WIDTH;
        [self.feedViewController.headerView setScrollValue:value isDirectionLeft:diff < 0];
    }

    self.lastOffset = scrollView.contentOffset.x;
}

-(void)collectionViewDidEndDragging:(UIScrollView *)scrollView {
    self.scrollView.scrollEnabled = YES;
}

-(CGFloat)tabListOffset {
    return self.profileInfoView.viewHeight - self.navBar.height;
}

-(FHNavBarView *)navBar {
    return self.viewController.customNavBarView;
}

-(FHPersonalHomePageProfileInfoView *)profileInfoView {
    return self.viewController.profileInfoView;
}

-(UIScrollView *)scrollView {
    return self.viewController.scrollView;
}

-(void)scrollsToTop {
    self.scrollViewScrollEnable = YES;
    self.tableViewScrollEnable = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        for(FHPersonalHomePageFeedListViewController *feedVC in self.feedListVCArray) {
            if([feedVC isKindOfClass:[FHPersonalHomePageFeedListViewController class]]) {
                [feedVC.tableView setContentOffset:CGPointZero animated:NO];
            }
        }
    });
}

-(void)refreshScrollStatus {
    CGFloat tabListOffset = [self tabListOffset];
    CGFloat offset = self.scrollView.contentOffset.y;
    if(offset >= tabListOffset) {
        self.scrollViewScrollEnable = NO;
        self.tableViewScrollEnable = YES;
    }else {
        self.scrollViewScrollEnable = YES;
        self.tableViewScrollEnable = NO;
    }
}

- (void)setIsNoFeed:(BOOL)isNoFeed {
    _isNoFeed = isNoFeed;
    self.scrollView.scrollEnabled = !isNoFeed;
}

-(CGFloat)safeArea {
    if([UIDevice btd_isIPhoneXSeries]){
        return 40;
    }
    return 0;
}

@end
