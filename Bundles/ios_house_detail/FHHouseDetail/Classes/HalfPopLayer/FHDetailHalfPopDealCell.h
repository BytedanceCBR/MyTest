//
//  FHDetailHalfPopDealCell.h
//  DemoFunTwo
//
//  Created by 春晖 on 2019/5/20.
//  Copyright © 2019 chunhui. All rights reserved.
//

#import <UIKit/UIKit.h>

@class FHRentDetailDataBaseExtraDialogContentModel;
NS_ASSUME_NONNULL_BEGIN
//交易贴士cell
@interface FHDetailHalfPopDealCell : UITableViewCell

@property(nonatomic , strong) UILabel *titleLabel;
@property(nonatomic , strong) UILabel *infoLabel;
@property(nonatomic , strong) UIImageView *imgView;

-(void)updateWithModel:(FHRentDetailDataBaseExtraDialogContentModel *)model;

@end

NS_ASSUME_NONNULL_END
