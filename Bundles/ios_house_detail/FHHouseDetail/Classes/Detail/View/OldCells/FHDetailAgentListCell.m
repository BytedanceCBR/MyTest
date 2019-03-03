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
#import "UILabel+House.h"

@interface FHDetailAgentListCell ()

@property (nonatomic, strong)   FHDetailHeaderView       *headerView;
@property (nonatomic, strong)   UIView       *containerView;
@property (nonatomic, strong)   FHDetailFoldViewButton       *foldButton;
@property (nonatomic, strong)   NSMutableDictionary       *tracerDicCache;

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
            // 添加事件
            itemView.tag = idx;
            itemView.licenceIcon.tag = idx;
            itemView.callBtn.tag = idx;
            itemView.imBtn.tag = idx;
            [itemView addTarget:self action:@selector(cellClick:) forControlEvents:UIControlEventTouchUpInside];
            [itemView.licenceIcon addTarget:self action:@selector(licenseClick:) forControlEvents:UIControlEventTouchUpInside];
            [itemView.callBtn addTarget:self action:@selector(phoneClick:) forControlEvents:UIControlEventTouchUpInside];
            [itemView.imBtn addTarget:self action:@selector(imclick:) forControlEvents:UIControlEventTouchUpInside];
            
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
        if (_foldButton) {
            [_foldButton removeFromSuperview];
            _foldButton = nil;
        }
        _foldButton = [[FHDetailFoldViewButton alloc] initWithDownText:@"查看全部" upText:@"收起" isFold:YES];
        [self.contentView addSubview:_foldButton];
        [_foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containerView.mas_bottom);
            make.height.mas_equalTo(58);
            make.left.right.mas_equalTo(self.contentView);
        }];
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView).offset(-58);
        }];
        [self.foldButton addTarget:self action:@selector(foldButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(self.contentView).offset(-20);
        }];
    }
    [self updateItems:NO];
}

// cell点击
- (void)cellClick:(UIControl *)control {
    NSInteger index = control.tag;
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
    if (index >= 0 && model.recommendedRealtors.count > 0 && index < model.recommendedRealtors.count) {
        FHDetailContactModel *contact = model.recommendedRealtors[index];
        [model.phoneCallViewModel jump2RealtorDetailWithPhone:contact];
    }
}

// 证书点击
- (void)licenseClick:(UIControl *)control {
    NSInteger index = control.tag;
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
    if (index >= 0 && model.recommendedRealtors.count > 0 && index < model.recommendedRealtors.count) {
        FHDetailContactModel *contact = model.recommendedRealtors[index];
        [model.phoneCallViewModel licenseActionWithPhone:contact];
    }
}

// 电话点击
- (void)phoneClick:(UIControl *)control {
    NSInteger index = control.tag;
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
    if (index >= 0 && model.recommendedRealtors.count > 0 && index < model.recommendedRealtors.count) {
        FHDetailContactModel *contact = model.recommendedRealtors[index];
        NSMutableDictionary *extraDict = @{}.mutableCopy;
        extraDict[@"realtor_id"] = contact.realtorId;
        extraDict[@"realtor_rank"] = @(index);
        extraDict[@"realtor_position"] = @"detail_related";
        [model.phoneCallViewModel callWithPhone:contact.phone searchId:model.searchId imprId:model.imprId extraDict:extraDict];
        // 静默关注功能
        [model.followUpViewModel silentFollowHouseByFollowId:model.houseId houseType:model.houseType actionType:model.houseType showTip:NO];
    }
}

// 点击会话
- (void)imclick:(UIControl *)control {
    NSInteger index = control.tag;
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
    if (index >= 0 && model.recommendedRealtors.count > 0 && index < model.recommendedRealtors.count) {
        FHDetailContactModel *contact = model.recommendedRealtors[index];
        [model.phoneCallViewModel imchatActionWithPhone:contact realtorRank:[NSString stringWithFormat:@"%d", index] position:@"detail_related"];
    }
}

