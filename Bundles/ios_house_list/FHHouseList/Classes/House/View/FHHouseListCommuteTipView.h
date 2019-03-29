//
//  FHHouseListCommuteTipView.h
//  FHHouseList
//
//  Created by 春晖 on 2019/3/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseListCommuteTipView : UIView

@property(nonatomic , assign) BOOL showHide;//是否显示 收起 或者修改

@property(nonatomic , copy) void (^changeOrHideBlock)(BOOL showHide);

-(void)updateTime:(NSString *)time tip:(NSString *)tip;

@end

NS_ASSUME_NONNULL_END
