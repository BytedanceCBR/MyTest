//
//  FHDetailNewHouseCoreInfoCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHDetailBaseCell.h"
#import "FHDetailBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@class FHDetailHouseNameModel;
@class FHDetailDisclaimerModel;

@interface FHDetailNewHouseCoreInfoCell : FHDetailBaseCell

@end

@interface FHDetailNewHouseCoreInfoModel : FHDetailBaseModel

@property (nonatomic, copy)     NSString  *pricingPerSqm;
@property (nonatomic, copy , nullable) NSString *gaodeLng;
@property (nonatomic, copy , nullable) NSString *gaodeLat;
@property (nonatomic, copy)     NSString  *constructionOpendate;
@property (nonatomic, strong)   NSString   *courtAddress;//楼盘地址
@property (nonatomic, assign)   NSInteger pricingSubStauts;
@property (nonatomic, strong)   NSString   *courtId;//楼盘id
@property (nonatomic, strong)   FHDetailHouseNameModel *houseName;
@property (nonatomic, strong)   FHDetailDisclaimerModel *disclaimerModel;
@property (nonatomic, weak)   id contactModel;

@end

NS_ASSUME_NONNULL_END
