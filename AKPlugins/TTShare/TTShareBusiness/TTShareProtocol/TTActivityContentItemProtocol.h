//
//  TTActivityContentItemProtocal.h
//  TTActivityViewControllerDemo
//
//  Created by 延晋 张 on 16/6/1.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TTShareType)
{
    TTShareText        =  0,
    TTShareImage       =  1,
    TTShareImageUrl    =  2,
    TTShareWebPage     =  3,
    TTShareVideo       =  4,
};

typedef void(^TTCustomAction)();

@protocol TTActivityContentItemProtocol<NSObject>

@required

/**
 *  content item的唯一标示字符(unique identification)
 */
@property (nonatomic, readonly) NSString *contentItemType;

@optional

/**
 *  展示在panel上的标题
 */
@property (nonatomic, copy) NSString *contentTitle;

/**
 *  展示在panel上的标题
 */
@property (nonatomic, copy) NSString *activityImageName;

@end

@protocol TTActivityContentItemSelectedProtocol <TTActivityContentItemProtocol>
//考虑Button的select状态和计数
@property (nonatomic, assign) BOOL selected;

@end

@protocol TTActivityContentItemSelectedDigProtocol <TTActivityContentItemSelectedProtocol>

//考虑Button的select状态和计数
@property (nonatomic, assign) BOOL banDig;
@property (nonatomic, assign) int64_t count;

@end


@protocol TTActivityContentItemShareProtocol <TTActivityContentItemProtocol>

/**
 *  分享类型
 */
@property (nonatomic, assign) TTShareType shareType;

/**
 *  分享的内容链接
 */
@property (nonatomic, copy) NSString *webPageUrl;

@end

