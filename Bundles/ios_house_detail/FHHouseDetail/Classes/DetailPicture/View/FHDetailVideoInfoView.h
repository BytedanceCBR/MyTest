//
//  FHDetailVideoInfoView.h
//  FHHouseDetail
//
//  Created by 张元科 on 2019/4/28.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHDetailVideoInfoView : UIView

@property(nonatomic , copy) void (^shareActionBlock)(void);
@property(nonatomic , copy) void (^collectActionBlock)(BOOL followStatus);

@property (nonatomic, strong)   UILabel       *priceLabel;
@property (nonatomic, strong)   UILabel       *infoLabel;
@property (nonatomic, assign)   NSInteger       followStatus;

@end

NS_ASSUME_NONNULL_END
