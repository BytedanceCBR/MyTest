//
//  TSVVideoPlayAddressManager.h
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/12/18.
//

#import <Foundation/Foundation.h>

@interface TSVVideoPlayAddressManager : NSObject

+ (void)saveVideoPlayAddress:(NSString *)address forGroupID:(NSString *)groupID;
+ (void)removeVideoPlayAddressForGroupID:(NSString *)groupID;
+ (NSString *)videoPlayeAddressForGroupID:(NSString *)groupID;

@end
