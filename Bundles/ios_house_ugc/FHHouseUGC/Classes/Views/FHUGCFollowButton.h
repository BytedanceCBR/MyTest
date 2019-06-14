//
//  FHUGCFollowButton.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/14.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

// 关注按钮 已关注 不能点击
@interface FHUGCFollowButton : UIControl

@property (nonatomic, assign)   BOOL       followed;// 默认是 NO 可点击

@end

NS_ASSUME_NONNULL_END
