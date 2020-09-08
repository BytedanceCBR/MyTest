//
//  FHHouseSaleLeaveView.h
//  FHHouseTrend
//
//  Created by 谢思铭 on 2020/9/8.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseSaleLeaveView : UIView

@property(nonatomic , copy) void (^quitBlock)(void);

- (void)show;

@end

NS_ASSUME_NONNULL_END
