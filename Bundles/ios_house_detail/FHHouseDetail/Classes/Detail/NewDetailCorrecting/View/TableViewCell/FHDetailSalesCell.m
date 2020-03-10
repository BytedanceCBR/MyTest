//
//  FHDetailSalesCell.m
//  FHHouseDetail
//
//  Created by 张静 on 2020/3/9.
//

#import "FHDetailSalesCell.h"
#import "FHDetailHeaderView.h"
#import <ByteDanceKit/UIImage+BTDAdditions.h>

@interface FHDetailSalesItemView: UIView

@property (nonatomic, strong) UIControl *tagView;
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
        make.height.mas_equalTo(20);
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

- (UIControl *)tagView
{
    if (!_tagView) {
        _tagView = [[UIControl alloc]init];
        _tagView.backgroundColor = [UIColor redColor];
    }
    return _tagView;
}

- (UILabel *)titleLabel
{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontMedium:16];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#4a4a4a"];
        _titleLabel.numberOfLines = 1;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return _titleLabel;
}

- (UILabel *)subtitleLabel
{
    if (!_subtitleLabel) {
        _subtitleLabel = [[UILabel alloc]init];
        _subtitleLabel.font = [UIFont themeFontRegular:14];
        _subtitleLabel.textColor = [UIColor colorWithHexString:@"#aeadad"]; // todo zjing test
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
        _submitBtn.titleLabel.font = [UIFont themeFontMedium:16];
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

    
    // todo zjing test
    NSArray *arr = @[@1,@2];
    if (arr.count > 0) {
        NSInteger itemsCount = arr.count;
        CGFloat vHeight = 71;
        for (NSInteger idx = 0; idx < arr.count; idx++) {
            NSObject *item = [[NSObject alloc]init];
            FHDetailSalesItemView *itemView = [[FHDetailSalesItemView alloc]initWithFrame:CGRectZero];
            // 添加事件
            itemView.tag = idx;
            itemView.submitBtn.tag = 100 + idx;
            itemView.titleLabel.text = @"成功成交可返现5000元";
            itemView.subtitleLabel.text = @"仅限本楼盘使用";
            [itemView.submitBtn setBackgroundImage:[UIImage btd_imageWithColor:[UIColor colorWithHexString:@"#ffefec"]] forState:UIControlStateNormal];
            [itemView.submitBtn setBackgroundImage:[UIImage btd_imageWithColor:[UIColor colorWithHexString:@"#ffefec"]] forState:UIControlStateHighlighted];
            [itemView.submitBtn setTitle:@"开启" forState:UIControlStateNormal];
            [itemView.submitBtn setTitle:@"开启" forState:UIControlStateHighlighted];
            [itemView.submitBtn addTarget:self action:@selector(submitBtnDidClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.containerView addSubview:itemView];
            [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(idx * vHeight);
                make.left.mas_equalTo(15);
                make.right.mas_equalTo(-15);
                make.height.mas_equalTo(vHeight);
            }];
        }
        [self.containerView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo(vHeight * itemsCount);
        }];
    }
}

- (void)submitBtnDidClick:(UIButton *)btn
{
    NSInteger index = btn.tag - 100;
    
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
    _containerView.clipsToBounds = YES;
    [self.contentView addSubview:_containerView];
    [_containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.headerView.mas_bottom).offset(15);
        make.left.mas_equalTo(self.shadowImage).mas_offset(15);
        make.right.mas_equalTo(self.shadowImage).mas_offset(-15);
        make.height.mas_equalTo(0);
        make.bottom.equalTo(self.contentView).offset(-12);
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
