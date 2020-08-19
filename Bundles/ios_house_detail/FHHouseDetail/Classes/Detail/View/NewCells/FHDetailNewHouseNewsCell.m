//
//  FHDetailNewHouseNewsCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHDetailNewHouseNewsCell.h"
#import "FHDetailHeaderView.h"
#import "TTRoute.h"
#import "FHUtils.h"
#import "FHEnvContext.h"

@interface FHDetailNewHouseNewsCell ()

@property (nonatomic, strong) UIImageView *shadowImage;
@property (nonatomic, strong) FHDetailHeaderView *headerView;
@property (nonatomic, strong) UIStackView *stackView;
@end

@implementation FHDetailNewHouseNewsCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier :reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (NSString *)elementTypeString:(FHHouseType)houseType
{
    return @"house_history";
}

- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    self.headerView = [[FHDetailHeaderView alloc] init];
    self.headerView.label.text = @"楼盘动态";
    [self.headerView addTarget:self action:@selector(moreButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:self.headerView];
    [self.headerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).mas_offset(15);
        make.right.mas_equalTo(self.contentView).mas_offset(-15);
        make.top.mas_equalTo(self.contentView).offset(20);
        make.height.mas_equalTo(46);
    }];
    self.stackView = [[UIStackView alloc] init];
    self.stackView.axis = UILayoutConstraintAxisVertical;
    [self.contentView addSubview:self.stackView];
    [self.stackView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_offset(30);
        make.right.mas_offset(-30);
        make.top.mas_equalTo(self.headerView.mas_bottom).mas_offset(20);
        make.bottom.mas_equalTo(self.contentView.mas_bottom).mas_equalTo(-20);
        make.height.mas_equalTo(0);
    }];
    
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailNewHouseNewsCellModel class]]) {
        return;
    }
    [self.stackView.arrangedSubviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    FHDetailNewHouseNewsCellModel *model = (FHDetailNewHouseNewsCellModel *)data;
    self.currentData = model;
    adjustImageScopeType(model);
    CGFloat stackViewHeight = 0;
    self.headerView.label.text = model.timeLineModel.totalCount.length ? model.timeLineModel.totalCount : @"楼盘动态";
    self.headerView.isShowLoadMore = model.timeLineModel.hasMore;
    
    for (FHDetailNewDataTimelineListModel *itemModel in model.timeLineModel.list) {
        FHDetailNewHouseNewsCellItemView *itemView = [[FHDetailNewHouseNewsCellItemView alloc] init];
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont themeFontSemibold:16]};
        CGRect rect = [itemModel.desc boundingRectWithSize:CGSizeMake(self.contentView.frame.size.width-60, CGFLOAT_MAX)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];
        CGFloat contentLabelHeight = rect.size.height <= 24 ? 24 : 48;
        [itemView newsViewShowWithData:itemModel];
        [self.stackView addArrangedSubview:itemView];
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(self.stackView);
            make.height.mas_equalTo(17 + 20 + 6 + contentLabelHeight);
        }];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreButtonClick)];
        [itemView addGestureRecognizer:tapGesture];
        stackViewHeight += 17 + 20 + 6 + contentLabelHeight;
    }

    [self.stackView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(stackViewHeight);
    }];
}

// 查看更多
- (void)moreButtonClick {
    FHDetailNewHouseNewsCellModel *model = (FHDetailNewHouseNewsCellModel *)self.currentData;

    if (model) {
        NSString *courtId = self.baseViewModel.houseId;

        NSDictionary *dict = [self.baseViewModel subPageParams];
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://floor_timeline_detail?court_id=%@",courtId]] userInfo:userInfo];
    }

}

- (void)maskButtonClick {
    NSDictionary *dictTrace = self.baseViewModel.detailTracerDic;
    
    NSMutableDictionary *mutableDict = [NSMutableDictionary new];
    [mutableDict setValue:dictTrace[@"page_type"] forKey:@"page_type"];
    [mutableDict setValue:dictTrace[@"rank"] forKey:@"rank"];
    [mutableDict setValue:dictTrace[@"origin_from"] forKey:@"origin_from"];
    [mutableDict setValue:dictTrace[@"origin_search_id"] forKey:@"origin_search_id"];
    [mutableDict setValue:dictTrace[@"log_pb"] forKey:@"log_pb"];

    [FHEnvContext recordEvent:mutableDict andEventKey:@"click_house_history"];
    
    NSString *courtId = self.baseViewModel.houseId;
    NSDictionary *dict = [self.baseViewModel subPageParams];
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://floor_timeline_detail?court_id=%@",courtId]] userInfo:userInfo];
    
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return _shadowImage;
}

@end

@implementation FHDetailNewHouseNewsCellModel
@end

@interface FHDetailNewHouseNewsCellItemView ()

@property (nonatomic, strong) UIView *dotView;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation FHDetailNewHouseNewsCellItemView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.timeLabel = [[UILabel alloc] init];
    self.timeLabel.font = [UIFont themeFontRegular:12];
    self.timeLabel.textColor = [UIColor themeGray3];
    [self addSubview:self.timeLabel];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(14);
        make.right.mas_equalTo(self);
        make.top.mas_equalTo(self);
        make.height.mas_equalTo(17);
    }];

    self.dotView = [UIView new];
    self.dotView.layer.cornerRadius = 4;
    self.dotView.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
    [self addSubview:self.dotView];
    [self.dotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.centerY.mas_equalTo(self.timeLabel);
        make.width.height.mas_equalTo(8);
    }];

    self.contentLabel = [[UILabel alloc] init];
    self.contentLabel.font = [UIFont themeFontSemibold:16];
    self.contentLabel.textColor = [UIColor themeGray1];
    self.contentLabel.numberOfLines = 2;
    self.contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self addSubview:self.contentLabel];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.timeLabel.mas_bottom).mas_offset(6);
        make.left.right.mas_equalTo(self.timeLabel);
        make.bottom.mas_equalTo(self.mas_bottom).offset(-20);
    }];
    
    self.lineView = [[UIView alloc] init];
    self.lineView.backgroundColor = [UIColor colorWithHexStr:@"#fff8ef"];
    [self addSubview:self.lineView];
    [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.dotView.mas_bottom).mas_offset(6);
        make.width.mas_equalTo(1);
        make.bottom.mas_equalTo(self.contentLabel);
        make.centerX.mas_equalTo(self.dotView);
    }];
    
}

- (void)newsViewShowWithData:(id)data {
    if ([data isKindOfClass:[FHDetailNewDataTimelineListModel class]]) {
        FHDetailNewDataTimelineListModel *model = (FHDetailNewDataTimelineListModel *)data;
        if (model.createdTime.length) {
            self.timeLabel.text = [FHUtils ConvertStrToTime:model.createdTime];
        } else {
            self.timeLabel.text = @"未知";
        }

        self.contentLabel.text = model.desc;
    }
}



@end
