//
//  FHFastQATextView.m
//  FHHouseFind
//
//  Created by 春晖 on 2019/6/18.
//

#import "FHFastQATextView.h"
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UIFont+House.h>
#import <Masonry/Masonry.h>
#import <TTPlatformUIModel/HPGrowingTextView.h>

#define TEXT_HOR_MARGIN  5
#define TEXT_VER_MARIN   8

@interface FHFastQATextView ()<HPGrowingTextViewDelegate>

@property(nonatomic , strong) HPGrowingTextView *textView;

@end

@implementation FHFastQATextView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.cornerRadius = 4;
        self.layer.masksToBounds = YES;
        
        _textView = [[HPGrowingTextView alloc] initWithFrame:self.bounds];
        _textView.maxNumberOfLines = 3;
        _textView.placeholderColor = [UIColor themeGray3];
        _textView.font = [UIFont themeFontRegular:14];
        _textView.backgroundColor = [UIColor clearColor];
//        _textView.delegate = self;
        
        [self addSubview:_textView];
        
        self.backgroundColor = RGB(0xf4, 0xf5, 0xf6);
        [self initConstraints];
    }
    return self;

}

-(void)initConstraints
{
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(TEXT_HOR_MARGIN);
        make.top.mas_equalTo(TEXT_VER_MARIN);
        make.right.mas_equalTo(-TEXT_HOR_MARGIN);
        make.bottom.mas_equalTo(-TEXT_VER_MARIN);
    }];
}

-(void)setDelegate:(id<UITextViewDelegate>)delegate
{
    self.textView.delegate = delegate;
}

-(id<UITextViewDelegate>)delegate
{
    return self.textView.delegate;
}

-(void)setText:(NSString *)text
{
    self.textView.text = text;
}

-(NSString *)text
{
    return self.textView.text;
}

-(void)setPlaceholder:(NSString *)placeholder
{
    _textView.placeholder = placeholder;
    
}
-(NSString *)placeholder
{
    return _textView.placeholder;
}

//-(void)textViewDidChange:(UITextView *)textView
//{
//    self.placeHolderLabel.hidden = (textView.text.length > 0);
//}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end

