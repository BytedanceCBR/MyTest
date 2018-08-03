/**
 * @file UIImageAdditions
 * @author David<gaotianpo@songshulin.net>
 *
 * @brief UIImage的扩展
 * 
 * @details UIImage 一些功能的扩展
 * 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface UIImage (Create)

+ (UIImage *)centerStrechedresourceImageNamed:(NSString *)name;

+ (UIImage*)imageWithColor:(UIColor*)color size:(CGSize)size;
/**
 * @brief 将图片保持纵横比不变缩放到一正方形区域内
 * @return 返回缩放后的图片，该图片自动释放
 */
-(UIImage *)imageScaleAspectToMaxSize:(CGFloat)newSize;

//image that cannot excceed maxSize and its data size cannot excceed dataSize in kb
- (NSData *)imageDataWithMaxSize:(CGSize)maxSize maxDataSize:(float)dataSize;

//两张图片合成一张
+ (UIImage *)drawImage:(UIImage*)fgImage inImage:(UIImage*)bgImage atPoint:(CGPoint)point;

+ (UIImage *)imageWithUIColor:(UIColor *)color;

/*
 有需要使用图片素材的，可以试试用下面几个方法来自行创建 UIImage
 
 iOS 3.2 and later
 
 属性：
 size ：尺寸小，in points，不需要乘2
 cornerRadius : 圆角
 borderWidth、borderColor : 描边
 backgroundColor : 背景色，纯色
 backgroundColors : 背景色，渐变色，现在只支持从上到下两个色值的的线性渐变
 */
+ (UIImage *)imageWithSize:(CGSize)size
           backgroundColor:(UIColor *)backgroundColor;

+ (UIImage *)imageWithSize:(CGSize)size
              cornerRadius:(CGFloat)cornerRadius
           backgroundColor:(UIColor *)backgroundColor;

+ (UIImage *)imageWithSize:(CGSize)size
               borderWidth:(CGFloat)borderWidth
               borderColor:(UIColor *)borderColor
           backgroundColor:(UIColor *)backgroundColor;

+ (UIImage *)imageWithSize:(CGSize)size
              cornerRadius:(CGFloat)cornerRadius
               borderWidth:(CGFloat)borderWidth
               borderColor:(UIColor *)borderColor
           backgroundColor:(UIColor *)backgroundColor;

+ (UIImage *)imageWithSize:(CGSize)size
              cornerRadius:(CGFloat)cornerRadius
               borderWidth:(CGFloat)borderWidth
               borderColor:(UIColor *)borderColor
          backgroundColors:(NSArray *)backgroundColors;

- (UIImage *)thumbnailImage:(NSInteger)thumbnailSize
          transparentBorder:(NSUInteger)borderSize
               cornerRadius:(NSUInteger)cornerRadius
       interpolationQuality:(CGInterpolationQuality)quality;


- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;


- (UIImage *)resizedImageWithContentMode:(UIViewContentMode)contentMode
                                  bounds:(CGSize)bounds
                    interpolationQuality:(CGInterpolationQuality)quality;


@end


@interface UIImage (RoundedCorner)
- (UIImage *)roundedCornerImage:(NSInteger)cornerSize borderSize:(NSInteger)borderSize;

- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius;

- (UIImage *)imageByRoundCornerRadius:(CGFloat)radius
                          borderWidth:(CGFloat)borderWidth
                          borderColor:(UIColor *)borderColor;
@end

@interface UIImage (Alpha)

- (UIImage *)imageWithAlpha;
- (UIImage *)transparentBorderImage:(NSUInteger)borderSize;

- (UIImage *)blurImageWithRadius:(CGFloat)blurRadius tintColor:(UIColor *)tintColor saturationDeltaFactor:(CGFloat)saturationDeltaFactor;

@end

@interface UIImage (AlphaCover)

- (UIImage *)imageWithAlphaColor:(UIColor *)alphaColor;

@end

@interface UIImage (TTAddMaskImage)

- (UIImage *)tt_imageWithMaskImage:(UIImage *)maskImage inRect:(CGRect)maskRect;

@end
