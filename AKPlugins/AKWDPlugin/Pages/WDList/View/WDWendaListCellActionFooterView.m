//
//  WDWendaListCellActionFooterView.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2017/12/29.
//

#import "WDWendaListCellActionFooterView.h"
#import <TTUIWidget/TTAlphaThemedButton.h>
#import <TTBaseLib/TTDeviceHelper.h>
#import <TTBaseLib/UIViewAdditions.h>
#import <TTBaseLib/TTBusinessManager+StringUtils.h>
#import "WDAnswerEntity.h"

@interface WDWendaListCellActionFooterView ()

@property (nonatomic, strong) SSThemedView         *lineView;
@property (nonatomic, strong) TTAlphaThemedButton  *diggButton;
@property (nonatomic, strong) TTAlphaThemedButton  *commentButton;
@property (nonatomic, strong) TTAlphaThemedButton  *forwardButton;

@property (nonatomic, strong) WDAnswerEntity *answerEntity;

@end

@implementation WDWendaListCellActionFooterView

+ (CGFloat)actionFooterHeight {
    return 37;
}

- (instancetype)initWithFrame:(CGRect)frame answerEntity:(WDAnswerEntity *)answerEntity {
    CGRect newFrame = frame;
    newFrame.size.height = [WDWendaListCellActionFooterView actionFooterHeight];
    self = [super initWithFrame:newFrame];
    if (self) {
        self.answerEntity = answerEntity;
        [self addSubview:self.lineView];
        [self addSubview:self.diggButton];
        [self addSubview:self.commentButton];
        [self addSubview:self.forwardButton];
    }
    return self;
}

- (void)refreshForwardCount:(NSNumber *)forwardCount commentCount:(NSNumber *)commentCount diggCount:(NSNumber *)diggCount isDigg:(BOOL)isDigg {
    [self refreshForwardCount:forwardCount];
    [self refreshCommentCount:commentCount];
    [self refreshDiggCount:diggCount isDigg:isDigg];
    
    self.lineView.width = self.width;
    self.lineView.height = [TTDeviceHelper ssOnePixel];
    
    CGFloat buttonWidth = ceilf(self.width/3);
    CGFloat actionButtonHeight = 36;
    
    self.forwardButton.top = 1;
    self.forwardButton.width = buttonWidth;
    self.forwardButton.height = actionButtonHeight;
    
    self.commentButton.top = 1;
    self.commentButton.width = self.width - buttonWidth * 2;
    self.commentButton.height = actionButtonHeight;
    
    self.diggButton.top = 1;
    self.diggButton.width = buttonWidth;
    self.diggButton.height = actionButtonHeight;
    
    self.forwardButton.left = 0;
    self.commentButton.left = self.forwardButton.right;
    self.diggButton.left = self.commentButton.right;
}

- (void)refreshForwardCount:(NSNumber *)forwardCount {
    [self.forwardButton setTitle:[WDWendaListCellActionFooterView forwardContentFromCount:forwardCount] forState:UIControlStateNormal];
}

- (void)refreshCommentCount:(NSNumber *)commentCount {
    [self.commentButton setTitle:[WDWendaListCellActionFooterView commentContentFromCount:commentCount] forState:UIControlStateNormal];
}

- (void)refreshDiggCount:(NSNumber *)diggCount isDigg:(BOOL)isDigg {
    self.diggButton.selected = isDigg;
    [self.diggButton setTitle:[WDWendaListCellActionFooterView diggContentFromCount:diggCount] forState:UIControlStateNormal];
    [self.diggButton setTitle:[WDWendaListCellActionFooterView diggContentFromCount:diggCount] forState:UIControlStateSelected];
}

- (void)diggButtonClick:(TTAlphaThemedButton *)diggButton {
    if ([self.delegate respondsToSelector:@selector(listCellActionFooterViewDiggButtonClick:)]) {
        [self.delegate listCellActionFooterViewDiggButtonClick:diggButton];
    }
}

- (void)commentButtonClick {
    if ([self.delegate respondsToSelector:@selector(listCellActionFooterViewCommentButtonClick)]) {
        [self.delegate listCellActionFooterViewCommentButtonClick];
    }
}

- (void)forwardButtonClick {
    if ([self.delegate respondsToSelector:@selector(listCellActionFooterViewForwardButtonClick)]) {
        [self.delegate listCellActionFooterViewForwardButtonClick];
    }
}

- (SSThemedView *)lineView {
    if (!_lineView) {
        _lineView = [[SSThemedView alloc] init];
        _lineView.backgroundColorThemeKey = kColorLine1;
    }
    return _lineView;
}

