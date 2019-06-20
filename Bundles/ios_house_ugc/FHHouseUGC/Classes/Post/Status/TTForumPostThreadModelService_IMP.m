//
//  TTForumPostThreadModelService_IMP.m
//  TTUGCFeature
//
//  Created by Vic on 2019/1/21.
//

#import "TTForumPostThreadModelService_IMP.h"

#import "TTForumPostThreadToPageViewModel.h"

@implementation TTForumPostThreadModelService_IMP

+ (instancetype)sharedInstance {
    static TTForumPostThreadModelService_IMP *imp;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        imp = [[TTForumPostThreadModelService_IMP alloc] init];
    });
    
    return imp;
}

- (NSString *)postShortVideoToPageConcernID {
    return [[TTForumPostThreadToPageViewModel sharedInstance_tt] postShortVideoToPageConcernID];
}

- (NSString *)postThreadToPageConcernID {
    return [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageConcernID];
}

- (NSString *)postThreadToPageCategoryID {
    return [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageCategoryID];
}

- (TTForumPostThreadToPageType)postThreadToPageType {
    return [[TTForumPostThreadToPageViewModel sharedInstance_tt] postThreadToPageType];
}

@end
