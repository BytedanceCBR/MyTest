//
//  FHHouseRentFacilityItemView.h
//  FHHouseRent
//
//  Created by leo on 2018/11/20.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FHSpringboardView.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHHouseRentFacilityItemView : UIView<FHSpringboardItemView>
@property (nonatomic, strong) UIImageView* iconView;
@property (nonatomic, strong) UILabel* label;
@property (nonatomic, strong) UILabel* strickoutLabel;
- (instancetype)initWithStrickoutLabel:(UILabel*)label;
-(void)setDisableLabel:(NSString*)text;

@end

NS_ASSUME_NONNULL_END
