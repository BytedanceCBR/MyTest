//
//  SSADHeader.h
//  Article
//
//  Created by Zhang Leonardo on 12-11-13.
//
//

#import <Foundation/Foundation.h>

#define kSSADAlwaysShowAreaKey @"kSSADAlwaysShowAreaKey" //使用该key 的banner 广告， umeng list广告， 将不受后台控制

#define SSADFetchedDisplayAreaInfosNotification @"SSADFetchedDisplayAreaInfosNotification"

typedef enum SSADViewSizeType {
    SSADViewSizeType_320x50 = 1,
    SSADViewSizeType_728x90
}SSADViewSizeType;

#define SSADSize_320x50     CGSizeMake(320.f, 50.f)  //forIphone
#define SSADSize_728x90    CGSizeMake(728.f, 90.f)  //forIpad

static inline SSADViewSizeType ssADSizeToType(CGSize size)
{
    if (CGSizeEqualToSize(size, SSADSize_320x50)) {
        return SSADViewSizeType_320x50;
    }
    else if (CGSizeEqualToSize(size, SSADSize_728x90)) {
        return SSADViewSizeType_728x90;
    }
    
    return -1;
}

static inline CGSize ssADViewSizeTypeToSize(SSADViewSizeType type)
{
    switch (type) {
        case SSADViewSizeType_320x50:
            return SSADSize_320x50;
            break;
        case SSADViewSizeType_728x90:
            return SSADSize_728x90;
            break;
        default:
            break;
    }
    return CGSizeZero;
}

@interface SSADHeader : NSObject

@end
