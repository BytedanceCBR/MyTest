//
//  FHNeighborhoodDetailCommentTagsCell.h
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/14.
//

#import "FHDetailBaseCell.h"
#import "FHNeighborhoodDetailCommentTagView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailCommentTagsCell : FHDetailBaseCollectionCell

@end

@interface FHNeighborhoodDetailCommentTagsModel : NSObject

@property(nonatomic , strong) NSArray<FHNeighborhoodDetailCommentTagModel *> *tags;

@end


NS_ASSUME_NONNULL_END
