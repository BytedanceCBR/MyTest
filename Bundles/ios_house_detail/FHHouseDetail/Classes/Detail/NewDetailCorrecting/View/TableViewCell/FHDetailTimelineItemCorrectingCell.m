//
//  FHDetailTimelineItemCorrectingCell.m
//  FHHouseDetail
//
//  Created by 张静 on 2020/4/29.
//

#import "FHDetailTimelineItemCorrectingCell.h"

#import "TTRoute.h"
#import "FHEnvContext.h"

@interface FHDetailTimelineItemCorrectingCell ()
@property (nonatomic, strong) UIButton *maskBtn;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *redDotView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *timeLineLeading;
@property (nonatomic, strong) UIView *headLine;
@property (nonatomic, strong) UIView *timeLineTailing;
@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, weak) UIView *containerView;

@end

@implementation FHDetailTimelineItemCorrectingCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        
//        self.containerView.backgroundColor = [UIColor whiteColor];
        [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.contentView);
            make.right.mas_equalTo(self.contentView);
            make.top.equalTo(self.contentView).offset(-14);
            make.bottom.equalTo(self.contentView).offset(14);
        }];
        [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.shadowImage).offset(15);
            make.right.mas_equalTo(self.shadowImage).offset(-15);
            make.top.mas_equalTo(self.shadowImage).offset(20);
            make.bottom.equalTo(self.shadowImage).offset(-20);
        }];
        _headLine = [UIView new];
//        _headLine.backgroundColor = [UIColor whiteColor];
        [self.containerView addSubview:_headLine];
        [_headLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.containerView);
            make.height.mas_equalTo(0);
        }];
        
        _timeLabel = [UILabel new];
        _timeLabel.font = [UIFont themeFontRegular:18];
        _timeLabel.textColor = [UIColor themeGray1];
        [self.containerView addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(48);
            make.right.equalTo(self.containerView).offset(-20);
            make.top.equalTo(self.headLine.mas_bottom);
            make.height.mas_equalTo(25);
        }];

        _redDotView= [UIView new];
        _redDotView.layer.cornerRadius = 4;
        _redDotView.backgroundColor = [UIColor themeGray4];
        [self.containerView addSubview:_redDotView];
        [_redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.centerY.equalTo(self.timeLabel);
            make.width.height.mas_equalTo(8);
        }];


        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontSemibold:16];
        _titleLabel.textColor = [UIColor themeGray1];
        [self.containerView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timeLabel.mas_bottom).offset(16);
            make.left.equalTo(self.timeLabel);
            make.height.mas_equalTo(26);
            make.right.equalTo(self.containerView).offset(-20);
        }];
        

        _contentLabel = [UILabel new];
        _contentLabel.font = [UIFont themeFontRegular:16];
        _contentLabel.textColor = [UIColor themeGray3];
        _contentLabel.numberOfLines = 2;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.containerView addSubview:_contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
            make.left.equalTo(self.titleLabel);
            make.right.equalTo(self.containerView).offset(-20);
            make.bottom.equalTo(self.containerView).offset(-20);
        }];


        _timeLineLeading = [UIView new];
        _timeLineLeading.backgroundColor = [UIColor themeGray8];
        [self.containerView addSubview:_timeLineLeading];
        [_timeLineLeading mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(24);
            make.width.mas_equalTo(1);
            make.top.equalTo(self.containerView);
            make.bottom.equalTo(self.redDotView.mas_top);
        }];
        


        _timeLineTailing = [UIView new];
        _timeLineTailing.backgroundColor = [UIColor themeGray8];
        [self.containerView addSubview:_timeLineTailing];
        [_timeLineTailing mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(24);
            make.width.mas_equalTo(0.5);
            make.top.equalTo(self.redDotView.mas_bottom).offset(4);
            make.bottom.equalTo(self.containerView);
        }];
        
        
        _maskBtn = [UIButton new];
        [_maskBtn addTarget:self action:@selector(maskButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _maskBtn.backgroundColor = [UIColor clearColor];
        [self.containerView addSubview:_maskBtn];
        [_maskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.containerView);
        }];

    }
    return self;
}

- (void)maskButtonClick:(UIButton *)button {

    if ([self.currentData isKindOfClass:[FHDetailNewTimeLineItemCorrectingModel class]]) {

        FHDetailNewTimeLineItemCorrectingModel *model = (FHDetailNewTimeLineItemCorrectingModel *)self.currentData;
        adjustImageScopeType(model)

        if (!model.isExpand) {
            NSDictionary *dictTrace = self.baseViewModel.detailTracerDic;
            
            NSMutableDictionary *mutableDict = [NSMutableDictionary new];
            [mutableDict setValue:dictTrace[@"page_type"] forKey:@"page_type"];
            [mutableDict setValue:dictTrace[@"rank"] forKey:@"rank"];
            [mutableDict setValue:dictTrace[@"origin_from"] forKey:@"origin_from"];
            [mutableDict setValue:dictTrace[@"origin_search_id"] forKey:@"origin_search_id"];
            [mutableDict setValue:dictTrace[@"log_pb"] forKey:@"log_pb"];

            [FHEnvContext recordEvent:mutableDict andEventKey:@"click_house_history"];
            
            NSString *courtId = ((FHDetailNewTimeLineItemCorrectingModel *)self.currentData).courtId;
            NSDictionary *dict = [self.baseViewModel subPageParams];
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://floor_timeline_detail?court_id=%@",courtId]] userInfo:userInfo];
        }
    }
}



- (void)refreshWithData:(id)data
{
    if([data isKindOfClass:[FHDetailNewTimeLineItemCorrectingModel class]])
    {
        self.currentData = data;
        FHDetailNewTimeLineItemCorrectingModel *model = (FHDetailNewTimeLineItemCorrectingModel*)data;
        if(model.createdTime)
        {
            _timeLabel.text = [self getTimeFromTimestamp:[model.createdTime doubleValue]];
        }
        self.titleLabel.text = model.title;
        self.contentLabel.text = model.desc;
        if (model.isExpand) {
            _contentLabel.numberOfLines = 0;
        }
        adjustImageScopeType(model);
        if (model.isFirstCell) {
            [_headLine mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(10);
            }];
            
            _timeLineLeading.hidden = YES;
            
            
            [_timeLineTailing mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(24);
                make.width.mas_equalTo(0.5);
                make.top.equalTo(self.redDotView.mas_bottom).offset(4);
                make.bottom.equalTo(self.containerView);
            }];
        }else
        {
            _timeLineLeading.hidden = NO;
        }
        if (model.isLastCell) {
            
            [_contentLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.containerView).offset(-20);
            }];
            [_timeLineTailing mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.containerView).offset(-20);
            }];
        }
    }
}

- (NSString *)getTimeFromTimestamp:(double)timestamp{
    //将对象类型的时间转换为NSDate类型
    double time = timestamp;
    NSDate *myDate = [NSDate dateWithTimeIntervalSince1970:time];

    //设置时间格式
    NSDateFormatter * formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"MM-dd"];

    //将时间转换为字符串
    NSString *timeStr = [formatter stringFromDate:myDate];
   
    if (timeStr) {
      return timeStr;
    }else
    {
      return @"未知";
    }
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}
- (UIView *)containerView {
    if (!_containerView) {
        UIView *containerView = [[UIView alloc]init];
        [self.contentView addSubview:containerView];
        _containerView = containerView;
    }
    return _containerView;
}

@end


@implementation FHDetailNewTimeLineItemCorrectingModel
@end
