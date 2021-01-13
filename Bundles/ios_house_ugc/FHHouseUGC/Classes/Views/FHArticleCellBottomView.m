//
//  FHUGCCellBottomView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHArticleCellBottomView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "UIButton+TTAdditions.h"
#import "UIViewAdditions.h"
#import "TTAccountManager.h"
#import "FHUGCFeedDetailJumpManager.h"
#import "FHUGCMoreOperationManager.h"

@interface FHArticleCellBottomView ()

@property(nonatomic ,strong) UILabel *position;
@property(nonatomic ,strong) UILabel *descLabel;
@property(nonatomic ,strong) UIButton *moreBtn;
@property(nonatomic ,strong) UIButton *answerBtn;
@property(nonatomic ,strong) UIView *positionView;
@property(nonatomic ,strong) UIView *bottomSepView;
@property(assign ,nonatomic) BOOL showPositionView;
@property(nonatomic ,strong) FHUGCMoreOperationManager *moreOperationManager;
@property(nonatomic ,strong) FHFeedUGCCellModel *cellModel;

@end

@implementation FHArticleCellBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _moreOperationManager = [[FHUGCMoreOperationManager alloc] init];
        _showPositionView = NO;
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.positionView = [[UIView alloc] init];
    _positionView.backgroundColor = [UIColor themeOrange2];
    _positionView.layer.masksToBounds= YES;
    _positionView.layer.cornerRadius = 4;
    _positionView.userInteractionEnabled = YES;
    _positionView.hidden = YES;
    [self addSubview:_positionView];
    
    UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(goToCommunityDetail:)];
    [self.positionView addGestureRecognizer:tap];
    
    self.position = [self LabelWithFont:[UIFont themeFontRegular:13] textColor:[UIColor themeOrange1]];
    _position.layer.masksToBounds = YES;
    _position.backgroundColor = [UIColor themeOrange2];
    [_position sizeToFit];
    [_position setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_position setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_positionView addSubview:_position];
    
    self.descLabel = [self LabelWithFont:[UIFont themeFontRegular:12] textColor:[UIColor themeGray4]];
    _descLabel.layer.masksToBounds = YES;
    _descLabel.backgroundColor = [UIColor whiteColor];
    [self addSubview:_descLabel];
    
    self.moreBtn = [[UIButton alloc] init];
    [_moreBtn setImage:[UIImage imageNamed:@"fh_ugc_icon_more"] forState:UIControlStateNormal];
    [_moreBtn addTarget:self action:@selector(moreOperation) forControlEvents:UIControlEventTouchUpInside];
    _moreBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self addSubview:_moreBtn];
    
    self.answerBtn = [[UIButton alloc] init];
    [_answerBtn setBackgroundColor:[UIColor themeOrange4]];
    [_answerBtn setTitle:@"去回答" forState:UIControlStateNormal];
    _answerBtn.titleLabel.font = [UIFont themeFontRegular:14];
    _answerBtn.layer.cornerRadius = 13;
    _answerBtn.layer.masksToBounds = YES;
    [_answerBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_answerBtn addTarget:self action:@selector(writeQuestion:) forControlEvents:UIControlEventTouchUpInside];
    _answerBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self addSubview:_answerBtn];
    self.answerBtn.hidden = YES;
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self addSubview:_bottomSepView];
}

- (void)initConstraints {
    self.positionView.top = 0;
    self.positionView.left = 20;
    self.positionView.width = 0;
    self.positionView.height = 24;
    
    self.descLabel.left = 20;
    self.descLabel.centerY = self.positionView.centerY;
    self.descLabel.height = 24;
    self.descLabel.width = [UIScreen mainScreen].bounds.size.width - 40 - 20 - 20;
    
    self.moreBtn.left = self.descLabel.right + 20;
    self.moreBtn.top = 2;
    self.moreBtn.height = 20;
    self.moreBtn.width = 20;
    
    self.answerBtn.left = self.descLabel.right + 20;
    self.answerBtn.centerY = self.descLabel.centerY;
    self.answerBtn.height = 26;
    self.answerBtn.width = 75;
    

    self.bottomSepView.left = 20;
    self.bottomSepView.top = self.positionView.bottom + 10;
    self.bottomSepView.height = 1;
    self.bottomSepView.width = [UIScreen mainScreen].bounds.size.width - 40;
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)refreshWithData:(FHFeedUGCCellModel *)cellModel {
    self.cellModel = cellModel;
    
    self.moreBtn.hidden = cellModel.hiddenMore;
    
    self.bottomSepView.left = cellModel.bottomLineLeftMargin;
    self.bottomSepView.top = self.height - cellModel.bottomLineHeight;
    self.bottomSepView.height = cellModel.bottomLineHeight;
    self.bottomSepView.width = [UIScreen mainScreen].bounds.size.width - cellModel.bottomLineLeftMargin - cellModel.bottomLineRightMargin;
    
    self.descLabel.attributedText = cellModel.desc;
    
    BOOL showCommunity = cellModel.showCommunity && !isEmptyString(cellModel.community.name);
    self.position.text = cellModel.community.name;
    [self showPositionView:showCommunity];
    
    if(cellModel.cellSubType == FHUGCFeedListCellSubTypeQuestion){
        [self updateIsQuestion];
    }
}

