//
//  TTSFQRShareView.h
//  QRDemo
//
//  Created by chenjiesheng on 2018/2/8.
//  Copyright © 2018年 陈杰生. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TTSFQRShareType)
{
    TTSFQRShareTypeShareCard = 0,
    TTSFQRShareTypeAskCard,
    TTSFQRShareTypeOther,
};

@interface TTSFQRShareView : UIView

+ (UIImage *)shareImageWithMahjongImage:(nullable UIImage *)mahjongImage
                              backImage:(nonnull UIImage *)backimage
                                tipText:(nullable NSString *)tipText
                              qrContent:(nullable NSString *)qrContent
                                   type:(TTSFQRShareType)shareType;

- (instancetype)initWithMahjongImage:(nullable UIImage *)mahjongImage
                           backImage:(nonnull UIImage *)backimage
                             tipText:(nullable NSString *)tipText
                           qrContent:(nullable NSString *)qrContent
                                type:(TTSFQRShareType)shareType;
@end
