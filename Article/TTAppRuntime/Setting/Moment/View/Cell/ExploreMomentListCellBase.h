//
//  ExploreMomentListCellBase.h
//  Article
//
//  Created by Zhang Leonardo on 15-1-14.
//
//

#import "SSThemed.h"
#import "ArticleMomentModel.h"
#import "ExploreMomentDefine.h"

@protocol ExploreMomentListCellBaseDelegate;

@interface ExploreMomentListCellBase : SSThemedTableViewCell

@property(nonatomic, strong)ArticleMomentModel * momentModel;
@property(nonatomic, assign)ArticleMomentSourceType sourceType;

@property(nonatomic, weak)id<ExploreMomentListCellBaseDelegate>delegate;

+ (CGFloat)heightForModel:(ArticleMomentModel *)model cellWidth:(CGFloat)width sourceType:(ArticleMomentSourceType)sourceType;
- (void)refreshWithModel:(ArticleMomentModel *)model indexPath:(NSIndexPath *)indexPath;


@end

@protocol  ExploreMomentListCellBaseDelegate<NSObject>

- (void)momentListCell:(ExploreMomentListCellBase *)listCell needReloadForIndex:(NSUInteger)index;
- (void)momentListCell:(ExploreMomentListCellBase *)listCell openCommentDetailForModel:(ArticleMomentModel *)model;

@optional

- (void)momentListCell:(ExploreMomentListCellBase *)listCell commentButtonClicked:(ArticleMomentCommentModel *)commentModel rectInKeyWindow:(CGRect)rect;

@end

