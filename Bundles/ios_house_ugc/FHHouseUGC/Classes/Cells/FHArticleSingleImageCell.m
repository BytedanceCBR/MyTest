//
//  FHUGCPureTitleCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/3.
//

#import "FHArticleSingleImageCell.h"
#import "FHArticleCellBottomView.h"
#import <UIImageView+BDWebImage.h>

@interface FHArticleSingleImageCell ()

@property(nonatomic ,strong) UILabel *contentLabel;
@property(nonatomic ,strong) UIImageView *singleImageView;
@property(nonatomic ,strong) FHArticleCellBottomView *bottomView;
@property(nonatomic ,strong) UIView *bottomSepView;

@end

@implementation FHArticleSingleImageCell

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
    _contentLabel.numberOfLines = 3;
    [self.contentView addSubview:_contentLabel];
    
    self.singleImageView = [[UIImageView alloc] init];
    _singleImageView.clipsToBounds = YES;
    _singleImageView.contentMode = UIViewContentModeScaleAspectFill;
    _singleImageView.backgroundColor = [UIColor themeGray6];
    _singleImageView.layer.borderColor = [[UIColor themeGray6] CGColor];
    _singleImageView.layer.borderWidth = 0.5;
    _singleImageView.layer.masksToBounds = YES;
    _singleImageView.layer.cornerRadius = 4;
    [self.contentView addSubview:_singleImageView];
    
    self.bottomView = [[FHArticleCellBottomView alloc] initWithFrame:CGRectZero];
    [self.contentView addSubview:_bottomView];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self.contentView addSubview:_bottomSepView];
}

- (void)initConstraints {
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(15);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.singleImageView.mas_left).offset(-15);
    }];
    
    [self.singleImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentLabel);
        make.right.mas_equalTo(self.contentView).offset(-20);
        make.width.mas_equalTo(120);
        make.height.mas_equalTo(90);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.singleImageView.mas_bottom).offset(10);
        make.left.right.mas_equalTo(self.contentView);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bottomView.mas_bottom).offset(10);
        make.bottom.left.right.mas_equalTo(self.contentView);
        make.height.mas_equalTo(5);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    FHFeedContentModel *model = (FHFeedContentModel *)data;
    //内容
    self.contentLabel.text = model.title;
    self.bottomView.descLabel.text = @"信息来源";
    
    FHFeedContentImageListModel *imageModel = [model.imageList firstObject];
    if(imageModel){
        [self.singleImageView bd_setImageWithURL:[NSURL URLWithString:imageModel.url] placeholder:nil];
    }
}

@end

