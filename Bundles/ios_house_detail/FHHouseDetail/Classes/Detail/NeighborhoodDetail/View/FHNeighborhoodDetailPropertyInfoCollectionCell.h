//
//  FHNeighborhoodDetailPropertyInfoCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/12.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNeighborhoodPropertyInfoCell.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailPropertyInfoCollectionCell : FHDetailBaseCollectionCell

@property (nonatomic, copy) void (^foldButtonActionBlock)(void);

@end

@interface FHNeighborhoodDetailPropertyInfoModel : NSObject
@property (nonatomic, assign)   BOOL       isFold; // 折叠
@property (nonatomic, copy , nullable) NSString *baseInfoFoldCount;
@property (nonatomic, strong , nullable) NSArray<FHHouseBaseInfoModel> *baseInfo;

@end

@interface FHNeighborhoodDetailPropertyItemView : UIView

@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, strong)   UILabel       *valueLabel;
- (void)updateWithBaseInfoModel:(FHHouseBaseInfoModel *)infoModel;
@end


NS_ASSUME_NONNULL_END
