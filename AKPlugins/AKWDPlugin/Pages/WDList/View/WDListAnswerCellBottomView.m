//
//  WDListAnswerCellBottomView.m
//  AKWDPlugin
//
//  Created by 张元科 on 2019/6/14.
//

#import "WDListAnswerCellBottomView.h"
#import "Masonry.h"
#import "UIFont+House.h"
#import <UIImageView+BDWebImage.h>
#import "FHCommonDefines.h"
#import "UIColor+Theme.h"
#import "WDAnswerService.h"
#import "FHUserTracker.h"
#import <UIImage+FIconFont.h>

@interface WDListAnswerCellBottomView ()

@property (nonatomic, strong)   WDListAnswerCellBottomButton       *commentBtn;
@property (nonatomic, strong)   WDListAnswerCellBottomButton       *followBtn;

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
    self.commentBtn = [[WDListAnswerCellBottomButton alloc] init];
    self.commentBtn.icon.image = ICON_FONT_IMG(20, @"\U0000e699", [UIColor themeGray1]);
    self.commentBtn.textLabel.text = @"0";
    [self.commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.commentBtn];
    // 点赞
    self.followBtn = [[WDListAnswerCellBottomButton alloc] init];
    self.followBtn.icon.image = ICON_FONT_IMG(20, @"\U0000e69c", [UIColor themeGray1]);
    self.followBtn.textLabel.text = @"0";
    [self.followBtn addTarget:self action:@selector(followBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.followBtn];
    
    [self setupConstraints];
}

- (void)setupConstraints {
    [self.followBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.right.mas_equalTo(self).offset(-20);
        make.bottom.mas_equalTo(self);
    }];
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.right.mas_equalTo(self.followBtn.mas_left).offset(-20);
        make.bottom.mas_equalTo(self);
    }];
}

- (void)setAnsEntity:(WDAnswerEntity *)ansEntity {
    _ansEntity = ansEntity;
    if (ansEntity) {
        self.commentBtn.textLabel.text = [NSString stringWithFormat:@"%lld",[ansEntity.commentCount longLongValue]];
        self.followBtn.textLabel.text = [NSString stringWithFormat:@"%lld",[ansEntity.diggCount longLongValue]];
        if (ansEntity.isDigg) {
            self.followBtn.followed = YES;
            self.followBtn.icon.image = ICON_FONT_IMG(20, @"\U0000e6b1", [UIColor themeOrange4]);
            self.followBtn.textLabel.textColor = [UIColor themeOrange4];
        } else {
            self.followBtn.followed = NO;
            self.followBtn.icon.image = ICON_FONT_IMG(20, @"\U0000e69c", [UIColor themeGray1]);
            self.followBtn.textLabel.textColor = [UIColor themeGray1];
        }
    }
    [self layoutIfNeeded];
}

- (void)commentBtnClick {
    if (isEmptyString(self.ansEntity.answerSchema)) {
        return;
    }
    
    [self click_comment];
    
    NSDictionary *dict = @{@"is_jump_comment":@(YES)};
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:dict];
    [[TTRoute sharedRoute] openURLByViewController:[NSURL URLWithString:self.ansEntity.answerSchema] userInfo:userInfo];
}

- (void)followBtnClick {
    NSMutableDictionary *tempDic = [self.apiParams mutableCopy];
    tempDic[@"page_type"] = @"question";
    self.apiParams = [tempDic copy];
    if (self.followBtn.followed) {
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
            tracerDict[@"ansid"] = ansid;
        }
        tracerDict[@"page_type"] = @"question";
        NSString *qid = tracerDict[@"qid"];
        tracerDict[@"group_id"] = qid ?: @"be_null";
        [FHUserTracker writeEvent:@"click_comment" params:tracerDict];
    }
}

// 详情 点赞
- (void)click_answer_like {
    if (self.gdExtJson && [self.gdExtJson isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tracerDict = self.gdExtJson.mutableCopy;
        tracerDict[@"click_position"] = @"feed_like";
        NSString *ansid = self.ansEntity.ansid;
        if (ansid.length > 0) {
            tracerDict[@"ansid"] = ansid;
        }
        tracerDict[@"page_type"] = @"question";
        NSString *qid = tracerDict[@"qid"];
        tracerDict[@"group_id"] = qid ?: @"be_null";
        [FHUserTracker writeEvent:@"rt_like" params:tracerDict];
    }
}

// 详情页 取消点赞
- (void)click_answer_dislike {
    if (self.gdExtJson && [self.gdExtJson isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *tracerDict = self.gdExtJson.mutableCopy;
        tracerDict[@"click_position"] = @"feed_dislike";
        NSString *ansid = self.ansEntity.ansid;
        if (ansid.length > 0) {
            tracerDict[@"ansid"] = ansid;
        }
        tracerDict[@"page_type"] = @"question";
        NSString *qid = tracerDict[@"qid"];
        tracerDict[@"group_id"] = qid ?: @"be_null";
        [FHUserTracker writeEvent:@"rt_dislike" params:tracerDict];
    }
}

@end

// WDListAnswerCellBottomButton
@interface WDListAnswerCellBottomButton ()

@end

@implementation WDListAnswerCellBottomButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setupUI];
        self.followed = NO;
    }
    return self;
}

- (void)setupUI {
    self.icon = [[UIImageView alloc] init];
    [self addSubview:_icon];
    
    self.textLabel = [self labelWithFont:[UIFont themeFontRegular:14] textColor:[UIColor themeGray1]];
    [self addSubview:_textLabel];
    
    [self setupConstraints];
}


- (void)setupConstraints {
    [self.icon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.mas_equalTo(self);
        make.width.height.mas_equalTo(20);
    }];
    
    [self.textLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self);
        make.left.mas_equalTo(self.icon.mas_right).mas_offset(4);
        make.right.mas_equalTo(self);
        make.height.mas_equalTo(20);
    }];
}

- (UILabel *)labelWithFont:(UIFont *)font textColor:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    return label;
}

@end
