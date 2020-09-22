//
//  HTSVideoDetailButton.m
//  LiveStreaming
//
//  Created by willorfang on 16/6/30.
//  Copyright © 2016年 Bytedance. All rights reserved.
//

#import "TSVIconLabelButton.h"
#import "Masonry.h"

@interface TSVIconLabelButton ()
@property (nonatomic, strong) UIImageView *iconImageView;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic, strong) NSString *lastLabelString;
@property (nonatomic, assign) CGFloat labelStableWidth;
@end

@implementation TSVIconLabelButton

- (instancetype)initWithImage:(NSString *)imageName label:(NSString *)labelString
{
    self = [self initWithFrame:CGRectZero];
    if (self) {
        self.clipsToBounds = YES;
        [self setContentHuggingPriority:UILayoutPriorityRequired-1 forAxis:UILayoutConstraintAxisHorizontal];
        [self setContentCompressionResistancePriority:UILayoutPriorityRequired-1 forAxis:UILayoutConstraintAxisHorizontal];
        _imageString = imageName;
        self.iconImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
        [self addSubview:self.iconImageView];
        _label = [[UILabel alloc] init];
        _label.text = labelString;
        _label.numberOfLines = 1;
        _label.textColor = [UIColor whiteColor];
        _label.font = [UIFont systemFontOfSize:12];
        _label.textAlignment = NSTextAlignmentCenter;
        _label.layer.shadowOffset = CGSizeZero;
        _label.layer.shadowColor = [UIColor colorWithWhite:0x66/255.0 alpha:0.9].CGColor;
        _label.layer.shadowRadius = 1.0;
        _label.layer.shadowOpacity = 1.0;
        [self addSubview:_label];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self);
        }];
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self);
            make.top.equalTo(self.iconImageView.mas_bottom).offset(-4);
            make.size.mas_equalTo(CGSizeMake(50, 20));
        }];

    }
    return self;
}

- (NSString *)labelString
{
    return self.label.text;
}

- (void)setLabelString:(NSString *)labelString
{
    self.lastLabelString = self.label.text;
    self.label.text = labelString;
}

- (void)setImageString:(NSString *)imageString
{
    _imageString = imageString;
    self.iconImageView.image = [UIImage imageNamed:imageString];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
}

- (UIImageView *)imageView
{
    return _iconImageView;
}

@end
