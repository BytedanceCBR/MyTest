//
//  FHCommunityDiscoveryCell.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/4/20.
//

#import <UIKit/UIKit.h>
#import "FHHouseUGCHeader.h"
#import "FHCommunityDiscoveryCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityDiscoveryCell : UICollectionViewCell

@property(nonatomic , strong) FHCommunityDiscoveryCellModel *cellModel;

@property(nonatomic , strong) NSString *enterType;
//是否显示小红点，埋点使用
@property(nonatomic , assign) BOOL withTips;
//是否是通过点击触发刷新
@property(nonatomic, assign) BOOL isRefreshTypeClicked;

- (UIViewController *)contentViewController;

- (void)refreshData:(BOOL)isHead isClick:(BOOL)isClick;

- (void)cellDisappear;

@end

NS_ASSUME_NONNULL_END
