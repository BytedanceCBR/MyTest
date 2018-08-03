//
//  TTDetailWebContainerDefine.h
//  TTWebViewBundle
//
//  Created by muhuai on 2017/7/30.
//  Copyright © 2017年 muhuai. All rights reserved.
//

#import <Foundation/Foundation.h>

//文章详情页浮层类型
typedef NS_ENUM(NSInteger, TTDetailNatantStyle)
{
    TTDetailNatantStyleDisabled,      //禁止浮层
    TTDetailNatantStyleInsert,       //点击或临界值拖拽调起
    TTDetailNatantStyleAppend,       //随手平滑滚出+点击调起
    TTDetailNatantStyleOnlyClick,    //点击调起
};

/**
 *  footer view 的显示状态
 */
typedef NS_ENUM(NSUInteger, TTDetailWebViewFooterStatus)
{
    TTDetailWebViewFooterStatusNoDisplay, //没有显示
    TTDetailWebViewFooterStatusDisplayHalf,//显示了一半
    TTDetailWebViewFooterStatusDisplayTotal,//完整显示, 此种显示是用户手动滑动到底部显示的
    TTDetailWebViewFooterStatusDisplayNotManual,//完整显示，此种显示不是用户手动滑动到底部显示的
};

typedef enum JSMetaInsertImageType {
    JSMetaInsertImageTypeNone,      //kJsMetaImageNoneKey
    JSMetaInsertImageTypeOrigin,    //kJsMetaImageOriginKey
    JSMetaInsertImageTypeThumb      //kJsMetaImageThumbKey
}JSMetaInsertImageType;

#define kJsMetaImageOriginKey       @"origin"
#define kJsMetaImageThumbKey        @"thumb"
#define kJsMetaImageNoneKey         @"none"
#define kJsMetaImageAllKey          @"all"
#define kShowOriginImageHost        @"origin_image"         //单张显示大图
#define kShowFullImageHost          @"full_image"           //进入图片浏览页面
#define kCacheSizeForAllTypeThumb   @"thumb"

@interface TTDetailWebContainerDefine : NSObject

+ (NSString *)tt_loadImageJSStringKeyForType:(JSMetaInsertImageType)type;

+ (JSMetaInsertImageType)tt_loadImageTypeWithImageMode:(NSNumber *)imageMode
                                    forseShowOriginImg:(BOOL)forseShowOriginImg;

@end
