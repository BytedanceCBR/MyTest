//
//  FHUGCFeedGuideView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/20.
//

#import "FHUGCFeedGuideView.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "FHUserTracker.h"
#import <Masonry.h>
#import <FHHouseBase/UIImage+FIconFont.h>

@interface FHUGCFeedGuideView ()

@property(nonatomic ,strong) UIImageView *arror;
@property(nonatomic ,strong) UIView *contentView;
@property(nonatomic ,strong) UILabel *contentLabel;

@end

@implementation FHUGCFeedGuideView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.backgroundColor = [UIColor whiteColor];
    
    self.arror = [[UIImageView alloc] init];
    _arror.image = ICON_FONT_IMG(12, @"\U0000e67f", [UIColor whiteColor]);//@"fh_ugc_feed_guide_arror_up"
    [self addSubview:_arror];
    
    self.contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor themeGray7];
    [self addSubview:_contentView];
    
    self.contentLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray2]];
    _contentLabel.attributedText = [self generateText];
    [_contentLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisVertical];
    [self.contentView addSubview:_contentLabel];
    
    self.closeBtn = [[UIButton alloc] init];
    [self.closeBtn addTarget:self action:@selector(onCloseGuideClick) forControlEvents:UIControlEventTouchUpInside];
    [_closeBtn setImage:ICON_FONT_IMG(12, @"\U0000e673", [UIColor themeGray3]) forState:UIControlStateNormal];//fh_ugc_feed_guide_close
    [self.contentView addSubview:_closeBtn];
}

- (void)initConstraints {
    [self.arror mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self).offset(40);
        make.width.mas_equalTo(12);
        make.height.mas_equalTo(6);
    }];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.arror.mas_bottom);
        make.left.right.bottom.mas_equalTo(self);
    }];

    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentLabel);
        make.right.mas_equalTo(self.contentView).offset(-6);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(20);
        make.right.mas_equalTo(self.closeBtn.mas_left).offset(-20);
        make.height.mas_equalTo(17);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (NSAttributedString *)generateText {
//    @"点击✌️进入圈子，查看更多新鲜事";
    NSMutableAttributedString *desc = [[NSMutableAttributedString alloc] initWithString:@"点击"];
    
    NSTextAttachment *attachment = [[NSTextAttachment alloc] init];
    attachment.bounds = CGRectMake(0, -3.5, 16, 16);
    attachment.image = [UIImage imageNamed:@"fh_ugc_finger_up"];
    NSAttributedString *attachmentAStr = [NSAttributedString attributedStringWithAttachment:attachment];
    [desc appendAttributedString:attachmentAStr];
    
    NSAttributedString *distanceAStr = [[NSAttributedString alloc] initWithString:@"进入圈子，查看更多新鲜事"];
    [desc appendAttributedString:distanceAStr];
    
    return desc;
}

-(void)onCloseGuideClick{
    NSMutableDictionary *tracerDic = [NSMutableDictionary dictionary];
    tracerDic[@"element_type"] = @"feed_community_guide_notice";
    tracerDic[@"page_type"] = @"nearby_list";
    tracerDic[@"enter_from"] = @"neighborhood_tab";
    tracerDic[@"click_position"] = @"cancel";
    [FHUserTracker writeEvent:@"click_options" params:tracerDic];
}
@end
