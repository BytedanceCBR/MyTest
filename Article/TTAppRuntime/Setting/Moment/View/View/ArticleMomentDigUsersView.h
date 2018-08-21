//
//  ArticleMomentDigUsersView.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-28.
//
//

#import "SSViewBase.h"
#import "ArticleMomentModel.h"
#import "ArticleMomentDiggManager.h"
#import "TTCommentModelProtocol.h"
#import "SSThemed.h"
@interface ArticleMomentDigUsersView : SSThemedView
@property(nonatomic, retain) ArticleMomentDiggManager *diggManger;
@property(nonatomic, retain) SSThemedTableView *listView;

- (id)initWithFrame:(CGRect)frame momentModel:(ArticleMomentModel *)model;

- (id)initWithFrame:(CGRect)frame commentModel:(id<TTCommentModelProtocol>)model;

- (void)refreshWithMomentModel:(ArticleMomentModel *)model;

@end
