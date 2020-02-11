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
#import "TTStringHelper.h"
#import "TTAccountManager.h"

#define topMargin 10
#define bottomMargin 10

#define topMarginList 22.5
#define bottomMarginList 22.5

@interface FHNeighbourhoodQuestionCell ()

@property(nonatomic ,strong) UIView *bgView;
@property(nonatomic ,strong) UIImageView *questionIcon;
@property(nonatomic ,strong) UIImageView *essenceIcon;
@property(nonatomic ,strong) UIImageView *answerIcon;
@property(nonatomic ,strong) TTUGCAttributedLabel *questionLabel;
@property(nonatomic ,strong) TTUGCAttributedLabel *answerLabel;
@property(nonatomic ,strong) UIButton *answerBtn;
@property(nonatomic ,strong) UILabel *descLabel;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;
@property(nonatomic ,assign) BOOL isList;

@end

@implementation FHNeighbourhoodQuestionCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.isList = YES;
    [self initUIs];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isList = YES;
        [self initUIs];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier isList:(BOOL)isList {
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        self.isList = isList;
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
    self.bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor whiteColor];
    [self.contentView addSubview:_bgView];
    
    self.essenceIcon = [[UIImageView alloc] init];
    _essenceIcon.image = [UIImage imageNamed:@"fh_ugc_wenda_essence"];
    _essenceIcon.hidden = YES;
    [self.bgView addSubview:_essenceIcon];
    
    self.questionIcon = [[UIImageView alloc] init];
    _questionIcon.image = [UIImage imageNamed:@"detail_question_ask"];
    [self.bgView addSubview:_questionIcon];
    
    self.answerIcon = [[UIImageView alloc] init];
    _answerIcon.image = [UIImage imageNamed:@"detail_question_answer"];
    [self.bgView addSubview:_answerIcon];
    
    self.questionLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _questionLabel.textColor = [UIColor themeGray1];
    _questionLabel.font = [UIFont themeFontRegular:16];
    _questionLabel.numberOfLines = 0;
    [self.bgView addSubview:_questionLabel];
    
    self.answerLabel = [[TTUGCAttributedLabel alloc] initWithFrame:CGRectZero];
    _answerLabel.textColor = [UIColor themeGray3];
    _answerLabel.font = [UIFont themeFontRegular:14];
    [self.bgView addSubview:_answerLabel];
    
    self.answerBtn = [[UIButton alloc] init];
    if(self.isList){
        _answerBtn.imageView.contentMode = UIViewContentModeCenter;
        [_answerBtn setImage:[UIImage imageNamed:@"detail_questiom_ask"] forState:UIControlStateNormal];
        [_answerBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
        [_answerBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
        [_answerBtn setTitle:@"去回答" forState:UIControlStateNormal];
        _answerBtn.backgroundColor = [UIColor themeGray7];
        _answerBtn.layer.masksToBounds = YES;
        _answerBtn.layer.cornerRadius = 20;
    }else{
        [_answerBtn setTitle:@"暂无回答，快去回答吧" forState:UIControlStateNormal];
    }
    [_answerBtn addTarget:self action:@selector(gotoWriteAnswer) forControlEvents:UIControlEventTouchUpInside];
    [_answerBtn setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
    _answerBtn.titleLabel.font = [UIFont themeFontRegular:14];
    _answerBtn.hidden = YES;
    [self.bgView addSubview:_answerBtn];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray3]];
    [_descLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_descLabel setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.bgView addSubview:_descLabel];
    
    if(self.isList){
        self.contentView.backgroundColor = [UIColor themeGray7];
        self.bgView.layer.masksToBounds = YES;
        self.bgView.layer.cornerRadius = 10;
        self.answerLabel.numberOfLines = 3;
    }
}

