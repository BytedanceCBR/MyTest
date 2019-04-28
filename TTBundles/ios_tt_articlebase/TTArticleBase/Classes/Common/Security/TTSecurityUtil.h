//
//  TTSecurityUtil.h
//  Article
//
//  Created by muhuai on 2017/9/20.
//
//

#import <Foundation/Foundation.h>

@interface TTSecurityUtil : NSObject

+ (instancetype)sharedInstance;

- (NSString *)encrypt:(NSString *)str token:(NSString *)token;

- (NSString *)decrypt:(NSString *)str token:(NSString *)token;

@end
