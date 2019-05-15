//
//  TTVFeedCollectionCellConfigure.m
//  Article
//
//  Created by pei yun on 2017/7/13.
//
//

#import "TTVFeedCollectionCellConfigure.h"
#import "TTVFeedCollectionVideoCell.h"
#import "TTCategory.h"
#import "TTFeedCollectionCellService.h"
#import "TTVSettingsConfiguration.h"

@implementation TTVFeedCollectionCellConfigure

+ (void)load
{
    [[TTFeedCollectionCellService sharedInstance] registerFeedCollectionCellHelperClass:self];
}

+ (nullable Class<TTFeedCollectionCell>)cellClassFromFeedCategory:(nonnull id<TTFeedCategory>)feedCategory
{
    BOOL isTitanVideoBusiness = ttvs_isTitanVideoBusiness();
    if (!isTitanVideoBusiness) {
        return nil;
    }
    switch (feedCategory.listDataType) {
        case TTFeedListDataTypeArticle:
            NSLog(@"TTFeedListDataTypeArticle: %@", feedCategory.categoryID);
            if ([feedCategory.categoryID isEqualToString:kTTVideoCategoryID]) {
                return [TTVFeedCollectionVideoCell class];
            }
            break;
        default:
            break;
    }
    return nil;
}

+ (NSArray<Class<TTFeedCollectionCell>> *)supportedCellClasses
{
    BOOL isTitanVideoBusiness = ttvs_isTitanVideoBusiness();
    if (!isTitanVideoBusiness) {
        return nil;
    }
    return @[
             [TTVFeedCollectionVideoCell class]
             ];
}

@end
