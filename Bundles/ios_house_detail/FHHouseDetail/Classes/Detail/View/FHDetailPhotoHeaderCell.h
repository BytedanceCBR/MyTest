//
//  FHDetailPhotoHeaderCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/11.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol FHDetailPhotoHeaderCellDelegate ;
@interface FHDetailPhotoHeaderCell : FHDetailBaseCell

@property(nonatomic , weak) id<FHDetailPhotoHeaderCellDelegate> delegate;

// 模型要实现FHDetailPhotoHeaderCellProtocol
-(void)updateWithImages:(NSArray<FHDetailPhotoHeaderModelProtocol>*)images;

@end

@protocol FHDetailPhotoHeaderCellDelegate <NSObject>

-(void)showImages:(NSArray<FHDetailPhotoHeaderModelProtocol>*)images currentIndex:(NSInteger)index inCell:(FHDetailPhotoHeaderCell *)cell;

@end


NS_ASSUME_NONNULL_END
