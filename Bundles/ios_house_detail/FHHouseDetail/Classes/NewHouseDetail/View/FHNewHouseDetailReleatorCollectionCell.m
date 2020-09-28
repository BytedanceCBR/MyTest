//
//  FHNewHouseDetailReleatorCollectionCell.m
//  Pods
//
//  Created by bytedance on 2020/9/9.
//

#import "FHNewHouseDetailReleatorCollectionCell.h"
#import <FHHouseBase/FHRealtorAvatarView.h>
#import "FHExtendHotAreaButton.h"
#import <ByteDanceKit/ByteDanceKit.h>

@interface FHNewHouseDetailReleatorCollectionCell ()
@property (nonatomic, strong)   FHRealtorAvatarView *avatorView;
@property (nonatomic, strong)   UIButton    *licenceIcon;
@property (nonatomic, strong)   UIButton    *callBtn;
@property (nonatomic, strong)   UIButton    *imBtn;
@property (nonatomic, strong)   UILabel     *name;
@property (nonatomic, strong)   UILabel     *agency;
@property (nonatomic, strong)   UIImageView *agencyBac;
@property (nonatomic, strong)   UIView      *agencyDescriptionBac;
@property (nonatomic, strong)   UILabel     *agencyDescriptionLabel;//公司介绍
@end

@implementation FHNewHouseDetailReleatorCollectionCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.avatorView = [[FHRealtorAvatarView alloc] init];
        [self addSubview:self.avatorView];
        [self.avatorView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.width.mas_equalTo(50);
            make.left.mas_equalTo(16);
            make.top.mas_equalTo(0);
        }];
        
        self.name = [[UILabel alloc] init];
        self.name.textColor = [UIColor themeBlack];
        self.name.font = [UIFont themeFontMedium:16];
        self.name.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.name];
        [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatorView.mas_right).offset(14);
            make.top.mas_equalTo(self.avatorView.mas_top).mas_offset(4);
            make.height.mas_equalTo(22);
        }];
        
        __weak typeof(self) weakSelf = self;
        self.callBtn = [[FHExtendHotAreaButton alloc] init];
        [self.callBtn setImage:[UIImage imageNamed:@"detail_agent_call_normal_new"] forState:UIControlStateNormal];
        [self.callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press_new"] forState:UIControlStateSelected];
        [self.callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press_new"] forState:UIControlStateHighlighted];
        [self.callBtn btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.phoneClickBlock) {
                weakSelf.phoneClickBlock(weakSelf.currentData);
            }
        }];
        [self addSubview:self.callBtn];
        [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(26);
            make.right.mas_equalTo(-15);
            make.top.mas_equalTo(self.name);
        }];
        
        self.imBtn = [[FHExtendHotAreaButton alloc] init];
        [self.imBtn setImage:[UIImage imageNamed:@"detail_agent_message_normal_new"] forState:UIControlStateNormal];
        [self.imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press_new"] forState:UIControlStateSelected];
        [self.imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press_new"] forState:UIControlStateHighlighted];
        [self.imBtn btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.imClickBlock) {
                weakSelf.imClickBlock(weakSelf.currentData);
            }
        }];
        [self addSubview:self.imBtn];
        [self.imBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(26);
            make.right.mas_equalTo(self.callBtn.mas_left).offset(-38);
            make.top.mas_equalTo(self.name);
        }];

        self.licenceIcon = [[FHExtendHotAreaButton alloc] init];
        [self.licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateNormal];
        [self.licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateSelected];
        [self.licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateHighlighted];
        [self.licenceIcon btd_addActionBlockForTouchUpInside:^(__kindof UIButton * _Nonnull sender) {
            if (weakSelf.licenseClickBlock) {
                weakSelf.licenseClickBlock(weakSelf.currentData);
            }
        }];
        [self addSubview:self.licenceIcon];
        [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.name.mas_right).offset(4);
            make.width.height.mas_equalTo(20);
            make.centerY.mas_equalTo(self.name);
            make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
        }];
        
        self.agencyBac = [[UIImageView alloc]init];
        self.agencyBac.image = [UIImage imageNamed:@"realtor_name_bac"];
        self.agencyBac.layer.borderWidth = 0.5;
        self.agencyBac.layer.borderColor = [[UIColor colorWithHexString:@"#d6d6d6"] CGColor];
        self.agencyBac.layer.cornerRadius = 2.0;
        self.agencyBac.layer.masksToBounds = YES;
        [self addSubview:self.agencyBac];
        
        self.agency = [[UILabel alloc] init];
        self.agency.textColor = [UIColor colorWithHexString:@"#929292"];
        self.agency.font = [UIFont themeFontMedium:10];
        self.agency.textAlignment = NSTextAlignmentLeft;
        [self addSubview:self.agency];
        [self.agency mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.agencyBac).offset(3);
            make.bottom.mas_equalTo(self.agencyBac).offset(-3);
            make.left.mas_equalTo(self.agencyBac).offset(5);
            make.right.mas_equalTo(self.agencyBac).offset(-5);
        }];
       
        self.agencyDescriptionBac = [[UIView alloc]init];
        self.agencyDescriptionBac.backgroundColor = [UIColor colorWithHexString:@"#fefaf4"];
        self.agencyDescriptionBac.layer.cornerRadius = 2.0;
        self.agencyDescriptionBac.layer.masksToBounds = YES;
        [self addSubview:self.agencyDescriptionBac];
        [self.agencyDescriptionBac mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatorView.mas_right).offset(8);
            make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left);
            make.height.mas_equalTo(18);
            make.bottom.mas_equalTo(self.avatorView);
        }];
        
        self.agencyDescriptionLabel = [[UILabel alloc] init];
        self.agencyDescriptionLabel.font = [UIFont themeFontRegular:10];
        self.agencyDescriptionLabel.backgroundColor = [UIColor clearColor];
        self.agencyDescriptionLabel.textColor = [UIColor themeBlack];
        self.agencyDescriptionLabel.textAlignment = NSTextAlignmentCenter;
        [self.agencyDescriptionLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        [self addSubview:self.agencyDescriptionLabel];
        [self.agencyDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.agencyDescriptionBac).offset(3);
            make.bottom.mas_equalTo(self.agencyDescriptionBac).offset(-3);
            make.left.mas_equalTo(self.agencyDescriptionBac).offset(10);
            make.right.mas_equalTo(self.agencyDescriptionBac).offset(-10);
        }];
    }
    return self;
}

