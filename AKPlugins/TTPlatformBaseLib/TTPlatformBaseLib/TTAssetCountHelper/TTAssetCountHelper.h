//
//  TTAssetCountHelper.h
//  Article
//
//  Created by 徐霜晴 on 16/11/18.
//
//

#import <Foundation/Foundation.h>

@interface TTAssetCountHelper : NSObject

+ (void)saveAssetCount;
+ (BOOL)hasValidAssetCountSavedLastTime ;
+ (NSInteger)assetCountSavedLastTime;
+ (void)getAssetCountIfAutorizedCompleted:(void(^)(BOOL succeed, NSInteger count))completed;

@end
