//
//  FHFakeInputNavbar.m
//  FHCommonUI
//
//  Created by 谷春晖 on 2018/11/22.
//

#import "FHFakeInputNavbar.h"
#import <Masonry/Masonry.h>
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import <UIViewAdditions.h>
#import "FHTextField.h"

#define MIN_HEIGHT    44
#define BOTTOM_MARGIN 6
#define HOR_MARGIN 10
#define DISPLAY_HOR_MARIN 18
#define ITEM_CONTAINER_WIDTH 50

@interface FHFakeInputNavbar()<UITextFieldDelegate>

@property(nonatomic , assign) FHFakeInputNavbarType type;
@property(nonatomic , strong) FHTextField *inputTextField;
@property(nonatomic , strong) UIView *leftContainerView;
@property(nonatomic , strong) UIView *rightContainerView;


@end


@implementation FHFakeInputNavbar

+(CGFloat)statusBarHeight
{
    CGFloat height = [UIApplication sharedApplication].statusBarFrame.size.height;
    if (height < 1) {// && !([UIApplication sharedApplication].statusBarHidden)
        height = 20;
    }
    return height;
}

+(CGFloat)perferredHeight
{
    CGFloat height = 44;
    if (@available(iOS 11.0 , *)) {
        UIEdgeInsets safeInsets = [[[[UIApplication sharedApplication] delegate]window] safeAreaInsets];
        if (safeInsets.top > 0) {
            //x device
            return height + safeInsets.top;
        }
    }
    return height + [self statusBarHeight];
}

-(instancetype)initWithType:(FHFakeInputNavbarType)type
{
    CGRect frame = [[UIScreen mainScreen] bounds];
    frame.size.height = MIN_HEIGHT;
    self = [super initWithFrame:frame];
    if (self) {
        _type = type;
        [self setupUI];
        
    }
    return self;
}

-(instancetype)init
{
    return [self initWithType:FHFakeInputNavbarTypeDefault];
}

-(instancetype)initWithFrame:(CGRect)frame
{
    if (frame.size.height < MIN_HEIGHT) {
        frame.size.height = MIN_HEIGHT;
    }
    
    self = [super initWithFrame:frame];
    if (self) {
        _type = FHFakeInputNavbarTypeDefault;
        [self setupUI];
    }
    return self;
}

-(FHTextField *)inputTextField
{
    if (!_inputTextField) {
        
        _inputTextField = [[FHTextField alloc] init];
        _inputTextField.borderStyle = UITextBorderStyleNone;
        _inputTextField.backgroundColor = [UIColor themeGray7];
        _inputTextField.font = [UIFont themeFontRegular:14];
        _inputTextField.textColor = [UIColor themeGray3];
        _inputTextField.delegate = self;
        _inputTextField.layer.cornerRadius = 4;
        _inputTextField.layer.masksToBounds = YES;
        _inputTextField.edgeInsets = UIEdgeInsetsMake(1, 0, 0, 0);
        UIImage *searchIcon = [UIImage imageNamed:@"nav_search_icon"];
        UIImageView *searchImgView = [[UIImageView alloc] initWithImage:searchIcon];
        searchImgView.frame = CGRectMake(0, 0, 12, 12);
        UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(00, 00, 32, 32)];
        [leftView addSubview:searchImgView];
        searchImgView.center = CGPointMake(leftView.width/2, leftView.height/2);
        leftView.backgroundColor = [UIColor clearColor];
        _inputTextField.leftView = leftView;
        _inputTextField.leftViewMode = UITextFieldViewModeAlways;
        
        
    }
    return _inputTextField;
}