- (void)showPositionView:(BOOL)isShow {
    self.positionView.hidden = !isShow;
    self.showPositionView = isShow;
    if(isShow){
        self.position.top = 3;
        self.position.height = 18;
        self.position.left = 6;
        [self.position sizeToFit];
        
        CGFloat labelWidth = self.position.width;
        self.positionView.left = 20;
        self.positionView.width = labelWidth + 12;
        self.positionView.height = 24;
        
        self.descLabel.left = self.positionView.right + 6;
        self.descLabel.centerY = self.positionView.centerY;
        self.descLabel.height = 24;
        self.descLabel.width = [UIScreen mainScreen].bounds.size.width - 40 - 20 - 20 - self.positionView.width - 6;
    }else{
        self.descLabel.left = 20;
        self.descLabel.centerY = self.positionView.centerY;
        self.descLabel.width = [UIScreen mainScreen].bounds.size.width - 40 - 20 - 20;
    }
}

- (void)writeQuestion:(UIButton *)btn {
    if ([TTAccountManager isLogin]) {
        [self questionAction];
    } else {
        [self gotoLogin];
    }
}

- (void)gotoLogin {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:self.cellModel.tracerDic[@"page_type"]?:@"be_null" forKey:@"enter_from"];
    [params setObject:@"want_answer" forKey:@"enter_type"];
    // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
    [params setObject:@(YES) forKey:@"need_pop_vc"];
    __weak typeof(self) wSelf = self;
    [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
        if (type == TTAccountAlertCompletionEventTypeDone) {
            // 登录成功
            if ([TTAccountManager isLogin]) {
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                   [wSelf questionAction];
                });
            }
        }
    }];
}

- (void)questionAction {
    NSURL *openUrl = [NSURL URLWithString:[NSString stringWithFormat:@"sslocal://wenda_post"]];
    NSMutableDictionary *info = @{}.mutableCopy;
    info[@"title"] = @"回答";
    info[@"qid"] = self.cellModel.groupId;
    NSMutableDictionary *tracer = @{}.mutableCopy;
    tracer[@"enter_from"] = self.cellModel.tracerDic[@"page_type"];
    tracer[@"enter_type"] = @"click";
    info[@"tracer"] = tracer;
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:info];
    [[TTRoute sharedRoute] openURLByPresentViewController:openUrl userInfo:userInfo];
}

- (void)moreOperation {
    [self.moreOperationManager showOperationAtView:self.moreBtn withCellModel:self.cellModel];
}

- (void)updateIsQuestion {
    if (![self.cellModel.desc.string isEqualToString:@"0个回答"]) {
        self.descLabel.attributedText = self.cellModel.desc;
    }else {
        self.descLabel.attributedText = [[NSAttributedString alloc] initWithString:@""];;
    }
    self.moreBtn.hidden = YES;
    self.answerBtn.hidden = NO;
    if (_showPositionView) {
        self.descLabel.width = [UIScreen mainScreen].bounds.size.width - 40 - 75 - 20 - self.positionView.width - 6;
    }else {
        self.descLabel.width = [UIScreen mainScreen].bounds.size.width - 40 - 75 - 20;
    }
     self.answerBtn.left = self.descLabel.right + 20;
    self.answerBtn.centerY = self.descLabel.centerY;
}

//进入圈子详情
- (void)goToCommunityDetail:(UITapGestureRecognizer *)sender {
    [FHUGCFeedDetailJumpManager goToCommunityDetail:self.cellModel];
}

@end
