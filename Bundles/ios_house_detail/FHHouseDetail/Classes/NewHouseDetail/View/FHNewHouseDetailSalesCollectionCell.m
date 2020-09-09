//
//  FHNewHouseDetailSalesCollectionCell.m
//  FHHouseDetail
//
//  Created by xubinbin on 2020/9/9.
//

#import "FHNewHouseDetailSalesCollectionCell.h"
#import <ByteDanceKit/UIImage+BTDAdditions.h>
#import "FHUIAdaptation.h"
#import <TTBaseLib/UIViewAdditions.h>

@interface FHNewHouseDetailSalesItemView: UIView

@property (nonatomic, strong) UIButton *tagView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *submitBtn;

@end

@implementation FHNewHouseDetailSalesItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    [self addSubview:self.tagView];
    [self addSubview:self.titleLabel];
    [self addSubview:self.subtitleLabel];
    [self addSubview:self.submitBtn];
    
    [self.tagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.mas_equalTo(3);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(18);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(19);
        make.left.mas_equalTo(self.tagView.mas_right).mas_offset(12);
        make.right.mas_equalTo(self.submitBtn.mas_left).mas_offset(-12);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(8);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.submitBtn.mas_left).mas_offset(-12);
    }];
    [self.submitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(0);
        make.height.mas_equalTo(28);
        make.width.mas_equalTo(66);
    }];
}

- (UIButton *)tagView
{
    if (!_tagView) {
        _tagView = [[UIButton alloc]init];
        [_tagView setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
        _tagView.layer.cornerRadius = 2;
        _tagView.layer.borderColor = [UIColor colorWithHexString:@"#ff6a6a" alpha:0.3].CGColor;
        _tagView.layer.borderWidth = 0.5;
        _tagView.layer.masksToBounds = YES;
        [_tagView setBackgroundImage:[UIImage btd_imageWithColor:[UIColor colorWithHexString:@"#ffefec"]] forState:UIControlStateNormal];
        _tagView.titleLabel.font = [UIFont themeFontMedium:AdaptFont(10)];
    }
    return _tagView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontMedium:16];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#4a4a4a"];
        _titleLabel.numberOfLines = 2;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel
{
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.font = [UIFont themeFontRegular:14];
        _subtitleLabel.textColor = [UIColor colorWithHexString:@"#aeadad"];
        _subtitleLabel.numberOfLines = 1;
        _subtitleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _subtitleLabel;
}

- (UIButton *)submitBtn
{
    if (!_submitBtn) {
        _submitBtn = [[UIButton alloc]init];
        [_submitBtn setTitleColor:[UIColor themeOrange1] forState:UIControlStateNormal];
        [_submitBtn setTitleColor:[UIColor themeOrange1] forState:UIControlStateHighlighted];
        _submitBtn.layer.cornerRadius = 15;
        _submitBtn.layer.masksToBounds = YES;
        _submitBtn.titleLabel.font = [UIFont themeFontMedium:AdaptFont(16)];
    }
    return _submitBtn;
}

@end

@interface FHNewHouseDetailSalesCollectionCell()

@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, strong) NSMutableDictionary *tracerDicCache;
@property (nonatomic, strong) NSMutableArray *itemTypeArr;

@end

