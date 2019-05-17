//
//  TTBadgeTrackerHelper.h
//  Article
//
//  Created by 王双华 on 2017/4/7.
//
//

#import <Foundation/Foundation.h>

@interface TTBadgeTrackerHelper : NSObject

+ (void)trackTipsWithLabel:(NSString *)label position:(NSString *)position style:(NSString *)style;
+ (void)trackTipsWithLabel:(NSString *)label position:(NSString *)position style:(NSString *)style categoryID:(NSString *)categoryID;
@end
