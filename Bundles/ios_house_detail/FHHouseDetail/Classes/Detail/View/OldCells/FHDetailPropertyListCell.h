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
@interface FHDetailPropertyListCell : FHDetailBaseCell

@end

@interface FHPropertyListRowView : UIView

@property (nonatomic, strong)   UILabel       *keyLabel;
@property (nonatomic, strong)   UILabel       *valueLabel;

@end

@interface FHDetailExtarInfoRowView : UIControl

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

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder;

+ (nonnull instancetype)appearance;

+ (nonnull instancetype)appearanceForTraitCollection:(nonnull UITraitCollection *)trait;

+ (nonnull instancetype)appearanceForTraitCollection:(nonnull UITraitCollection *)trait whenContainedIn:(nullable Class<UIAppearanceContainer>)ContainerClass, ...;

+ (nonnull instancetype)appearanceWhenContainedIn:(nullable Class<UIAppearanceContainer>)ContainerClass, ...;

- (void)traitCollectionDidChange:(nullable UITraitCollection *)previousTraitCollection;

- (CGPoint)convertPoint:(CGPoint)point fromCoordinateSpace:(nonnull id<UICoordinateSpace>)coordinateSpace;

- (CGPoint)convertPoint:(CGPoint)point toCoordinateSpace:(nonnull id<UICoordinateSpace>)coordinateSpace;

- (CGRect)convertRect:(CGRect)rect fromCoordinateSpace:(nonnull id<UICoordinateSpace>)coordinateSpace;

- (CGRect)convertRect:(CGRect)rect toCoordinateSpace:(nonnull id<UICoordinateSpace>)coordinateSpace;

- (void)didUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context withAnimationCoordinator:(nonnull UIFocusAnimationCoordinator *)coordinator;

- (void)setNeedsFocusUpdate;

- (BOOL)shouldUpdateFocusInContext:(nonnull UIFocusUpdateContext *)context;

- (void)updateFocusIfNeeded;

- (nonnull NSArray<id<UIFocusItem>> *)focusItemsInRect:(CGRect)rect;

@end

// FHDetailPropertyListModel
@interface FHDetailPropertyListModel : FHDetailBaseModel

@property (nonatomic, strong , nullable) NSArray<FHHouseCoreInfoModel> *baseInfo;
@property (nonatomic, strong , nullable) FHDetailDataBaseExtraModel *extraInfo;
@property (nonatomic, strong , nullable) FHRentDetailDataBaseExtraModel *rentExtraInfo;
@property (nonatomic, strong , nullable) FHDetailDataCertificateModel *certificate ;
@property (nonatomic, weak) FHHouseDetailContactViewModel *contactViewModel;

@end

NS_ASSUME_NONNULL_END
