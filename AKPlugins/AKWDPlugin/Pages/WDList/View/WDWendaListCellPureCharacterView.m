//
//  WDWendaListCellPureCharacterView.m
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/3.
//

#import "WDWendaListCellPureCharacterView.h"
#import "TTTAttributedLabel.h"
#import "WDListCellLayoutModel.h"
#import "WDUIHelper.h"
#import "WDLayoutHelper.h"

@interface WDWendaListCellPureCharacterView ()

@property (nonatomic, strong) TTTAttributedLabel *abstContentLabel;

@property (nonatomic, copy) NSString *answerText;

@end

@implementation WDWendaListCellPureCharacterView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.abstContentLabel];
    }
    return self;
}

- (void)updateAbstContentLabelText:(NSString *)text
{
    [self updateAbstContentLabelText:text numberOfLines:0];
}

- (void)updateAbstContentLabelText:(NSString *)text numberOfLines:(NSInteger)numberOfLines
{
    self.answerText = text;
    CGFloat fontSize = [WDListCellLayoutModel lightAnswerAbstractContentFontSize];
    CGFloat lineHeight = [WDListCellLayoutModel lightAnswerAbstractContentLineHeight];
    CGFloat paraSpace = [WDListCellLayoutModel lightAnswerAbstractContentParaSpace];
    NSMutableAttributedString *attributedString = [WDLayoutHelper attributedStringWithString:text fontSize:fontSize lineHeight:lineHeight paragraphSpace:paraSpace];
    [attributedString addAttribute:NSForegroundColorAttributeName value:[UIColor tt_themedColorForKey:kFHColorCharcoalGrey] range:NSMakeRange(0, [attributedString.string length])];
    self.abstContentLabel.numberOfLines = numberOfLines;
    self.abstContentLabel.attributedTruncationToken = [self tokenAttributeString];
    self.abstContentLabel.attributedText = attributedString;
}

- (void)refreshAbstContentLabelLayout:(CGFloat)height
{
    self.abstContentLabel.frame = CGRectMake(kWDCellLeftPadding - 1, 0, self.width - kWDCellLeftPadding - kWDCellRightPadding + 2 , height);
    self.height = height;
}

- (void)setHighlighted:(BOOL)highlighted {
    if (highlighted) {
        self.abstContentLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground3];
    } else {
        self.abstContentLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
}

- (void)themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    
    self.abstContentLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
    self.abstContentLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [self updateAbstContentLabelText:self.answerText];
}

- (NSAttributedString *)tokenAttributeString
{
    CGFloat fontSize = [WDListCellLayoutModel lightAnswerAbstractContentFontSize];
    NSMutableAttributedString *token = [[NSMutableAttributedString alloc] initWithString:@"..."
                                                                              attributes:@{
                                                                                           NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                                                           NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kColorText1]}
                                        ];
    NSMutableAttributedString *appendToken = [[NSMutableAttributedString alloc] initWithString:@"全文"
                                                                              attributes:@{
                                                                                           NSFontAttributeName : [UIFont systemFontOfSize:fontSize],
                                                                                           NSForegroundColorAttributeName : [UIColor tt_themedColorForKey:kFHColorCoral]}
                                        ];
    [token appendAttributedString:appendToken];
    return token;
}

- (TTTAttributedLabel *)abstContentLabel {
    if (!_abstContentLabel) {
        CGFloat fontSize = [WDListCellLayoutModel lightAnswerAbstractContentFontSize];
        _abstContentLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectZero];
        _abstContentLabel.attributedTruncationToken = [self tokenAttributeString];
        _abstContentLabel.numberOfLines = 0;
        _abstContentLabel.clipsToBounds = YES;
        _abstContentLabel.font = [UIFont systemFontOfSize:fontSize];
        _abstContentLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _abstContentLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    }
    return _abstContentLabel;
}

@end
