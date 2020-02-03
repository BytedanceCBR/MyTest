//
//  FHUGCHotTopicSubCell.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/8/25.
//

#import "FHUGCHotTopicSubCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <Masonry.h>
#import <UIImageView+BDWebImage.h>
#import "FHUGCModel.h"

@interface FHUGCHotTopicSubCell ()

@property(nonatomic, strong) UIImageView *bgView;
@property(nonatomic, strong) UILabel *rankLabel;
@property(nonatomic, strong) UILabel *titleLabel;
@property(nonatomic, strong) UILabel *descLabel;

@end

@implementation FHUGCHotTopicSubCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        [self initView];
        [self initConstains];
    }
    return self;
}

- (void)refreshWithData:(id)data index:(NSInteger)index {
    if([data isKindOfClass:[FHFeedContentRawDataHotTopicListModel class]]){
        FHFeedContentRawDataHotTopicListModel *model = (FHUGCScialGroupDataModel *)data;
        _titleLabel.text = model.forumName;
        _descLabel.text = model.talkCountStr;
        _rankLabel.text = [NSString stringWithFormat:@"%i",index + 1];

        if(index < 3){
            _rankLabel.textColor = [UIColor themeOrange1];
        }else{
            _rankLabel.textColor = [UIColor themeGray3];
        }
    }
}

- (void)initView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.bgView = [[UIImageView alloc] init];
    [self.contentView addSubview:_bgView];
    
    self.rankLabel = [self LabelWithFont:[UIFont themeFontSemibold:15] textColor:[UIColor themeGray3]];
    _rankLabel.textAlignment = NSTextAlignmentRight;
    _rankLabel.text = @"5";
    [self.bgView addSubview:_rankLabel];
    
    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:15] textColor:[UIColor themeGray1]];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.bgView addSubview:_titleLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    _descLabel.textAlignment = NSTextAlignmentLeft;
    [self.bgView addSubview:_descLabel];
}

- (void)initConstains {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.rankLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView);
        make.left.mas_equalTo(self.bgView).offset(16);
        make.width.mas_equalTo(8);
        make.height.mas_equalTo(21);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView);
        make.left.mas_equalTo(self.rankLabel.mas_right).offset(5);
        make.right.mas_equalTo(self.bgView).offset(-15);
        make.height.mas_equalTo(21);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom);
        make.left.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.titleLabel);
        make.height.mas_equalTo(17);
    }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
