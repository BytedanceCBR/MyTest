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
#import "FHDetailFoldViewButton.h"

@interface FHDetailAgentListCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, strong)   FHDetailFoldViewButton       *foldButton;

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
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)data;
    if (model.recommendedRealtors.count > 0) {
        __block NSInteger itemsCount = 0;
        CGFloat vHeight = 66.0;
        [model.recommendedRealtors enumerateObjectsUsingBlock:^(FHDetailContactModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            FHDetailAgentItemView *itemView = [[FHDetailAgentItemView alloc] init];
            [self.containerView addSubview:itemView];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(itemsCount * vHeight);
                make.left.right.mas_equalTo(self.containerView);
                make.height.mas_equalTo(vHeight);
            }];
            itemView.name.text = obj.realtorName;
            itemView.agency.text = obj.agencyName;
            if (obj.avatarUrl.length > 0) {
                [itemView.avator bd_setImageWithURL:[NSURL URLWithString:obj.avatarUrl] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
            }
            itemView.licenceIcon.hidden = ![self shouldShowContact:obj];
            itemsCount += 1;
        }];

    }
    // > 3 添加折叠展开
    if (model.recommendedRealtors.count > 3) {
        _foldButton = [[FHDetailFoldViewButton alloc] initWithDownText:@"查看全部" upText:@"收起" isFold:YES];
    }
    [self updateItems];
//    [self test];
}

//- (void)test {
//     FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
//    model.isFold = !model.isFold;
//    [self updateItems];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        [self test];
//    });
//}

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
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

- (void)updateItems {
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
    if (model.recommendedRealtors.count > 3) {
        [model.tableView beginUpdates];
        if (model.isFold) {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(66 * 3);
            }];
        } else {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(66 * model.recommendedRealtors.count);
            }];
        }
        [self setNeedsUpdateConstraints];
        [model.tableView endUpdates];
    }
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

- (instancetype)init
{
    self = [super init];
    if (self) {
        _isFold = YES;
    }
    return self;
}

@end
    
