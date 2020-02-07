//
//  FHNeighbourhoodQuestionCell.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2020/2/7.
//

#import "FHNeighbourhoodQuestionCell.h"
#import "FHArticleCellBottomView.h"
#import "FHUGCCellHelper.h"
#import "TTBaseMacro.h"

#define topMargin 10
#define bottomMargin 10

@interface FHNeighbourhoodQuestionCell ()

@property(nonatomic ,strong) UIImageView *questionIcon;
@property(nonatomic ,strong) UIImageView *answerIcon;
@property(nonatomic ,strong) TTUGCAttributedLabel *questionLabel;
@property(nonatomic ,strong) TTUGCAttributedLabel *answerLabel;
@property(nonatomic ,strong) UILabel *descLabel;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHNeighbourhoodQuestionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    [self initUIs];
}

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initUIs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)initUIs {
    [self initViews];
    [self initConstraints];
}

- (void)initViews {
    self.questionIcon = [[UIImageView alloc] init];
    _questionIcon.image = [UIImage imageNamed:@"detail_question_ask"];
    [self.contentView addSubview:_questionIcon];
    
    self.answerIcon = [[UIImageView alloc] init];
    _answerIcon.image = [UIImage imageNamed:@"detail_question_answer"];
    [self.contentView addSubview:_answerIcon];
    
    self.questionLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _questionLabel.textColor = [UIColor themeGray1];
    _questionLabel.font = [UIFont themeFontRegular:16];
    _questionLabel.numberOfLines = 0;
    [self.contentView addSubview:_questionLabel];
    
    self.answerLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _answerLabel.textColor = [UIColor themeGray3];
    _answerLabel.font = [UIFont themeFontRegular:14];
    [self.contentView addSubview:_answerLabel];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    [_descLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_descLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.contentView addSubview:_descLabel];
    
//    self.bottomView = [[FHArticleCellBottomView alloc] initWithFrame:CGRectZero];
//    __weak typeof(self) wself = self;
//    _bottomView.deleteCellBlock = ^{
//        [wself deleteCell];
//    };
//    [_bottomView.guideView.closeBtn addTarget:self action:@selector(closeGuideView) forControlEvents:UIControlEventTouchUpInside];
//    [self.contentView addSubview:_bottomView];
//
//    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
//    [self.bottomView.positionView addGestureRecognizer:tap];
}

- (void)initConstraints {
    [self.questionIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(12);
        make.left.mas_equalTo(self.contentView).offset(16);
        make.width.height.mas_equalTo(18);
    }];
    
    [self.questionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.questionIcon.mas_top).offset(-2);
        make.left.mas_equalTo(self.questionIcon.mas_right).offset(10);
        make.right.mas_equalTo(self.contentView).offset(-20);
    }];
    
    [self.answerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.questionLabel.mas_bottom).offset(11);
        make.left.mas_equalTo(self.contentView).offset(16);
        make.width.height.mas_equalTo(18);
    }];
    
    [self.answerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.answerIcon.mas_top).offset(-1);
        make.left.mas_equalTo(self.answerIcon.mas_right).offset(10);
        make.right.mas_equalTo(self.descLabel.mas_left).offset(-20);
        make.height.mas_equalTo(20);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.answerIcon.mas_top).offset(-1);
        make.right.mas_equalTo(self.contentView).offset(-20);
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
    [self.questionLabel setText:cellModel.questionAStr];
    //回答
    if(isEmptyString(cellModel.answerStr)){
        self.answerLabel.hidden = YES;
    }else{
        self.answerLabel.hidden = NO;
        [self.answerLabel setText:cellModel.answerAStr];
    }
    
    self.descLabel.text = @"32个回答";
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        CGFloat height = topMargin + cellModel.questionHeight + bottomMargin;

        if(cellModel.answerHeight > 0){
            height += (cellModel.answerHeight + 10);
        }

        return height;
    }
    return 44;
}

//- (void)showGuideView {
//    if(_cellModel.isInsertGuideCell){
//        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(bottomViewHeight + guideViewHeight);
//        }];
//    }else{
//        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.height.mas_equalTo(bottomViewHeight);
//        }];
//    }
//}
//
//- (void)closeGuideView {
//    self.cellModel.isInsertGuideCell = NO;
//    [self.cellModel.tableView beginUpdates];
//
//    [self showGuideView];
//    self.bottomView.cellModel = self.cellModel;
//
//    [self setNeedsUpdateConstraints];
//
//    [self.cellModel.tableView endUpdates];
//
//    if(self.delegate && [self.delegate respondsToSelector:@selector(closeFeedGuide:)]){
//        [self.delegate closeFeedGuide:self.cellModel];
//    }
//}
//
//- (void)deleteCell {
//    if(self.delegate && [self.delegate respondsToSelector:@selector(deleteCell:)]){
//        [self.delegate deleteCell:self.cellModel];
//    }
//}
//
////进入圈子详情
//- (void)goToCommunityDetail:(UITapGestureRecognizer *)sender {
//    if(self.delegate && [self.delegate respondsToSelector:@selector(goToCommunityDetail:)]){
//        [self.delegate goToCommunityDetail:self.cellModel];
//    }
//}

@end
