//
//  FHHomeRentCell.m
//  FHHouseHome
//
//  Created by xubinbin on 2020/11/2.
//

#import "FHHomeRentCell.h"
#import "UIImage+FIconFont.h"
#import "FHHouseDislikeView.h"
#import "FHSingleImageInfoCellModel.h"
#import "TTReachability.h"
#import "ToastManager.h"
#import "FHHomeRequestAPI.h"
#import "FHUserTracker.h"
#import "FHCommonDefines.h"

@interface FHHomeRentCell()

@property (nonatomic, strong) FHSingleImageInfoCellModel *cellModel;
@property (nonatomic, strong) UIButton *closeBtn;
@property (nonatomic, strong) FHHomeHouseDataItemsModel *homeItemModel;

@end

@implementation FHHomeRentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [super initUI];
    self.contentView.backgroundColor = [UIColor themeGray7];
    self.houseCellBackView.hidden = NO;
    [self.houseCellBackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.top.bottom.mas_equalTo(0);
    }];
    [self.mainImageView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(12);
        make.left.mas_equalTo(26);
    }];
    [self.houseMainImageBackView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.mainImageView).offset(3);
        make.left.mas_equalTo(self.mainImageView).offset(3);
        make.right.mas_equalTo(self.mainImageView).offset(-3);
        make.bottom.mas_equalTo(self.mainImageView).offset(-3);
    }];
    [self.mainTitleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-40);
    }];
    [self.pricePerSqmLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-23);
    }];
    [self.contentView addSubview:self.closeBtn];
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-23);
        make.top.mas_equalTo(14);
        make.width.height.mas_equalTo(16);
    }];
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHHomeHouseDataItemsModel class]]) {
        return;
    }
    FHHomeHouseDataItemsModel *model = (FHHomeHouseDataItemsModel *)data;
    self.homeItemModel = model;
    if (model.dislikeInfo) {
        self.closeBtn.hidden = NO;
    } else {
        self.closeBtn.hidden = YES;
    }
    self.mainTitleLabel.text = model.title;
    self.subTitleLabel.text = model.subtitle;
    self.priceLabel.text = model.pricing;
    if (model.addrData.length > 0) {
        self.tagLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        NSAttributedString *attributeString = [FHSingleImageInfoCellModel createTagAttrString:model.addrData textColor:[UIColor themeGray2] backgroundColor:[UIColor whiteColor]];
        self.tagLabel.attributedText = attributeString;
    }
    self.pricePerSqmLabel.attributedText = [[NSMutableAttributedString alloc] initWithString:@" " attributes:@{}];
    self.priceLabel.font = [UIFont themeFontSemibold:[UIDevice btd_isScreenWidthLarge320] ? 16 : 15];
    FHImageModel *imageModel = [model.houseImage firstObject];
    [self updateMainImageWithUrl:imageModel.url];
}

- (void)refreshIndexCorner:(BOOL)isFirst andLast:(BOOL)isLast {
    if (isFirst) {
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH - 30, 88);
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(15, 15)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = frame;
        maskLayer.path = maskPath.CGPath;
        self.houseCellBackView.layer.mask = maskLayer;
    } else {
        self.houseCellBackView.layer.mask = nil;
    }
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        _closeBtn.hidden = YES;
        UIImage *img = ICON_FONT_IMG(16, @"\U0000e673", [UIColor themeGray5]);
        [_closeBtn setImage:img forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(dislike) forControlEvents:UIControlEventTouchUpInside];
        _closeBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -20, -10, -20);
    }
    return _closeBtn;
}

- (void)dislike {
    if(self.delegate && [self.delegate respondsToSelector:@selector(canDislikeClick)]){
        BOOL canDislike = [self.delegate canDislikeClick];
        if(!canDislike){
            return;
        }
    }
    [self trackClickHouseDislke];
    NSArray *dislikeInfo = self.homeItemModel.dislikeInfo;
    if(dislikeInfo && [dislikeInfo isKindOfClass:[NSArray class]]){
        __weak typeof(self) wself = self;
        FHHouseDislikeView *dislikeView = [[FHHouseDislikeView alloc] init];
        FHHouseDislikeViewModel *viewModel = [[FHHouseDislikeViewModel alloc] init];

        NSMutableArray *keywords = [NSMutableArray array];
        for (FHHomeHouseDataItemsDislikeInfoModel *infoModel in dislikeInfo) {
            NSMutableDictionary *dic = [NSMutableDictionary dictionary];
            if(infoModel.id){
                [dic setObject:infoModel.id forKey:@"id"];
            }
            if(infoModel.text){
                [dic setObject:infoModel.text forKey:@"name"];
            }
            if(infoModel.mutualExclusiveIds){
                [dic setObject:infoModel.mutualExclusiveIds forKey:@"mutual_exclusive_ids"];
            }
            [keywords addObject:dic];
        }
        viewModel.keywords = keywords;
        viewModel.groupID = self.cellModel.houseId;
        viewModel.extrasDict = self.homeItemModel.tracerDict;
        [dislikeView refreshWithModel:viewModel];
        CGPoint point = self.closeBtn.center;
        [dislikeView showAtPoint:point
                        fromView:self.closeBtn
                 didDislikeBlock:^(FHHouseDislikeView * _Nonnull view) {
            [wself dislikeConfirm:view];
        }];
    }
}

- (void)dislikeConfirm:(FHHouseDislikeView *)view {
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    
    NSMutableArray *dislikeInfo = [NSMutableArray array];
    for (FHHouseDislikeWord *word in view.dislikeWords) {
        if(word.isSelected){
            [dislikeInfo addObject:@([word.ID integerValue])];
        }
    }
    //发起请求
    [FHHomeRequestAPI requestHomeHouseDislike:self.homeItemModel.idx houseType:[self.homeItemModel.houseType integerValue] dislikeInfo:dislikeInfo completion:^(bool success, NSError * _Nonnull error) {
        if(success){
            [[ToastManager manager] showToast:@"感谢反馈，将减少推荐类似房源"];
            //代理
            if(self.delegate && [self.delegate respondsToSelector:@selector(dislikeConfirm:cell:)] && self.homeItemModel){
                [self.delegate dislikeConfirm:self.homeItemModel cell:self];
            }
        }else{
            [[ToastManager manager] showToast:@"反馈失败"];
        }
    }];
}

#pragma mark - dislike埋点

- (void)trackClickHouseDislke {
    if(self.homeItemModel.tracerDict){
        NSMutableDictionary *tracerDict = [self.homeItemModel.tracerDict mutableCopy];
        tracerDict[@"click_position"] = @"house_dislike";
        [tracerDict removeObjectsForKeys:@[@"enter_from",@"element_from"]];
        TRACK_EVENT(@"click_house_dislike", tracerDict);
    }
}

@end