-(void)setupUI
{

    self.leftContainerView = [[UIView alloc] init];
    self.rightContainerView = [[UIView alloc]init];
    
            
    [self addSubview:self.leftContainerView];
    [self addSubview:self.rightContainerView];
    [self addSubview:self.inputTextField];
 
    [_leftContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(HOR_MARGIN);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(ITEM_CONTAINER_WIDTH);
        make.width.mas_equalTo(ITEM_CONTAINER_WIDTH);
    }];
    
    [_inputTextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(ITEM_CONTAINER_WIDTH + HOR_MARGIN);
        make.right.mas_equalTo(self).offset(-DISPLAY_HOR_MARIN);
        make.bottom.mas_equalTo(self).mas_offset(-BOTTOM_MARGIN);
        make.height.mas_equalTo(32);
    }];
    
    [_rightContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_offset(-HOR_MARGIN);
        make.bottom.mas_equalTo(self);
        make.height.mas_equalTo(ITEM_CONTAINER_WIDTH);
        make.width.mas_equalTo(ITEM_CONTAINER_WIDTH);
    }];
    
    UIButton *backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, ITEM_CONTAINER_WIDTH, 44);
    backButton.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 0, 0);
    UIImage *image = [UIImage imageNamed:@"nav_back_arrow"];
    [backButton setImage:image forState:UIControlStateNormal];
    [backButton setImage:image forState:UIControlStateHighlighted];
    [backButton addTarget:self action:@selector(backAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addLeftItem:backButton];
    
    if (_type == FHFakeInputNavbarTypeMap) {
        [self addMapItem];
    }
    
    self.backgroundColor = [UIColor whiteColor];
}

-(void)setPlaceHolder:(NSString *)placeHolder
{
    NSDictionary *attrDict = @{NSFontAttributeName:[UIFont themeFontRegular:12],
                               NSForegroundColorAttributeName:[UIColor themeGray3]
                               };
    NSAttributedString *attrPlaceHolder = [[NSAttributedString alloc] initWithString:placeHolder attributes:attrDict];
    _inputTextField.attributedPlaceholder = attrPlaceHolder;
}

-(NSString *)placeHolder
{
    if (_inputTextField.attributedText.string.length > 0) {
        return _inputTextField.attributedText.string;
    }
    return _inputTextField.placeholder;
}

-(void)setInputText:(NSString *)inputText
{
    if (inputText) {
        NSDictionary *attrDict = @{NSFontAttributeName:[UIFont themeFontRegular:12],
                                   NSForegroundColorAttributeName:[UIColor themeGray1]
                                   };
        NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:inputText attributes:attrDict];
        _inputTextField.attributedText = attrText;
    }else{
        _inputTextField.attributedText = nil;
        _inputTextField.text = nil;
    }

}

-(NSString *)inputText
{
    return _inputTextField.text;
}

-(void)backAction:(id)sender
{
 
    if (_defaultBackAction) {
        _defaultBackAction();
    }
    
}

-(void)mapAction:(id)sender
{
    if (_showMapAction) {
        _showMapAction();
    }
}

-(void)addMapItem
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *img = [UIImage imageNamed:@"nav_map_icon"];
    [button setImage:img forState:UIControlStateNormal];
    [button setImage:img forState:UIControlStateHighlighted];
    button.frame = CGRectMake(0, 0, ITEM_CONTAINER_WIDTH, 44);
    button.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -6);
    [button addTarget:self action:@selector(mapAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addRightItem:button];
}

-(void)removeSubViews:(UIView *)view
{
    NSArray *subViews = [view subviews];
    [subViews enumerateObjectsUsingBlock:^(UIView *  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
}

-(void)addRightItem:(UIView *)itemView
{
    [self removeSubViews:_rightContainerView];
    CGFloat rightMargin = DISPLAY_HOR_MARIN;
    if (itemView) {
        [self.rightContainerView addSubview:itemView];
        rightMargin = ITEM_CONTAINER_WIDTH+HOR_MARGIN;
        [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(self.rightContainerView);
            make.centerY.mas_equalTo(self.inputTextField);
            make.size.mas_equalTo(itemView.size);
        }];
    }
    
    [self.inputTextField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(self).offset(-rightMargin);
    }];
}

-(void)addLeftItem:(UIView *)itemView
{
    [self removeSubViews:self.leftContainerView];
    [self.leftContainerView addSubview:itemView];
 
    [itemView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(self.leftContainerView);
        make.centerY.mas_equalTo(self.inputTextField);
        make.size.mas_equalTo(itemView.size);
    }];
}

-(void)refreshNavbarType:(FHFakeInputNavbarType)type {
    
    if (type == self.type) {
        return;
    }
    
    self.type = type;
    
    if (type == FHFakeInputNavbarTypeMap) {
        
        [self addMapItem];
    }else {
        
        [self addRightItem:nil];
    }
    
}

#pragma mark - uitextfield delegate
-(BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (_tapInputBar) {
        _tapInputBar();
    }
    return NO;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
