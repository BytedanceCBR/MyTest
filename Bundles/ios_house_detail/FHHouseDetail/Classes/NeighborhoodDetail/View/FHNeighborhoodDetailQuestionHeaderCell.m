//
//  FHNeighborhoodDetailQuestionHeaderCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/13.
//

#import "FHNeighborhoodDetailQuestionHeaderCell.h"
#import <TTRoute.h>
#import "TTBaseMacro.h"
#import "FHUserTracker.h"
#import "UIDevice+BTDAdditions.h"
#import "FHCornerView.h"
#import "TTAccountManager.h"
#import "TTStringHelper.h"

@interface FHNeighborhoodDetailQuestionHeaderCell ()

@property (nonatomic, strong) UIView *topLine;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *rightBtn;
@property (nonatomic, strong) FHCornerCustomLabel *cornerLabel;
@property (nonatomic, strong) UILabel *emptyContentLabel;
@property (nonatomic, strong) UIButton *questionWriteBtn;

@end

@implementation FHNeighborhoodDetailQuestionHeaderCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNeighborhoodDetailQuestionHeaderModel class]]) {
        FHNeighborhoodDetailQuestionHeaderModel *model = (FHNeighborhoodDetailQuestionHeaderModel *)data;
        CGFloat height = model.topMargin + 25;
        
        if(model.isEmpty){
            height += 44;
        }else{
            height += 2;
        }
        
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailQuestionHeaderModel class]]) {
        return;
    }
    self.currentData = data;
    FHNeighborhoodDetailQuestionHeaderModel *model = (FHNeighborhoodDetailQuestionHeaderModel *)data;
    if (model) {
        self.titleLabel.text = model.title;
        self.topLine.hidden = model.hiddenTopLine;
        [self.titleLabel mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(model.topMargin);
        }];
        
        self.emptyContentLabel.hidden = !model.isEmpty;
        self.cornerLabel.hidden = !model.isEmpty;
        self.questionWriteBtn.hidden = !model.isEmpty;
        self.rightBtn.hidden = !(model.totalCount > model.count);
        
        if(model.isEmpty){
            self.emptyContentLabel.text = model.questionWriteEmptyContent;
            if(model.questionWriteTitle.length > 0){
                [self.questionWriteBtn setTitle:model.questionWriteTitle forState:UIControlStateNormal];
            }
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    self.topLine = [[UIView alloc] init];
    _topLine.backgroundColor = [UIColor themeGray6];
    [self.contentView addSubview:_topLine];
    
    self.titleLabel = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    _titleLabel.textColor = [UIColor themeGray1];
    _titleLabel.font = [UIFont themeFontSemibold:16];
    [self.contentView addSubview:_titleLabel];
    
    self.rightBtn = [[UIButton alloc] init];
    _rightBtn.hidden = YES;
    [_rightBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_rightBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    _rightBtn.imageView.contentMode = UIViewContentModeCenter;
    [_rightBtn setImage:[UIImage imageNamed:@"neighborhood_detail_comment_right_arror"] forState:UIControlStateNormal];
    [_rightBtn setImage:[UIImage imageNamed:@"neighborhood_detail_comment_right_arror"] forState:UIControlStateHighlighted];
    [_rightBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    _rightBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_rightBtn setTitle:@"查看全部" forState:UIControlStateNormal];
    [_rightBtn sizeToFit];
    [_rightBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, - _rightBtn.imageView.image.size.width, 0, _rightBtn.imageView.image.size.width)];
    [_rightBtn setImageEdgeInsets:UIEdgeInsetsMake(0, _rightBtn.titleLabel.bounds.size.width, 0, -_rightBtn.titleLabel.bounds.size.width)];
    [_rightBtn addTarget:self action:@selector(gotoQuestionList) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_rightBtn];
    
    self.cornerLabel = [[FHCornerCustomLabel alloc] init];
    _cornerLabel.hidden = YES;
    _cornerLabel.cornerRadius = 4;
    _cornerLabel.corners = UIRectCornerTopRight | UIRectCornerBottomRight | UIRectCornerBottomLeft;
    _cornerLabel.text = @"问大家";
    _cornerLabel.backgroundColor = [UIColor themeOrange4];
    _cornerLabel.font = [UIFont themeFontMedium:12];
    _cornerLabel.textColor = [UIColor whiteColor];
    _cornerLabel.textAlignment = NSTextAlignmentCenter;
    [self.contentView addSubview:_cornerLabel];
    
    self.emptyContentLabel = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    _emptyContentLabel.hidden = YES;
    _emptyContentLabel.textColor = [UIColor themeGray1];
    _emptyContentLabel.font = [UIFont themeFontRegular:14];
    [self.contentView addSubview:_emptyContentLabel];
    
    self.questionWriteBtn = [[UIButton alloc] init];
    _questionWriteBtn.hidden = YES;
    [_questionWriteBtn setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [_questionWriteBtn setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    _questionWriteBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 9, 0, 9);
    _questionWriteBtn.layer.masksToBounds = YES;
    _questionWriteBtn.layer.cornerRadius = 12;
    _questionWriteBtn.layer.borderWidth = 0.5;
    _questionWriteBtn.layer.borderColor = [[UIColor themeOrange4] CGColor];
    [_questionWriteBtn setTitleColor:[UIColor themeOrange4] forState:UIControlStateNormal];
    _questionWriteBtn.titleLabel.font = [UIFont themeFontSemibold:12];
    [_questionWriteBtn setTitle:@"去提问" forState:UIControlStateNormal];
    [_questionWriteBtn addTarget:self action:@selector(gotoWendaPublish) forControlEvents:UIControlEventTouchUpInside];
    [self.contentView addSubview:_questionWriteBtn];
}

- (void)initConstraints {
    [self.topLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView);
        make.left.mas_equalTo(self.contentView).offset(12);
        make.right.mas_equalTo(self.contentView).offset(-12);
        make.height.mas_equalTo([UIDevice btd_onePixel]);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(5);
        make.left.mas_equalTo(self.contentView).offset(12);
        make.right.mas_equalTo(self.rightBtn.mas_left).offset(-5);
        make.height.mas_equalTo(25);
    }];
    
    [self.rightBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.titleLabel);
        make.right.mas_equalTo(self.contentView).offset(-12);
        make.height.mas_equalTo(25);
    }];
    
    [self.cornerLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleLabel.mas_bottom).offset(13);
        make.left.mas_equalTo(self.contentView).offset(12);
        make.width.mas_equalTo(42);
        make.height.mas_equalTo(18);
    }];
    
    [self.emptyContentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.cornerLabel);
        make.left.mas_equalTo(self.cornerLabel.mas_right).offset(5);
        make.right.mas_equalTo(self.questionWriteBtn.mas_left).offset(-6);
        make.height.mas_equalTo(20);
    }];
    
    [self.questionWriteBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.mas_equalTo(self.cornerLabel);
        make.right.mas_equalTo(self.contentView).offset(-12);
        make.height.mas_equalTo(24);
    }];
}

