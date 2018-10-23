//
//  TTAdCanvasTextView.m
//  Article
//
//  Created by yin on 2017/3/28.
//
//

#import "TTAdCanvasTextCell.h"
#import "TTAdCanvasManager.h"
#import "TTAdCanvasUtils.h"
#import "TTLabelTextHelper.h"

@interface TTAdCanvasTextCell ()

@property (nonatomic, strong) TTAdCanvasLayoutModel* model;
@property (nonatomic, strong) SSThemedLabel* label;

@end

@implementation TTAdCanvasTextCell

- (instancetype)initWithWidth:(CGFloat)width
{
   self = [super initWithWidth:width];
    if (self) {
        [self setSubViews];
    }
    return self;
}

- (void)setSubViews
{
    self.label = [[SSThemedLabel alloc] init];
    [self addSubview:self.label];
}


- (void)refreshWithModel:(TTAdCanvasLayoutModel *)model
{
    self.model = model;
    self.label.text = model.data.text;
    self.label.numberOfLines = 0;
    self.label.textColor = [TTAdCanvasUtils colorWithCanvasRGBAString:model.styles.color];
    self.label.font = [UIFont systemFontOfSize:model.styles.fontSize.floatValue];
    self.label.textAlignment = self.model.styles.textAlignment;
}


- (void)canvasCell:(TTAdCanvasBaseCell *)cell showStatus:(TTAdCanvasItemShowStatus)showStatus itemIndex:(NSInteger)itemIndex
{
    switch (showStatus) {
        case TTAdCanvasItemShowStatus_WillDisplay:
            [self trackShow];
            break;
            
        default:
            break;
    }
}


- (void)trackShow
{
    [[TTAdCanvasManager sharedManager] trackCanvasTag:@"detail_immersion_ad" label:@"impression_text" dict:nil];
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    float fontSize = self.model.styles.fontSize.floatValue;
    float lineHeight = self.model.styles.lineHeight.floatValue;
    
    self.label.attributedText = [TTLabelTextHelper attributedStringWithString:self.model.data.text fontSize:fontSize lineHeight:lineHeight lineBreakMode:NSLineBreakByWordWrapping isBoldFontStyle:NO firstLineIndent:0 textAlignment:self.model.styles.textAlignment];
    
    CGFloat maxTitleLabelWidth = self.width - self.model.styles.marginLeft.floatValue - self.model.styles.marginRight.floatValue;
    
    CGFloat titleHeight = [TTLabelTextHelper heightOfText:self.model.data.text fontSize:fontSize forWidth:maxTitleLabelWidth forLineHeight:lineHeight constraintToMaxNumberOfLines:0 firstLineIndent:0 textAlignment:self.model.styles.textAlignment];
    
    self.label.size = CGSizeMake(maxTitleLabelWidth, titleHeight);
    self.label.origin = CGPointMake(self.model.styles.marginLeft.floatValue, self.model.styles.marginTop.floatValue);
    
    
}

+ (CGFloat)heightForModel:(TTAdCanvasLayoutModel *)model inWidth:(CGFloat)width
{
    float fontSize = model.styles.fontSize.floatValue;
    float lineHeight = model.styles.lineHeight.floatValue;
    CGFloat maxTitleLabelWidth = width - model.styles.marginLeft.floatValue - model.styles.marginRight.floatValue;
    CGFloat titleHeight = [TTLabelTextHelper heightOfText:model.data.text fontSize:fontSize forWidth:maxTitleLabelWidth forLineHeight:lineHeight constraintToMaxNumberOfLines:0 firstLineIndent:0 textAlignment:model.styles.textAlignment];
    
    return model.styles.marginTop.floatValue + model.styles.marginBottom.floatValue + titleHeight;
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
