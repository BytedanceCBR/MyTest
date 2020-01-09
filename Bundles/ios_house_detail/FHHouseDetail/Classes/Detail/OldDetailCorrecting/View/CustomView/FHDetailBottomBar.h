//
//  FHDetailBottomBar.h
//  Pods
//
//  Created by liuyu on 2019/12/26.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseModel.h"
NS_ASSUME_NONNULL_BEGIN
@class FHDetailUGCGroupChatButton;
@interface FHDetailBottomBar : UIView
@property (nonatomic, weak) FHDetailUGCGroupChatButton *bottomGroupChatBtn;
@property (nonatomic, assign)   BOOL       showIM;
@property(nonatomic, copy)void(^bottomBarContactBlock)(void);
@property(nonatomic, copy)void(^bottomBarRealtorBlock)(void);
@property(nonatomic, copy)void(^bottomBarLicenseBlock)(void);
@property(nonatomic, copy)void(^bottomBarImBlock)(void);
@property(nonatomic, copy)void(^bottomBarGroupChatBlock)(void);
- (void)refreshBottomBar:(FHDetailContactModel *)contactPhone contactTitle:(NSString *)contactTitle chatTitle:(NSString *)chatTitle;
- (void)startLoading;
- (void)stopLoading;

@end

// 新房 加群看房按钮
@interface FHDetailUGCGroupChatButton : UIControl

@property (nonatomic, strong)   UILabel       *titleLabel;

@end

NS_ASSUME_NONNULL_END
