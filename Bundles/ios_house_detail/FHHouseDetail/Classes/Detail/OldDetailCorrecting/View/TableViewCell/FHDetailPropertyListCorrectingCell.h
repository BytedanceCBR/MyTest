//
//  FHDetailPropertyListCell.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/13.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
#import "FHDetailOldModel.h"
#import "FHDetailRentModel.h"

NS_ASSUME_NONNULL_BEGIN

@class FHHouseDetailContactViewModel;
// 用于二手房属性列表
@interface FHDetailPropertyListCorrectingCell : FHDetailBaseCell

@end



@interface FHDetailExtarInfoCorrectingRowView : UIControl

@property (nonatomic, strong)   UILabel       *nameLabel;
@property (nonatomic, strong)   UILabel       *infoLabel;
@property (nonatomic, strong)   UIImageView   *logoImageView;
@property (nonatomic, strong)   UILabel       *indicatorLabel;
@property (nonatomic, strong)   UIImageView  *indicator;
@property (nonatomic, strong)   id data;

-(void)updateWithOfficalData:(FHDetailDataBaseExtraOfficialModel *)officialModel;

-(void)updateWithDetectiveData:(FHDetailDataBaseExtraDetectiveModel *)detectiveModel;

-(void)updateWithSecurityInfo:(FHRentDetailDataBaseExtraSecurityInformationModel *)securityInfo;

-(void)updateWithBudgetData:(FHDetailDataBaseExtraBudgetModel *)budgetmodel;

-(void)updateWithNeighborhoodInfoData:(FHDetailDataBaseExtraNeighborhoodModel *)neighborModel;

-(void)updateWithFloorInfo:(FHDetailDataBaseExtraFloorInfoModel *)floorInfo;

-(void)updateWithHouseCertificationInfo:(FHDetailDataBaseExtraHouseCertificationModel *)houseCertificationInfo;

@end

// FHDetailPropertyListModel
@interface FHDetailPropertyListCorrectingModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHHouseCoreInfoModel> *baseInfo;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraModel *extraInfo;
@property (nonatomic, strong , nullable) FHRentDetailDataBaseExtraModel *rentExtraInfo;
@property (nonatomic, strong , nullable) FHDetailDataCertificateModel *certificate ;
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;

@end

NS_ASSUME_NONNULL_END
