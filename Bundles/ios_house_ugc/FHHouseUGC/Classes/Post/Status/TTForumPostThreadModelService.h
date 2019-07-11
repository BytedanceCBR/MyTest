//
//  TTForumPostThreadModelService.h
//  TTUGCService
//
//  Created by Vic on 2019/1/21.
//

#ifndef TTForumPostThreadModelService_h
#define TTForumPostThreadModelService_h

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TTForumPostThreadToPageType) {
    TTForumPostThreadToPageType_MainPage,
    TTForumPostThreadToPageType_FollowPage
};

@protocol TTForumPostThreadModelService <NSObject>

- (NSString *)postShortVideoToPageConcernID;

- (NSString *)postThreadToPageConcernID;

- (NSString *)postThreadToPageCategoryID;

- (TTForumPostThreadToPageType)postThreadToPageType;

@end

#endif /* TTForumPostThreadModelService_h */
