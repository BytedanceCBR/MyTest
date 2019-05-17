//
//  TTMinePhotoCarouselEntry.h
//  Article
//
//  Created by chenjiesheng on 2018/3/7.
//

#import "TTSettingGeneralEntry.h"
#import "AKPhotoCarouselCellModel.h"
@interface AKMinePhotoCarouselEntry : TTSettingGeneralEntry

@property (nonatomic, copy)NSArray<AKPhotoCarouselCellModel *>  *cellModels;

- (instancetype)initWithArray:(NSArray *)cellModelDicts;
@end
