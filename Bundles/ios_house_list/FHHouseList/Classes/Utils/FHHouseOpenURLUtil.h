//
//  FHHouseOpenURLUtil.h
//  FHHouseList
//
//  Created by 春晖 on 2019/8/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHouseOpenURLUtil : NSObject

+(BOOL)isSameURL:(NSString *)url1 and:(NSString *)url2;

+(NSDictionary *)queryDict:(NSString *)url;

@end

NS_ASSUME_NONNULL_END
