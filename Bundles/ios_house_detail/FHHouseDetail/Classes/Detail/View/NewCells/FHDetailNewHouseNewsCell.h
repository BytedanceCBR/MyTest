//
//  FHDetailNewHouseNewsCell.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHDetailBaseCell.h"
#import "FHDetailHeaderView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailNewHouseNewsCell : FHDetailBaseCell
@property (nonatomic, strong) FHDetailHeaderView *headerView;
@end

@interface FHDetailNewHouseNewsCellModel : JSONModel

@property (nonatomic, assign) BOOL hasMore;
@property (nonatomic, strong) NSString * titleText;
@property (nonatomic, strong) NSString * courtId;

@end

NS_ASSUME_NONNULL_END
