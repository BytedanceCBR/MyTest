//
//  FHAnswerDetailTitleView.m
//  AKWDPlugin
//
//  Created by bytedance on 2020/9/15.
//

#import "FHAnswerDetailTitleView.h"
#import <UIColor+Theme.h>
#import <UIFont+House.h>
#import <Masonry/Masonry.h>
#import "WDAnswerEntity.h"
#import <NSString+BTDAdditions.h>

@interface FHAnswerDetailTitleView ()
@property(nonatomic,strong) UILabel *questionTitleLabel;
@property(nonatomic,strong) UILabel *answerCountLabel;
@property(nonatomic,strong) UIImageView *arrowView;
@end

@implementation FHAnswerDetailTitleView


-(instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]) {
        _questionTitleLabel = [[UILabel alloc] init];
        _questionTitleLabel.numberOfLines = 1;
        _questionTitleLabel.textAlignment = NSTextAlignmentLeft;
        _questionTitleLabel.textColor = [UIColor themeBlack];
        _questionTitleLabel.font = [UIFont themeFontRegular:14];
        [self addSubview:_questionTitleLabel];
        
        _answerCountLabel = [[UILabel alloc] init];
        _answerCountLabel.numberOfLines = 1;
        _answerCountLabel.textAlignment = NSTextAlignmentLeft;
        _answerCountLabel.textColor = [UIColor themeBlack];
        _answerCountLabel.font = [UIFont themeFontRegular:12];
        [self addSubview:_answerCountLabel];
        
        _arrowView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"all_card_arrow"]];
        [self addSubview:_arrowView];
        
        [self.questionTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.mas_equalTo(22);
        }];
        [self.answerCountLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self);
            make.top.equalTo(self.questionTitleLabel.mas_bottom);
            make.height.mas_equalTo(18);
        }];
        [self.arrowView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.answerCountLabel);
            make.width.height.mas_equalTo(18);
            make.left.equalTo(self.answerCountLabel.mas_right);
        }];
    }
    return self;
}

-(void)updateWithDetailModel:(WDDetailModel *)detailModel {
    self.questionTitleLabel.text = detailModel.answerEntity.questionTitle;
    NSString *answerCountText = detailModel.allAnswerText;
    answerCountText = [answerCountText stringByReplacingOccurrencesOfString:@"全部" withString:@""];
    self.answerCountLabel.text = answerCountText;
    CGFloat width = [self.answerCountLabel.text btd_sizeWithFont:[UIFont themeFontRegular:12] width:self.size.width].width;
    [self.answerCountLabel mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(width);
    }];
}

-(void)setIsShow:(BOOL)isShow {
    _isShow = isShow;
    self.hidden = !isShow;
}

- (CGSize)intrinsicContentSize {
    return self.size;
}


@end
