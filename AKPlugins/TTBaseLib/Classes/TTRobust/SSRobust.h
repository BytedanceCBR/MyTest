//
//  SSRobust.h
//  Article
//
//  Created by SunJiangting on 15-3-16.
//
//

#import <Foundation/Foundation.h>

@protocol SSShieldDelegate <NSObject>

/**
 * @abstract 当保护器需要保护字典fields时，它本身不知道该如何保护，所以需要提供一个保护的策略，默认是为字典的为value保护一下，返回被保护的字典
 * @<li> @{@"key1": value} ----------> shield(@{@"key1":shield(value)})，其余的类似
 */
- (id)applyShieldWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)reversedDictionaryFromShield:(NSDictionary *)shieldObject;

- (id)applyShieldWithArray:(NSArray *)array;
- (NSArray *)reversedArrayFromShield:(NSArray *)shieldObject;

- (id)applyShieldWithObject:(NSObject/*AnyObject*/ *)anyObject;
- (NSObject *)reversedObjectFromShield:(NSObject *)shieldObject;
@end

extern void SSOpenRobustObject(void);
extern void SSCloseRobustObject(void);
extern BOOL SSIsRobustObject(void);

/**
 * @abstract 将对象转换成比较鲁棒的对象。提供一层透明的中间保护层，当访问到被保护对象的unrecognizedSelector时，会通通返回nil
 * @param    object 被保护对象
 * @param    delegate 当保护时，delegate提供保护策略。如果传入nil, 则使用默认的保护策略
 * @return   鲁棒的对象
 */
extern id SSConvertToRobustObject(id/*NSObject*/ object, id<SSShieldDelegate> delegate);
extern id SSGetContentFromRobustObject(id robustObject);

typedef NS_OPTIONS(NSUInteger, SSPropertyPolicy){
    SSPropertyPolicyAssign = 1 << 0,
    SSPropertyPolicyRetain = 1 << 1,
    SSPropertyPolicyCopy   = 1 << 2,
    
    SSPropertyPolicyAtomic    = 1 << 10,
    SSPropertyPolicyNonatomic = 1 << 11,
};


@interface SSProperty : NSObject
@property(nonatomic, copy, readonly) NSString   *name;  // property name
@property(nonatomic, copy, readonly) Class      type;  // class Name
@property(nonatomic, readonly) SSPropertyPolicy policy;
@property(nonatomic, readonly) BOOL             readonly;
@end

extern SSProperty * SSGetPropertyFromClass(Class pClass, NSString *propertyName);
extern NSDictionary/*@{propertyName=SSProperty}*/ * SSGetPropertiesFromClass(Class pClass);
/**
 *  判断是否是某个类的子类
 *
 *  @param _class _class
 *  @param parentClass parentClass
 *
 *  @return 是否是某个类的子类
 */
extern BOOL TTClassIsSubClassOfClass(Class _class, Class parentClass);

