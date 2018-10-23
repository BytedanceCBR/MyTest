//
//  TTGuideDispatchManager.h
//  Article
//
//  Created by fengyadong on 16/6/2.
//
//

#import <Foundation/Foundation.h>
#import "NSObject+TTAdditions.h"


/**
 * 弹窗启动优先级
 */
typedef NS_ENUM(NSUInteger, TTGuidePriority) {
    kTTGuidePriorityLow,
    kTTGuidePriorityNormal,
    kTTGuidePriorityHigh,
};

@protocol TTGuideProtocol <NSObject>
/**
 *  当前引导视图是否应该展示
 *
 *  @param context 上下文环境，比如父视图
 *
 *  @return 是否应该显示
 */
- (BOOL)shouldDisplay:(id)context;
/**
 *  展示当前引导视图
 *
 *  @param context 上下文环境，比如父视图
 */
- (void)showWithContext:(id)context;
/**
 *  上下文环境
 */
@property (nonatomic, strong) id context;


@optional

/**
 *  @return context 当前弹窗的优先级
 */
- (TTGuidePriority)priority;

@end

@interface TTGuideDispatchManager : NSObject <Singleton>
/**
 *  将当前引导视图加入到队列当中，如果为第一个那么立即展示
 *
 *  @param item    展示视图
 *  @param context 上下文环境，比如父视图
 */
- (void)addGuideViewItem:(id<TTGuideProtocol>)item withContext:(id)context;
/**
 *  当前引导视图出队列，可能已经展示完毕，也可能不应该展示
 *
 *  @param item 出队列的视图
 */
- (void)removeGuideViewItem:(id<TTGuideProtocol>)item;
/**
 *  当前任务队列是否空闲
 *
 *  @return 是否空闲
 */
- (BOOL)isQueueEmpty;
/**
 *  将当前视图插入到必须在它之后展现的视图之前
 *
 *  @param item      当前要展现的视图
 *  @param className 必须在当前视图之后展现的视图的类名
 *  @param context   上下文环境，比如父视图
 */
- (void)insertGuideViewItem:(id<TTGuideProtocol>)item beforeClassName:(NSString *)className withContext:(id)context;
/**
 *  从队列中删除某种类型的视图
 *
 *  @param className 这个类的名字
 */
- (void)removeItemWithClassName:(NSString *)className;


/**
 *  队列中是否包含某种类型的视图
 *
 *  @param className 这种类
 */
- (BOOL)containItemForClass:(Class)aClass;

@end
