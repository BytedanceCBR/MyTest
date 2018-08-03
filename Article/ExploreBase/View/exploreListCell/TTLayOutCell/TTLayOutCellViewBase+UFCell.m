//
//  TTLayOutCellViewBase+UFCell.m
//  Article
//
//  Created by 王双华 on 16/11/11.
//
//

#import "TTLayOutCellViewBase+UFCell.h"

@implementation TTLayOutCellViewBase (UFCell)

- (void)setupSubviewsForUFCell
{
    SSThemedLabel *newsTitleLabel = [[SSThemedLabel alloc] init];
    newsTitleLabel.textColorThemeKey = kColorText1;
    newsTitleLabel.numberOfLines = kUFDongtaiTitleLineNumber();
    [self addSubview:newsTitleLabel];
    self.newsTitleLabel = newsTitleLabel;
    SSThemedLabel *userNameLabel = [[SSThemedLabel alloc] init];
    userNameLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    userNameLabel.font = [UIFont tt_boldFontOfSize:kUFSourceLabelFontSize()];
    userNameLabel.textColorThemeKey = kSourceViewTextColor();
    userNameLabel.userInteractionEnabled = YES;
    UITapGestureRecognizer *sourceLabelTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sourceImageClick)];
    [userNameLabel addGestureRecognizer:sourceLabelTapGestureRecognizer];
    [self addSubview:userNameLabel];
    self.userNameLabel = userNameLabel;
    
    SSThemedLabel *userVerifiedLabel = [[SSThemedLabel alloc] init];
    userVerifiedLabel.textColorThemeKey = kColorText1;
    userVerifiedLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    [self addSubview:userVerifiedLabel];
    self.userVerifiedLabel = userVerifiedLabel;
    
    SSThemedLabel *recommendLabel = [[SSThemedLabel alloc] init];
    recommendLabel.textColorThemeKey = kColorText1;
    recommendLabel.backgroundColor = [TTUISettingHelper cellViewBackgroundColor];
    [self addSubview:recommendLabel];
    self.recommendLabel = recommendLabel;
    
    SSThemedView *actionSepLine = [[SSThemedView alloc] init];
    actionSepLine.backgroundColorThemeKey = kColorLine1;
    [self addSubview:actionSepLine];
    self.actionSepLine = actionSepLine;
    
    SSThemedView *verticalLineView = [[SSThemedView alloc] init];
    verticalLineView.backgroundColorThemeKey = kColorText1;
    [self addSubview:verticalLineView];
    self.verticalLineView = verticalLineView;
    
    SSThemedButton *wenDaButton = [[SSThemedButton alloc] init];
    [wenDaButton.titleLabel setFont:[UIFont tt_fontOfSize:12]];
    wenDaButton.imageName = @"notice_feed";
    wenDaButton.highlightedImageName = @"notice_feed";
    [wenDaButton setTitle:@"问答" forState:UIControlStateNormal];
    wenDaButton.titleColorThemeKey = kColorText12;
    wenDaButton.backgroundColorThemeKey = kColorBackground7;
    wenDaButton.layer.cornerRadius = 4;
    [wenDaButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
    [wenDaButton setImageEdgeInsets:UIEdgeInsetsMake(0, -5, 0, 0)];
    [wenDaButton addTarget:self action:@selector(sourceImageClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:wenDaButton];
    self.wenDaButton = wenDaButton;
}

- (void)layoutComponentsForUFCell
{
    [self layoutNewsTitleLabel];
    [self layoutUserNameLabel];
    [self layoutUserVerifiedLabel];
    [self layoutRecommendLabel];
    [self layoutUserVerifiedImg];
    [self layoutActionSepLine];
    [self layoutVerticalLineView];
    [self layoutWenDaButton];
}

- (void)layoutNewsTitleLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.newsTitleLabel.hidden = cellLayOut.newsTitleLabelHidden;
    if (!self.newsTitleLabel.hidden) {
        self.newsTitleLabel.frame = cellLayOut.newsTitleLabelFrame;
        self.newsTitleLabel.attributedText = self.orderedData.cellLayOut.newsTitleAttributedStr;
    }
}

- (void)layoutUserNameLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.userNameLabel.hidden = cellLayOut.userNameLabelHidden;
    if (!self.userNameLabel.hidden) {
        self.userNameLabel.frame = cellLayOut.userNameLabelFrame;
        self.userNameLabel.text = cellLayOut.userNameLabelStr;
    }
}

- (void)layoutUserVerifiedLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.userVerifiedLabel.hidden = cellLayOut.userVerifiedLabelHidden;
    if (!self.userVerifiedLabel.hidden) {
        self.userVerifiedLabel.frame = cellLayOut.userVerifiedLabelFrame;
        self.userVerifiedLabel.textColorThemeKey = cellLayOut.userVerifiedLabelTextColorThemeKey;
        self.userVerifiedLabel.text = cellLayOut.userVerifiedLabelStr;
        self.userVerifiedLabel.font = [UIFont tt_fontOfSize:cellLayOut.userVerifiedLabelFontSize];
    }
}

- (void)layoutRecommendLabel
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.recommendLabel.hidden = cellLayOut.recommendLabelHidden;
    if (!self.recommendLabel.hidden) {
        self.recommendLabel.frame = cellLayOut.recommendLabelFrame;
        self.recommendLabel.text = cellLayOut.recommendLabelStr;
        self.recommendLabel.font = [UIFont tt_fontOfSize:cellLayOut.recommendLabelFontSize];
    }
}

- (void)layoutUserVerifiedImg
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    if (!cellLayOut.userVerifiedImgHidden) {
        [self.sourceImageView showOrHideVerifyViewWithVerifyInfo:cellLayOut.userVerifiedImgAuthInfo decoratorInfo:cellLayOut.userDecoration sureQueryWithID:NO userID:nil];
    }
    else{
        [self.sourceImageView showOrHideVerifyViewWithVerifyInfo:nil decoratorInfo:cellLayOut.userDecoration sureQueryWithID:NO userID:nil];
    }
}

- (void)layoutActionSepLine
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.actionSepLine.hidden = cellLayOut.actionSepLineHidden;
    if (!self.actionSepLine.hidden) {
        self.actionSepLine.frame = cellLayOut.actionSepLineFrame;
    }
}

- (void)layoutVerticalLineView
{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.verticalLineView.hidden = cellLayOut.verticalLineViewHidden;
    if (!self.verticalLineView.hidden) {
        self.verticalLineView.frame = cellLayOut.verticalLineViewFrame;
    }
}

- (void)layoutWenDaButton{
    TTLayOutCellBaseModel *cellLayOut = self.orderedData.cellLayOut;
    self.wenDaButton.hidden = cellLayOut.wenDaButtonHidden;
    if (!self.wenDaButton.hidden) {
        self.wenDaButton.frame = cellLayOut.wenDaButtonFrame;
    }
}
@end
