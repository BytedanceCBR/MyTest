//
//  TTRecommendUserCell.h
//  推人卡片
//  Article
//
//  Created by 王双华 on 16/11/30.
//
//

#import "ExploreCellBase.h"
#import "ExploreCellViewBase.h"
#import "TTFeedDislikeView.h"

@interface TTRecommendUserCell : ExploreCellBase
@end

@interface TTRecommendUserCellView : ExploreCellViewBase
+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType slice:(BOOL)slice;
@end
