//
//  FHNeighborhoodDetailReleatorCollectionCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/13.
//

#import "FHNeighborhoodDetailReleatorCollectionCell.h"
#import "FHDetailAgentItemView.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHNeighborhoodDetailReleatorCollectionCell ()

@property (nonatomic, strong) FHDetailAgentItemView *itemView;



@end

@implementation FHNeighborhoodDetailReleatorCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (![data isKindOfClass:[FHDetailContactModel class] ]) {
        return CGSizeZero;
    }
    FHDetailContactModel *obj = (FHDetailContactModel *)data;
    CGFloat vHeight = 65;
    if (obj.realtorScoreDescription.length > 0 && obj.realtorScoreDisplay.length > 0 && obj.realtorTags.count > 0) {
        vHeight = 90;
    }else {
        vHeight = 65;
    }
    return CGSizeMake(width, vHeight);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailContactModel class] ]) {
        return;
    }
    self.currentData = data;
    FHDetailContactModel *obj = (FHDetailContactModel *)data;
    if (self.itemView) {
        [self.itemView removeFromSuperview];
        self.itemView = nil;
    }
    FHDetailAgentItemView *itemView = [[FHDetailAgentItemView alloc] initWithModel:obj topMargin:0];
    
    self.itemView = itemView;
    [self.contentView addSubview:itemView];
    CGFloat vHeight = 65;
    if (obj.realtorScoreDescription.length > 0 && obj.realtorScoreDisplay.length > 0 && obj.realtorTags.count > 0) {
        vHeight = 90;
    }else {
        vHeight = 65;
    }
    __weak typeof(self) weakSelf = self;
    
    
    [itemView addTarget:self action:@selector(cellClick:) forControlEvents:UIControlEventTouchUpInside];
    
    [itemView.licenseIcon btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
        if (weakSelf.licenseClickBlock) {
            weakSelf.licenseClickBlock(weakSelf.currentData);
        }
    }];

    [itemView.callBtn btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
        if (weakSelf.phoneClickBlock) {
            weakSelf.phoneClickBlock(weakSelf.currentData);
        }
    }];
    [itemView.imBtn btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
        if (weakSelf.imClickBlock) {
            weakSelf.imClickBlock(weakSelf.currentData);
        }
    }];
    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.contentView);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(vHeight);
    }];
    itemView.name.text = obj.realtorName;
    if (obj.realtorName.length >5 && obj.realtorCellShow == FHRealtorCellShowStyle3) {
        itemView.name.text = [NSString stringWithFormat:@"%@...",[obj.realtorName substringToIndex:5]];
    }
    itemView.agency.text = obj.agencyName;
    /// 如果门店信息和从业资格都为空则不展示名字右侧的分割线
    BOOL hideVSepLine = obj.agencyName.length == 0 && obj.certificate.length == 0;
    itemView.vSepLine.hidden = hideVSepLine;
    [itemView.avatorView updateAvatarWithModel:obj];
    if (obj.realtorCellShow == FHRealtorCellShowStyle0) {
        itemView.agency.font = [UIFont themeFontRegular:14];
    }
    /// 北京商业化开城需求的新样式，这个优先级更高
    BOOL showNewLicenseStyle = [self shouldShowNewLicenseStyle:obj];
    if (showNewLicenseStyle) {
        NSURL *iconURL = [NSURL URLWithString:obj.certification.iconUrl];
        [itemView configForNewLicenseIconStyle:showNewLicenseStyle imageURL:iconURL];
    } else {
        BOOL isLicenceIconHidden = ![self shouldShowContact:obj];
        [itemView configForLicenceIconWithHidden:isLicenceIconHidden];
    }
    if(obj.realtorEvaluate.length > 0) {
        itemView.realtorEvaluate.text = obj.realtorEvaluate;
    }
    if(obj.realtorScoreDisplay.length > 0) {
          itemView.score.text = obj.realtorScoreDisplay;
      }
    if(obj.realtorScoreDescription.length > 0) {
          itemView.scoreDescription.text = obj.realtorScoreDescription;
      }
}
/// 北京商业化开城需求新增逻辑
- (BOOL)shouldShowNewLicenseStyle:(FHDetailContactModel *)contact {
    BOOL result  = NO;
    FHContactCertificationModel *certificationModel = contact.certification;
    result = certificationModel.openUrl.length > 0;
    
    return result;
}

- (BOOL)shouldShowContact:(FHDetailContactModel* )contact {
    BOOL result  = NO;
    if (contact.businessLicense.length > 0) {
        result = YES;
    }
    if (contact.certificate.length > 0) {
        result = YES;
    }
    return result;
}

- (NSString *)elementType {
    return @"neighborhood_detail_related";
}

- (void)cellClick:(UIControl *)control {
    if (self.releatorClickBlock) {
        self.releatorClickBlock(self.currentData);
    }
}
@end
