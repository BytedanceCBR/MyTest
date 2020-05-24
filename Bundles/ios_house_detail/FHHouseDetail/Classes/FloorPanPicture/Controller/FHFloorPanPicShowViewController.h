//
//  FHFloorPanPicShowViewController.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/12.
//

#import "FHBaseViewController.h"
#import <FHHouseBase/FHHouseType.h>
#import "FHDetailNewModel.h"
#import "FHDetailBaseModel.h"
#import "FHHouseDetailContactViewModel.h"
#import "FHDetailMediaHeaderCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanPicShowViewController : FHBaseViewController
@property (nonatomic , strong) NSArray* pictsArray;
@property(nonatomic, copy) void (^albumImageBtnClickBlock)(NSInteger index);
@property(nonatomic, copy) void (^albumImageStayBlock)(NSInteger index,NSInteger stayTime);

@property (nonatomic, strong , nullable) NSArray<FHDetailNewTopImage *> *topImages;
//@property (nonatomic, strong) FHDetailMediaHeaderModel       *mediaHeaderModel;
@property (nonatomic, strong) FHHouseDetailContactViewModel *contactViewModel;
@property (nonatomic, strong, nullable) FHClueAssociateInfoModel *associateInfo;

@property (nonatomic, copy) NSString *elementFrom;
@end

NS_ASSUME_NONNULL_END
