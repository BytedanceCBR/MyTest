//
//  FHNeighborhoodDetailCommentTagView.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/14.
//

#import "FHNeighborhoodDetailCommentTagView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"

#define leftMargin 10
#define rightMargin 10

@interface FHNeighborhoodDetailCommentTagView ()

@property(nonatomic , strong) FHNeighborhoodDetailCommentTagModel *model;
@property(nonatomic , strong) UIImageView *digIcon;
@property(nonatomic , strong) UILabel *persentLabel;
@property(nonatomic , strong) UIView *spLine;
@property(nonatomic , strong) UILabel *contentLabel;

@end

@implementation FHNeighborhoodDetailCommentTagView

- (instancetype)initWithFrame:(CGRect)frame model:(FHNeighborhoodDetailCommentTagModel *)model
{
    self = [super initWithFrame:frame];
    if (self) {
        _model = model;
        [self initViews];
        [self initConstaints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor colorWithHexStr:@"#f5f5f5"];
    
//    self.digIcon = [[UIImageView alloc] init];
//    _digIcon.image = [UIImage imageNamed:@"neighborhood_detail_comment_digg_icon"];
//    [self addSubview:_digIcon];
//
//    self.persentLabel = [self LabelWithFont:[UIFont themeFontMedium:12] textColor:[UIColor themeOrange4]];
//    _persentLabel.text = self.model.persent;
//    [self addSubview:_persentLabel];
//
//    self.spLine = [[UIView alloc] init];
//    _spLine.backgroundColor = [UIColor themeGray6];
//    [self addSubview:_spLine];
    
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray1]];
    _contentLabel.text = self.model.content;
    [self addSubview:_contentLabel];
}

- (void)initConstaints {
//    [self.digIcon mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self).offset(leftMargin);
//        make.centerY.mas_equalTo(self).offset(-1);
//        make.width.height.mas_equalTo(14);
//    }];
//
//    [self.persentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.digIcon.mas_right).offset(2);
//        make.bottom.mas_equalTo(self.digIcon.mas_bottom).offset(2);
//        make.height.mas_equalTo(17);
//    }];
//
//    [self.spLine mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.persentLabel.mas_right).offset(6);
//        make.centerY.mas_equalTo(self.persentLabel);
//        make.width.mas_equalTo(1);
//        make.height.mas_equalTo(12);
//    }];
    
//    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(self.spLine.mas_right).offset(5);
//        make.centerY.mas_equalTo(self.persentLabel);
//        make.height.mas_equalTo(17);
//    }];
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
           make.left.mas_equalTo(self).offset(leftMargin);
           make.centerY.mas_equalTo(self);
           make.height.mas_equalTo(17);
       }];
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

+ (CGFloat)getTagViewWidth:(FHNeighborhoodDetailCommentTagModel *)model {
//    CGFloat width = leftMargin + rightMargin + 14 + 2 + 12;
//    CGRect persentRect = [model.persent boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 17) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont themeFontMedium:12],NSFontAttributeName, nil] context:nil];
    CGFloat width = leftMargin + rightMargin + 2 ;
    CGRect contentRect = [model.content boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 17) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIFont themeFontRegular:12],NSFontAttributeName, nil] context:nil];
//    CGFloat persentWidth = ceil(persentRect.size.width);
    CGFloat contentWidth = ceil(contentRect.size.width);
//    width += persentWidth;
    width += contentWidth;

    return width;
}

@end

@implementation FHNeighborhoodDetailCommentTagModel

@end
