//
//  FRPageStayManager.h
//  Article
//
//  Created by 王霖 on 15/8/9.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, FRPageDisappearType) {
    FRPageDisappearTypeLeave = 0,
    FRPageDisappearTypeSuspend,
};

@protocol FRPageStayManagerDelegate <NSObject>

@optional
/**
 *  页面离开 或者 application resign active时候调用
 *
 *  @param timeInterval 页面停留时间
 */
- (void)pageStayRecorderWithTimeInterval:(int64_t)timeInterval pageDisappearType:(FRPageDisappearType)pageDisappearType;

@end


@interface FRPageStayManager : NSObject

/**
 *  页面停留时间统计单例
 *
 *  @return 统计实例
 */
+ (instancetype)sharePageStayManager;

/**
 *  页面开始统计
 *
 *  @param page 需要统计的页面
 */
- (void)startPageStayWithPage:(id<FRPageStayManagerDelegate>)page;

/**
 *  页面结束统计
 *
 *  @param page 需要结束统计的页面
 */
- (void)endPageStayWithPage:(id<FRPageStayManagerDelegate>)page;

/**
 *  进入页面
 *
 *  @param page 进入页面
 */
- (void)enterPageStayWithPage:(id<FRPageStayManagerDelegate>)page;

/**
 *  离开页面
 *
 *  @param page 离开页面
 */
- (void)leavePageStayWithPage:(id<FRPageStayManagerDelegate>)page;

@end
