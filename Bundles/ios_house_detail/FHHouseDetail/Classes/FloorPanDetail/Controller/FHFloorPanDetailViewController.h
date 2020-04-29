//
//  FHFloorPanDetailViewController.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/13.
//

#import "FHHouseDetailSubPageViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanDetailViewController : FHHouseDetailSubPageViewController
@property (nonatomic, assign)   BOOL     isViewDidDisapper;
//设置状态栏
- (void)refreshContentOffset:(CGPoint)contentOffset;

@end

NS_ASSUME_NONNULL_END
