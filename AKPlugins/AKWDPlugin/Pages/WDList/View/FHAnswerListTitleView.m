//
//  FHAnswerListTitleView.m
//  AKWDPlugin
//
//  Created by bytedance on 2020/9/16.
//

#import "FHAnswerListTitleView.h"
#import <Masonry/Masonry.h>
#import <UIColor+Theme.h>
#import <UIFont+House.h>
#import <WDQuestionEntity.h>

@interface FHAnswerListTitleView ()
@property(nonatomic,strong) UILabel *titleLabel;

@end

@implementation FHAnswerListTitleView

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont themeFontMedium:16];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.numberOfLines = 1;
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_titleLabel];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
    }
    return self;
}

-(void)updateWithViewModel:(WDListViewModel *)viewModel {
    self.titleLabel.text = viewModel.questionEntity.title;
}

-(CGSize)intrinsicContentSize {
    return self.size;
}

@end
