//
//  FHUGCHotTopicSubCell.m
//  AKCommentPlugin
//
//  Created by 谢思铭 on 2019/8/25.
//

#import "FHUGCHotTopicSubCell.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "Masonry.h"
#import "UIImageView+BDWebImage.h"
#import "FHUGCModel.h"
#import "UIViewAdditions.h"

@interface FHUGCHotTopicSubCell ()

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
        FHFeedContentRawDataHotTopicListModel *model = (FHFeedContentRawDataHotTopicListModel *)data;
        _titleLabel.text = model.forumName;
        _descLabel.text = model.talkCountStr;
        _rankLabel.text = [NSString stringWithFormat:@"%li",index + 1];

        if(index < 3){
            _rankLabel.textColor = [UIColor themeOrange1];
        }else{
            _rankLabel.textColor = [UIColor themeGray3];
        }
    }
}

- (void)initView {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.rankLabel = [self LabelWithFont:[UIFont themeFontSemibold:15] textColor:[UIColor themeGray3]];
    _rankLabel.textAlignment = NSTextAlignmentRight;
    _rankLabel.text = @"5";
    [self.contentView addSubview:_rankLabel];

    self.titleLabel = [self LabelWithFont:[UIFont themeFontRegular:15] textColor:[UIColor themeGray1]];
    _titleLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_titleLabel];

    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray3]];
    _descLabel.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_descLabel];
}

- (void)initConstains {
    self.rankLabel.top = 0;
    self.rankLabel.left = 16;
    self.rankLabel.width = 8;
    self.rankLabel.height = 21;
    
    self.titleLabel.top = 0;
    self.titleLabel.left = self.rankLabel.right + 5;
    self.titleLabel.width = [UIScreen mainScreen].bounds.size.width/2 - 4 - 15 - self.titleLabel.left;
    self.titleLabel.height = 21;

    self.descLabel.top = self.titleLabel.bottom;
    self.descLabel.left = self.titleLabel.left;
    self.descLabel.width = self.titleLabel.width;
    self.descLabel.height = 17;
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    label.layer.masksToBounds = YES;
    label.backgroundColor = [UIColor whiteColor];
    
    return label;
}

@end