@implementation FHNewHouseDetailSalesCollectionCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNewHouseDetailSalesCellModel class]]) {
        FHNewHouseDetailSalesCellModel *model = (FHNewHouseDetailSalesCellModel *)data;
        if (model.discountInfo.count > 0) {
            CGFloat height = 66 * model.discountInfo.count;
            return CGSizeMake(width, 16 + height);
        } else {
            return CGSizeMake(width, 64);
        }
    }
    return CGSizeZero;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _itemTypeArr = [NSMutableArray array];
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    _tracerDicCache = [NSMutableDictionary new];
    _containerView = [[UIView alloc] init];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.top.mas_equalTo(16);
        make.bottom.mas_equalTo(-20);
        make.height.mas_equalTo(0);
    }];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNewHouseDetailSalesCellModel class]]) {
        return;
    }
    self.currentData = data;
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    FHNewHouseDetailSalesCellModel *model = (FHNewHouseDetailSalesCellModel *)data;

    if (model.discountInfo.count > 0) {
        NSInteger itemsCount = model.discountInfo.count;
        CGFloat vHeight = 66;
        CGFloat totalHeight = 0;
        UIView *lastView = nil;
        for (NSInteger idx = 0; idx < itemsCount; idx++) {
            FHDetailNewDiscountInfoItemModel *item = model.discountInfo[idx];
            [_itemTypeArr addObject:[NSString stringWithFormat:@"%ld",item.itemType]];
            FHNewHouseDetailSalesItemView *itemView = [[FHNewHouseDetailSalesItemView alloc]initWithFrame:CGRectZero];
            // 添加事件
            itemView.tag = idx;
            itemView.submitBtn.tag = 100 + idx;
            [itemView.tagView setTitle:item.itemDesc forState:UIControlStateNormal];
            [itemView.tagView setTitle:item.itemDesc forState:UIControlStateHighlighted];
            itemView.titleLabel.text = item.discountContent;
            itemView.subtitleLabel.text = item.discountSubContent;
            [itemView.submitBtn setBackgroundImage:[UIImage btd_imageWithColor:[UIColor colorWithHexString:@"#ffefec"]] forState:UIControlStateNormal];
            [itemView.submitBtn setBackgroundImage:[UIImage btd_imageWithColor:[UIColor colorWithHexString:@"#ffefec"]] forState:UIControlStateHighlighted];
            [itemView.submitBtn setTitle:item.actionDesc forState:UIControlStateNormal];
            [itemView.submitBtn setTitle:item.actionDesc forState:UIControlStateHighlighted];
            [itemView.submitBtn addTarget:self action:@selector(submitBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.containerView addSubview:itemView];
            [itemView.tagView sizeToFit];
            [itemView.submitBtn sizeToFit];

            CGFloat btnWidth = itemView.submitBtn.width + 34;
            CGFloat iconWidth = itemView.tagView.width + 10;
            [itemView.tagView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(iconWidth);
            }];

            [itemView.submitBtn mas_updateConstraints:^(MASConstraintMaker *make) {
                make.width.mas_equalTo(btnWidth);
            }];
            itemView.titleLabel.width = [UIScreen mainScreen].bounds.size.width - btnWidth - iconWidth - 42 * 2;
            [itemView.titleLabel sizeToFit];
            CGFloat titleHeight  = floor(itemView.titleLabel.height);
            CGFloat topOffset = 0;
    //            if (titleHeight >= 44) {
    //                vHeight = 66 + titleHeight ;
    //                topOffset = -2;
    //            }
            vHeight = 44 + titleHeight ;
            totalHeight += vHeight;
            [itemView.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(topOffset);
                make.height.mas_equalTo(titleHeight);
            }];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                if (lastView) {
                    make.top.mas_equalTo(lastView.mas_bottom);
                }else {
                    make.top.mas_equalTo(-1);
                }
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(-15);
                make.height.mas_equalTo(vHeight);
            }];
            lastView = itemView;
        }
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(totalHeight);
        }];
    }
}

- (void)submitBtnDidClick:(UIButton *)btn
{
    NSInteger index = btn.tag - 100;

    FHNewHouseDetailSalesCellModel *model = (FHNewHouseDetailSalesCellModel *)self.currentData;
    if (index <0 || index >= model.discountInfo.count) {
        return;
    }
    FHDetailNewDiscountInfoItemModel *itemInfo = model.discountInfo[index];

//    [self addClickOptionLog:@(itemInfo.actionType)];
//
//    //099 优惠跳转类型
//    if (itemInfo.actionType == 3 && itemInfo.activityURLString.length) {
//        NSString *urlString = itemInfo.activityURLString.copy;
//        //@"https://m.xflapp.com/magic/page/ejs/5ecb69c9d7ff73025f6ea4e0?appType=manyhouse";
//        if([urlString hasPrefix:@"http://"] ||
//           [urlString hasPrefix:@"https://"]) {
//            UIViewController *topController = [TTUIResponderHelper topViewControllerFor:self];
//            ssOpenWebView([NSURL URLWithString:urlString], @"", topController.navigationController, NO, nil);
//            return;
//        }
//        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:urlString]];
//        return;
//    }

//    NSString *title = itemInfo.discountReportTitle;
//    NSString *subtitle = itemInfo.discountReportSubTitle;
//    NSString *toast = [NSString stringWithFormat:@"%@，%@",itemInfo.discountReportDoneTitle,itemInfo.discountReportDoneSubTitle];
//    NSString *btnTitle = itemInfo.discountButtonText;
//    NSMutableDictionary *extraDic = @{@"position":@"coupon"
//                                      }.mutableCopy;
//    extraDic[kFHCluePage] = itemInfo.page;
//    extraDic[@"title"] = title;
//    extraDic[@"subtitle"] = subtitle;
//    extraDic[@"btn_title"] = btnTitle;
//    extraDic[@"toast"] = toast;
//
//    NSMutableDictionary *associateParamDict = @{}.mutableCopy;
//    associateParamDict[kFHAssociateInfo] = itemInfo.associateInfo.reportFormInfo;
//    NSMutableDictionary *reportParamsDict = [model.contactViewModel baseParams].mutableCopy;
//    reportParamsDict[@"position"] = @"coupon";
//    if (extraDic.count > 0) {
//        [associateParamDict addEntriesFromDictionary:extraDic];
//        reportParamsDict[kFHAssociateInfo] = itemInfo.associateInfo.reportFormInfo;
//    }
//    associateParamDict[kFHReportParams] = reportParamsDict;
//
//    [model.contactViewModel fillFormActionWithParams:associateParamDict];
//    [model.contactViewModel fillFormActionWithExtraDict:extraDic];
}


#pragma mark - FHDetailScrollViewDidScrollProtocol

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    
    return @"coupon";
}

-(void)addClickOptionLog:(NSNumber *)actionType
{
//    click_position: recieve（领取），subscribe（预约）
//    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
//    tracerDic[@"element_type"] = @"coupon";
//    tracerDic[@"action_type"] = actionType;
//    TRACK_EVENT(@"click_options", tracerDic);
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

@end

@implementation FHNewHouseDetailSalesCellModel

@end