- (TTAlphaThemedButton *)diggButton {
    if (!_diggButton) {
        _diggButton = [[TTAlphaThemedButton alloc] init];
        NSString *selectImageName = @"feed_like_press";
        _diggButton.titleLabel.font = [UIFont systemFontOfSize:[WDWendaListCellActionFooterView buttonFontSize]];
        _diggButton.titleColorThemeKey = [WDWendaListCellActionFooterView titleColorKey];
        _diggButton.selectedTitleColorThemeKey = kColorText4;
        [_diggButton setImageName:[WDWendaListCellActionFooterView diggImageName]];
        [_diggButton setSelectedImageName:selectImageName];
        [_diggButton setImageEdgeInsets:UIEdgeInsetsMake(0, -[WDWendaListCellActionFooterView sepPadding], 0, [WDWendaListCellActionFooterView sepPadding])];
        [_diggButton setTitleEdgeInsets:UIEdgeInsetsMake(0, [WDWendaListCellActionFooterView sepPadding], 0, -[WDWendaListCellActionFooterView sepPadding])];
        [_diggButton addTarget:self action:@selector(diggButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _diggButton;
}

- (TTAlphaThemedButton *)commentButton {
    if (!_commentButton) {
        _commentButton = [[TTAlphaThemedButton alloc] init];
        _commentButton.titleLabel.font = [UIFont systemFontOfSize:[WDWendaListCellActionFooterView buttonFontSize]];
        _commentButton.titleColorThemeKey = [WDWendaListCellActionFooterView titleColorKey];
        [_commentButton setImageName:[WDWendaListCellActionFooterView commentImageName]];
        [_commentButton setImageEdgeInsets:UIEdgeInsetsMake(0, -[WDWendaListCellActionFooterView sepPadding], 0, [WDWendaListCellActionFooterView sepPadding])];
        [_commentButton setTitleEdgeInsets:UIEdgeInsetsMake(0, [WDWendaListCellActionFooterView sepPadding], 0, -[WDWendaListCellActionFooterView sepPadding])];
        [_commentButton addTarget:self action:@selector(commentButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentButton;
}

- (TTAlphaThemedButton *)forwardButton {
    if (!_forwardButton) {
        _forwardButton = [[TTAlphaThemedButton alloc] init];
        _forwardButton.titleLabel.font = [UIFont systemFontOfSize:[WDWendaListCellActionFooterView buttonFontSize]];
        _forwardButton.titleColorThemeKey = [WDWendaListCellActionFooterView titleColorKey];
        [_forwardButton setImageName:[WDWendaListCellActionFooterView forwardImageName]];
        [_forwardButton setImageEdgeInsets:UIEdgeInsetsMake(0, -[WDWendaListCellActionFooterView sepPadding], 0, [WDWendaListCellActionFooterView sepPadding])];
        [_forwardButton setTitleEdgeInsets:UIEdgeInsetsMake(0, [WDWendaListCellActionFooterView sepPadding], 0, -[WDWendaListCellActionFooterView sepPadding])];
        [_forwardButton addTarget:self action:@selector(forwardButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _forwardButton;
}

+ (NSString *)diggContentFromCount:(NSNumber *)diggCount {
    NSString *digg = [NSString stringWithFormat:@"%@",[TTBusinessManager formatCommentCount:[diggCount longLongValue]]];
    if (isEmptyString(digg) || [digg isEqualToString:@"0"]) {
        digg = @"赞";
    }
    return digg;
}

+ (NSString *)commentContentFromCount:(NSNumber *)commentCount {
    NSString *comment = [NSString stringWithFormat:@"%@",[TTBusinessManager formatCommentCount:[commentCount longLongValue]]];
    if (isEmptyString(comment) || [comment isEqualToString:@"0"]) {
        comment = @"评论";
    }
    return comment;
}

+ (NSString *)forwardContentFromCount:(NSNumber *)forwardCount {
    NSString *forward = [NSString stringWithFormat:@"%@",[TTBusinessManager formatCommentCount:[forwardCount longLongValue]]];
    if (isEmptyString(forward) || [forward isEqualToString:@"0"]) {
        forward = @"转发";
    }
    return forward;
}

+ (CGFloat)sepPadding {
    return 5 / 2;
}

+ (CGFloat)buttonFontSize {
    return 12;
}

+ (NSString *)titleColorKey {
    return kColorText1;
}

+ (NSString *)diggImageName {
    return @"u13_like_feed";
}

+ (NSString *)commentImageName {
    return @"u13_comment_feed";
}

+ (NSString *)forwardImageName {
    return @"u13_share_feed";
}

@end
