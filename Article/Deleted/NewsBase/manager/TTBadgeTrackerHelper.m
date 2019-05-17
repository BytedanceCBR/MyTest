//
//  TTBadgeTrackerHelper.m
//  Article
//
//  Created by 王双华 on 2017/4/7.
//
//

#import "TTBadgeTrackerHelper.h"

@implementation TTBadgeTrackerHelper

+ (void)trackTipsWithLabel:(NSString *)label position:(NSString *)position style:(NSString *)style
{
    [self trackTipsWithLabel:label position:position style:style categoryID:nil];
}

+ (void)trackTipsWithLabel:(NSString *)label position:(NSString *)position style:(NSString *)style categoryID:(NSString *)categoryID
{
    if (!isEmptyString(label) && !isEmptyString(position) && !isEmptyString(style)) {
        NSMutableDictionary *extra = [NSMutableDictionary dictionaryWithCapacity:2];
        [extra setValue:categoryID forKey:@"category_name"];
        [extra setValue:position forKey:@"position"];
        [extra setValue:style forKey:@"style"];
        wrapperTrackEventWithCustomKeys(@"tips", label, nil, nil, extra);
    }
}

@end
