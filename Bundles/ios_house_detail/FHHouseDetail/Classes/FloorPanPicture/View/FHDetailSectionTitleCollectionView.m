//
//  FHPictureListTitleCollectionView.m
//  Pods
//
//  Created by bytedance on 2020/5/21.
//

#import "FHDetailSectionTitleCollectionView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>

@implementation FHDetailSectionTitleCollectionView

- (void)prepareForReuse {
    [super prepareForReuse];
    self.moreActionBlock = nil;
    self.arrowsImg.hidden = YES;
    self.subTitleLabel.hidden = YES;
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.centerY.mas_equalTo(self).offset(2);
    }];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.titleLabel.font = [UIFont themeFontRegular:14];
        self.titleLabel.textColor = [UIColor colorWithHexStr:@"#6d7278"];
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(15);
            make.centerY.mas_equalTo(self).offset(2);
        }];
        
        self.arrowsImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-4"]];
        self.arrowsImg.hidden = YES;
        [self addSubview:self.arrowsImg];
        [self.arrowsImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-12);
            make.height.width.mas_equalTo(20);
            make.centerY.mas_equalTo(self.titleLabel);
        }];
        
        self.subTitleLabel = [[UILabel alloc] init];
        self.subTitleLabel.font = [UIFont themeFontRegular:14];
        self.subTitleLabel.textColor = [UIColor themeGray2];
        self.subTitleLabel.hidden = YES;
        [self addSubview:self.subTitleLabel];
        [self.subTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.titleLabel.mas_right).mas_offset(6);
            make.centerY.mas_equalTo(self.titleLabel);
        }];
        
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(moreAction:)]];
    }
    return self;
}

- (void)setSubTitleWithTitle:(NSString *)subTitle{ //一定要先设置Label的内容再设置
    if (subTitle.length > 0) {
        self.subTitleLabel.text = [NSString stringWithFormat:@"| %@",subTitle];
        self.subTitleLabel.hidden = NO;
    } else {
        self.subTitleLabel.hidden = YES;
    }
}

- (void)setupNeighborhoodDetailStyle {
    self.titleLabel.font = [UIFont themeFontSemibold:16];
    self.titleLabel.textColor = [UIColor themeGray1];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.centerY.mas_equalTo(self);
    }];
}

- (void)moreAction:(UITapGestureRecognizer *)tapGesture {
    if (self.moreActionBlock) {
        self.moreActionBlock();
    }
}

@end
