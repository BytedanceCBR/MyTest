//
//  TTFavouriteContentItem.m
//  Article
//
//  Created by 延晋 张 on 2017/1/18.
//
//

#import "TTFavouriteContentItem.h"

NSString * const TTActivityContentItemTypeFavourite        =
@"com.toutiao.ActivityContentItem.Favourite";

@implementation TTFavouriteContentItem

- (NSString *)contentItemType
{
    return TTActivityContentItemTypeFavourite;
}

- (NSString *)activityImageName {
    NSString * imageName = @"love_allshare";
    if (self.selected) {
        imageName = [NSString stringWithFormat:@"%@_selected", imageName];
    }
    return imageName;
}

@end
