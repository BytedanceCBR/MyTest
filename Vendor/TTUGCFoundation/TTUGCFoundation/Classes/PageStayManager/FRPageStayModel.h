//
//  FRPageStayModel.h
//  Article
//
//  Created by 王霖 on 15/8/9.
//
//

#import <Foundation/Foundation.h>

/**
 *  记录页面停留时间model。
 */
@interface FRPageStayModel : NSObject

/**
 *  Model指定初始化器
 *
 *  @param page 需要记录停留时间的page，model弱引用page
 *
 *  @return model实例
 */
- (instancetype)initWithPage:(id)page NS_DESIGNATED_INITIALIZER;

/**
 *  需要记录停留时间的页面
 */
@property (nonatomic, weak, readonly)id page;

/**
 *  页面停留时间。
 */
@property (nonatomic, assign, readonly)NSTimeInterval pageStayTimeInterval;


/**
 *  页面是否是model对应记录的页面
 *
 *  @param page 页面
 *
 *  @return 页面是否是model对应记录的页面
 */
- (BOOL)isModelPage:(id)page;

/**
 *  恢复记录页面停留时间
 */
- (void)resumePageStay;

/**
 *  暂停记录页面停留时间
 */
- (void)suspendPageStay;

/**
 *  进入页面，开始记录页面停留时间
 */
- (void)enterPage;

/**
 *  离开页面，停止记录页面停留时间
 */
- (void)leavePage;

/**
 *  重置页面停留时间
 */
- (void)resetPageStayTimeInterval;

@end
