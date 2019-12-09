//
//  FHDetailBottomBarView.h
//  Pods
//
//  Created by 张静 on 2019/2/12.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseModel.h"

NS_ASSUME_NONNULL_BEGIN


@interface FHDetailBottomBarView : UIView

@property(nonatomic, copy)void(^bottomBarContactBlock)(void);
@property(nonatomic, copy)void(^bottomBarRealtorBlock)(void);
@property(nonatomic, copy)void(^bottomBarLicenseBlock)(void);
@property(nonatomic, copy)void(^bottomBarImBlock)(void);
@property(nonatomic, copy)void(^bottomBarGroupChatBlock)(void);
@property (nonatomic, assign)   BOOL       showIM;
@property(nonatomic , strong) UIButton *groupChatBtn;// 新房加群f看房

- (void)refreshBottomBar:(FHDetailContactModel *)contactPhone contactTitle:(NSString *)contactTitle chatTitle:(NSString *)chatTitle;
- (void)startLoading;
- (void)stopLoading;

// 新房 加群看房功能
- (void)refreshBottomBarWithGroupChatTitle:(NSString *)groupChatTitle;

@end

NS_ASSUME_NONNULL_END
