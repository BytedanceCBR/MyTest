//
//  FHFloorPanPicShowViewController.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/12.
//

#import "FHBaseViewController.h"
#import <FHHouseBase/FHHouseType.h>
#import "FHDetailNewModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHFloorPanPicShowViewController : FHBaseViewController
@property (nonatomic , strong) NSArray* pictsArray;
@property(nonatomic, copy) void (^albumImageBtnClickBlock)(NSInteger index);
@property(nonatomic, copy) void (^albumImageStayBlock)(NSInteger index,NSInteger stayTime);

@property (nonatomic, strong , nullable) NSArray<FHDetailNewTopImage *> *topImages;
@end

NS_ASSUME_NONNULL_END
