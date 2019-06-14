//
//  FHCommunityFeedListController.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import "FHBaseViewController.h"
#import "FHHouseUGCHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityFeedListController : FHBaseViewController

@property(nonatomic, assign) FHCommunityFeedListType listType;
//发布按钮
@property(nonatomic, strong) UIButton *publishBtn;
//附加在feed上面的自定义view
@property(nonatomic, strong) UIView *tableHeaderView;
//是否需要下拉刷新，默认为YES
@property(nonatomic, assign) BOOL tableViewNeedPullDown;
//发布按钮距离底部的高度,默认为0
@property(nonatomic, assign) CGFloat publishBtnBottomHeight;

- (void)showNotify:(NSString *)message;
//下拉刷新数据
- (void)startLoadData;


@end

NS_ASSUME_NONNULL_END
