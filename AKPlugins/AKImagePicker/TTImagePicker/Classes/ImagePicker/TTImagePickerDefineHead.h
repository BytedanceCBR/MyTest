//
//  TTImagePickerHead.h
//  TestPhotos
//
//  Created by tyh on 2017/4/7.
//  Copyright © 2017年 tyh. All rights reserved.
//

#ifndef TTImagePickerHead_h
#define TTImagePickerHead_h

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIColor+TTThemeExtension.h"
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceUIUtils.h"
#import "TTUIResponderHelper.h"


#define dispatch_main_async_safe_ttImagePicker(block)\
    if ([NSThread isMainThread]) {\
        block();\
    } else {\
        dispatch_async(dispatch_get_main_queue(), block);\
    }


#define iOS7Later ([UIDevice currentDevice].systemVersion.floatValue >= 7.0f)
#define iOS8Later ([UIDevice currentDevice].systemVersion.floatValue >= 8.0f)
#define iOS9Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.0f)
#define iOS9_1Later ([UIDevice currentDevice].systemVersion.floatValue >= 9.1f)

#define KScreenWidth [UIScreen mainScreen].bounds.size.width
#define KScreenHeight [UIScreen mainScreen].bounds.size.height

//UI适配
#define TTFontSize(size)  [TTDeviceUIUtils tt_fontSize:size]
#define TTFont(size)  [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:size]]
#define TTPadding(padding) [TTDeviceUIUtils tt_padding:padding]

#define TTSafeAreaInsetsBottom [TTUIResponderHelper mainWindow].safeAreaInsets.bottom
#define TTSafeAreaInsetsTop [TTUIResponderHelper mainWindow].safeAreaInsets.top


static NSString *const TTImagePickerSelctedCountDidChange = @"TTImagePickerSelctedCountDidChange";


typedef enum : NSUInteger {
    TTImagePickerModePhoto = 0, //default 默认都是只有图片（包括gif）
    TTImagePickerModeVideo,
    TTImagePickerModeAll        //这种类型埋点暂时很少，见track,有需要加别的@涂耀辉
} TTImagePickerMode;


@class TTAlbumModel;
@protocol TTImagePickerNavDelegate <NSObject>

@optional

/// 导航栏关闭
- (void)ttImagePickerNavDidClose;
/// 选择哪个相册
- (void)ttImagePickerNavDidSelect:(TTAlbumModel *)model;
/// 点击完成
- (void)ttImagePickerNavDidFinish;


@end

/// 定制相册导航栏需要的协议
@protocol TTImagePickerNavProtocol <NSObject>

@optional
@property(nonatomic,weak) id<TTImagePickerNavDelegate> delegate;

@property (nonatomic,assign)BOOL enableSelcect;


/// 当请求完成相册数据时回调
- (void)didCompletedTheRequestWithAlbums:(NSArray <TTAlbumModel *> *)models;


@end


#endif /* TTImagePickerHead_h */
