//
//  TTArticleMomentDigUsersViewController.h
//  Article
//
//  Created by zhaoqin on 27/12/2016.
//
//

#import "SSViewControllerBase.h"
#import "TTModalWrapController.h"

typedef NS_ENUM(NSUInteger, TTArticleMomentDigUserSource) {
    TTArticleMomentDigUserSourceCommentDetail = 1,
    TTArticleMomentDigUserSourceCommentRepostDetail = 2
};

@class TTArticleMomentDigUsersView;
@class ArticleMomentModel;

@interface TTArticleMomentDigUsersViewController : SSViewControllerBase<TTModalWrapControllerProtocol>
@property(nonatomic, copy)NSString *mediaId;
@property(nonatomic, copy)NSString *commentId;
@property(nonatomic, copy)NSString *gid;
@property(nonatomic, copy)NSString *momentId;
@property(nonatomic, copy)NSString *categoryName;
@property(nonatomic, copy)NSString *fromPage;
@property(nonatomic, strong)TTArticleMomentDigUsersView * diggUserView;
@property(nonatomic, assign) BOOL needRefresh;
@property(nonatomic, assign) BOOL hasNestedInModalContainer;
@property(nonatomic, assign) TTArticleMomentDigUserSource sourceFrom;
@property(nonatomic, assign) BOOL isBanShowAuthor;
@end
