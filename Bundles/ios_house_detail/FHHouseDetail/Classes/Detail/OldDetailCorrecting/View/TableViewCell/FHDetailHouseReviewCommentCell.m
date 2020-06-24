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
#import "UITextView+TTAdditions.h"
#import "UIViewAdditions.h"

@implementation FHDetailHouseReviewCommentCellModel : FHDetailBaseModel
@end

@interface FHDetailHouseReviewCommentCell () <FHDetailHouseReviewCommentItemViewDelegate>
@property(nonatomic, strong) FHDetailHeaderView *headerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property(nonatomic, strong) UIView *containerView;
@property(nonatomic, strong) FHDetailFoldViewButton *foldButton;
@property(nonatomic, strong) NSMutableDictionary *tracerDicCache;
@end

@implementation FHDetailHouseReviewCommentCell

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"realtor_evaluation"; // 带看房评
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _tracerDicCache = [NSMutableDictionary new];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"经纪人带看房评";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(42);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.left.mas_equalTo(self.contentView).offset(15);
        make.height.mas_equalTo(46);
    }];
    _containerView = [[UIView alloc] init];
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(2);
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
        make.height.mas_equalTo(0);
        make.bottom.mas_equalTo(self.shadowImage).offset(-35);
    }];
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailHouseReviewCommentCellModel class]]) {
        return;
    }
    FHDetailHouseReviewCommentCellModel *modelData = (FHDetailHouseReviewCommentCellModel *) data;
    self.shadowImage.image = modelData.shadowImage;
    if(modelData.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(modelData.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(modelData.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
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
            make.top.mas_equalTo(beforeView != nil ? beforeView.mas_bottom : self.containerView.mas_top).offset(20);
            make.left.right.mas_equalTo(self.containerView);
            make.height.mas_equalTo(itemHeight);
        }];
        [itemView refreshWithData:obj];
        height += (itemHeight + 20);
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
//        _foldButton = [[FHDetailFoldViewButton alloc] initWithDownText:@"查看全部" upText:@"收起" isFold:YES];
        _foldButton = [[FHDetailFoldViewButton alloc] initWithDownText:@"查看更多房评" upText:@"收起" isFold:YES];
        _foldButton.openImage = [UIImage imageNamed:@"message_more_arrow"];
        _foldButton.foldImage = [UIImage imageNamed:@"message_flod_arrow"];
        _foldButton.keyLabel.textColor = [UIColor colorWithHexStr:@"#4a4a4a"];
         _foldButton.keyLabel.font = [UIFont themeFontRegular:14];
        [self.contentView addSubview:_foldButton];
        [_foldButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.containerView.mas_bottom).offset(15);
            make.height.mas_equalTo(58);
            make.left.right.mas_equalTo(self.contentView);
        }];
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            if(modelData.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
            make.bottom.mas_equalTo(self.shadowImage).offset(-70);
            }else {
               make.bottom.mas_equalTo(self.shadowImage).offset(-93);
            }
        }];
        [self.foldButton addTarget:self action:@selector(foldButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    } else {
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            if(modelData.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
                make.bottom.mas_equalTo(self.shadowImage).offset(-12);
            }else {
                make.bottom.mas_equalTo(self.shadowImage).offset(-35);
            }
        }];
    }
    [self updateItems:NO];
}

