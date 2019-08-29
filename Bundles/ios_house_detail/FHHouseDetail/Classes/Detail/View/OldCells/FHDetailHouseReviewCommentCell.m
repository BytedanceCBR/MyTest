//
// Created by zhulijun on 2019-08-27.
//

#import "FHDetailHouseReviewCommentCell.h"
#import "FHDetailOldModel.h"
#import "FHDetailHouseReviewCommentItemView.h"
#import "TTBaseMacro.h"
#import "TTUGCAttributedLabel.h"
#import "FHDetailFoldViewButton.h"
#import "FHDetailHeaderView.h"

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
//        // 添加事件
//        itemView.tag = idx;
//        itemView.licenceIcon.tag = idx;
//        itemView.callBtn.tag = idx;
//        itemView.imBtn.tag = idx;
//        [itemView addTarget:self action:@selector(cellClick:) forControlEvents:UIControlEventTouchUpInside];
//        [itemView.licenceIcon addTarget:self action:@selector(licenseClick:) forControlEvents:UIControlEventTouchUpInside];
//        [itemView.callBtn addTarget:self action:@selector(phoneClick:) forControlEvents:UIControlEventTouchUpInside];
//        [itemView.imBtn addTarget:self action:@selector(imclick:) forControlEvents:UIControlEventTouchUpInside];
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
//        itemView.name.text = obj.realtorInfo.realtorName ?: @"";
//        itemView.agency.text = obj.agencyName;
//        if (obj.avatarUrl.length > 0) {
//            [itemView.avator bd_setImageWithURL:[NSURL URLWithString:obj.avatarUrl] placeholder:[UIImage imageNamed:@"detail_default_avatar"]];
//        }
//        FHDetailContactImageTagModel *tag = obj.imageTag;
//        [self refreshIdentifyView:itemView.identifyView withUrl:tag.imageUrl];
//        if (tag.imageUrl.length > 0) {
//            [itemView.identifyView bd_setImageWithURL:[NSURL URLWithString:tag.imageUrl]];
//            itemView.identifyView.hidden = NO;
//        } else {
//            itemView.identifyView.hidden = YES;
//        }
//        itemView.licenceIcon.hidden = ![self shouldShowContact:obj];
//        itemsCount += 1;
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
    NSInteger showCount = model.isExpand ? model.houseReviewComment.count: MIN(model.houseReviewComment.count, 2);
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
    NSInteger showCount = modelData.isExpand ? modelData.houseReviewComment.count: MIN(modelData.houseReviewComment.count, 2);
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

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath; {
//    return self.curData.houseReviewComment.count * 42;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section; {
//    return self.curData.houseReviewComment.count;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath; {
//    if (indexPath.row >= self.curData.houseReviewComment.count) return [UITableViewCell new];
//    FHDetailHouseReviewCommentItemView *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([FHDetailHouseReviewCommentItemView class]) forIndexPath:indexPath];
//    if (!cell) {
//        cell = [[FHDetailHouseReviewCommentItemView alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:NSStringFromClass([FHDetailHouseReviewCommentItemView class])];
//    }
//    FHDetailHouseReviewCommentModel *commentItemModel = self.curData.houseReviewComment[indexPath.row];
//    [cell refreshWithData:commentItemModel];
//    return cell;
//}
@end
