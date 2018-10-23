//
//  ArticleMomentCommentModel.h
//  Article
//
//  Created by Dianwei on 14-5-22.
//
//

#import <Foundation/Foundation.h>
#import "SSBaseModel.h"
#import "SSUserModel.h"
#import "TTQutoedCommentModel.h"

@interface ArticleMomentCommentModel : SSBaseModel<NSCoding>
+ (NSArray*)commentsWithArray:(NSArray*)array;
- (instancetype)initWithDictionary:(NSDictionary*)dict;
@property(nonatomic, assign)NSTimeInterval createTime;
@property(nonatomic, retain)NSString *content;
@property(nonatomic, retain)NSString *replyID;
@property(nonatomic, retain)SSUserModel *replyUser;
@property(nonatomic, retain)SSUserModel *user;
@property(nonatomic, assign)int diggCount;
@property(nonatomic, assign) BOOL userDigged;
@property(nonatomic, assign) BOOL isPgcAuthor;
@property(nonatomic, assign) BOOL isOwner;
@property(nonatomic, strong) TTQutoedCommentModel *qutoedComment;
@property(nonatomic, assign) BOOL isLocal;

//cache layout
@property(nonatomic, assign) CGFloat height;
@property(nonatomic, assign) CGFloat descHeight;

- (NSDictionary *)toDict;

@end
