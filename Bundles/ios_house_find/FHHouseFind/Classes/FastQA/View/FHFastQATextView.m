//
//  FHFastQATextView.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/6/18.
//

#import "FHFastQATextView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <Masonry/Masonry.h>

#define TEXT_HOR_MARGIN  15
#define TEXT_VER_MARIN   8

@interface FHFastQATextView ()<UITextViewDelegate>

@property(nonatomic , strong) UITextView *textView;
@property(nonatomic , strong) UILabel *placeHolderLabel;

@end

@implementation FHFastQATextView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        self.backgroundColor = RGB(0xf4, 0xf5, 0xf6);
        
        _placeHolderLabel = [[UILabel alloc] init];
        _textView = [[UITextView alloc] initWithFrame:self.bounds];
        
        _textView.delegate = self;
        
        [self addSubview:_textView];
        [self addSubview:_placeHolderLabel];
    }
    return self;

}

-(void)initConstraints
{
    [self.placeHolderLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(TEXT_HOR_MARGIN);
        make.top.mas_equalTo(TEXT_VER_MARIN);
        make.right.mas_lessThanOrEqualTo(-TEXT_HOR_MARGIN);
    }];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(TEXT_HOR_MARGIN);
        make.top.mas_equalTo(TEXT_VER_MARIN);
        make.right.mas_equalTo(-TEXT_HOR_MARGIN);
        make.bottom.mas_equalTo(-TEXT_VER_MARIN);
    }];
}

-(void)setText:(NSString *)text
{
    self.textView.text = text;
    self.placeHolderLabel.hidden = (text.length > 0);
}

-(NSString *)text
{
    return self.textView.text;
}

-(void)textViewDidChange:(UITextView *)textView
{
    self.placeHolderLabel.hidden = (textView.text.length > 0);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

