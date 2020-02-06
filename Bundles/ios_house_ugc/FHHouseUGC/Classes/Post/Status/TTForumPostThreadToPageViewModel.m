//
//  TTForumPostThreadToPageViewModel.m
//  Article
//
//  Created by ranny_90 on 2017/8/17.
//
//

#import "TTForumPostThreadToPageViewModel.h"
#import "TTCategoryDefine.h" //这东西为啥在UIModel库里？
#import "TTCategory.h"
#import "TTArticleCategoryManager.h"
#import <TTKitchen/TTKitchen.h>
#import "TTTabBarProvider.h"
#import "TSVShortVideoPostTaskProtocol.h"
#import <TTKitchenExtension/TTKitchenExtension.h>

@implementation TTForumPostThreadToPageViewModel

- (NSString *)postShortVideoToPageConcernID {
    BOOL isInShortVideoTab = [[TTTabBarProvider currentSelectedTabTag] isEqualToString:kTTTabHTSTabKey];
    if (isInShortVideoTab) {
        return kTTShortVideoConcernID;
    }
    else {
        return [self postThreadToPageConcernID];
    }
}

- (NSString *)postThreadToPageConcernID{
    
    if ([self postThreadToPageType] == TTForumPostThreadToPageType_MainPage) {
        return kTTMainConcernID;
    }
    
    else{
        return KTTFollowPageConcernID;
    }
}

- (NSString *)postThreadToPageCategoryID{
    if ([self postThreadToPageType] == TTForumPostThreadToPageType_MainPage) {
        return kTTMainCategoryID;
    }
    
    else{
        return kTTFollowCategoryID;
    }
}

- (TTForumPostThreadToPageType)postThreadToPageType{
    
    TTForumPostThreadToPageType pageType = TTForumPostThreadToPageType_FollowPage;
    
    //发布完成跳转至关注频道开关打开
    if ([TTKitchen getBOOL:kTTKUGCPostToFollowPageEnable]) {
        
    }
    
    return pageType;
}

@end
