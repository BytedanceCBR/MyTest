//
//  FHDetailSalesCell.m
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/9.
//

#import "FHDetailSalesCell.h"
#import "FHDetailHeaderView.h"
#import <ByteDanceKit/UIImage+BTDAdditions.h>
#import "FHDetailNewModel.h"
#import <TTBaseLib/UIViewAdditions.h>
#import "FHHouseFillFormHelper.h"
#import "FHUIAdaptation.h"

@interface FHDetailSalesItemView: UIView

@property (nonatomic, strong) UIButton *tagView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UIButton *submitBtn;

@end

@implementation FHDetailSalesItemView

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
        make.left.top.mas_equalTo(0);
        make.width.mas_equalTo(30);
        make.height.mas_equalTo(18);
    }];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(19);
        make.left.mas_equalTo(self.tagView.mas_right).mas_offset(12);
        make.right.mas_equalTo(self.submitBtn.mas_left).mas_offset(-5);
    }];
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).mas_offset(8);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.submitBtn.mas_left).mas_offset(-5);
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
        _tagView.layer.borderColor = [UIColor colorWithHexString:@"#ff6a6a"].CGColor;
        _tagView.backgroundColor = [UIColor colorWithHexString:@"#ffefec"];
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

@interface FHDetailSalesCell ()

@property (nonatomic, strong) FHDetailHeaderView *headerView;
@property (nonatomic, strong) UIView *containerView;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong)   NSMutableDictionary       *tracerDicCache;

@end

@implementation FHDetailSalesCell

- (void)refreshWithData:(id)data
{
    if (self.currentData == data || ![data isKindOfClass:[FHDetailSalesCellModel class]]) {
        return;
    }
    self.currentData = data;
    //
    for (UIView *v in self.containerView.subviews) {
        [v removeFromSuperview];
    }
    FHDetailSalesCellModel *model = (FHDetailSalesCellModel *)data;
    
    adjustImageScopeType(model)
 
    if (model.discountInfo.count > 0) {
        NSInteger itemsCount = model.discountInfo.count;
        CGFloat vHeight = 71;
        CGFloat totalHeight = 0;
        UIView *lastView = nil;
        for (NSInteger idx = 0; idx < itemsCount; idx++) {
            FHDetailNewDiscountInfoItemModel *item = model.discountInfo[idx];
            FHDetailSalesItemView *itemView = [[FHDetailSalesItemView alloc]initWithFrame:CGRectZero];
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
            if (titleHeight >= 44) {
                vHeight = 71 + titleHeight - 19;
                topOffset = -2;
            }
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

    FHDetailSalesCellModel *model = (FHDetailSalesCellModel *)self.currentData;
    if (index <0 || index >= model.discountInfo.count) {
        return;
    }
    FHDetailNewDiscountInfoItemModel *itemInfo = model.discountInfo[index];
    NSString *title = itemInfo.discountReportTitle;
    NSString *subtitle = itemInfo.discountReportSubTitle;
    NSString *toast = itemInfo.discountReportDoneTitle;
    NSString *btnTitle = itemInfo.discountButtonText;
    NSMutableDictionary *extraDic = @{@"realtor_position":@"phone_button",
                                      @"position":@"report_button",
                                      @"element_from":@"be_null"
                                      }.mutableCopy;
    extraDic[kFHCluePage] = itemInfo.page;
    extraDic[@"title"] = title;
    extraDic[@"subtitle"] = subtitle;
    extraDic[@"btn_title"] = btnTitle;
    extraDic[@"toast"] = toast;

    [model.contactViewModel fillFormActionWithExtraDict:extraDic];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI
{
    _tracerDicCache = [NSMutableDictionary new];
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    _headerView = [[FHDetailHeaderView alloc] init];
    _headerView.label.text = @"优惠信息";
    [self.contentView addSubview:_headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.shadowImage).offset(30);
        make.right.mas_equalTo(self.shadowImage).offset(-15);
        make.left.mas_equalTo(self.shadowImage).offset(15);
        make.height.mas_equalTo(46);
    }];
    _containerView = [[UIView alloc] init];
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(30);
        make.left.mas_equalTo(self.shadowImage).mas_offset(15);
        make.right.mas_equalTo(self.shadowImage).mas_offset(-15);
        make.height.mas_equalTo(0);
        make.bottom.equalTo(self.shadowImage).offset(-20);
    }];
}

#pragma mark - FHDetailScrollViewDidScrollProtocol

// 滑动house_show埋点
- (void)fhDetail_scrollViewDidScroll:(UIView *)vcParentView {
//    CGPoint point = [self convertPoint:CGPointZero toView:vcParentView];
//    FHDetailAgentListModel *model = (FHDetailAgentListModel *) self.currentData;
//    __block CGFloat showHeight = 0;
//    for (int m = 0; m <model.recommendedRealtors.count; m++) {
//        FHDetailContactModel *showModel = model.recommendedRealtors[m];
//        if (showModel.realtorScoreDisplay.length>0 && showModel.realtorScoreDescription.length>0&&showModel.realtorTags.count >0) {
//            showHeight = showHeight +100;
//        }else {
//            showHeight = showHeight + 76;
//        };
//        if (UIScreen.mainScreen.bounds.size.height - point.y>showHeight) {
//            NSInteger showCount = model.isFold ? MIN(m, 3):MIN(model.recommendedRealtors.count, m);
//            [self tracerRealtorShowToIndex:showCount];
//        };
//    }
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"be_null";
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

@implementation FHDetailSalesCellModel


@end
