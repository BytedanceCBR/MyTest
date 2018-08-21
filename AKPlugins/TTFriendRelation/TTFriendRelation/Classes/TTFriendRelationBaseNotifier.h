//
//  TTFriendRelationBaseNotifier.h
//  Article
//
//  Created by lipeilun on 2017/11/30.
//

#import <Foundation/Foundation.h>

@protocol TTFriendRelationValueChangedProtocol
- (void)friendRelationChangedWithValue:(NSNumber *)nValue;
@end

@protocol TTFriendRelationNotifyProtocol

/**
 通知新值

 @param value 对应值
 */
- (void)notifyAllObserversValue:(id)value;


/**
 删除观察者

 @param observer
 */
- (void)removeObserver:(id)observer;

/**
 注册属性观察者

 @param observer
 @param keypath  对应属性的keypath
 */
- (void)registerPropertyObserver:(id)observer keypath:(NSString *)keypath;

/**
 注册方法观察者

 @param observer
 */
- (void)registerSelectorObserver:(id<TTFriendRelationValueChangedProtocol>)observer;
@end

/**
 TTFriendRelationBaseNotifier
 
 用户关系通知器
 可以通过注册观察者接收用户关系的通知，目前包含属性通知和方法通知
 分别用于有某个明确的model需要把关注状态的keypath传入，接收用户关系修改的通知。
 或传某个方法做独立的更新操作
 
 NOTICE:实际使用时，注册后可以不主动删除，生命周期结束后，通知器会自动停止对其维护
 */
@interface TTFriendRelationBaseNotifier : NSObject <TTFriendRelationNotifyProtocol>
@property (nonatomic, strong) NSMapTable *propertyNotifyMap;
@property (nonatomic, strong) NSHashTable *selectorNotifyTable;
@end
