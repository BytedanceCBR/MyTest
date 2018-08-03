//
//  TSVListAutoRefreshRecorder.h
//  HTSVideoPlay
//
//  Created by 王双华 on 2017/11/17.
//

#import <Foundation/Foundation.h>
#import "TTCategory.h"

@interface TSVListAutoRefreshRecorder : NSObject

+ (BOOL)shouldAutoRefreshForCategory:(TTCategory *)category;
+ (void)saveLastTimeRefreshForCategory:(TTCategory *)category;

@end
