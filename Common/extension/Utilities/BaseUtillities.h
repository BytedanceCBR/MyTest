//
//  Created by David Alpha Fox on 3/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//


#import <UIKit/UIKit.h>
#import <Security/Security.h>
#import <objc/runtime.h> 
#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>

/**
 * @brief 得到本地化的字符串，如果未找到，则使用默认值
 */
NSString* SSLocalizedString(NSString* key, NSString* defaultValue,...);

/**
 * @brief 判断一个id是否是nil，如果是nil则直接创建一个空的autorelease的字符串返回，否则返回value的字符串
 */
NSString * SSTransNullToBlank(id value);

/**
 * @brief 判断一个string是否是nil，如果是nil则直接创建一个空的autorelease的字符串返回，否则返回value字符串
 */
NSString * SSStringOrBlank(NSString * value);

/**
 * @brief 创建一个NSError，描述为传入的描述
 */
NSError * SSError(NSString * description, ...);

///**
// * @brief 判断是否是4.0以上的系统
// */
//BOOL SSSystemVersionIOSGTFour();

/**
 * @brief 交换类中的两个sel的实现，黑魔法和runtime有关
 */
void SSSwizzle(Class c, SEL origSEL, SEL newSEL);

/**
 * @brief 判断一个NSNumber是否是nil，如果是nil则直接创建一个返回默认值的NSNumber，否则返回原NSNumber
 */

BOOL SSIsEmptyString(NSString * string);

NSNumber * SSNumberOrZero(NSNumber * value);

BOOL SSCheckAndUpdate(NSString * key, int seconds);

// every time the count of key will inc, return true when equal to count
BOOL SSCheckAndUpdateCount(NSString * key, int count, BOOL includeBigger);

void setUpCookiesJar(NSString* channelId,NSString * appName);
