//
//  TTForumPostThreadToPageViewModel.h
//  Article
//
//  Created by ranny_90 on 2017/8/17.
//
//

#import <Foundation/Foundation.h>
#import <TTBaseLib/NSObject+TTAdditions.h>
#import "TTForumPostThreadModelService.h"

@interface TTForumPostThreadToPageViewModel : NSObject<Singleton>

- (NSString *)postShortVideoToPageConcernID;

- (NSString *)postThreadToPageConcernID;

- (NSString *)postThreadToPageCategoryID;

- (TTForumPostThreadToPageType)postThreadToPageType;

@end
