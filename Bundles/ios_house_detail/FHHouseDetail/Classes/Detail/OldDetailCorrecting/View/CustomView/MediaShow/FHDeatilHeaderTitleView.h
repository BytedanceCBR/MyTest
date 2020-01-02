//
//  FHDeatilHeaderTitleView.h
//  AKCommentPlugin
//
//  Created by liuyu on 2019/11/26.
//

#import <UIKit/UIKit.h>
#import "FHDetailBaseModel.h"
#import "FHDetailHouseTitleModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHDeatilHeaderTitleView : UIView
@property (nonatomic, strong) NSArray *tags;// FHHouseTagsModel item类型
@property (nonatomic, copy) NSString *titleStr;
@property (strong, nonatomic) FHDetailHouseTitleModel *model;
@end


NS_ASSUME_NONNULL_END
