//
//  FHDetailAgentItemView.h
//  Pods
//
//  Created by bytedance on 2020/8/23.
//

#import <UIKit/UIKit.h>
#import <FHHouseBase/FHRealtorAvatarView.h>
#import "FHDetailBaseModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHDetailAgentItemView : UIControl

@property (nonatomic, strong)   FHRealtorAvatarView *avatorView;
@property (nonatomic, strong)   UIButton    *licenceIcon;
@property (nonatomic, strong)   UIButton    *callBtn;
@property (nonatomic, strong)   UIButton    *imBtn;
@property (nonatomic, strong)   UILabel     *name;
@property (nonatomic, strong)   UILabel     *agency;
@property (nonatomic, strong)   UIImageView *agencyBac;
@property (nonatomic, strong)   UILabel     *score;
@property (nonatomic, strong)   UILabel     *scoreDescription;
@property (nonatomic, strong)   UILabel     *realtorEvaluate;  // 话术
@property (nonatomic, strong)   UIView      *agencyDescriptionBac;
@property (nonatomic, strong)   UILabel     *agencyDescriptionLabel;//公司介绍


-(instancetype)initWithModel:(FHDetailContactModel *)model topMargin:(CGFloat )topMargin;

-(void)configForLicenceIconWithHidden:(BOOL)isHidden;

@end

NS_ASSUME_NONNULL_END
