//
//  FHDetailPriceChangeNoticeCell.h
//  FHHouseDetail
//
//  Created by liuyu on 2020/4/10.
//

#import "FHDetailBaseCell.h"
#import "FHDetailOldModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHDetailPriceChangeNoticeCell : FHDetailBaseCell

@end

@interface  FHDetailPriceNoticeModel: FHDetailBaseModel
@property (nonatomic, weak)     FHHouseDetailBaseViewModel       *baseViewModel;
@property (nonatomic, strong , nullable) FHDetailPriceChangeNoticeModel *priceChangeNotice;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;
@property (nonatomic, strong) FHDetailContactModel *contactPhone;
@property (nonatomic, weak) UIViewController *belongsVC;
@property (nonatomic, weak)   id contactModel;


@end

@interface FHDetailPriceChangeNoticeItem : UIControl
@property (copy, nonatomic) NSString *imageName;
@property (copy, nonatomic) NSString *content;
@end


NS_ASSUME_NONNULL_END