-(void)newHouseModifiedLayoutNameNeedShowCenter:(BOOL )showCenter{

    [self.name mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatorView.mas_right).offset(10);
        if (showCenter) {
            make.centerY.mas_equalTo(self.avatorView);
        } else {
            make.top.mas_equalTo(self.avatorView.mas_top).mas_offset(4);
        }
        make.height.mas_equalTo(20);
    }];
    
    [self.name setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];  //这个好神奇！！！
    
    [self.agencyBac mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.name);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.name.mas_right).offset(4);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
    }];
    
    //[self.agency setContentCompressionResistancePriority:UILayoutPriorityDragThatCannotResizeScene forAxis:UILayoutConstraintAxisHorizontal];
    self.agency.textAlignment = NSTextAlignmentCenter;
    
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailContactModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailContactModel *model = (FHDetailContactModel *)data;
    
    self.name.text = model.realtorName;
    self.agency.text = model.agencyName;
    [self.avatorView updateAvatarWithModel:model];
    
    [self newHouseModifiedLayoutNameNeedShowCenter:model.agencyDescription.length <= 0];
    if (model.agencyDescription.length > 0) {
        self.agencyDescriptionBac.hidden = NO;
    } else {
        self.agencyDescriptionBac.hidden = YES;
    }
    self.agencyDescriptionLabel.text = model.agencyDescription;
    BOOL result  = NO;
    if (model.businessLicense.length > 0) {
        result = YES;
    }
    if (model.certificate.length > 0) {
        result = YES;
    }
    self.licenceIcon.hidden = !result;
}

- (NSString *)elementType {
    return @"new_detail_related";
}

@end

//@implementation FHNewHouseDetailReleatorCellModel
//@end
