//
//  FHPostUGCProgressView.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/20.
//

#import <UIKit/UIKit.h>
#import "FHUGCBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

// 发帖进度，添加后视图不需移除，后续高度自动变化，并执行：refreshViewBlk
@interface FHPostUGCProgressView : UIView

+ (instancetype)sharedInstance;

// 刷新视图闭包
@property (nonatomic, copy)     dispatch_block_t      refreshViewBlk;

//新的发现页面
@property(nonatomic, assign) BOOL isNewDiscovery;

// 视图高度
- (CGFloat)viewHeight;

// 刷新高度
- (void)updatePostData;

@end

@interface FHPostUGCProgressCell : FHUGCBaseCell

//新的发现页面
@property(nonatomic, assign) BOOL isNewDiscovery;

@end

NS_ASSUME_NONNULL_END
