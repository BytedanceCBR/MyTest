//
//  FHNeighborhoodDetailQuestionCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHNeighborhoodDetailQuestionCell.h"
#import "FHUGCCellHelper.h"
#import "TTBaseMacro.h"
#import "TTStringHelper.h"
#import "TTAccountManager.h"

@interface FHNeighborhoodDetailQuestionCell ()

@property(nonatomic ,strong) UIView *bgView;
@property(nonatomic ,strong) UIImageView *questionIcon;
@property(nonatomic ,strong) TTUGCAttributedLabel *questionLabel;
@property(nonatomic ,strong) UILabel *descLabel;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHNeighborhoodDetailQuestionCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initUIs];
    }
    return self;
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_bgView];
    
    self.questionIcon = [[UIImageView alloc] init];
    _questionIcon.image = [UIImage imageNamed:@"detail_question_ask"];
    [self.bgView addSubview:_questionIcon];
    
    self.questionLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _questionLabel.textColor = [UIColor themeGray1];
    _questionLabel.font = [UIFont themeFontRegular:14];
    _questionLabel.numberOfLines = 1;
    [self.bgView addSubview:_questionLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    [_descLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_descLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.bgView addSubview:_descLabel];
    
    self.contentView.backgroundColor = [UIColor themeGray7];
    self.bgView.layer.masksToBounds = YES;
}

- (void)initConstraints {
    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.contentView);
    }];
    
    [self.questionIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.left.mas_equalTo(self.bgView).offset(16);
        make.width.height.mas_equalTo(18);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.right.mas_equalTo(self.bgView).offset(-16);
        make.height.mas_equalTo(20);
    }];
    
    [self.questionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.bgView);
        make.left.mas_equalTo(self.questionIcon.mas_right).offset(10);
        make.right.mas_equalTo(self.descLabel.mas_left).offset(-16);
        make.height.mas_equalTo(20);
    }];
}

-(UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(id)data {
    if (![data isKindOfClass:[FHFeedUGCCellModel class]]) {
        return;
    }
    self.currentData = data;
    
    FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;

    self.cellModel = cellModel;
    //问题
    [self.questionLabel setText:cellModel.questionStr];
    self.descLabel.text = cellModel.answerCountText;
}

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    return CGSizeMake(width, 30);
}

- (NSAttributedString *)convertDescToAttributeString:(NSString *)desc count:(NSInteger)count {
    if (!isEmptyString(desc)) {
        NSString *countText = [NSString stringWithFormat:@"%li",(long)count];
        NSRange range = [desc rangeOfString:countText];
        if (range.location >= 0 && range.length > 0) {
            NSMutableAttributedString *mutableAttributedString = [[NSMutableAttributedString alloc] initWithString:desc];
            NSMutableDictionary *attributes = @{}.mutableCopy;
            [attributes setValue:[UIColor themeGray1] forKey:NSForegroundColorAttributeName];
            [attributes setValue:[UIFont themeFontMedium:14] forKey:NSFontAttributeName];
            [mutableAttributedString addAttributes:attributes range:range];
            return mutableAttributedString;
        }
    }
    return nil;
}

@end