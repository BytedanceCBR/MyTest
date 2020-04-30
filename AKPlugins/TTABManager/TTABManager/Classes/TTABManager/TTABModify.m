//
//  TTABPatch.m
//  AFgzipRequestSerializer
//
//  Created by zuopengliu on 2/11/2017.
//

#import "TTABModify.h"
#import "TTABManager.h"
#import "TTABManagerUtil.h"



@implementation TTABModify

+ (void)modifyClientAB:(NSDictionary *)modifyMappers
{
    
    if (!modifyMappers ||
        ![modifyMappers isKindOfClass:[NSDictionary class]] ||
        [modifyMappers count] == 0) {
        return;
    }
    
    // do patch
}

@end