- (void)foldButtonClick:(UIButton *)button {
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
    model.isFold = !model.isFold;
    self.foldButton.isFold = model.isFold;
    [self updateItems:YES];
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

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _tracerDicCache = [NSMutableDictionary new];
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

- (void)updateItems:(BOOL)animated {
    FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
    NSInteger realtorShowCount = 0;
    if (model.recommendedRealtors.count > 3) {
        if (animated) {
            [model.tableView beginUpdates];
        }
        if (model.isFold) {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(66 * 3);
            }];
            realtorShowCount = 3;
        } else {
            [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(66 * model.recommendedRealtors.count);
            }];
            realtorShowCount = model.recommendedRealtors.count;
            [self addRealtorClickMore];
        }
        [self setNeedsUpdateConstraints];
        if (animated) {
            [model.tableView endUpdates];
        }
    } else if (model.recommendedRealtors.count > 0) {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(66 * model.recommendedRealtors.count);
        }];
        realtorShowCount = model.recommendedRealtors.count;
    } else {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(0);
        }];
        realtorShowCount = 0;
    }
    // realtor_show埋点
    [self tracerRealtorShowToIndex:realtorShowCount];
}

- (void)tracerRealtorShowToIndex:(NSInteger)index {
    for (int i = 0; i< index; i++) {
        NSString *cahceKey = [NSString stringWithFormat:@"%d",i];
        if (self.tracerDicCache[cahceKey]) {
            continue;
        }
        self.tracerDicCache[cahceKey] = @(YES);
        FHDetailAgentListModel *model = (FHDetailAgentListModel *)self.currentData;
        if (i < model.recommendedRealtors.count) {
            FHDetailContactModel *contact = model.recommendedRealtors[i];
            NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
            tracerDic[@"element_type"] = @"old_detail_related";
            tracerDic[@"realtor_id"] = contact.realtorId ?: @"be_null";
            tracerDic[@"realtor_rank"] = @(i);
            tracerDic[@"realtor_position"] = @"detail_related";
            if (contact.phone.length < 1) {
                [tracerDic setValue:@"0" forKey:@"phone_show"];
            } else {
                [tracerDic setValue:@"1" forKey:@"phone_show"];
            }
            if (![@"" isEqualToString:contact.imOpenUrl] && contact.imOpenUrl != nil) {
                [tracerDic setValue:@"1" forKey:@"im_show"];
            } else {
                [tracerDic setValue:@"0" forKey:@"im_show"];
            }
            // 移除字段
            [tracerDic removeObjectsForKeys:@[@"card_type",@"element_from",@"search_id"]];
            [FHUserTracker writeEvent:@"realtor_show" params:tracerDic];
        }
    }
}

- (void)addRealtorClickMore {
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    // 移除字段
    [tracerDic removeObjectsForKeys:@[@"card_type",@"element_from",@"search_id",@"enter_from"]];
    [FHUserTracker writeEvent:@"realtor_click_more" params:tracerDic];
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"old_detail_related";
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

- (void)setupUI {
    _avator = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_default_avatar"]];
    _avator.layer.cornerRadius = 23;
    _avator.contentMode = UIViewContentModeScaleAspectFill;
    _avator.clipsToBounds = YES;
    [self addSubview:_avator];
    
    _licenceIcon = [[FHExtendHotAreaButton alloc] init];
    [_licenceIcon setImage:[UIImage imageNamed:@"contact"] forState:UIControlStateNormal];
    [self addSubview:_licenceIcon];
    
    _callBtn = [[FHExtendHotAreaButton alloc] init];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_normal"] forState:UIControlStateNormal];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press"] forState:UIControlStateSelected];
    [_callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press"] forState:UIControlStateHighlighted];
    [self addSubview:_callBtn];
    
    _imBtn = [[FHExtendHotAreaButton alloc] init];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_normal"] forState:UIControlStateNormal];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press"] forState:UIControlStateSelected];
    [_imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press"] forState:UIControlStateHighlighted];
    [self addSubview:_imBtn];
    
    self.name = [UILabel createLabel:@"" textColor:@"#081f33" fontSize:16];
    _name.font = [UIFont themeFontMedium:16];
    _name.textAlignment = NSTextAlignmentLeft;
    [self addSubview:_name];
    
    self.agency = [UILabel createLabel:@"" textColor:@"#a1aab3" fontSize:14];
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
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left);
    }];
    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.name.mas_right).offset(4);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.name);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
    }];
    [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.right.mas_equalTo(-20);
        make.centerY.mas_equalTo(self.avator);
    }];
    [self.imBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(40);
        make.right.mas_equalTo(self.callBtn.mas_left).offset(-20);
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
    
