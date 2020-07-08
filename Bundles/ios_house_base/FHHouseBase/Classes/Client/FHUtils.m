//
//  FHUtils.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/21.
//

#import "FHUtils.h"
#import "NSDictionary+TTAdditions.h"
#import "TTSettingsManager.h"

@implementation FHUtils

+ (void)setContent:(id)object forKey:(NSString *)keyStr
{
    if (object && [keyStr isKindOfClass:[NSString class]]) {
        [[NSUserDefaults standardUserDefaults] setValue:object forKey:keyStr];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

+ (instancetype)contentForKey:(NSString *)keyStr
{
    if ([keyStr isKindOfClass:[NSString class]]) {
       return  [[NSUserDefaults standardUserDefaults] valueForKey:keyStr];
    }else
    {
        return nil;
    }
}

+ (NSString *)getJsonStrFrom:(NSDictionary *)dic
{
    if (![dic isKindOfClass:[NSDictionary class]]) {
        return @"";
    }
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONReadingAllowFragments error:&error];
    if (data && !error) {
        NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        temp = [temp stringByAddingPercentEncodingWithAllowedCharacters:NSCharacterSet.URLQueryAllowedCharacterSet];
        return temp;
    }
    return @"";
}

+ (NSString *)getJsonStrFromNoEncode:(NSDictionary *)dic{
    if (![dic isKindOfClass:[NSDictionary class]]) {
          return @"";
      }
      
      NSError *error = nil;
      NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONReadingAllowFragments error:&error];
      if (data && !error) {
          NSString *temp = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
          return temp;
      }
      return @"";
}

+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString
{
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err)
    {
        NSLog(@"json解析失败：%@",err);
        return nil;
    }
    return dic;
}

+ (NSString *)getUrlFormStrFromDict:(NSDictionary *)dic andFirstChar:(BOOL)withFirst
{
    NSMutableString *resultStr = [NSMutableString new];
    
    for (NSString * key in dic.allKeys) {
        if ([dic[key] isKindOfClass:[NSString class]] || [dic[key] isKindOfClass:[NSNumber class]]) {
            [resultStr appendString:[NSString stringWithFormat:@"&%@=%@",key,dic[key]]];
        }else if([dic[key] isKindOfClass:[NSDictionary class]])
        {
            [resultStr appendString:[NSString stringWithFormat:@"&%@=%@",key,[FHUtils getJsonStrFrom:dic[key]]]];
        }
    }
    
    if (!withFirst && resultStr.length > 1) {
        resultStr = [resultStr substringFromIndex:1];
    }
    return resultStr;
}

/**
 * @method
 *
 * @brief 获取两个日期之间的天数
 * @param fromDate       起始日期
 * @param toDate         终止日期
 * @return    总天数
 */
+ (NSInteger)numberOfDaysWithFromDate:(NSDate *)fromDate toDate:(NSDate *)toDate{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents    * comp = [calendar components:NSCalendarUnitDay
                                             fromDate:fromDate
                                               toDate:toDate
                                              options:NSCalendarWrapComponents];
    return comp.day;
}

+ (NSDate *)dateFromString:(NSString *)dateStr
{
    if (dateStr == nil) {
        return nil;
    }
    
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSDate *birthdayDate = [dateFormatter dateFromString:dateStr];
    return birthdayDate;
}

+ (NSString *)stringFromNSDate:(NSDate *)date
{
    if(!date)
    {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

+ (NSString *)stringFromNSDateDay:(NSDate *)date
{
    if(!date)
    {
        return nil;
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd"];
    NSString *strDate = [dateFormatter stringFromDate:date];
    return strDate;
}

/*
 周边加阴影，并且同时圆角，注意这个方法必须在view已经布局完成能够获得frame的情况下使用
 */
+ (void)addShadowToView:(UIView *)view
            withOpacity:(float)shadowOpacity
           shadowColor:(UIColor *)shadowColor
           shadowOffset:(CGSize)shadowOffset
           shadowRadius:(CGFloat)shadowRadius
        andCornerRadius:(CGFloat)cornerRadius {
    //////// shadow /////////
    CALayer *shadowLayer = [CALayer layer];
    shadowLayer.frame = view.layer.frame;
    
    shadowLayer.shadowColor = shadowColor.CGColor;//shadowColor阴影颜色
    shadowLayer.shadowOffset = shadowOffset;//shadowOffset阴影偏移，默认(0, -3),这个跟shadowRadius配合使用
    shadowLayer.shadowOpacity = shadowOpacity;//0.8;//阴影透明度，默认0
    shadowLayer.shadowRadius = shadowRadius;//8;//阴影半径，默认3
    
    //路径阴影
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    float width = shadowLayer.bounds.size.width;
    float height = shadowLayer.bounds.size.height;
    float x = shadowLayer.bounds.origin.x;
    float y = shadowLayer.bounds.origin.y;
    
    CGPoint topLeft      = shadowLayer.bounds.origin;
    CGPoint topRight     = CGPointMake(x + width, y);
    CGPoint bottomRight  = CGPointMake(x + width, y + height);
    CGPoint bottomLeft   = CGPointMake(x, y + height);
    
    CGFloat offset = -1.f;
    [path moveToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    [path addArcWithCenter:CGPointMake(topLeft.x + cornerRadius, topLeft.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI endAngle:M_PI_2 * 3 clockwise:YES];
    [path addLineToPoint:CGPointMake(topRight.x - cornerRadius, topRight.y - offset)];
    [path addArcWithCenter:CGPointMake(topRight.x - cornerRadius, topRight.y + cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 * 3 endAngle:M_PI * 2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomRight.x + offset, bottomRight.y - cornerRadius)];
    [path addArcWithCenter:CGPointMake(bottomRight.x - cornerRadius, bottomRight.y - cornerRadius) radius:(cornerRadius + offset) startAngle:0 endAngle:M_PI_2 clockwise:YES];
    [path addLineToPoint:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y + offset)];
    [path addArcWithCenter:CGPointMake(bottomLeft.x + cornerRadius, bottomLeft.y - cornerRadius) radius:(cornerRadius + offset) startAngle:M_PI_2 endAngle:M_PI clockwise:YES];
    [path addLineToPoint:CGPointMake(topLeft.x - offset, topLeft.y + cornerRadius)];
    
    //设置阴影路径
    shadowLayer.shadowPath = path.CGPath;
    
    //////// cornerRadius /////////
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
//    view.layer.shouldRasterize = YES;
//    view.layer.rasterizationScale = [UIScreen mainScreen].scale;
    
    [view.superview.layer insertSublayer:shadowLayer below:view.layer];
}
    
+ (UIImage*)createImageWithColor:(UIColor*)color {
    CGRect rect = CGRectMake(0.0f,0.0f,1.0f,1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

- (UIImage *)imageWithCornerRadius:(CGFloat)radius imageView:(UIImage *)imageView {
    CGRect rect = (CGRect){0.f, 0.f, imageView.size};
    
    UIGraphicsBeginImageContextWithOptions(imageView.size, NO, UIScreen.mainScreen.scale);
    CGContextAddPath(UIGraphicsGetCurrentContext(),
                     [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:radius].CGPath);
    CGContextClip(UIGraphicsGetCurrentContext());
    
    [imageView drawInRect:rect];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

+(BOOL)getSettingEnableBooleanForKey:(NSString *)key{
    NSDictionary *fhSettings= [[TTSettingsManager sharedManager] settingForKey:@"f_settings" defaultValue:@{} freeze:YES];
    return [fhSettings tt_boolValueForKey:key];
}
@end
