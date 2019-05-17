//
//  TTSFQRManager.h
//  QRDemo
//
//  Created by chenjiesheng on 2018/2/8.
//  Copyright © 2018年 陈杰生. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTSFQRShareView.h"

@class TTMahjongModel;

typedef void(^completionBlock)(UIImage *image);

@interface TTSFQRManager : NSObject

+ (instancetype)shareInstance;
+ (UIImage *)QRImageWithText:(NSString *)text;

+ (void)downLoadInfoWithInfoDict:(NSDictionary *)dict
                  withCompletion:(completionBlock)completionBlock
                       shareType:(TTSFQRShareType)shareType
                         mahjong:(TTMahjongModel *)mahjong;
@end
