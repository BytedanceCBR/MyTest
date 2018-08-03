//
//  TSVVideoShareManager.h
//  HTSVideoPlay
//
//  Created by bytedance on 2017/12/1.
//

#import <Foundation/Foundation.h>

@protocol TTActivityContentItemProtocol;

@interface TSVVideoShareManager : NSObject

+ (NSArray<id<TTActivityContentItemProtocol>> *)synchronizeUserDefaultsWithItemArray:(NSArray *)array;

+ (void)synchronizeUserDefaultsWithAvtivityType:(NSString *)type;

@end
