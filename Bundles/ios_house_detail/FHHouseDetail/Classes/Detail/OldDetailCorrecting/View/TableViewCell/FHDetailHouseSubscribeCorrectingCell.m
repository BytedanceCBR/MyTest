//
//  FHDetailHouseSubscribeCorrectingCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/3/19.
//

#import "FHDetailHouseSubscribeCorrectingCell.h"
#import "UILabel+House.h"
#import "FHTextField.h"
#import "FHEnvContext.h"
#import "ToastManager.h"
#import <FHHouseBase/FHUserInfoManager.h>
#import <FHHouseBase/NSObject+FHOptimize.h>
#import "SSCommonLogic.h"
#import "TTAccountLoginManager.h"
#import <TTAccountSDK/TTAccount.h>
#import <FHHouseBase/FHHouseFillFormHelper.h>

@interface FHDetailHouseSubscribeCorrectingCell()<UITextFieldDelegate>
@property (nonatomic, weak) UIImageView *shadowImage;
@property(nonatomic, weak) UIImageView *bacIma;
@property(nonatomic, weak) UIButton *subscribeBtn;
@property(nonatomic, strong) UILabel *tipNameLabel;
@end

@implementation FHDetailHouseSubscribeCorrectingCell

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailHouseSubscribeCorrectingModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailHouseSubscribeCorrectingModel *model = (FHDetailHouseSubscribeCorrectingModel *)data;
    self.shadowImage.image = model.shadowImage;
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
    self.subscribeBlock = model.subscribeBlock;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (UIImageView *)bacIma {
    if (!_bacIma) {
        UIImageView *bacIma = [[UIImageView alloc]init];
        bacIma.image = [UIImage imageNamed:@"houseSubscribeBac_new"];
        bacIma.userInteractionEnabled = YES;
        [self.contentView addSubview:bacIma];
        _bacIma = bacIma;
    }
    return  _bacIma;
}

- (void)setupUI {
    
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView).mas_offset(-30);
        make.bottom.mas_equalTo(self.contentView).mas_offset(4.5);
    }];
    
    [self.bacIma mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(21);
        make.right.mas_equalTo(self.contentView).offset(-21);
        make.top.mas_equalTo(self.contentView).offset(12);
        make.bottom.mas_equalTo(self.contentView).offset(-12 - 4.5);
        make.height.mas_equalTo(46);
    }];
    
    UIButton *subscribeBtn = [[UIButton alloc] init];
    [subscribeBtn setTitle:@"去订阅" forState:UIControlStateNormal];
    [subscribeBtn setTitleColor:[UIColor colorWithHexStr:@"#9c6d43"] forState:UIControlStateNormal];
    subscribeBtn.titleLabel.font = [UIFont themeFontMedium:12];
    subscribeBtn.layer.cornerRadius = 1;
    subscribeBtn.layer.borderWidth = 0.5;
    subscribeBtn.layer.borderColor = [[UIColor colorWithHexStr:@"#9c6d43"] CGColor];
    subscribeBtn.backgroundColor = [UIColor colorWithHexString:@"fffaf0"];
    [subscribeBtn addTarget:self action:@selector(subscribe) forControlEvents:UIControlEventTouchUpInside];
    [self.bacIma addSubview:subscribeBtn];
    self.subscribeBtn = subscribeBtn;
    [self.subscribeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bacIma);
        make.right.mas_equalTo(self.bacIma).offset(-9);
        make.width.mas_equalTo(54);
        make.height.mas_equalTo(24);
    }];
    
    self.tipNameLabel = [[UILabel alloc] init];
    self.tipNameLabel.textAlignment = NSTextAlignmentLeft;
    self.tipNameLabel.textColor = [UIColor colorWithHexString:@"9c6d43"];
    self.tipNameLabel.font = [UIFont themeFontMedium:14];
    self.tipNameLabel.text = @"订阅房源动态，掌握一手信息";
    [self.bacIma addSubview:self.tipNameLabel];
    [self.tipNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bacIma).offset(9);
        make.right.mas_equalTo(self.subscribeBtn.mas_left).offset(-9);
        make.centerY.mas_equalTo(self.bacIma);
        make.height.mas_equalTo(20);
    }];
}

- (void)subscribe {
    if (self.subscribeBlock) {
        self.subscribeBlock(nil);
    }
}

@end

@implementation FHDetailHouseSubscribeCorrectingModel
@end
