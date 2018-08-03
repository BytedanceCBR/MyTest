//
//  TTPanelDefine.h
//  Pods
//
//  Created by 延晋 张 on 16/6/1.
//
//

#import <Foundation/Foundation.h>

#define kRootViewWillTransitionToSize       @"kRootViewWillTransitionToSize"

typedef NS_ENUM(NSUInteger, TTActivityPanelControllerItemLoadImageType) {
    // 使用TTThemed加载图片
    TTActivityPanelControllerItemLoadImageTypeThemed,
    // 使用URL加载图片
    TTActivityPanelControllerItemLoadImageTypeURL,
    // 使用Image加载图片
    TTActivityPanelControllerItemLoadImageTypeImage,
};

typedef NS_ENUM(NSUInteger, TTActivityPanelControllerItemActionType) {
    // 点击activity item后，panel消失
    TTActivityPanelControllerItemActionTypeDismiss,
    // 点击activity item后，panel不消失
    TTActivityPanelControllerItemActionTypeNone,
};

typedef NS_OPTIONS(NSUInteger, TTActivityPanelControllerItemUIType) {
    // activity item有边框
    TTActivityPanelControllerItemUITypeBorder = 1 << 0,
    // activity item有圆角
    TTActivityPanelControllerItemUITypeCornerRadius = 1 << 1,
};

@protocol TTActivityPanelActivityProtocol <NSObject>

@optional
- (TTActivityPanelControllerItemLoadImageType)itemLoadImageType;

- (TTActivityPanelControllerItemActionType)itemActionType;

- (TTActivityPanelControllerItemUIType)itemUIType;

- (NSString *)itemImageName;

- (NSString *)itemImageURL;

- (UIImage *)itemImage;

@end