- (void)initConstraints {
    if(self.isList){
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(7.5);
            make.bottom.mas_equalTo(self.contentView).offset(-7.5);
            make.left.mas_equalTo(self.contentView).offset(15);
            make.right.mas_equalTo(self.contentView).offset(-15);
        }];
        
        [self.questionIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgView).offset(17);
            make.left.mas_equalTo(self.bgView).offset(16);
            make.width.height.mas_equalTo(18);
        }];
        
        [self.answerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.answerIcon.mas_top).offset(-1);
            make.left.mas_equalTo(self.answerIcon.mas_right).offset(10);
            make.right.mas_equalTo(self.bgView).offset(-16);
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.answerLabel.mas_bottom).offset(10);
            make.right.mas_equalTo(self.bgView).offset(-16);
            make.height.mas_equalTo(20);
        }];
        
        [self.answerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.questionLabel.mas_bottom).offset(30);
            make.left.mas_equalTo(self.bgView).offset(16);
            make.right.mas_equalTo(self.bgView).offset(-16);
            make.height.mas_equalTo(40);
        }];
    }else{
        [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(0);
            make.bottom.mas_equalTo(self.contentView).offset(0);
            make.left.mas_equalTo(self.contentView).offset(0);
            make.right.mas_equalTo(self.contentView).offset(0);
        }];
        
        [self.questionIcon mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.bgView).offset(12);
            make.left.mas_equalTo(self.bgView).offset(16);
            make.width.height.mas_equalTo(18);
        }];
        
        [self.answerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.answerIcon.mas_top).offset(-1);
            make.left.mas_equalTo(self.answerIcon.mas_right).offset(10);
            make.right.mas_equalTo(self.descLabel.mas_left).offset(-16);
            make.height.mas_equalTo(20);
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.answerIcon.mas_top).offset(-1);
            make.right.mas_equalTo(self.bgView).offset(-16);
            make.height.mas_equalTo(20);
        }];
        
        [self.answerBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.answerIcon.mas_top).offset(-1);
            make.left.mas_equalTo(self.answerIcon.mas_right).offset(10);
            make.height.mas_equalTo(20);
        }];
    }
    
    [self.questionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.questionIcon.mas_top).offset(-2);
        make.left.mas_equalTo(self.questionIcon.mas_right).offset(10);
        make.right.mas_equalTo(self.bgView).offset(-16);
    }];
    
    [self.answerIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.questionLabel.mas_bottom).offset(11);
        make.left.mas_equalTo(self.bgView).offset(16);
        make.width.height.mas_equalTo(18);
    }];
    
    [self.essenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.right.mas_equalTo(self.bgView);
        make.width.height.mas_equalTo(66);
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
    //隐藏掉通用的精华图标
    self.decorationImageView.hidden = YES;
    
    if(cellModel.isStick && (cellModel.stickStyle == FHFeedContentStickStyleGood || cellModel.stickStyle == FHFeedContentStickStyleTopAndGood) && cellModel.isInNeighbourhoodQAList){
        self.essenceIcon.hidden = NO;
    }else{
        self.essenceIcon.hidden = YES;
    }
    
    //问题
    [self.questionLabel setText:cellModel.questionAStr];
    //回答
    if(isEmptyString(cellModel.answerStr)){
        self.answerLabel.hidden = YES;
        self.descLabel.hidden = YES;
        self.answerBtn.hidden = NO;
        if(self.isList){
            self.answerIcon.hidden = YES;
        }else{
            self.answerIcon.hidden = NO;
        }
    }else{
        self.answerLabel.hidden = NO;
        self.answerIcon.hidden = NO;
        self.descLabel.hidden = NO;
        self.answerBtn.hidden = YES;
    }
    
    [self.answerLabel setText:cellModel.answerAStr];
    self.descLabel.text = @"32个回答";
}

+ (CGFloat)heightForData:(id)data {
    if([data isKindOfClass:[FHFeedUGCCellModel class]]){
        FHFeedUGCCellModel *cellModel = (FHFeedUGCCellModel *)data;
        if(cellModel.isInNeighbourhoodQAList){
            CGFloat height = topMarginList + cellModel.questionHeight + bottomMarginList + 30;
            
            if(cellModel.answerHeight > 0){
                height += (cellModel.answerHeight + 10);
            }else{
                height += 65;
            }
            
            return height;
        }else{
            CGFloat height = topMargin + cellModel.questionHeight + bottomMargin;
            
            if(cellModel.answerHeight > 0){
                height += (cellModel.answerHeight + 10);
            }else{
                //显示去回答
                height += 30;
            }
            
            return height;
        }
    }
    return 44;
}

//写回答
- (void)gotoWriteAnswer {
    if(!isEmptyString(self.cellModel.writeAnswerSchema)){
        NSURL *url = [TTStringHelper URLWithURLString:self.cellModel.writeAnswerSchema];
        [[TTRoute sharedRoute] openURLByViewController:url userInfo:nil];
    }
    
    if ([TTAccountManager isLogin]) {
        [self gotoPostWDAnswer];
    } else {
        [self gotoLogin];
    }
}

- (void)gotoPostWDAnswer {
    NSString *routeUrl = @"sslocal://ugc_post_wd_answer";
    NSURL *openUrl = [NSURL URLWithString:routeUrl];
    NSMutableDictionary *dict = @{}.mutableCopy;
    if (self.cellModel.groupId.length > 0) {
        dict[@"qid"] = self.cellModel.groupId;
    }

//    NSMutableDictionary *tracerDict = @{}.mutableCopy;
//    tracerDict[@"origin_from"] = self.goDetailDict[@"enter_from"];
//    tracerDict[@"enter_from"] = @"question";
//    tracerDict[@"enter_type"] = @"click";
//    tracerDict[@"log_pb"] = self.goDetailDict[@"log_pb"];
//    dict[@"tracer"] = tracerDict;
    dict[@"title"] = @"写回答";
//    if (self.viewModel.post_gdExtJson && [self.viewModel.post_gdExtJson isKindOfClass:[NSDictionary class]]) {
//        dict[@"gd_ext_json"] = self.viewModel.post_gdExtJson;
//    }
    
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByPresentViewController:openUrl userInfo:userInfo];
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
//    NSString *page_type = cellModel.tracerDict[@"page_type"] ?: @"be_null";
//    [params setObject:page_type forKey:@"enter_from"];
    [params setObject:@"click_publisher" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    params[@"from_ugc"] = @(YES);
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.6 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [wSelf gotoPostWDAnswer];
                });
            }
        }
    }];
}

@end
