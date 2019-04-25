//
//  TTAdapterManager.h
//  Article
//
//  Created by xuzichao on 16/1/18.
//
//

/**
 *  适配设计原则都是建立在iphone6的基础上，此处采取的都是C模式，根据系数适配
 *  https://wiki.bytedance.com/pages/viewpage.action?pageId=52898516
 *  @param designNum 设计师给的值
 *  @return 对应机型下正确的值
 */

#import <Foundation/Foundation.h>

@interface TTAdapterManager : NSObject

//视图的间距以及缩放尺寸
+ (CGFloat)getCalculateViewSpace:(CGFloat)designNum;

//文字行间距
+ (CGFloat)getCalculateLineSpace:(CGFloat)designNum;

//字间距
+ (CGFloat)getCalculateCharacterSpace:(CGFloat)designNum;

//字号
+ (CGFloat)getCalculateFont:(CGFloat)designFont;

@end


static inline CGFloat adapterSpace(CGFloat num) {
    return [TTAdapterManager getCalculateViewSpace:num];
}

static inline CGFloat adapterFont(CGFloat num) {
    return [TTAdapterManager getCalculateFont:num];
}

