//
//  TTActivityShareSequenceManager.h
//  Article
//
//  Created by lishuangyang on 2017/8/25.
//
//

#import <Foundation/Foundation.h>
#import "NSObject+TTAdditions.h"
#import "TTActivity.h"
#import "TTActivityProtocol.h"

typedef NS_ENUM(NSUInteger, TTVActivityShareErrorCode){
    TTVActivityShareSuccess,   //分享成功
    TTVActivityShareErrorFailed,    //分享失败
    TTVActivityShareErrorUnavaliable,   //API过低／不支持分享
    TTVActivityShareErrorNotInstalled,  //未安装
    TTVACtivityShareErrorExceedMaxImageSize,  //图片过大
    TTVACtivityShareErrorExceedTextLength   //文字内容过长
};


@protocol TTActivityShareSequenceChangedMessage <NSObject>

- (void)message_shareActivitySequenceChanged;

@end

/**
 *  使用一个key: shareActivitySequenceArray 存储 原shareActivity
 *  使用一个key: shareServiceSequenceArray 存储新share库支持的service
 *  存在userDefault中
 */

@interface TTActivityShareSequenceManager : NSObject<Singleton>

//原shareActivitymanager
- (NSArray *)getAllShareActivitySequence;

//返回值暂时没用，均返回ture
- (BOOL)instalAllShareActivitySequenceFirstActivity:(TTActivityType )activityType;

//新share库
- (NSArray *)getAllShareServiceSequence;

//返回值暂时没用，均返回ture
- (BOOL)instalAllShareServiceSequenceFirstActivity:(NSString *)activityType;

+ (NSString *)activityStringTypeFromActivityType:(TTActivityType)itemType;

+ (TTActivityType)activityTypeFromStringActivityType:(NSString *)activityTypeString;

+ (TTVActivityShareErrorCode)shareErrorCodeFromItemErrorCode:(NSError *)itemError WithActivity:(id<TTActivityProtocol>)activity;

@end