- (void)gotoQuestionList {
    FHNeighborhoodDetailQuestionHeaderModel *cellModel = (FHNeighborhoodDetailQuestionHeaderModel *)self.currentData;
    if(!isEmptyString(cellModel.questionListSchema)){
        NSURL *url = [NSURL URLWithString:cellModel.questionListSchema];
        NSMutableDictionary *dict = @{}.mutableCopy;
        dict[@"neighborhood_id"] = cellModel.neighborhoodId;
        dict[@"title"] = cellModel.title;
        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        tracerDict[UT_ORIGIN_FROM] = cellModel.detailTracerDic[@"origin_from"] ?: @"be_null";
        tracerDict[UT_ENTER_FROM] = cellModel.detailTracerDic[@"page_type"] ?: @"be_null";
        tracerDict[UT_LOG_PB] = cellModel.detailTracerDic[@"log_pb"] ?: @"be_null";
        tracerDict[@"from_gid"] = cellModel.neighborhoodId;
        dict[TRACER_KEY] = tracerDict;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:userInfo];
    }
}

- (void)gotoWendaPublish {
    if ([TTAccountManager isLogin]) {
        [self gotoWendaVC];
    } else {
        [self gotoLogin];
    }
}

- (void)gotoWendaVC {
    FHNeighborhoodDetailQuestionHeaderModel *cellModel = (FHNeighborhoodDetailQuestionHeaderModel *)self.currentData;
    if(!isEmptyString(cellModel.questionWriteSchema)){
        NSURLComponents *components = [[NSURLComponents alloc] initWithString:cellModel.questionWriteSchema];
        NSMutableDictionary *dict = @{}.mutableCopy;
        NSMutableDictionary *tracerDict = @{}.mutableCopy;
        tracerDict[UT_ENTER_FROM] = cellModel.detailTracerDic[@"page_type"];
        tracerDict[UT_LOG_PB] = cellModel.detailTracerDic[@"log_pb"] ?: @"be_null";
        tracerDict[UT_ELEMENT_FROM] = @"neighborhood_question";
        dict[TRACER_KEY] = tracerDict;
        dict[@"neighborhood_id"] = cellModel.neighborhoodId;
        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        [[TTRoute sharedRoute] openURLByPresentViewController:components.URL userInfo:userInfo];
    }
}

- (void)gotoLogin {
    FHNeighborhoodDetailQuestionHeaderModel *cellModel = (FHNeighborhoodDetailQuestionHeaderModel *)self.currentData;
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    NSString *page_type = cellModel.detailTracerDic[@"page_type"] ?: @"be_null";
    [params setObject:page_type forKey:@"enter_from"];
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
                    [wSelf gotoWendaVC];
                });
            }
        }
    }];
}

@end

@implementation FHNeighborhoodDetailQuestionHeaderModel


@end
