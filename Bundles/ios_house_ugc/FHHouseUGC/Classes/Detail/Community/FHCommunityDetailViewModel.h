//
// Created by zhulijun on 2019-06-12.
//

#import <Foundation/Foundation.h>
#import <FHUGCShareManager.h>

@class FHCommunityDetailViewController;
@class FHCommunityDetailHeaderView;


@interface FHCommunityDetailViewModel : NSObject <UIScrollViewDelegate>
@property (nonatomic , strong) NSMutableDictionary *tracerDict;
@property (nonatomic, weak)     UIButton       *shareButton;
@property (nonatomic, strong)   FHUGCShareInfoModel *shareInfo;// 分享信息，服务端返回
@property (nonatomic, copy)     NSDictionary       *shareTracerDict;// 分享埋点数据

- (instancetype)initWithController:(FHCommunityDetailViewController *)viewController tracerDict:(NSDictionary*)tracerDict;

- (void)requestData:(BOOL) userPull refreshFeed:(BOOL) refreshFeed showEmptyIfFailed:(BOOL) showEmptyIfFailed showToast:(BOOL) showToast;

- (void)viewWillAppear;

- (void)viewDidAppear;

- (void)viewWillDisappear;

- (void)addGoDetailLog;

- (void)addStayPageLog:(NSTimeInterval)stayTime;

- (void)addPublicationsShowLog;

- (void)refreshBasicInfo;

- (void)gotoSocialFollowUserList;

- (void)gotoPostThreadVC;

- (void)gotoVotePublish;

- (void)gotoGroupChat;

- (void)gotoWendaPublish;

@end
