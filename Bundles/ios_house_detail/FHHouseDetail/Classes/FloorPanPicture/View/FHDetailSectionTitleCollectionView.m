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
    self.tagViews.hidden = YES;
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
            make.top.mas_equalTo(self).offset(20);
        }];
        
        self.arrowsImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"arrowicon-feed-4"]];
        self.arrowsImg.contentMode = UIViewContentModeCenter;
        self.arrowsImg.hidden = YES;
        [self addSubview:self.arrowsImg];
        [self.arrowsImg mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.mas_equalTo(self).offset(-16);
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
        
        [self.tagViews mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self);
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

-(UIView *)getTagViewWithName:(NSInteger)idx{
    UIView *tagView = [[UIView alloc ]init];
    UILabel *tagLab = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, 48, 17)];
    tagLab.font = [UIFont themeFontRegular:12];
    tagLab.textColor = [UIColor colorWithHexString:@"#aeadad"];
    tagLab.text = [[self getTagName] objectAtIndex:idx];
    UIImageView *imgView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[[self getTagViewName] objectAtIndex:idx]]];
    imgView.frame = CGRectMake(0,0,16,16);
    [tagView addSubview:tagLab];
    [tagView addSubview:imgView];
    [self addSubview:tagView];
    [self.tagViews addSubview:tagView];
    return tagView;
}

- (UIView *)tagViews{
    if(!_tagViews){
        UIView *tagViews = [[UIView alloc]init];
        [self addSubview: tagViews];
        _tagViews = tagViews;
        _tagViews.hidden = YES;
    }
    return _tagViews;
}

-(NSArray *)getTagName{
    return @[@"免费带看",@"专属服务",@"详情解读",@"户型分析"];
}

-(NSArray *)getTagViewName{
    return @[@"releatortag1",@"releatortag2",@"releatortag3",@"releatortag4"];
}

- (void)setSubTagView{
    if(_tagViews && _tagViews.subviews.count){
        self.tagViews.hidden = NO;
    }else{
        CGFloat width = (self.bounds.size.width - 32 - 16)/4;
        [[self getTagName] enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [[self getTagViewWithName:idx] mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.mas_equalTo(self).offset(width*idx + 16);
                make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(6);
            }];
        }];
        self.tagViews.hidden = NO;
    }
}


- (void)setupNeighborhoodDetailStyle {
    self.titleLabel.font = [UIFont themeFontSemibold:16];
    self.titleLabel.textColor = [UIColor themeGray1];
    [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(12);
        make.centerY.mas_equalTo(self);
    }];
    self.subTitleLabel.textColor = [UIColor themeGray1];
    self.arrowsImg.image = [UIImage imageNamed:@"neighborhood_detail_v3_arrow_icon"];
}

- (void)moreAction:(UITapGestureRecognizer *)tapGesture {
    if (self.moreActionBlock) {
        self.moreActionBlock();
    }
}

@end
