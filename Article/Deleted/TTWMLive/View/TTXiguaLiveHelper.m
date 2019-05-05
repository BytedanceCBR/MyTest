//
//  TTXiguaLiveHelper.m
//  Article
//
//  Created by lipeilun on 2017/12/5.
//

#import "TTXiguaLiveHelper.h"
#import "TTXiguaLiveModel.h"

@implementation TTXiguaLiveHelper

+ (NSString *)generateDescText:(TTXiguaLiveModel *)model {
    NSString *result;
    if (!isEmptyString([model liveUserInfoModel].name)) {
        result = [NSString stringWithFormat:@"%@ %ld人观看", [model liveUserInfoModel].name, [model liveLiveInfoModel].watchingCount];
    } else {
        result = [NSString stringWithFormat:@"%ld人观看", [model liveLiveInfoModel].watchingCount];
    }
    return result;
}

@end
