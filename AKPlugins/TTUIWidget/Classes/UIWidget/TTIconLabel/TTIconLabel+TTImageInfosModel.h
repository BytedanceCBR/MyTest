//
//  TTIconLabel+TTImageInfosModel.h
//  Article
//
//  Created by lizhuoli on 17/3/22.
//
//

#import "TTIconLabel.h"
#import "TTImageInfosModel.h"

@interface TTIconLabel (TTImageInfosModel)

/** 通过TTImageInfosModel添加图标 */
- (void)addIconWithImageInfosModel:(TTImageInfosModel *)model;
/** 通过TTImageInfosModel数组批量添加图标 */
- (void)addIconsWithImageInfosModels:(NSArray<TTImageInfosModel*> *)models;
/** 通过TTImageInfosModel添加图标到指定的Index */
- (void)insertIconWithImageInfosModel:(TTImageInfosModel *)model atIndex:(NSUInteger)index;
/** 获取指定TTImageInfosModel的图标Index */
- (NSUInteger)indexOfImageInfosModel:(TTImageInfosModel *)model;

@end
