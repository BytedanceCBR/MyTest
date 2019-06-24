//
//  FHUGCCellBottomView.m
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/4.
//

#import "FHUGCCellBottomView.h"
#import <Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "FHCommonApi.h"
#import "ToastManager.h"
#import "TTReachability.h"
#import "TTAccountManager.h"
#import "UIButton+TTAdditions.h"

@interface FHUGCCellBottomView ()

@property(nonatomic ,strong) UIView *likeView;
@property(nonatomic ,strong) UIImageView *likeImageView;
@property(nonatomic ,strong) UILabel *likeLabel;
@property(nonatomic ,strong) UIView *bottomSepView;

@end

@implementation FHUGCCellBottomView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self initConstraints];
    }
    return self;
}

- (void)initViews {
    
    self.positionView = [[UIView alloc] init];
    _positionView.backgroundColor = [[UIColor themeRed3] colorWithAlphaComponent:0.1];
    _positionView.layer.masksToBounds= YES;
    _positionView.layer.cornerRadius = 4;
    _positionView.userInteractionEnabled = YES;
    _positionView.hidden = YES;
    [self addSubview:_positionView];
    
    self.position = [self LabelWithFont:[UIFont themeFontRegular:13] textColor:[UIColor themeRed3]];
    [_position sizeToFit];
    [_positionView addSubview:_position];
    
    self.commentBtn = [[UIButton alloc] init];
    [_commentBtn setImage:[UIImage imageNamed:@"fh_ugc_comment"] forState:UIControlStateNormal];
    [_commentBtn setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    _commentBtn.titleLabel.font = [UIFont themeFontRegular:14];
    [_commentBtn setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [_commentBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    _commentBtn.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self addSubview:_commentBtn];
    
    self.likeView = [[UIView alloc] init];
    _likeView.userInteractionEnabled = YES;
    [self addSubview:_likeView];
    
    UITapGestureRecognizer* singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(like:)];
    [self.likeView addGestureRecognizer:singleTap];
    
    self.likeImageView = [[UIImageView alloc] init];
    _likeImageView.image = [UIImage imageNamed:@"fh_ugc_like"];
    [self.likeView addSubview:_likeImageView];
    
    self.likeLabel = [self LabelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    [_likeLabel sizeToFit];
    [self.likeView addSubview:_likeLabel];
    
    self.bottomSepView = [[UIView alloc] init];
    _bottomSepView.backgroundColor = [UIColor themeGray7];
    [self addSubview:_bottomSepView];
}

- (FHUGCFeedGuideView *)guideView {
    if(!_guideView){
        _guideView = [[FHUGCFeedGuideView alloc] init];
        [self addSubview:_guideView];
    }
    return _guideView;
}

- (void)initConstraints {
    [self.positionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self).offset(20);
        make.top.mas_equalTo(self);
        make.height.mas_equalTo(24);
    }];
    
    [self.position mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.positionView).offset(6);
        make.right.mas_equalTo(self.positionView).offset(-6);
        make.centerY.mas_equalTo(self.positionView);
        make.height.mas_equalTo(18);
    }];
    
    [self.likeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self.commentBtn.mas_left).offset(-80);
        make.width.mas_equalTo(70);
        make.height.mas_equalTo(24);
    }];
    
    [self.likeImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.likeView).offset(10);
        make.centerY.mas_equalTo(self.likeView);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.likeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.mas_equalTo(self.likeView);
        make.left.mas_equalTo(self.likeImageView.mas_right).offset(3);
        make.right.mas_equalTo(self.likeView);
    }];
    
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(24);
    }];
    
    [self.bottomSepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.positionView.mas_bottom).offset(20);
        make.left.right.mas_equalTo(self);
        make.height.mas_equalTo(5);
    }];
}

- (void)setCellModel:(FHFeedUGCCellModel *)cellModel {
    _cellModel = cellModel;
    //设置是否显示引导
    if(cellModel.isInsertGuideCell){
        self.guideView.hidden = NO;
        [self.guideView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.positionView.mas_bottom);
            make.left.right.mas_equalTo(self);
            make.height.mas_equalTo(42);
        }];
    }else{
        self.guideView.hidden = YES;
    }
}

- (UILabel *)LabelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

- (void)showPositionView:(BOOL)isShow {
    self.positionView.hidden = !isShow;
}

- (void)updateLikeState:(NSString *)diggCount userDigg:(NSString *)userDigg {
    self.likeLabel.text = diggCount;
    if([userDigg boolValue]){
        self.likeImageView.image = [UIImage imageNamed:@"fh_ugc_like_selected"];
    }else{
        self.likeImageView.image = [UIImage imageNamed:@"fh_ugc_like"];
    }
}

// 点赞
- (void)like:(UITapGestureRecognizer *)sender {
    // 网络
    if (![TTReachability isNetworkConnected]) {
        [[ToastManager manager] showToast:@"网络异常"];
        return;
    }
    // 如果未登录，先登录
    if(![TTAccountManager isLogin]){
//        NSMutableDictionary *dict = @{}.mutableCopy;
//        dict[@"enter_from"] = @"minetab";
//        dict[@"enter_type"] = @"login";
//        TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
        
        NSURL* url = [NSURL URLWithString:@"snssdk1370://flogin"];
        [[TTRoute sharedRoute] openURLByPushViewController:url userInfo:nil];
        return;
    }
    // 刷新UI
    NSInteger user_digg = [self.cellModel.userDigg integerValue];
    NSInteger diggCount = [self.cellModel.diggCount integerValue];
    if(user_digg == 1){
        //已点赞
        self.cellModel.userDigg = @"0";
        if(diggCount > 0){
            diggCount = diggCount - 1;
        }
    }else{
        //未点赞
        self.cellModel.userDigg = @"1";
        diggCount = diggCount + 1;
    }
    
    self.cellModel.diggCount = [NSString stringWithFormat:@"%i",diggCount];
    [self updateLikeState:self.cellModel.diggCount userDigg:self.cellModel.userDigg];
    
    [FHCommonApi requestCommonDigg:self.cellModel.groupId groupType:FHDetailDiggTypeTHREAD action:[self.cellModel.userDigg integerValue] completion:nil];
}

@end
