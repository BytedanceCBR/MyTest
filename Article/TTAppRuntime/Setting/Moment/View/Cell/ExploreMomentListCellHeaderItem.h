//
//  ExploreMomentListCellHeaderItem.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-28.
//
//

#import "ExploreMomentListCellItemBase.h"
#import "ExploreMomentListCellUserInfoItemView.h"
#import "ExploreMomentListCellCommentItemView.h"
//#import "ExploreMomentListCellForumItemView.h"
#import "ExploreMomentListCellUserActionItemView.h"
#import "ExploreMomentListCellPicItemView.h"
#import "ExploreMomentListCellForwardItemView.h"
#import "ExploreMomentListCellOriginArticleItemView.h"
#import "ExploreMomentListCellTimeAndReportItem.h"
#import "ExploreMomentDefine.h"

@interface ExploreMomentListCellHeaderItem : ExploreMomentListCellItemBase

//@property(nonatomic, assign)ArticleMomentSourceType sourceType;

@property(nonatomic, strong)ExploreMomentListCellUserInfoItemView * userInfoItemView;
@property(nonatomic, strong)ExploreMomentListCellCommentItemView * commentItemView;
//@property(nonatomic, strong)ExploreMomentListCellForumItemView * forumItemView;
@property(nonatomic, strong)ExploreMomentListCellTimeAndReportItem * timeAndReportItemView;
@property(nonatomic, strong)ExploreMomentListCellUserActionItemView * actionItemView;
@property(nonatomic, strong)ExploreMomentListCellPicItemView * picItemView;
@property(nonatomic, strong)ExploreMomentListCellForwardItemView * forwardItemView;
@property(nonatomic, strong)ExploreMomentListCellOriginArticleItemView * originArticleItemView;
- (void)arrowButtonClicked;
@end
