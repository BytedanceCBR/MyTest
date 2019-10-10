//
//  FHTopicTopBackView.h
//  FHHouseUGC
//
//  Created by 张元科 on 2019/8/23.
//

#import <UIKit/UIKit.h>
#import "FHTopicHeaderModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHTopicTopBackView : UIView

@property (nonatomic, strong)   UIImageView        *headerImageView;
@property (nonatomic, strong) UIImageView *avatar;

- (void)updateWithInfo:(FHTopicHeaderModel *)headerModel;

@end

NS_ASSUME_NONNULL_END