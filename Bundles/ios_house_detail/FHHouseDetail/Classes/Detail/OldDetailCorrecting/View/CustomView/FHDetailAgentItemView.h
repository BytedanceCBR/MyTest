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

@property (nonatomic, strong)   UILabel     *nameLabel;
@property (nonatomic, strong)   UIButton    *callBtn;
@property (nonatomic, strong)   UIButton    *imBtn;

@property (nonatomic, strong)   UIButton    *licenseButton; //认证按钮
@property (nonatomic, strong)   UILabel     *agencyLabel; //经纪公司
@property (nonatomic, strong)   UIImageView *agencyBac;

@property (nonatomic, strong)   UILabel     *scoreLabel; //服务分 + 小区熟悉度


-(instancetype)initWithModel:(FHDetailContactModel *)model topMargin:(CGFloat )topMargin;

@end

@interface FHDetailAgentItemTagsFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGFloat maximumInteritemSpacing;

@end

@interface FHDetailAgentItemTagsViewCell: UICollectionViewCell

@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UIImageView *tagImageView;

+ (NSString *)reuseIdentifier;

- (void)refreshWithData:(id)data;

@end


NS_ASSUME_NONNULL_END
