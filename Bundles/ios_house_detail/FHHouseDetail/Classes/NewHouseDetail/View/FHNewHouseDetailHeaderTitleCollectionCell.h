//
//  FHNewHouseDetailHeaderTitleCollectionCell.h
//  AKCommentPlugin
//
//  Created by bytedance on 2020/9/6.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHNewHouseDetailHeaderTitleCollectionCell : FHDetailBaseCollectionCell

@end

@interface FHNewHouseDetailHeaderTitleCellModel : NSObject

@property (nonatomic, copy) NSString *titleStr;
@property (nonatomic, copy) NSString *aliasName;
@property (nonatomic, strong) NSArray *tags;// FHHouseTagsModel item类型
@property (nonatomic, copy , nullable) NSString *businessTag;
@property (nonatomic, copy , nullable) NSString *advantage;

@end

NS_ASSUME_NONNULL_END
