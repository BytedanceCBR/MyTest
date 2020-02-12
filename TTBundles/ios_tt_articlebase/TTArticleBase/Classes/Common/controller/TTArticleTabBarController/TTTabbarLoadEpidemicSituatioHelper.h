//
//  TTTabbarLoadEpidemicSituatioHelper.h
//  TTArticleBase
//
//  Created by liuyu on 2020/2/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TTTabbarLoadEpidemicSituatioHelper : NSObject
+(void)downloadEpidemicSituationToCacheWithNormalUrl:(NSString *)normalStr highlighthUrl:(NSString *)highlightStr;
@end

NS_ASSUME_NONNULL_END
