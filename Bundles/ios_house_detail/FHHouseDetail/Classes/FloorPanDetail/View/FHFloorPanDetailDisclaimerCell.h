//
//  FHFloorPanDetailDisclaimerCell.h
//  FHHouseDetail
//
//  Created by luowentao on 2020/4/12.
//

#import "FHDetailBaseCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanDetailDisclaimerCell : FHDetailBaseCell

@end


@interface FHFloorPanDetailDisclaimerModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) FHDisclaimerModel *disclaimer ;
@property (nonatomic, strong , nullable) FHDetailContactModel *contact;//留着以后联系联系人用

@end


NS_ASSUME_NONNULL_END
