//
// Created by zhulijun on 2019-08-27.
//

#import "FHDetailHouseReviewCommentCell.h"
#import "FHDetailHouseReviewCommentItemView.h"
#import "TTBaseMacro.h"
#import "TTUGCAttributedLabel.h"
#import "FHDetailFoldViewButton.h"
#import "FHDetailHeaderView.h"
#import "FHHouseContactConfigModel.h"
#import "FHHousePhoneCallUtils.h"
#import "FHHouseFollowUpConfigModel.h"
#import "FHHouseFollowUpHelper.h"
#import "FHHouseDetailPhoneCallViewModel.h"

@implementation FHDetailHouseReviewCommentCellModel : FHDetailBaseModel
@end

@interface FHDetailHouseReviewCommentCell () <FHDetailHouseReviewCommentItemViewDelegate>
@property(nonatomic, strong) FHDetailHeaderView *headerView;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) FHDetailFoldViewButton *foldButton;
@property(nonatomic, strong) NSMutableDictionary *tracerDicCache;
@end

@implementation FHDetailHouseReviewCommentCell

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @""; // 周边小区
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    _containerView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(self.contentView);
    }];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailHouseReviewCommentCellModel class]]) {
        return;
    }
    FHDetailHouseReviewCommentCellModel *modelData = (FHDetailHouseReviewCommentCellModel *) data;
    if (modelData.houseReviewComment.count <= 0) {
        return;
    }
    self.currentData = modelData;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }

    __block FHDetailHouseReviewCommentItemView *beforeView = nil;
    __block CGFloat height = 0.0f;
    WeakSelf;
    [modelData.houseReviewComment enumerateObjectsUsingBlock:^(FHDetailHouseReviewCommentModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        StrongSelf;
        FHDetailHouseReviewCommentItemView *itemView = [[FHDetailHouseReviewCommentItemView alloc] init];
        itemView.delegate = wself;
        itemView.tag = idx;
        CGFloat itemHeight = [FHDetailHouseReviewCommentItemView heightForData:obj];
        [wself.containerView addSubview:itemView];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(beforeView != nil ? beforeView.mas_bottom : self.containerView.mas_top).offset(10);
            make.left.right.mas_equalTo(self.containerView);
            make.height.mas_equalTo(itemHeight);
        }];
        [itemView refreshWithData:obj];
        height += (itemHeight + 10);
        beforeView = itemView;
    }];


    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    // > 3 添加折叠展开
    if (modelData.houseReviewComment.count > 2) {
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

- (void)updateItems:(BOOL)animated {
    FHDetailHouseReviewCommentCellModel *model = (FHDetailHouseReviewCommentCellModel *) self.currentData;
    NSInteger showCount = model.isExpand ? model.houseReviewComment.count : MIN(model.houseReviewComment.count, 2);
    __block CGFloat height = 0.0f;
    [model.houseReviewComment enumerateObjectsUsingBlock:^(FHDetailHouseReviewCommentModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        height += [FHDetailHouseReviewCommentItemView heightForData:obj] + 10;
        if (idx == showCount - 1) {
            *stop = YES;
        }
    }];
    if (animated) {
        [model.tableView beginUpdates];
    }
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [self setNeedsUpdateConstraints];
    if (animated) {
        [model.tableView endUpdates];
    }
}

- (void)foldButtonClick:(UIButton *)button {
    FHDetailHouseReviewCommentCellModel *modelData = (FHDetailHouseReviewCommentCellModel *) self.currentData;
    modelData.isExpand = !modelData.isExpand;
    self.foldButton.isFold = !modelData.isExpand;
    [self updateItems:YES];
}

- (void)onReadMoreClick:(FHDetailHouseReviewCommentItemView *)item {
    FHDetailHouseReviewCommentCellModel *modelData = (FHDetailHouseReviewCommentCellModel *) self.currentData;
    NSInteger showCount = modelData.isExpand ? modelData.houseReviewComment.count : MIN(modelData.houseReviewComment.count, 2);
    __block CGFloat height = 0.0f;
    [modelData.houseReviewComment enumerateObjectsUsingBlock:^(FHDetailHouseReviewCommentModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        height += [FHDetailHouseReviewCommentItemView heightForData:obj] + 10;
        if (idx == showCount - 1) {
            *stop = YES;
        }
    }];
    [modelData.tableView beginUpdates];
    [item mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([FHDetailHouseReviewCommentItemView heightForData:item.curData]);
    }];
    [item.commentView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([item.curData commentHeight]);
    }];
    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    [self setNeedsUpdateConstraints];
    [modelData.tableView endUpdates];
}

