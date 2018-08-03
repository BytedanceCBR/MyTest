//
//  TTCommentImageHelper.h
//  Article
//
//  Created by chenjiesheng on 2017/2/16.
//
//

#import <UIKit/UIKit.h>

@class TTImageInfosModel;

@interface TTCommentImageHelper : NSObject

typedef void(^completionBlock)(UIImage * _Nullable image);

+ (void)setupObjectImageWithInfoModel:(TTImageInfosModel * _Nonnull)infoModel object:(NSObject * _Nullable)object callback:(completionBlock _Nullable)callback;

//获得一个透明度为0.3的黑色遮罩处理后的image，如果originImage的identified为空那么返回原图
+ (UIImage * _Nonnull)nightImageWithOriginImage:(UIImage * _Nullable)originImage;

+ (UIImage * _Nonnull)dayImageWithOriginImage:(UIImage * _Nullable)originImage;
@end
