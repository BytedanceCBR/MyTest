//
//  TTDetailNatantRiskWarningView.m
//  Article
//
//  Created by Ray on 16/4/6.
//
//

#import "TTDetailNatantRiskWarningView.h"
#import "ArticleInfoManager.h"
#import "TTLabelTextHelper.h"
#import "SSThemed.h"
#import "TTDetailNatantLayout.h"

#define kLeftPadding 15

@interface TTDetailNatantRiskWarningView ()
{
    CGFloat _lineHeight;
}

@property(nonatomic, strong, nonnull) SSThemedLabel * riskWarningLabel;
@property(nonatomic, strong, nonnull) NSString * riskWarningText;
@end

@implementation TTDetailNatantRiskWarningView

- (instancetype)initWithWidth:(CGFloat)width
{
    if (self = [super init]) {
        self.frame = CGRectMake(kLeftPadding, 0, width, 0);
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (UILabel *)riskWarningLabel{
    if (!_riskWarningLabel) {
        _riskWarningLabel = [SSThemedLabel new];
        _riskWarningLabel.backgroundColor = [UIColor clearColor];
        _riskWarningLabel.numberOfLines = 0;
        CGFloat fontSize = [TTDetailNatantLayout sharedInstance_tt].riskLabelFontSize;
        _riskWarningLabel.font = [UIFont systemFontOfSize:fontSize];
        _lineHeight = _riskWarningLabel.font.pointSize * 1.5;
        _riskWarningLabel.textColorThemeKey = kColorText3;
        [self addSubview:_riskWarningLabel];
    }
    return _riskWarningLabel;
}

- (void)refreshUI{
    if (self.riskWarningText && self.riskWarningText.length>0) {
        self.riskWarningLabel.frame = CGRectMake(0, 0, self.width, 0);
        self.riskWarningLabel.attributedText = [TTLabelTextHelper attributedStringWithString:self.riskWarningText fontSize:_riskWarningLabel.font.pointSize lineHeight:_lineHeight];
        CGFloat labelHeight = [TTLabelTextHelper heightOfText:_riskWarningLabel.text
                                                     fontSize:_riskWarningLabel.font.pointSize
                                                     forWidth:_riskWarningLabel.width
                                                forLineHeight:_lineHeight
                                 constraintToMaxNumberOfLines:0 firstLineIndent:0 textAlignment:NSTextAlignmentLeft];
        _riskWarningLabel.height = labelHeight;
        self.frame = CGRectMake(kLeftPadding, 0, self.bounds.size.width, _riskWarningLabel.frame.size.height);
    }else{
        _riskWarningLabel.text = @"";
        self.frame = CGRectMake(kLeftPadding, 0, self.bounds.size.width, 0);
    }
}

-(void)reloadData:(id)object{
    if (![object isKindOfClass:[ArticleInfoManager class]]) {
        return;
    }
    ArticleInfoManager * articleInfo = (ArticleInfoManager *)object;
    self.riskWarningText = articleInfo.riskWarningTip;
    [self refreshUI];
}

@end
