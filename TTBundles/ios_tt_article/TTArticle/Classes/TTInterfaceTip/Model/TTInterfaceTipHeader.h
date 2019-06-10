//
//  TTInterfaceTipHeader.h
//  Article
//
//  Created by chenjiesheng on 2017/6/25.
//
//

#import <UIKit/UIKit.h>

#ifndef TTInterfaceTipHeader_h
#define TTInterfaceTipHeader_h

typedef NS_ENUM(NSUInteger, TTInterfaceTipsMoveDirection){
    TTInterfaceTipsMoveDirectionNone,
    TTInterfaceTipsMoveDirectionUp,
    TTInterfaceTipsMoveDirectionDown,
    TTInterfaceTipsMoveDirectionLeft,
    TTInterfaceTipsMoveDirectionRight
};

static NSString *const kTTInterfaceContextTopHeightKey = @"kTTInterfaceContextTopHeightKey";
static NSString *const kTTInterfaceContextBottomHeightKey = @"kTTInterfaceContextBottomHeightKey";
static NSString *const kTTInterfaceContextTabbarHeightKey = @"kTTInterfaceContextTabbarHeightKey";
static NSString *const kTTInterfaceContextCurrentSelectedViewControllerKey = @"kTTInterfaceContextCurrentSelectedViewController";
static NSString *const kTTInterfaceContextMineIconViewKey = @"kTTInterfaceContextMineIconViewKey";

@protocol TTInterfaceBackViewControllerProtocol <NSObject>
//这个协议主要是去获取一些和UI相关的现场
@optional
- (CGFloat)topHeight;
- (CGFloat)bottomHeight;
- (UIView *)mineIconView;
@end

@protocol TTInterfaceTabBarControllerProtocol <NSObject>
//这个协议主要是去获得一些tabController相关的现场
- (NSInteger)currentTabIndex;
- (UIViewController<TTInterfaceBackViewControllerProtocol> *)currentSelectedViewController;
- (CGFloat)tabbarVisibleHeight;
@optional
- (UIView *)mineIconView;
@end


#endif /* TTInterfaceTipHeader_h */
