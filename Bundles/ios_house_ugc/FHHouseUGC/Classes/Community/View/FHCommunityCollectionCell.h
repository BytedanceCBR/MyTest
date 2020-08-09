//
//  FHCommunityCollectionCell.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/2.
//

#import <UIKit/UIKit.h>
#import "FHHouseUGCHeader.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHCommunityCollectionCell : UICollectionViewCell

@property(nonatomic , assign) FHCommunityCollectionCellType type;

@property(nonatomic , strong) NSString *enterType;
//是否显示小红点，埋点使用
@property(nonatomic , assign) BOOL withTips;
//是否是通过点击触发刷新
@property(nonatomic, assign) BOOL isRefreshTypeClicked;
//埋点
@property(nonatomic, strong) NSDictionary *tracerDic;

- (UIViewController *)contentViewController;

- (void)refreshData:(BOOL)isHead isClick:(BOOL)isClick;

- (void)cellDisappear;

- (void)setType:(FHCommunityCollectionCellType)type tracerDict:(NSDictionary *)tracerDic;

@end

NS_ASSUME_NONNULL_END
