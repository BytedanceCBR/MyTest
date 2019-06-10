//
//  TTBuryContentItem.m
//  Article
//
//  Created by lishuangyang on 2017/8/24.
//
//

#import "TTBuryContentItem.h"

NSString * const TTActivityContentItemTypeBury       =      @"com.toutiao.ActivityContentItem.Bury";

@implementation TTBuryContentItem

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeBury;
}

- (NSString *)activityImageName
{
    NSString * imageName = @"digdown_allshare";
    if (self.selected) {
        imageName = [NSString stringWithFormat:@"%@_selected", imageName];
    }
    return imageName;
}
@end
