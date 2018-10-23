//
//  TTArticleCardCellViewFooterView.m
//  Article
//
//  Created by 王双华 on 16/4/21.
//
//

#import "TTArticleCardCellViewFooterView.h"
#import "SSThemed.h"
#import "TTImageView.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "Card+CoreDataClass.h"
#import "TTTrackerWrapper.h"
#import "TTRoute.h"
#import "TTAlphaThemedButton.h"
#import "TTThemeConst.h"
#import "TTDeviceHelper.h"
#import "TTStringHelper.h"

#define kLeftPadding            15
#define kRightPadding           15
#define kHorizonGap             15
#define kVerticalLineHeight     ([TTDeviceHelper isScreenWidthLarge320] ? 12 : 8)
#define kArrowImageLeftPadding  6

#define kTitleLabelFontSize     ([TTDeviceHelper isScreenWidthLarge320] ? 14 : 12)

@interface TTArticleCardCellViewFooterView ()

@property(nonatomic,weak)id target;
@property(nonatomic,assign)SEL selector;

@property(nonatomic, copy)NSString *leftButtonUrl;
@property(nonatomic, copy)NSString *middleButtonUrl;
@property(nonatomic, copy)NSString *rightButtonUrl;
@property(nonatomic, copy)NSString *cardID;
@property(nonatomic, copy)NSString *categoryID;

//热点新闻跳转需求
@property (nonatomic, copy) NSString *showMoreSchema;
@end

@implementation TTArticleCardCellViewFooterView {
    TTAlphaThemedButton *_leftTitleButton;
    
    SSThemedView * _leftSepLineView;
    TTAlphaThemedButton *_middleTitleButton;
    
    SSThemedView * _rightSepLineView;
    TTAlphaThemedButton *_rightTitleButton;
    
    SSThemedButton *_arrowTitleButton;
    SSThemedButton *_arrowImageButton;
    
    //    SSThemedView *_sepLineView;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.clipsToBounds = YES;
        _leftTitleButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectZero];
        _leftTitleButton.enableHighlightAnim = YES;
        _leftTitleButton.titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        _leftTitleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_leftTitleButton];
        
        _leftSepLineView = [[SSThemedView alloc] init];
        [self addSubview:_leftSepLineView];
        
        _middleTitleButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectZero];
        _middleTitleButton.enableHighlightAnim = YES;
        _middleTitleButton.titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        _middleTitleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_middleTitleButton];
        
        _rightSepLineView = [[SSThemedView alloc] init];
        [self addSubview:_rightSepLineView];
        
        _rightTitleButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectZero];
        _rightTitleButton .enableHighlightAnim = YES;
        _rightTitleButton.titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        _rightTitleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_rightTitleButton];
        
        _arrowTitleButton = [[SSThemedButton alloc] initWithFrame:CGRectZero];
        _arrowTitleButton.titleLabel.font = [UIFont systemFontOfSize:kTitleLabelFontSize];
        _arrowTitleButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self addSubview:_arrowTitleButton];
        
        _arrowImageButton = [[SSThemedButton alloc] initWithFrame:CGRectZero];
        _arrowImageButton.imageName = @"all_card_arrow";
        [_arrowImageButton sizeToFit];
        [self addSubview:_arrowImageButton];
        
        //        _sepLineView = [[SSThemedView alloc] init];
        //        _sepLineView.backgroundColorThemeKey = kColorLine1;
        //        [self addSubview:_sepLineView];
        
        [_leftTitleButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_middleTitleButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [_rightTitleButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        
        [self initConstraints];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tap];
        
        [self reloadThemeUI];
    }
    return self;
}

- (void)themeChanged:(NSNotification *)notification {
    _leftTitleButton.titleColorThemeKey = kColorText1;
    _middleTitleButton.titleColorThemeKey = kColorText1;
    _rightTitleButton.titleColorThemeKey = kColorText1;
    _arrowTitleButton.titleColorThemeKey = kColorText1;
    
    _leftSepLineView.backgroundColorThemeKey = kColorLine9;
    _rightSepLineView.backgroundColorThemeKey = kColorLine9;
    
    _arrowImageButton.imageName = @"all_card_arrow";
}

- (void)initConstraints{
    //constraints
    [_leftTitleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(kLeftPadding);
        make.centerY.equalTo(self);
    }];
    
    [_leftSepLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftTitleButton.mas_right).with.offset(kHorizonGap);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake([TTDeviceHelper ssOnePixel], kVerticalLineHeight));
    }];
    
    [_middleTitleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_leftSepLineView.mas_right).with.offset(kHorizonGap);
        make.centerY.equalTo(self);
    }];
    
    [_rightSepLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_middleTitleButton.mas_right).with.offset(kHorizonGap);
        make.centerY.equalTo(self);
        make.size.mas_equalTo(CGSizeMake([TTDeviceHelper ssOnePixel], kVerticalLineHeight));
    }];
    
    [_rightTitleButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(_rightSepLineView.mas_right).with.offset(kHorizonGap);
        make.centerY.equalTo(self);
    }];
    
    //    [_sepLineView mas_makeConstraints:^(MASConstraintMaker *make) {
    //        make.top.equalTo(self);
    //        make.left.mas_equalTo(kLeftPadding);
    //        make.right.equalTo(self.mas_right).with.offset(- kLeftPadding);
    //        make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
    //    }];
}

