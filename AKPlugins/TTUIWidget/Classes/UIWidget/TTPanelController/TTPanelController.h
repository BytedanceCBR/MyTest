//
//  FRPanelController.h
//  Article
//
//  Created by zhaopengwei on 15/7/26.
//
//

#import <Foundation/Foundation.h>
#import "TTDeviceHelper.h"
#import "TTUIResponderHelper.h"

typedef void (^CancelBlock)(void);

@interface TTPanelController : NSObject

/**
 *  构造一个PanelController
 *
 *  @param items       TTPanelControllerItem的数组的数组 @[@[item1, item2], @[item3, item4]]
 *  @param cancelTitle 取消button的title
 *
 *  @return TTPanelController
 */
- (instancetype)initWithItems:(NSArray *)items cancelTitle:(NSString *)cancelTitle;

- (instancetype)initWithItems:(NSArray *)items cancelTitle:(NSString *)cancelTitle cancelBlock:(CancelBlock)cancelBlock;
/**
 *  展示panel
 */
- (void)show;
/**
 *  收起pannel
 *
 *  @param block block when animation finish
 */
- (void)hideWithBlock:(void(^)(void))block;
- (void)hideWithBlock:(void(^)(void))block animation:(BOOL)animated;

@end

//ugly code: 为了解耦且不增加其他业务方使用成本，暂时paste业务代码，后续优化
static inline CGFloat paddingForPadDevice ()
{
    CGFloat viewWidth = [TTUIResponderHelper windowSize].width;
    CGFloat midDivideAspect = 1.f/2.f;
    CGFloat rightDivideAspect = 1.f/3.f;
    CGFloat deviceWidth = [TTUIResponderHelper screenSize].width;
    CGFloat deviceHeight = [TTUIResponderHelper screenSize].height;
    
    //这里用device的宽高判断orientation 是否是Portrait
    if (deviceHeight > deviceWidth) {
        if (viewWidth == deviceWidth) {
            //全屏
            if ([TTDeviceHelper isIpadProDevice]) {
                return 200.f;
            }
            else {
                return 119.f;
            }
        }
        else if (viewWidth > deviceWidth * midDivideAspect) {
            //左屏
            if ([TTDeviceHelper isIpadProDevice]) {
                return 26.f;
            }
            else {
                return 20.f;
            }
        }
        else {
            //右屏(竖屏没有中屏)
            if ([TTDeviceHelper isIpadProDevice]) {
                return 13.f;
            }
            else {
                return 10.f;
            }
        }
    }
    else {
        if (viewWidth == deviceWidth) {
            //全屏
            if ([TTDeviceHelper isIpadProDevice]) {
                return 265.f;
            }
            else {
                return 200.f;
            }
        }
        else if (viewWidth > deviceWidth * midDivideAspect) {
            //左屏
            if ([TTDeviceHelper isIpadProDevice]) {
                return 45.f;
            }
            else {
                return 35.f;
            }
        }
        else if (viewWidth > deviceWidth * rightDivideAspect) {
            //中屏
            if ([TTDeviceHelper isIpadProDevice]) {
                return 26.f;
            }
            else {
                return 20.f;
            }
        }
        else {
            //右屏
            if ([TTDeviceHelper isIpadProDevice]) {
                return 13.f;
            }
            else {
                return 10.f;
            }
        }
    }
}
