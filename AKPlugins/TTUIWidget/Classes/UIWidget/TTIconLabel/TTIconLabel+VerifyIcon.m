//
//  TTIconLabel+VerifyIcon.m
//  Article
//
//  Created by lizhuoli on 17/1/24.
//
//

#import "TTIconLabel+VerifyIcon.h"
#import "TTVerifyIconHelper.h"

#import <objc/runtime.h>

@implementation TTIconLabel (VerifyIcon)

-(void)addIconWithVerifyInfo:(NSString *)verifyInfo
{
//#if DEBUG
//    verifyInfo = kTTVerifyDefaultVerifyInfo;
//#endif
    if (isEmptyString(verifyInfo)) {
        return;
    }
    
    TTVerifyIconModel *verifyIcon = [TTVerifyIconHelper avatarIconOfVerifyInfo:verifyInfo];
    if (!verifyIcon) {
        return;
    }
    
    // 确保认证图标在第一位
    if (verifyIcon.imageURL && !isEmptyString(verifyIcon.imageName)) { // 未下载完成图片
        [self insertIconWithDayIconURL:verifyIcon.imageURL nightIconURL:nil size:CGSizeMake(verifyIcon.imageSize.width / 3, verifyIcon.imageSize.height / 3) atIndex:0];
    } else { // 包括已下载的网络图片，或者网络失败fallback的本地图
        [self insertIconWithDayIcon:verifyIcon.image nightIcon:nil size:CGSizeZero atIndex:0];
    }
}

@end
