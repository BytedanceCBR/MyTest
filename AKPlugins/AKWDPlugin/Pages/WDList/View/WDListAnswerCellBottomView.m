//
//  WDListAnswerCellBottomView.m
//  AKWDPlugin
//
//  Created by 张元科 on 2019/6/14.
//

#import "WDListAnswerCellBottomView.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import "UIImageView+BDWebImage.h"
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"
#import "WDAnswerService.h"
#import "FHUserTracker.h"
#import "UIImage+FIconFont.h"
#import "TTAccountManager.h"
#import "UIButton+FHUGCMultiDigg.h"

@interface WDListAnswerCellBottomView ()

@property (nonatomic, strong) UIButton *commentButton;
@property (nonatomic, strong) UIButton *digButton;

@end

@implementation WDListAnswerCellBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
    }
    return self;
}

- (void)setupUI {
    self.backgroundColor = [UIColor whiteColor];
    // 评论
    self.commentButton = [[UIButton alloc] init];
    [self.commentButton setImage:ICON_FONT_IMG(20, @"\U0000e699", [UIColor themeGray1]) forState:UIControlStateNormal] ;
    [self.commentButton setTitle:@"0" forState:UIControlStateNormal];
    [self.commentButton setTitleColor:[UIColor themeGray1] forState:UIControlStateNormal];
    [self.commentButton setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [self.commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    [self.commentButton sizeToFit];
    self.commentButton.titleLabel.font = [UIFont themeFontRegular:14];
    self.commentButton.titleLabel.layer.masksToBounds = YES;
    [self.commentButton addTarget:self action:@selector(commentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.commentButton];
    // 点赞
    self.digButton = [[UIButton alloc] init];
    [self.digButton setTitle:@"0" forState:UIControlStateNormal];
    [self.digButton setImageEdgeInsets:UIEdgeInsetsMake(0, -2, 0, 2)];
    [self.digButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 2, 0, -2)];
    self.digButton.titleLabel.font = [UIFont themeFontRegular:14];
    self.digButton.titleLabel.layer.masksToBounds = YES;
    [self.digButton sizeToFit];
    self.digButton.hitTestEdgeInsets = UIEdgeInsetsMake(-10, -10, -10, -10);
    [self.digButton addTarget:self action:@selector(digButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.digButton];
    [self.digButton enableMulitDiggEmojiAnimation];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.digButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self).offset(-20);
        make.height.mas_equalTo(20);
    }];
    [self.commentButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self).offset(10);
        make.right.mas_equalTo(self.digButton.mas_left).offset(-20);
        make.height.mas_equalTo(20);
    }];
}

- (void)setAnsEntity:(WDAnswerEntity *)ansEntity {
    _ansEntity = ansEntity;
    if (ansEntity) {
        [self.commentButton setTitle:[NSString stringWithFormat:@"%lld",[ansEntity.commentCount longLongValue]] forState:UIControlStateNormal] ;
        [self.digButton setTitle:[NSString stringWithFormat:@"%lld",[ansEntity.diggCount longLongValue]] forState:UIControlStateNormal];
        self.digButton.selected = ansEntity.isDigg;
    }
    [self layoutIfNeeded];
}

- (void)commentButtonClick {
    if (isEmptyString(self.ansEntity.answerSchema)) {
        return;
    }
    
    [self click_comment];
    
    NSDictionary *dict = @{@"is_jump_comment":@(YES)};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:self.ansEntity.answerSchema] userInfo:userInfo];
}

- (void)digButtonClick {
    if(![TTAccountManager isLogin]) {
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        [params setObject:@"question" forKey:@"enter_from"];
        [params setObject:@"feed_like" forKey:@"enter_type"];
        // 登录成功之后不自己Pop，先进行页面跳转逻辑，再pop
        [params setObject:@(YES) forKey:@"need_pop_vc"];
        params[@"from_ugc"] = @(YES);
        __weak typeof(self) wSelf = self;
        [TTAccountLoginManager showAlertFLoginVCWithParams:params completeBlock:^(TTAccountAlertCompletionEventType type, NSString * _Nullable phoneNum) {
            if (type == TTAccountAlertCompletionEventTypeDone) {
                // 登录成功
                if ([TTAccountManager isLogin]) {
                    [wSelf digButtonClick];
                }
            }
        }];
        
        return;
    }
    
    NSMutableDictionary *tempDic = [self.apiParams mutableCopy];
    tempDic[@"page_type"] = @"question";
    self.apiParams = [tempDic copy];
    if (self.digButton.selected) {
        // 取消点赞
        [self click_answer_dislike];
        self.ansEntity.isDigg = NO;
        self.ansEntity.diggCount = (self.ansEntity.diggCount.longLongValue >= 1) ? @(self.ansEntity.diggCount.longLongValue - 1) : @0;
        [WDAnswerService digWithAnswerID:self.ansEntity.ansid diggType:WDDiggTypeUnDigg enterFrom:@"wenda_list" apiParam:self.apiParams finishBlock:nil];
    } else {
        // 点赞
        [self click_answer_like];
        self.ansEntity.isDigg = YES;
        self.ansEntity.diggCount = @(self.ansEntity.diggCount.longLongValue + 1);
        [WDAnswerService digWithAnswerID:self.ansEntity.ansid diggType:WDDiggTypeDigg enterFrom:@"wenda_list" apiParam:self.apiParams finishBlock:nil];
    }
    self.ansEntity = self.ansEntity;
}

// 详情 评论
- (void)click_comment {
    if (self.gdExtJson && [self.gdExtJson isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tracerDict = self.gdExtJson.mutableCopy;
        tracerDict[@"click_position"] = @"question_comment";
        NSString *ansid = self.ansEntity.ansid;
        if (ansid.length > 0) {
            tracerDict[@"group_id"] = ansid ?: @"be_null";
        }
        tracerDict[@"page_type"] = @"question";
        [FHUserTracker writeEvent:@"click_comment" params:tracerDict];
    }
}

// 详情 点赞
- (void)click_answer_like {
    if (self.gdExtJson && [self.gdExtJson isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tracerDict = self.gdExtJson.mutableCopy;
        tracerDict[@"click_position"] = @"feed_detail";
        NSString *ansid = self.ansEntity.ansid;
        if (ansid.length > 0) {
            tracerDict[@"group_id"] = ansid ?: @"be_null";
        }
        tracerDict[@"page_type"] = @"question";
        [FHUserTracker writeEvent:@"click_like" params:tracerDict];
    }
}

// 详情页 取消点赞
- (void)click_answer_dislike {
    if (self.gdExtJson && [self.gdExtJson isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tracerDict = self.gdExtJson.mutableCopy;
        tracerDict[@"click_position"] = @"feed_detail";
        NSString *ansid = self.ansEntity.ansid;
        if (ansid.length > 0) {
            tracerDict[@"group_id"] = ansid ?: @"be_null";
        }
        tracerDict[@"page_type"] = @"question";
        [FHUserTracker writeEvent:@"click_dislike" params:tracerDict];
    }
}

@end
