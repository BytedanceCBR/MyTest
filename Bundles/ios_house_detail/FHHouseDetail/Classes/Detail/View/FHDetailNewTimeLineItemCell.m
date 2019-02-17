//
//  FHDetailNewHouseNewsCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/15.
//

#import "FHDetailNewTimeLineItemCell.h"

@interface FHDetailNewTimeLineItemCell ()
@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *redDotView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *timeLineLeading;
@property (nonatomic, strong) UIView *headLine;
@property (nonatomic, strong) UIView *timeLineTailing;
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
        _timeLabel.font = [UIFont themeFontRegular:18];
        _timeLabel.textColor = [UIColor colorWithHexString:@"#081f33"];
        [self.contentView addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(48);
            make.right.equalTo(self.contentView).offset(-20);
            make.top.equalTo(self.headLine.mas_bottom);
            make.height.mas_equalTo(25);
        }];

        _redDotView= [UIView new];
        _redDotView.layer.cornerRadius = 4;
        _redDotView.backgroundColor = [UIColor colorWithHexString:@"#a1aab3"];
        [self.contentView addSubview:_redDotView];
        [_redDotView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(20);
            make.centerY.equalTo(self.timeLabel);
            make.width.height.mas_equalTo(8);
        }];


        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontSemibold:16];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#081f33"];
        [self.contentView addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.timeLabel.mas_bottom).offset(16);
            make.left.equalTo(self.timeLabel);
            make.height.mas_equalTo(26);
            make.right.equalTo(self.contentView).offset(-20);
        }];
        

        _contentLabel = [UILabel new];
        _contentLabel.font = [UIFont themeFontRegular:14];
        _contentLabel.textColor = [UIColor colorWithHexString:@"#8a9299"];
        _contentLabel.numberOfLines = 2;
        _contentLabel.lineBreakMode = NSLineBreakByWordWrapping;
        [self.contentView addSubview:_contentLabel];
        [_contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.titleLabel.mas_bottom).offset(4);
            make.left.equalTo(self.titleLabel);
            make.right.equalTo(self.contentView).offset(-20);
            make.bottom.equalTo(self.contentView).offset(-20);
        }];


        _timeLineLeading = [UIView new];
        _timeLineLeading.backgroundColor = [UIColor colorWithHexString:@"#f2f4f5"];
        [self.contentView addSubview:_timeLineLeading];
        [_timeLineLeading mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(24);
            make.width.mas_equalTo(1);
            make.top.equalTo(self.contentView);
            make.bottom.equalTo(self.redDotView.mas_top).offset(-4);
        }];


        _timeLineTailing = [UIView new];
        _timeLineTailing.backgroundColor = [UIColor colorWithHexString:@"#f2f4f5"];
        [self.contentView addSubview:_timeLineTailing];
        [_timeLineTailing mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.timeLineLeading.mas_left);
            make.width.mas_equalTo(0.5);
            make.top.equalTo(self.redDotView.mas_bottom).offset(4);
            make.bottom.equalTo(self.contentView);
        }];

    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if([data isKindOfClass:[FHDetailNewTimeLineItemModel class]])
    {
        FHDetailNewTimeLineItemModel *model = (FHDetailNewTimeLineItemModel*)data;
//        NSDateFormatter * dateFormater = [NSDateFormatter str
        _timeLabel.text = @"12-21";
        self.titleLabel.text = model.title;
        self.contentLabel.text = model.desc;
        if (model.isFirstCell) {
            [_headLine mas_updateConstraints:^(MASConstraintMaker *make) {
                make.height.mas_equalTo(15);
            }];
        }
//        re.dateFormat = "MM-dd"
//        self.timeLabel.text
        
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