- (void)updateItems:(BOOL)animated {
    FHDetailHouseReviewCommentCellModel *model = (FHDetailHouseReviewCommentCellModel *) self.currentData;
    NSInteger showCount = model.isExpand ? model.houseReviewComment.count : MIN(model.houseReviewComment.count, 2);
    __block CGFloat height = 0.0f;
    [model.houseReviewComment enumerateObjectsUsingBlock:^(FHDetailHouseReviewCommentModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        height += [FHDetailHouseReviewCommentItemView heightForData:obj] + 20;
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

- (void)fh_willDisplayCell;{
    [self addRealtorShowLog];
}

- (void)foldButtonClick:(UIButton *)button {
    FHDetailHouseReviewCommentCellModel *modelData = (FHDetailHouseReviewCommentCellModel *) self.currentData;
    modelData.isExpand = !modelData.isExpand;
    self.foldButton.isFold = !modelData.isExpand;
    if(modelData.isExpand){
        [self addClickLoadMoreLog];
    }
    [self addClickLoadMoreLog];
    [self updateItems:YES];
    [self addRealtorShowLog];
}

- (void)onReadMoreClick:(FHDetailHouseReviewCommentItemView *)item {
    FHDetailHouseReviewCommentCellModel *modelData = (FHDetailHouseReviewCommentCellModel *) self.currentData;
    NSInteger showCount = modelData.isExpand ? modelData.houseReviewComment.count : MIN(modelData.houseReviewComment.count, 2);
    __block CGFloat height = 0.0f;
    [modelData.houseReviewComment enumerateObjectsUsingBlock:^(FHDetailHouseReviewCommentModel *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        height += [FHDetailHouseReviewCommentItemView heightForData:obj] + 20;
        if (idx == showCount - 1) {
            *stop = YES;
        }
    }];
    [modelData.tableView beginUpdates];

    [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(height);
    }];
    
    if(item.curData.isExpended){
        [item setComment:item.curData];
    }

    if(item.curData.isExpended){
        item.commentView.height = [item.curData commentHeight];
    }

    [item mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([FHDetailHouseReviewCommentItemView heightForData:item.curData]);
    }];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self layoutIfNeeded];
    }completion:^(BOOL finished) {
        if(!item.curData.isExpended){
            item.commentView.height = [item.curData commentHeight];
            [item setComment:item.curData];
        }
    }];
    
    [modelData.tableView endUpdates];
    if(item.curData.isExpended){
        [self addClickReadMoreLog:item.curData];
    }
}

