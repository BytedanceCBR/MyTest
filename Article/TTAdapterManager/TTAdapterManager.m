//
//  TTAdapterManager.m
//  Article
//
//  Created by xuzichao on 16/1/18.
//
//

#import "TTAdapterManager.h"
#import "TTDeviceHelper.h"

@implementation TTAdapterManager

//视图的间距以及缩放尺寸
+ (CGFloat)getCalculateViewSpace:(CGFloat)designNum
{
    CGFloat temp = designNum;
    
    if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) {
        temp = designNum * 0.85;
    }
    else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]){
        temp = designNum;
    }
    else if ([TTDeviceHelper is736Screen]){
        temp = designNum * 1.1;
    }
    else if ([TTDeviceHelper isPadDevice] || [TTDeviceHelper isIpadProDevice]){
        temp = designNum * 1.3;
    }
    else {
        temp = designNum;
    }
    
    return  roundf(temp);
    
}


//文字行间距
+ (CGFloat)getCalculateLineSpace:(CGFloat)designNum
{
    return designNum;
}

//字间距
+ (CGFloat)getCalculateCharacterSpace:(CGFloat)designNum
{
    return designNum;
}

//字号
+ (CGFloat)getCalculateFont:(CGFloat)designNum
{
    if (designNum <= 30) {
        
        if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) {
            return designNum - 2;
        }
        else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]){
            return designNum;
        }
        else if ([TTDeviceHelper is736Screen]){
            return designNum + 2;
        }
        else if ([TTDeviceHelper isPadDevice] || [TTDeviceHelper isIpadProDevice]){
            return designNum + 4;
        }
        else {
            return designNum;
        }
    }
    else {
        
        if ([TTDeviceHelper is568Screen] || [TTDeviceHelper is480Screen]) {
            return designNum - 4;
        }
        else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice]){
            return designNum;
        }
        else if ([TTDeviceHelper is736Screen]){
            return designNum + 4;
        }
        else if ([TTDeviceHelper isPadDevice] || [TTDeviceHelper isIpadProDevice]){
            return designNum + 10;
        }
        else {
            return designNum;
        }
    }
}

@end