- (void)refreshUIWithModel:(ExploreOrderedData *)orderedData {
    Card *card = orderedData.card;
    self.cardID = [NSString stringWithFormat:@"%lld",card.uniqueID];
    self.categoryID = [NSString stringWithFormat:@"%@",orderedData.categoryID];
    _leftTitleButton.hidden = YES;
    _leftSepLineView.hidden = YES;
    _middleTitleButton.hidden = YES;
    _rightSepLineView.hidden = YES;
    _rightSepLineView.hidden = YES;
    _rightTitleButton.hidden = YES;
    _arrowImageButton.hidden = YES;
    _arrowTitleButton.hidden = YES;
    _arrowTitleButton.userInteractionEnabled = NO;
    _arrowImageButton.userInteractionEnabled = NO;
    
    NSUInteger count = card.tabModelLists.count;
    ExploreEmbedListCardTabInfoModel *tabInfoModel = nil;
    for (int i = 0; i < count; i ++) {
        tabInfoModel = card.tabModelLists[i];
        if (i == 0) {
            self.leftButtonUrl = tabInfoModel.taburl;
            [_leftTitleButton setTitle:tabInfoModel.tabtext forState:UIControlStateNormal];
            [_leftTitleButton sizeToFit];
            _leftTitleButton.hidden = NO;
        }
        if (i == 1) {
            self.middleButtonUrl = tabInfoModel.taburl;
            [_middleTitleButton setTitle:tabInfoModel.tabtext forState:UIControlStateNormal];
            [_middleTitleButton sizeToFit];
            _leftSepLineView.hidden = NO;
            _middleTitleButton.hidden = NO;
        }
        if (i == 2) {
            self.rightButtonUrl = tabInfoModel.taburl;
            [_rightTitleButton setTitle:tabInfoModel.tabtext forState:UIControlStateNormal];
            [_rightTitleButton sizeToFit];
            _rightSepLineView.hidden = NO;
            _rightTitleButton.hidden = NO;
        }
    }
    if (count == 0) {
        [_arrowTitleButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(kLeftPadding);
            make.right.equalTo(_arrowImageButton.mas_left).with.offset(- kArrowImageLeftPadding);
            make.centerY.equalTo(self);
        }];
        
        [_arrowImageButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(_arrowTitleButton.mas_right).with.offset(kArrowImageLeftPadding);
            make.centerY.equalTo(self);
        }];
    }
    else{
        [_arrowTitleButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(_arrowImageButton.mas_left).with.offset(- kArrowImageLeftPadding);
            make.centerY.equalTo(self);
        }];
        
        [_arrowImageButton mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).with.offset(- kRightPadding);
            make.centerY.equalTo(self);
        }];
    }
    
    if (card.showMoreModel.title) {
        [_arrowTitleButton setTitle:card.showMoreModel.title forState:UIControlStateNormal];
        [_arrowTitleButton sizeToFit];
        _arrowTitleButton.hidden = NO;
        
        //support user interaction for hotnews article
        if ([card.cardType integerValue] == 6) {
            _arrowTitleButton.userInteractionEnabled = YES;
            [_arrowTitleButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
            self.showMoreSchema = [card.showMoreData tt_stringValueForKey:@"url"];
        }
    }
    _arrowImageButton.hidden = NO;
    
    [self reloadThemeUI];
}

- (void)buttonClicked:(id)sender{
    NSString *label = @"click_bottom_";
    if (sender == _leftTitleButton) {
        label = [label stringByAppendingString:@"1"];
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:_leftButtonUrl]];
    }
    else if (sender == _middleTitleButton){
        label = [label stringByAppendingString:@"2"];
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:_middleButtonUrl]];
    }
    else if (sender == _rightTitleButton){
        label = [label stringByAppendingString:@"3"];
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:_rightButtonUrl]];
    } else if (sender == _arrowTitleButton) {
        //热点要闻showmore
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:self.showMoreSchema]];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        NSRange range = [self.showMoreSchema rangeOfString:@"category="];
        NSUInteger index = range.location + range.length;
        NSString *descCategory = [self.showMoreSchema substringFromIndex:index];
        if (isEmptyString(descCategory)) return;
        [params setValue:self.cardID forKey:@"card_id"];
        [params setValue:@"stream" forKey:@"tab_name"];
        [params setValue:descCategory forKey:@"to_category_name"];
        [params setValue:@"list" forKey:@"position"];
        [params setValue:@"click_headline" forKey:@"enter_from"];
        [params setValue:self.categoryID forKey:@"category_name"];
        [TTTrackerWrapper eventV3:@"click_more_news" params:params];
        [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:self.showMoreSchema]];
    }
    wrapperTrackEventWithCustomKeys(@"card", label, self.cardID, nil, @{@"category_name":self.categoryID});
}

- (void)setTarget:(id)target selector:(SEL)selector {
    _target = target;
    _selector = selector;
}

- (void)handleTap:(UITapGestureRecognizer *)gestureRecognize {
    if (_target && [_target respondsToSelector:_selector])  {
        NSMethodSignature *signature = [_target methodSignatureForSelector:_selector];
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
        [invocation setTarget:_target];
        [invocation setSelector:_selector];
        [invocation invoke];
    }
}


@end

