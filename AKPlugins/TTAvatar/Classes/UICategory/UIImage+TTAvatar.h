//
//  UIImage+TTAvatar.h
//
//  Created by 邱鑫玥 on 2017/5/24.
//

#import <UIKit/UIKit.h>

/**
 *  UIImage (TTAvatar)
 */
@interface UIImage (TTAvatar)
/**
 *  将图片根据Imageview的大小，contentmode以及圆角值重绘成圆角图片
 *  @param radius 圆角值
 *  @param size imageview的大小
 *  @param contentMode imageview的contentmode
 */
- (UIImage *)tt_imageByRoundCornerRadius:(CGSize)radius size:(CGSize)size contentMode:(UIViewContentMode)contentMode;

@end
