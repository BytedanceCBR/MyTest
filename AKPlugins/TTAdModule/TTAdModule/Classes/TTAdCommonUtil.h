//
//  TTAdCommonUtil.h
//  Article
//
//  Created by carl on 2016/11/29.
//
//

#import <Foundation/Foundation.h>

@interface TTAdCommonUtil : NSObject
+ (nullable NSDictionary *)generalDeviceInfo;
@end

@interface NSDictionary (TTAdJSONSerial)

- (nullable NSString *)format2JSONString;

@end
