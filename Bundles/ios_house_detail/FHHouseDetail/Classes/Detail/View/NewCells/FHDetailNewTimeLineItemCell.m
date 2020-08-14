//
//  FHDetailNewTimeLineItemCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHDetailNewTimeLineItemCell.h"
#import "TTRoute.h"
#import "FHEnvContext.h"
#import <ByteDanceKit/NSDate+BTDAdditions.h>
#import "FHUtils.h"

@interface FHDetailNewTimeLineItemCell ()
@property (nonatomic, strong) UIButton *maskBtn;
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *redDotView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *timeLineLeading;
@property (nonatomic, strong) UIView *headLine;
@property (nonatomic, strong) UIView *timeLineTailing;

@property (nonatomic, strong) UIView *lineView;

@end

@implementation FHDetailNewTimeLineItemCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        
        _headLine = [UIView new];
        _headLine.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_headLine];
        [_headLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.contentView);
            make.height.mas_equalTo(0);
        }];
        
        _timeLabel = [UILabel new];
        _timeLabel.font = [UIFont themeFontRegular:12];
        _timeLabel.textColor = [UIColor themeGray3];
        [self.contentView addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(29);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.equalTo(self.headLine.mas_bottom);
            make.height.mas_equalTo(17);
        }];

        _redDotView= [UIView new];
        _redDotView.layer.cornerRadius = 4;
        _redDotView.backgroundColor = [UIColor colorWithHexStr:@"#ff9629"];
        [self.contentView addSubview:_redDotView];
        [_redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.centerY.equalTo(self.timeLabel);
            make.width.height.mas_equalTo(8);
        }];


        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontSemibold:16];
        _titleLabel.textColor = [UIColor themeGray1];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timeLabel.mas_bottom).offset(6);
            make.left.equalTo(self.timeLabel);
            make.height.mas_equalTo(24);
            make.right.equalTo(self.contentView).offset(-15);
        }];
        

        _contentLabel = [UILabel new];
        _contentLabel.font = [UIFont themeFontRegular:16];
        _contentLabel.textColor = [UIColor themeGray3];
        _contentLabel.numberOfLines = 2;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(6);
            make.left.equalTo(self.titleLabel);
            make.right.equalTo(self.contentView).offset(-15);
            make.bottom.equalTo(self.contentView).offset(-20);
        }];
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor colorWithHexStr:@"#fff8ef"];
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.redDotView.mas_bottom).mas_offset(6);
            make.width.mas_equalTo(1);
            make.bottom.mas_equalTo(self.contentLabel);
            make.centerX.mas_equalTo(self.redDotView);
        }];

//        _timeLineLeading = [UIView new];
//        _timeLineLeading.backgroundColor = [UIColor colorWithHexStr:@"#fff8ef"];
//        [self.contentView addSubview:_timeLineLeading];
//        [_timeLineLeading mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.centerY.mas_offset(self.redDotView);
//            make.width.mas_equalTo(1);
//            make.top.equalTo(self.contentView);
//            make.bottom.equalTo(self.redDotView.mas_top);
//        }];
//
//
//
//        _timeLineTailing = [UIView new];
//        _timeLineTailing.backgroundColor = [UIColor themeGray8];
//        [self.contentView addSubview:_timeLineTailing];
//        [_timeLineTailing mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.left.mas_equalTo(24);
//            make.width.mas_equalTo(0.5);
//            make.top.equalTo(self.redDotView.mas_bottom).offset(4);
//            make.bottom.equalTo(self.contentView);
//        }];
        
        
        _maskBtn = [UIButton new];
        [_maskBtn addTarget:self action:@selector(maskButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        _maskBtn.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:_maskBtn];
        [_maskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];

    }
    return self;
}

- (void)maskButtonClick:(UIButton *)button {

    if ([self.currentData isKindOfClass:[FHDetailNewTimeLineItemModel class]]) {

        FHDetailNewTimeLineItemModel *model = (FHDetailNewTimeLineItemModel *)self.currentData;
        if (!model.isExpand) {
            NSDictionary *dictTrace = self.baseViewModel.detailTracerDic;
            
            NSMutableDictionary *mutableDict = [NSMutableDictionary new];
            [mutableDict setValue:dictTrace[@"page_type"] forKey:@"page_type"];
            [mutableDict setValue:dictTrace[@"rank"] forKey:@"rank"];
            [mutableDict setValue:dictTrace[@"origin_from"] forKey:@"origin_from"];
            [mutableDict setValue:dictTrace[@"origin_search_id"] forKey:@"origin_search_id"];
            [mutableDict setValue:dictTrace[@"log_pb"] forKey:@"log_pb"];

            [FHEnvContext recordEvent:mutableDict andEventKey:@"click_house_history"];
            
            NSString *courtId = ((FHDetailNewTimeLineItemModel *)self.currentData).courtId;
            NSDictionary *dict = [self.baseViewModel subPageParams];
            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://floor_timeline_detail?court_id=%@",courtId]] userInfo:userInfo];
            
            
        }
    }
}



- (void)refreshWithData:(id)data
{
    if([data isKindOfClass:[FHDetailNewTimeLineItemModel class]])
    {
        self.currentData = data;
        FHDetailNewTimeLineItemModel *model = (FHDetailNewTimeLineItemModel*)data;
        if(model.createdTime)
        {
            _timeLabel.text = [FHUtils ConvertStrToTime:model.createdTime];
        }
        self.titleLabel.text = model.title;
        self.contentLabel.text = model.desc;
        if (model.isExpand) {
            _contentLabel.numberOfLines = 0;
        }
//        if (model.isFirstCell) {
//            [_headLine mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.height.mas_equalTo(10);
//            }];
//
//            _timeLineLeading.hidden = YES;
//
//
//            [_timeLineTailing mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(24);
//                make.width.mas_equalTo(0.5);
//                make.top.equalTo(self.redDotView.mas_bottom).offset(4);
//                make.bottom.equalTo(self.contentView);
//            }];
//        }else
//        {
//            _timeLineLeading.hidden = NO;
//        }
//        if (model.isLastCell) {
//            [_timeLineTailing mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.bottom.equalTo(self.contentView).offset(-20);
//            }];
//        }
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

@end

@implementation FHDetailNewTimeLineItemModel
@end
