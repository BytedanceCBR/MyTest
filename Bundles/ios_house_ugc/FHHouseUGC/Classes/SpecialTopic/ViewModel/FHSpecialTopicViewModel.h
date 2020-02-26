//
//  FHSpecialTopicViewModel.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/2/20.
//

#import <Foundation/Foundation.h>
#import <FHUGCShareManager.h>
#import "FHCommunityFeedListBaseViewModel.h"

@class FHSpecialTopicViewController;
@class FHSpecialTopicHeaderView;


@interface FHSpecialTopicViewModel : FHCommunityFeedListBaseViewModel <UIScrollViewDelegate>
@property (nonatomic , strong) NSMutableDictionary *tracerDict;
@property (nonatomic, weak)     UIButton       *shareButton;
@property (nonatomic, strong)   FHUGCShareInfoModel *shareInfo;// 分享信息，服务端返回
@property (nonatomic, copy)     NSDictionary       *shareTracerDict;// 分享埋点数据

//- (instancetype)initWithController:(FHSpecialTopicViewController *)viewController tracerDict:(NSDictionary*)tracerDict;

- (instancetype)initWithTableView:(UITableView *)tableView controller:(FHSpecialTopicViewController *)viewController;

- (void)requestData:(BOOL) userPull refreshFeed:(BOOL) refreshFeed showEmptyIfFailed:(BOOL) showEmptyIfFailed showToast:(BOOL) showToast;

- (void)viewWillAppear;

- (void)viewDidAppear;

- (void)viewWillDisappear;

- (void)addGoDetailLog;

- (void)addStayPageLog:(NSTimeInterval)stayTime;

- (void)addPublicationsShowLog;

- (void)refreshBasicInfo;

- (void)gotoPostThreadVC;

- (void)updateNavBarWithAlpha:(CGFloat)alpha;

@end
