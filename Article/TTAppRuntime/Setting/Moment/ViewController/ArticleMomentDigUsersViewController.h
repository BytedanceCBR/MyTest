//
//  ArticleMomentDigUsersViewController.h
//  Article
//
//  Created by Zhang Leonardo on 14-5-28.
//
//

#import "SSViewControllerBase.h"
#import "ArticleMomentModel.h"
#import "TTCommentModelProtocol.h"
#import "ArticleMomentDigUsersView.h"
@interface ArticleMomentDigUsersViewController : SSViewControllerBase
@property(nonatomic, copy)NSString *mediaId;
@property(nonatomic, copy)NSString *commentId;
@property(nonatomic, copy)NSString *gid;
@property(nonatomic, copy)NSString *momentId;
@property(nonatomic, strong)ArticleMomentDigUsersView * diggUserView;
@property(nonatomic, assign) BOOL needRefresh;
- (id)initWithMomentModel:(ArticleMomentModel *)model;
- (instancetype)initWithCommentModel:(id<TTCommentModelProtocol>)commentModel;  //后续动态和评论拆开后会迁出去 @zengruihuan
- (void)refreshIfNeedWithMoment:(ArticleMomentModel *)model;
@end
