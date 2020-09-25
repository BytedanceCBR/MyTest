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

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UIView *redDotView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *contentLabel;
@property (nonatomic, strong) UIView *lineView;

@end

@implementation FHDetailNewTimeLineItemCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _timeLabel = [UILabel new];
        _timeLabel.font = [UIFont themeFontSemibold:16];
        _timeLabel.textColor = [UIColor themeGray1];
        [self.contentView addSubview:_timeLabel];
        [_timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(33);
            make.width.mas_equalTo(MAXFLOAT);
            make.top.equalTo(0);
            make.height.mas_equalTo(22);
        }];


        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontMedium:12];
        _titleLabel.textColor = [UIColor themeOrange1];
        _timeLabel.layer.cornerRadius = 2;
        _timeLabel.layer.masksToBounds = YES;
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
            make.right.equalTo(self.contentView).offset(-38);
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
    }
    return self;
}

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
        CGFloat width = MIN([self.titleLabel btd_widthWithHeight:17] + 12, 60);
        CGFloat maxWidth = MAIN_SCREEN_WIDTH - 15 - 33 - timeWidth - 4;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(MIN(width, maxWidth));
        }];
        self.contentLabel.text = model.desc;
        if (model.isExpand) {
            _contentLabel.numberOfLines = 0;
        }
        if (model.isFirstCell) {
            [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(15);
            }];
            [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(21);
            }];
        } else {
            [self.timeLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
            }];
            [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.top.mas_equalTo(0);
            }];
        }
        if (model.isLastCell) {
            [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(-20);
            }];
        } else {
            [self.lineView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.mas_equalTo(0);
            }];
        }
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
