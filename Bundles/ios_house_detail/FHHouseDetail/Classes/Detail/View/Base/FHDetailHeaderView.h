//
//  FHDetailHeaderView.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

// 使用的时候布局需要设置高度：>= 46
@interface FHDetailHeaderView : UIButton

@property (nonatomic, strong)   UILabel       *label;

@property (nonatomic, assign)   BOOL       isShowLoadMore;

@end

NS_ASSUME_NONNULL_END
