//
// Created by zhulijun on 2019-06-03.
// 小区话题列表页Cell
//

#import "FHTopicCell.h"
#import "FHTopicListModel.h"
#import <BDWebImage/BDWebImage.h>


@interface FHTopicCell ()
@property(nonatomic, strong) UIImageView *headerImageView;
@property(nonatomic, strong) UIView *headerImageTagView;
@property(nonatomic, strong) UILabel *headerImageTagViewLabel;
@property(nonatomic, strong) UIImageView *headerImageTagViewBackground;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *subtitleLabel;
@property(nonatomic, strong) UILabel *detailLabel;
@property(nonatomic, strong) UIView *bottomSepLine;
@end

@implementation FHTopicCell

- (UIImageView *)headerImageView {
    if(!_headerImageView) {
        _headerImageView = [UIImageView new];
        _headerImageView.layer.cornerRadius = 4;
        _headerImageView.layer.masksToBounds = YES;
        _headerImageView.layer.borderWidth = 0.5;
        _headerImageView.layer.borderColor = [UIColor themeGray6].CGColor;
        _headerImageView.contentMode = UIViewContentModeScaleAspectFill;
    }
    return _headerImageView;
}

-(UIView *)headerImageTagView {
    if(!_headerImageTagView) {
        _headerImageTagView = [UIView new];
        
        [_headerImageTagView addSubview:self.headerImageTagViewBackground];
        
        [_headerImageTagView addSubview:self.headerImageTagViewLabel];
        
        [self.headerImageTagViewBackground mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_headerImageTagView);
        }];
        
        [self.headerImageTagViewLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_headerImageTagView);
        }];
    }
    return _headerImageTagView;
}

-(UIImageView *)headerImageTagViewBackground {
    if(!_headerImageTagViewBackground) {
        _headerImageTagViewBackground = [[UIImageView alloc] init];
    }
    return _headerImageTagViewBackground;
}

-(UILabel *)headerImageTagViewLabel {
    if(!_headerImageTagViewLabel) {
        _headerImageTagViewLabel = [UILabel new];
        _headerImageTagViewLabel.font = [UIFont themeFontMedium:10];
        _headerImageTagViewLabel.textColor = [UIColor themeWhite];
        _headerImageTagViewLabel.textAlignment = NSTextAlignmentCenter;
        _headerImageTagViewLabel.numberOfLines = 1;
    }
    return _headerImageTagViewLabel;
}

-(UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}

-(UILabel *)subtitleLabel {
    if(!_subtitleLabel) {
        _subtitleLabel = [UILabel new];
        _subtitleLabel.font = [UIFont themeFontRegular:13];
        _subtitleLabel.textColor = [UIColor themeGray3];
        _subtitleLabel.numberOfLines = 1;
    }
    return _subtitleLabel;
}

- (UILabel *)detailLabel {
    if(!_detailLabel) {
        _detailLabel = [UILabel new];
        _detailLabel.font = [UIFont themeFontRegular:13];
        _detailLabel.textColor = [UIColor themeGray3];
        _detailLabel.numberOfLines = 1;
    }
    return _detailLabel;
}

-(UIView *)bottomSepLine {
    if(!_bottomSepLine) {
        _bottomSepLine = [UIView new];
        _bottomSepLine.backgroundColor = [UIColor themeGray6];
    }
    return _bottomSepLine;
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    [self.contentView addSubview:self.headerImageView];
    [self.contentView addSubview:self.headerImageTagView];
    [self.contentView addSubview:self.titleLabel];
    [self.contentView addSubview:self.subtitleLabel];
    [self.contentView addSubview:self.detailLabel];
    [self.contentView addSubview:self.bottomSepLine];
}

- (void)initConstraints {

    [self.headerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(74);
        make.top.equalTo(self.contentView).offset(10);
        make.left.equalTo(self.contentView).offset(20);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
    
    [self.headerImageTagView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(22);
        make.height.mas_equalTo(18);
        make.top.equalTo(self.headerImageView);
        make.left.equalTo(self.headerImageView).offset(4);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.headerImageView.mas_right).offset(10);
        make.height.mas_equalTo(self.titleLabel.font.pointSize + 2);
        make.top.equalTo(self.headerImageView).offset(6);
        make.right.equalTo(self.contentView).offset(-20);
    }];
    
    [self.subtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.top.equalTo(self.titleLabel.mas_bottom).offset(2);
        make.bottom.equalTo(self.detailLabel.mas_top).offset(-2);
    }];
    
    [self.detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.titleLabel);
        make.height.mas_equalTo(self.detailLabel.font.pointSize + 2);
        make.bottom.equalTo(self.headerImageView).offset(-5);
    }];
    
    [self.bottomSepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(0.5);
        make.left.equalTo(self.headerImageView);
        make.right.equalTo(self.titleLabel);
        make.bottom.equalTo(self.contentView).offset(-0.5);
    }];
}

- (void)refreshWithData:(id)data {
    
    if (![data isKindOfClass:FHTopicListResponseDataListModel.class]) {
        return;
    }
    
    FHTopicListResponseDataListModel* itemData = (FHTopicListResponseDataListModel *)data;
    self.headerImageTagViewLabel.text = itemData.rank?:@"";
    self.headerImageTagViewLabel.hidden = !(self.headerImageTagViewLabel.text.length > 0);
    [self.headerImageView bd_setImageWithURL:[NSURL URLWithString:itemData.avatarUrl] placeholder:nil];
    self.titleLabel.text = itemData.forumName.length > 0 ? [NSString stringWithFormat:@"#%@#", itemData.forumName]:@"";
    self.subtitleLabel.text = itemData.desc ?:@"";
    self.detailLabel.text = itemData.talkCountStr ?:@"";
}

- (void)configHeaderImageTagViewBackgroundWithIndex: (NSInteger)rowIndex {
    NSString *imageName = rowIndex < 3 ? @"fh_ugc_topic_list_header_tag_red" : @"fh_ugc_topic_list_header_tag_orange";
    self.headerImageTagViewBackground.image =  [UIImage imageNamed: imageName];
}
@end
