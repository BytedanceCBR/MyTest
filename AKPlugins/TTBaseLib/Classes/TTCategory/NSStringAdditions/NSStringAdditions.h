/**
 * @file NSStringAdditions
 * @author David<gaotianpo@songshulin.net>
 *
 * @brief NSString的扩展
 * 
 * @details NSString 一些功能的扩展
 * 
 */


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (SSNSStringAdditions)

/**
 *  将字符串转换为16进制
 *
 *  @param string string
 *
 *  @return 转换后的字符串
 */
+ (NSString *)hexStringFromString:(NSString *)string;

/**
 *  获取缓存路径
 *
 *  @return 缓存路径
 */
- (NSString *)stringCachePath;

/**
 * @brief 获取程序的用户文档目录的路径加上自身
 * @return 用户文档目录路径字串加上自身，该字符串是自动释放的
 */
- (NSString *)stringDocumentsPath;

/**
 * @brief 返回自身的md5
 * @return 返回自身的md5的16进制字串
 */
- (NSString *)MD5HashString;

/**
 *  获取SHA256
 *
 *  @return 转换后的字符串
 */
- (NSString *)SHA256String;

/**
 *  去掉字符串头部和尾部的空格
 *
 *  @return 处理后的字符串
 */
- (NSString*)trimmed;

/**
 *  获取字符串宽高
 *
 *  @param font 字体大小
 *
 *  @return size
 */
- (CGSize)sizeWithFontCompatible:(UIFont *)font;

/**
 *  获取字符串宽高
 *
 *  @param font font
 *  @param constrainedSize constrainedSize
 *  @param paragraphStyle paragraphStyle
 *
 *  @return size
 */
- (CGSize)sizeWithFont:(UIFont *)font constrainedToSize:(CGSize)constrainedSize paragraphStyle:(NSParagraphStyle *)paragraphStyle;

/**
 *  使用正则表达式将字符串分割，array中不包含正则表达式
 *
 *  @param regex regex
 *
 *  @return components
 */
- (NSArray *)componentsSeparatedByRegex:(NSString *)regex;

/**
 *  使用正则表达式将字符串分割，检查是否包含ranges
 *
 *  @param regex regex
 *  @param ranges ranges
 *  @param resultRanges resultRanges
 *
 *  @return components
 */
- (NSArray *)componentsSeparatedByRegex:(NSString *)regex ranges:(NSArray **)ranges checkingResults:(NSArray **)resultRanges;
@end

@interface NSString (JSONExtension)

- (id)JSONValue;

@end
