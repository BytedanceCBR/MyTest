//
//  ExploreMomentListCellForumItemView.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-14.
//
//  动态cell中的元素， 用于显示动态中的话题

#import "ExploreMomentListCellItemBase.h"

typedef NS_ENUM(NSUInteger, ExploreMomentListCellForumItemViewType)
{
    ExploreMomentListCellForumItemViewTypeMoment,
    ExploreMomentListCellForumItemViewTypeForward,
};


@interface ExploreMomentListCellForumItemView : ExploreMomentListCellItemBase

- (id)initWithWidth:(CGFloat)cellWidth userInfo:(NSDictionary *)uInfo forumType:(ExploreMomentListCellForumItemViewType)type;

+ (BOOL)needShowForModel:(ArticleMomentModel *)model
                userInfo:(NSDictionary *)uInfo
               forumType:(ExploreMomentListCellForumItemViewType)type;

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model
                      cellWidth:(CGFloat)cellWidth
                       userInfo:(NSDictionary *)uInfo
                      forumType:(ExploreMomentListCellForumItemViewType)type;


@end
