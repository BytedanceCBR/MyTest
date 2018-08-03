//
//  ExploreMomentListCellOriginArticleItemView.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-19.
//
//  动态cell中的元素, 用于展示原文章信息

#import "ExploreMomentListCellItemBase.h"
#import "ArticleDetailHeader.h"

/**
 *  动态中现实原文的view
 */
typedef NS_ENUM(NSUInteger, ExploreMomentListCellOriginArticleItemViewType)
{
    /**
     *  用于在动态列表cell中， 展示原文的信息
     */
    ExploreMomentListCellOriginArticleItemViewTypeMoment,
    /**
     *  用于在动态列表cell的转发view中，展示原文信息
     */
    ExploreMomentListCellOriginArticleItemViewTypeForward,
};

@interface ExploreMomentListCellOriginArticleItemView : ExploreMomentListCellItemBase

@property(nonatomic, assign)NewsGoDetailFromSource goDetailFromSource;

- (id)initWithWidth:(CGFloat)cellWidth
           userInfo:(NSDictionary *)uInfo
       itemViewType:(ExploreMomentListCellOriginArticleItemViewType)type;

+ (BOOL)needShowForModel:(ArticleMomentModel *)model
                userInfo:(NSDictionary *)uInfo
            itemViewType:(ExploreMomentListCellOriginArticleItemViewType)type;

+ (CGFloat)heightForMomentModel:(ArticleMomentModel *)model
                      cellWidth:(CGFloat)cellWidth
                       userInfo:(NSDictionary *)uInfo
                   itemViewType:(ExploreMomentListCellOriginArticleItemViewType)type;


@end
