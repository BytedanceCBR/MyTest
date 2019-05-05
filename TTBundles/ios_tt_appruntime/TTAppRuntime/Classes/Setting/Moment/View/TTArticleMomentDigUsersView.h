//
//  TTArticleMomentDigUsersView.h
//  Article
//
//  Created by zhaoqin on 27/12/2016.
//
//

#import "SSViewBase.h"
#import "ArticleMomentModel.h"
#import "ArticleMomentDiggManager.h"
#import "TTCommentModelProtocol.h"
#import "SSThemed.h"

@interface TTArticleMomentDigUsersView : SSThemedView
@property(nonatomic, retain) ArticleMomentDiggManager *diggManger;
@property(nonatomic, retain) SSThemedTableView *listView;
@property(nonatomic, copy) NSString *groupId;
@property(nonatomic, copy) NSString *categoryName;
@property(nonatomic, copy) NSString *fromPage;
@property(nonatomic, assign) BOOL isBanShowAuthor;

- (instancetype)initWithFrame:(CGRect)frame commentID:(NSString *)commentID;

@end
