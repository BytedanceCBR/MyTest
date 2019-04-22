//
//  TSVPublishShortVideoHelper.m
//  Article
//
//  Created by 王双华 on 2018/1/18.
//

#import "TSVPublishShortVideoHelper.h"
#import "TTForumPostThreadToPageViewModel.h"
#import <TSVShortVideoPostTaskProtocol.h>
#import <TTCategoryDefine.h>

@implementation TSVPublishShortVideoHelper

+ (NSString *)publishShortVideoInsertToConcernID
{
    NSString *concernID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageConcernID];
    if ([TSVTabManager sharedManager].isInShortVideoTab) {
        concernID = kTTShortVideoConcernID;
    }
    if (isEmptyString(concernID)) {
        concernID = kTTMainConcernID;
    }
    return concernID;
}

+ (NSString *)publishShortVideoInsertToCategoryID
{
    NSString *categoryID = [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageCategoryID];
    if ([TSVTabManager sharedManager].isInShortVideoTab) {
        categoryID = kTTUGCVideoCategoryID;
    }
    if (isEmptyString(categoryID)) {
        categoryID = kTTMainCategoryID;
    }
    return categoryID;
}

@end
