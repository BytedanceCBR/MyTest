//
//  SSCookieManager.h
//  Article
//
//  Created by Dianwei on 13-5-12.
//
//

#import <Foundation/Foundation.h>

@interface SSCookieManager : NSObject

+ (void)setSessionIDToCookie:(NSString *)sessionID;

+ (NSString *)sessionIDFromCookie;

@end
