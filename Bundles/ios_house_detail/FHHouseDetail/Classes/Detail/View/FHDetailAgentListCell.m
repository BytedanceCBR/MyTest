//
//  FHDetailAgentListCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/2/14.
//

#import "FHDetailAgentListCell.h"
#import <Masonry.h>
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "FHDetailOldModel.h"
#import "FHURLSettings.h"
#import "TTRoute.h"
#import "FHDetailHeaderView.h"
#import "FHExtendHotAreaButton.h"

@interface FHDetailAgentListCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;

@end

@implementation FHDetailAgentListCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailAgentListModel class]]) {
        return;
    }
    self.currentData = data;
    //
    
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)data;

    [self layoutIfNeeded];
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (UILabel *)createLabel:(NSString *)text textColor:(NSString *)hexColor fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor colorWithHexString:hexColor];
    label.font = [UIFont themeFontRegular:fontSize];
    return label;
}

- (void)setupUI {
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"推荐经纪人";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(46);
    }];
}


@end


// FHDetailAgentItemView

@implementation FHDetailAgentItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (UILabel *)createLabel:(NSString *)text textColor:(NSString *)hexColor fontSize:(CGFloat)fontSize {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.textColor = [UIColor colorWithHexString:hexColor];
    label.font = [UIFont themeFontRegular:fontSize];
    return label;
}

- (void)setupUI {
    _avator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"default-avatar-icons"]];
    _avator.layer.cornerRadius = 23;
    _avator.contentMode = UIViewContentModeScaleAspectFill;
    _avator.clipsToBounds = YES;
    [self addSubview:_avator];
    
    _licenceIcon = [[FHExtendHotAreaButton alloc] init];
    [_licenceIcon setImage:[UIImage imageNamed:@"contact"] forState:UIControlStateNormal];
    [self addSubview:_licenceIcon];
    
    _callBtn = [[FHExtendHotAreaButton alloc] init];
    [_callBtn setImage:[UIImage imageNamed:@"icon-phone"] forState:UIControlStateNormal];
    [self addSubview:_callBtn];
    
    self.name = [self createLabel:@"" textColor:@"#081f33" fontSize:16];
    _name.font = [UIFont themeFontMedium:16];
    _name.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_name];
    
    self.agency = [self createLabel:@"" textColor:@"#a1aab3" fontSize:14];
    _agency.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_agency];
    
    [self.avator mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(46);
        make.left.mas_equalTo(20);
        make.top.mas_equalTo(20);
        make.bottom.mas_equalTo(self);
    }];
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avator.mas_right).offset(14);
        make.top.mas_equalTo(self.avator).offset(4);
        make.height.mas_equalTo(22);
    }];
    [self.agency mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.name.mas_bottom);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.avator.mas_right).offset(14);
        make.right.mas_lessThanOrEqualTo(self.callBtn.mas_left);
    }];
    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.name.mas_right).offset(4);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.name);
        make.right.mas_lessThanOrEqualTo(self.callBtn.mas_left).offset(-10);
    }];
    [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(self.avator);
    }];
}

@end

// FHDetailAgentListModel

@implementation FHDetailAgentListModel


@end
