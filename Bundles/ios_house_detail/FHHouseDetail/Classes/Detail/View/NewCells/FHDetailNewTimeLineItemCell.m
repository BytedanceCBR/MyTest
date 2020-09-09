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
#import "UILabel+BTDAdditions.h"

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
        _timeLabel.font = [UIFont themeFontSemibold:16];
        _timeLabel.textColor = [UIColor themeGray1];
        [self.contentView addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(33);
            make.width.mas_equalTo(MAXFLOAT);
            make.top.equalTo(self.headLine.mas_bottom);
            make.height.mas_equalTo(22);
        }];


        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontMedium:12];
        _titleLabel.textColor = [UIColor themeOrange1];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.backgroundColor = [UIColor colorWithHexStr:@"#fff8ef"];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timeLabel);
            make.left.equalTo(self.timeLabel.mas_right).offset(4);
            make.height.mas_equalTo(22);
            make.width.mas_equalTo(MAXFLOAT);
        }];

        _contentLabel = [UILabel new];
        _contentLabel.font = [UIFont themeFontRegular:16];
        _contentLabel.textColor = [UIColor themeGray1];
        _contentLabel.numberOfLines = 2;
        _contentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        [self.contentView addSubview:_contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(10);
            make.left.equalTo(self.timeLabel);
            make.right.equalTo(self.contentView).offset(-48);
            make.bottom.equalTo(self.contentView).offset(-20);
        }];
        self.lineView = [[UIView alloc] init];
        self.lineView.backgroundColor = [UIColor colorWithHexStr:@"#fff8ef"];
        [self.contentView addSubview:self.lineView];
        [self.lineView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.mas_equalTo(0);
            make.width.mas_equalTo(2);
            make.left.mas_equalTo(18);
        }];
        
        _redDotView= [UIView new];
        _redDotView.backgroundColor = [UIColor whiteColor];
        _redDotView.layer.cornerRadius = 5;
        _redDotView.layer.borderWidth = 2;
        _redDotView.layer.borderColor = [UIColor themeOrange1].CGColor;
        [self.contentView addSubview:_redDotView];
        [_redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(14);
            make.centerY.equalTo(self.timeLabel);
            make.width.height.mas_equalTo(10);
        }];
        
//        _maskBtn = [UIButton new];
//        [_maskBtn addTarget:self action:@selector(maskButtonClick:) forControlEvents:UIControlEventTouchUpInside];
//        _maskBtn.backgroundColor = [UIColor clearColor];
//        [self.contentView addSubview:_maskBtn];
//        [_maskBtn mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.edges.equalTo(self.contentView);
//        }];

    }
    return self;
}

//- (void)maskButtonClick:(UIButton *)button {
//
//    if ([self.currentData isKindOfClass:[FHDetailNewTimeLineItemModel class]]) {
//
//        FHDetailNewTimeLineItemModel *model = (FHDetailNewTimeLineItemModel *)self.currentData;
//        if (!model.isExpand) {
//            NSDictionary *dictTrace = self.baseViewModel.detailTracerDic;
//            
//            NSMutableDictionary *mutableDict = [NSMutableDictionary new];
//            [mutableDict setValue:dictTrace[@"page_type"] forKey:@"page_type"];
//            [mutableDict setValue:dictTrace[@"rank"] forKey:@"rank"];
//            [mutableDict setValue:dictTrace[@"origin_from"] forKey:@"origin_from"];
//            [mutableDict setValue:dictTrace[@"origin_search_id"] forKey:@"origin_search_id"];
//            [mutableDict setValue:dictTrace[@"log_pb"] forKey:@"log_pb"];
//
//            [FHEnvContext recordEvent:mutableDict andEventKey:@"click_house_history"];
//            
//            NSString *courtId = ((FHDetailNewTimeLineItemModel *)self.currentData).courtId;
//            NSDictionary *dict = [self.baseViewModel subPageParams];
//            TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc]initWithInfo:dict];
//            [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:[NSString stringWithFormat:@"sslocal://floor_timeline_detail?court_id=%@",courtId]] userInfo:userInfo];
//            
//            
//        }
//    }
//}



- (void)refreshWithData:(id)data
{
    if([data isKindOfClass:[FHDetailNewTimeLineItemModel class]])
    {
        self.currentData = data;
        FHDetailNewTimeLineItemModel *model = (FHDetailNewTimeLineItemModel*)data;
        if(model.createdTime)
        {
            _timeLabel.text = [FHUtils ConvertStrToTimeForm:model.createdTime];
        }
        CGFloat timeWidth = [self.timeLabel btd_widthWithHeight:22];
        [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(timeWidth);
        }];
        self.titleLabel.text = model.title;
        CGFloat width = [self.titleLabel btd_widthWithHeight:17] + 12;
        CGFloat maxWidth = CGRectGetMaxX(self.contentView.frame) - 15 - CGRectGetMaxX(self.timeLabel.frame);
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(MIN(width, maxWidth));
        }];
        self.contentLabel.text = model.desc;
        if (model.isExpand) {
            _contentLabel.numberOfLines = 0;
        }
        if (model.isFirstCell) {
            [_headLine mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(15);
            }];

//            _timeLineLeading.hidden = YES;


//            [_timeLineTailing mas_updateConstraints:^(MASConstraintMaker *make) {
//                make.left.mas_equalTo(24);
//                make.width.mas_equalTo(0.5);
//                make.top.equalTo(self.redDotView.mas_bottom).offset(4);
//                make.bottom.equalTo(self.contentView);
//            }];
        }else
        {
            [_headLine mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(0);
            }];
//            _timeLineLeading.hidden = NO;
        }
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
