//

//  FHMessageViewController.h
//  FHHouseMessage
//
//  Created by 谢思铭 on 2019/1/31.
//

#import "FHBaseViewController.h"
#import "FHNoNetHeaderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHMessageViewController<UIViewControllerErrorHandler> : FHBaseViewController 

@property(nonatomic, strong) UITableView *tableView;
@property(nonatomic , strong) UIView *containerView;
@property(nonatomic, strong) FHNoNetHeaderView *notNetHeader;

- (NSString *)getPageType;

@end

NS_ASSUME_NONNULL_END