- (void)onCallClick:(FHDetailHouseReviewCommentItemView *)item {
    NSInteger index = item.tag;
    FHDetailHouseReviewCommentCellModel *cellModel = (FHDetailHouseReviewCommentCellModel *) self.currentData;

    FHDetailContactModel *contact = item.curData.realtorInfo;
    NSMutableDictionary *extraDict = @{}.mutableCopy;
    extraDict[@"realtor_id"] = contact.realtorId;
    extraDict[@"realtor_rank"] = @(index);
    extraDict[@"realtor_position"] = @"realtor_evaluation";
    extraDict[@"realtor_logpb"] = contact.realtorLogpb;
    if (self.baseViewModel.detailTracerDic) {
        [extraDict addEntriesFromDictionary:self.baseViewModel.detailTracerDic];
    }
    NSDictionary *associateInfoDict = cellModel.associateInfo.phoneInfo;
    extraDict[kFHAssociateInfo] = associateInfoDict;
    FHAssociatePhoneModel *associatePhone = [[FHAssociatePhoneModel alloc]init];
    associatePhone.reportParams = extraDict;
    associatePhone.associateInfo = associateInfoDict;
    associatePhone.realtorId = contact.realtorId;
    associatePhone.searchId = cellModel.searchId;
    associatePhone.imprId = cellModel.imprId;
    if (cellModel.bizTrace) {
        associatePhone.extraDict = @{@"biz_trace":cellModel.bizTrace};
    }
    associatePhone.houseType = self.baseViewModel.houseType;
    associatePhone.houseId = self.baseViewModel.houseId;
    associatePhone.showLoading = NO;

    
//    FHHouseContactConfigModel *contactConfig = [[FHHouseContactConfigModel alloc] initWithDictionary:extraDict error:nil];
//    contactConfig.houseType = self.baseViewModel.houseType;
//    contactConfig.houseId = self.baseViewModel.houseId;
//    contactConfig.phone = contact.phone;
//    contactConfig.realtorId = contact.realtorId;
//    contactConfig.searchId = cellModel.searchId;
//    contactConfig.imprId = cellModel.imprId;
//    contactConfig.from = @"app_oldhouse_evaluate";
    
    [FHHousePhoneCallUtils callWithAssociatePhoneModel:associatePhone completion:^(BOOL success, NSError * _Nonnull error, FHDetailVirtualNumModel * _Nonnull virtualPhoneNumberModel) {

        if (success && [cellModel.belongsVC isKindOfClass:[FHHouseDetailViewController class]]) {
            FHHouseDetailViewController *vc = (FHHouseDetailViewController *) cellModel.belongsVC;
            vc.isPhoneCallShow = YES;
            vc.phoneCallRealtorId = contact.realtorId;
            vc.phoneCallRequestId = virtualPhoneNumberModel.requestId;
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
    imExtra[@"realtor_position"] = @"realtor_evaluation";
    
    if([self.baseViewModel.detailData isKindOfClass:FHDetailOldModel.class]) {
        FHDetailOldModel *detailOldModel = (FHDetailOldModel *)self.baseViewModel.detailData;
        if(detailOldModel.data.houseReviewCommentAssociateInfo) {
            imExtra[kFHAssociateInfo] = detailOldModel.data.houseReviewCommentAssociateInfo;
        }
    }
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
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[@"element_from"] = @"realtor_evaluation";
    [cellModel.phoneCallViewModel jump2RealtorDetailWithPhone:contact isPreLoad:NO extra:dict];
}

-(void)addRealtorShowLog{
    FHDetailHouseReviewCommentCellModel *model = (FHDetailHouseReviewCommentCellModel *) self.currentData;
    NSInteger showCount = model.isExpand ? model.houseReviewComment.count : MIN(model.houseReviewComment.count, 2);
    [self tracerRealtorEvaluationShowToIndex:showCount];
}

-(void)addClickLoadMoreLog{
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"]= tracerDic[@"page_type"];
    params[@"element_from"]= @"realtor_evaluation";
    [FHUserTracker writeEvent:@"click_loadmore" params:params];
}

-(void)addClickReadMoreLog:(FHDetailHouseReviewCommentModel *)data{
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"page_type"]= tracerDic[@"page_type"];
    params[@"element_from"]= @"realtor_evaluation_fulltext";
    params[@"item_id"]= data.commentId;
    tracerDic[@"realtor_logpb"] = data.realtorInfo.realtorLogpb;
    [FHUserTracker writeEvent:@"click_loadmore" params:params];
}

- (void)tracerRealtorEvaluationShowToIndex:(NSInteger)index {
    for (int i = 0; i< index; i++) {
        NSString *cacheKey = [NSString stringWithFormat:@"%d",i];
        if (self.tracerDicCache[cacheKey]) {
            continue;
        }
        self.tracerDicCache[cacheKey] = @(YES);
        FHDetailHouseReviewCommentCellModel *model = (FHDetailHouseReviewCommentCellModel *)self.currentData;
        if (i < model.houseReviewComment.count) {
            FHDetailHouseReviewCommentModel *reviewCommentModel = model.houseReviewComment[i];
            NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
            tracerDic[@"element_type"] = @"realtor_evaluation";
            tracerDic[@"realtor_id"] = reviewCommentModel.realtorInfo.realtorId ?: @"be_null";
            tracerDic[@"realtor_rank"] = @(i);
            tracerDic[@"realtor_position"] = @"realtor_evaluation";
            tracerDic[@"item_id"] = reviewCommentModel.commentId;
            tracerDic[@"realtor_logpb"] = reviewCommentModel.realtorInfo.realtorLogpb;
            [tracerDic removeObjectsForKeys:@[@"card_type",@"element_from",@"search_id"]];
            [FHUserTracker writeEvent:@"realtor_evaluation_show" params:tracerDic];
        }
    }
}
@end
