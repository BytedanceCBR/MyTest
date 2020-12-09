//
//  FHNeighborhoodDetailPropertyInfoCollectionCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/12.
//

#import "FHDetailBaseCell.h"
#import "FHDetailNeighborhoodPropertyInfoCell.h"
#import <IGListKit/IGListKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface FHNeighborhoodDetailPropertyInfoCollectionCell : FHDetailBaseCollectionCell<IGListBindable>

@property (nonatomic, copy) void (^allButtonActionBlock)(void);

@end

@interface FHNeighborhoodDetailPropertyInfoModel : NSObject<IGListDiffable>
@property (nonatomic, assign)   BOOL       isFold; // 折叠
@property (nonatomic, copy , nullable) NSString *baseInfoFoldCount;
@property (nonatomic, strong , nullable) NSArray<FHHouseBaseInfoModel> *baseInfo;

- (instancetype)transformFoldStatus ;
@end

@interface FHNeighborhoodDetailPropertyItemView : UIView

@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, strong)   UILabel       *valueLabel;
- (void)updateWithBaseInfoModel:(FHHouseBaseInfoModel *)infoModel;
@end


NS_ASSUME_NONNULL_END
