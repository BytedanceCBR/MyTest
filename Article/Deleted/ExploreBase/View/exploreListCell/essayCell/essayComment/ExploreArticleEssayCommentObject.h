//
//  ExploreArticleEssayCommentObject.h
//  Article
//
//  Created by Chen Hong on 14-10-23.
//
//

#import <Foundation/Foundation.h>
#import "SSUserBaseModel.h"

@interface ExploreArticleEssayCommentObject : NSObject
@property(nonatomic,copy)NSString *content;
@property(nonatomic,retain)SSUserBaseModel *user;

- (void)updateWithDictionary:(NSDictionary *)dict;

@end
