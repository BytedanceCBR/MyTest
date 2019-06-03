//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHUGCSingleImageCell.h"
#import <UIImageView+BDWebImage.h>


@interface FHUGCSingleImageCell ()

@property(nonatomic ,strong) UILabel *contentLabel;
@property(nonatomic ,strong) UIImageView *singleImageView;

@end

@implementation FHUGCSingleImageCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:16] textColor:[UIColor themeGray1]];
    [self.contentView addSubview:_contentLabel];
    
    self.singleImageView = [[UIImageView alloc] init];
    _singleImageView.clipsToBounds = YES;
    _singleImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:_singleImageView];
}

- (void)initConstraints {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(10);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(50);
    }];
    
    [self.singleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel.mas_bottom).offset(10);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.width.mas_equalTo(150);
        make.height.mas_equalTo(100);
        make.bottom.mas_equalTo(self.contentView).offset(-10);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    self.contentLabel.text = @"据说经常看美女可以防止猝死";
//    self.singleImageView.image = [UIImage imageNamed:@"fh_mine_avatar"];
    
    [self.singleImageView bd_setImageWithURL:[NSURL URLWithString:@"http://dingyue.nosdn.127.net/ZhOMrnt0EI7KrfveuYBe96RC6jlGUWdKf0IVDx96qzzL31552910938719.jpeg"] placeholder:[UIImage imageNamed:@"fh_mine_avatar"]];
}

@end