- (void)onCallClick:(FHDetailHouseReviewCommentItemView *)item {
    NSInteger index = item.tag;
    FHDetailHouseReviewCommentCellModel *cellModel = (FHDetailHouseReviewCommentCellModel *) self.currentData;

    FHDetailContactModel *contact = item.curData.realtorInfo;
    NSMutableDictionary *extraDict = @{}.mutableCopy;
    extraDict[@"realtor_id"] = contact.realtorId;
    extraDict[@"realtor_rank"] = @(index);
    extraDict[@"realtor_position"] = @"detail_related";
    if (self.baseViewModel.detailTracerDic) {
        [extraDict addEntriesFromDictionary:self.baseViewModel.detailTracerDic];
    }

    FHHouseContactConfigModel *contactConfig = [[FHHouseContactConfigModel alloc] initWithDictionary:extraDict error:nil];
    contactConfig.houseType = self.baseViewModel.houseType;
    contactConfig.houseId = self.baseViewModel.houseId;
    contactConfig.phone = contact.phone;
    contactConfig.realtorId = contact.realtorId;
    contactConfig.searchId = cellModel.searchId;
    contactConfig.imprId = cellModel.imprId;
    //TODO 修改from
    contactConfig.from = @"app_oldhouse_mulrealtor";
    [FHHousePhoneCallUtils callWithConfigModel:contactConfig completion:^(BOOL success, NSError *_Nonnull error) {
        if (success && [cellModel.belongsVC isKindOfClass:[FHHouseDetailViewController class]]) {
            FHHouseDetailViewController *vc = (FHHouseDetailViewController *) cellModel.belongsVC;
            vc.isPhoneCallShow = YES;
            vc.phoneCallRealtorId = contactConfig.realtorId;
        }
    }];

    FHHouseFollowUpConfigModel *configModel = [[FHHouseFollowUpConfigModel alloc] initWithDictionary:extraDict error:nil];
    configModel.houseType = self.baseViewModel.houseType;
    configModel.followId = self.baseViewModel.houseId;
    configModel.actionType = self.baseViewModel.houseType;

    // 静默关注功能
    [FHHouseFollowUpHelper silentFollowHouseWithConfigModel:configModel];
}

- (void)onImClick:(FHDetailHouseReviewCommentItemView *)item {
    NSInteger index = item.tag;
    FHDetailHouseReviewCommentCellModel *cellModel = (FHDetailHouseReviewCommentCellModel *) self.currentData;
    FHDetailContactModel *contact = item.curData.realtorInfo;

    NSMutableDictionary *imExtra = @{}.mutableCopy;
    imExtra[@"realtor_position"] = @"detail_related";
    //TODO 修改from
    imExtra[@"from"] = @"app_oldhouse_mulrealtor";
    [cellModel.phoneCallViewModel imchatActionWithPhone:contact realtorRank:[NSString stringWithFormat:@"%d", index] extraDic:imExtra];
}

- (void)onLicenseClick:(FHDetailHouseReviewCommentItemView *)item {
    FHDetailHouseReviewCommentCellModel *cellModel = (FHDetailHouseReviewCommentCellModel *) self.currentData;
    FHDetailContactModel *contact = item.curData.realtorInfo;
    [cellModel.phoneCallViewModel licenseActionWithPhone:contact];
}

- (void)onRealtorInfoClick:(FHDetailHouseReviewCommentItemView *)item {
    FHDetailHouseReviewCommentCellModel *cellModel = (FHDetailHouseReviewCommentCellModel *) self.currentData;
    FHDetailContactModel *contact = item.curData.realtorInfo;
    cellModel.phoneCallViewModel.belongsVC = cellModel.belongsVC;
    [cellModel.phoneCallViewModel jump2RealtorDetailWithPhone:contact isPreLoad:NO];
}

@end
