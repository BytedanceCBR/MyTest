//
//  TTRealnameAuthSubmitView.m
//  Article
//
//  Created by lizhuoli on 16/12/20.
//
//

#import "TTRealnameAuthSubmitView.h"
#import "TTDeviceHelper.h"

@interface TTRealnameAuthSubmitView ()

@property (nonatomic, strong) SSThemedLabel *ensureLabel;
@property (nonatomic, strong) SSThemedLabel *tipLabel;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *IDNumLabel;
@property (nonatomic, strong) SSThemedLabel *nameTextLabel;
@property (nonatomic, strong) SSThemedLabel *IDNumTextLabel;
@property (nonatomic, strong) SSThemedButton *editNameButton;
@property (nonatomic, strong) SSThemedButton *editIDNumButton;

@end

@implementation TTRealnameAuthSubmitView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _ensureLabel = [SSThemedLabel new];
        _tipLabel = [SSThemedLabel new];
        _nameLabel = [SSThemedLabel new];
        _IDNumLabel = [SSThemedLabel new];
        _nameTextLabel = [SSThemedLabel new];
        _IDNumTextLabel = [SSThemedLabel new];
        _editNameButton = [SSThemedButton new];
        _editIDNumButton = [SSThemedButton new];
        
        [self addSubview:_ensureLabel];
        [self addSubview:_tipLabel];
        [self addSubview:_nameLabel];
        [self addSubview:_IDNumLabel];
        [self addSubview:_nameTextLabel];
        [self addSubview:_IDNumTextLabel];
        [self addSubview:_editNameButton];
        [self addSubview:_editIDNumButton];
        
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    SSThemedView *line01 = [SSThemedView new];
    SSThemedView *line02 = [SSThemedView new];
    
    [self addSubview:line01];
    [self addSubview:line02];
    
    self.ensureLabel.text = @"确认信息";
    self.ensureLabel.textColorThemeKey =kColorText1;
    self.ensureLabel.font = [UIFont systemFontOfSize:16];
    [self.ensureLabel sizeToFit];
    [self.ensureLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.top.equalTo(self);
        make.width.mas_equalTo(self.ensureLabel.width);
    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.ensureLabel.mas_right).with.offset(10);
        make.right.equalTo(self);
        make.centerY.equalTo(self.ensureLabel);
    }];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(self.ensureLabel.mas_bottom).with.offset(27);
    }];
    [self.nameTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipLabel);
        make.right.equalTo(self.editNameButton.mas_left).with.offset(-15);
        make.centerY.equalTo(self.nameLabel);
    }];
    [self.editNameButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.editNameButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.centerY.equalTo(self.nameLabel);
    }];
    [line01 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
        make.left.and.right.equalTo(self);
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(16);
    }];
    [self.IDNumLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self);
        make.top.equalTo(line01.mas_bottom).with.offset(15);
    }];
    [self.IDNumTextLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.tipLabel);
        make.right.equalTo(self.editIDNumButton.mas_left).with.offset(-15);
        make.centerY.equalTo(self.IDNumLabel);
    }];
    [self.editIDNumButton setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    [self.editIDNumButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.centerY.equalTo(self.IDNumLabel);
    }];
    [line02 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
        make.left.and.right.and.bottom.equalTo(self);
    }];
    
    line01.backgroundColorThemeKey = kColorLine1;
    line02.backgroundColorThemeKey = kColorLine1;
    
    self.tipLabel.text = @"根据您的身份证照片识别以下信息";
    self.tipLabel.textColorThemeKey = kColorText14;
    self.tipLabel.font = [UIFont systemFontOfSize:14];
    self.tipLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    [self.tipLabel sizeToFit];
    
    self.nameLabel.text = @"姓名：";
    self.nameLabel.textColorThemeKey = kColorText1;
    self.nameLabel.font = [UIFont systemFontOfSize:16];
    [self.nameLabel sizeToFit];
    
    self.IDNumLabel.text =@"证件号：";
    self.IDNumLabel.textColorThemeKey = kColorText1;
    self.IDNumLabel.font = [UIFont systemFontOfSize:16];
    [self.IDNumLabel sizeToFit];
    
    [self.editNameButton setTitle:@"修改" forState:UIControlStateNormal];
    self.editNameButton.titleColorThemeKey = kColorText5;
    self.editNameButton.highlightedTitleColorThemeKey = kColorText5Highlighted;
    self.editNameButton.titleLabel.font = [UIFont systemFontOfSize:14];
    [self.editIDNumButton setTitle:@"修改" forState:UIControlStateNormal];
    self.editIDNumButton.titleColorThemeKey = kColorText5;
    self.editIDNumButton.highlightedTitleColorThemeKey = kColorText5Highlighted;
    self.editIDNumButton.titleLabel.font = [UIFont systemFontOfSize:14];
    
    [self.editNameButton addTarget:self action:@selector(editName:) forControlEvents:UIControlEventTouchUpInside];
    [self.editIDNumButton addTarget:self action:@selector(editIDNum:) forControlEvents:UIControlEventTouchUpInside];
    
    self.nameTextLabel.font = [UIFont systemFontOfSize:16];
    self.nameTextLabel.textColorThemeKey = kColorText1;
    self.nameTextLabel.tag = TTRealnameAuthSubmitTextName;
    self.nameTextLabel.numberOfLines = 1;
    self.nameTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
    
    self.IDNumTextLabel.font = [UIFont systemFontOfSize:16];
    self.IDNumTextLabel.textColorThemeKey = kColorText1;
    self.IDNumTextLabel.numberOfLines = 1;
    self.IDNumTextLabel.lineBreakMode = NSLineBreakByTruncatingTail;
}

- (void)editName:(UIButton *)sender
{
    TTUserProfileInputView *inputView = [[TTUserProfileInputView alloc] initWithFrame:CGRectZero];
    inputView.textView.placeHolder = @"请输入姓名";
    [inputView.tipLabel setText:NSLocalizedString(@"1-7个字", nil)];
    inputView.count = 14;
    inputView.textView.text = self.nameTextLabel.text;
    inputView.tag = TTRealnameAuthSubmitTextName;
    inputView.delegate = self.delegate;
    [inputView showInView:self.delegate.view animated:YES];
}

- (void)editIDNum:(UIButton *)sender
{
    TTUserProfileInputView *inputView = [[TTUserProfileInputView alloc] initWithFrame:CGRectZero];
    inputView.textView.placeHolder = @"请输入身份证号";
    [inputView.tipLabel setText:NSLocalizedString(@"15或18位证件号", nil)];
    inputView.count = 18;
    inputView.textView.text = self.IDNumTextLabel.text;
    inputView.tag = TTRealnameAuthSubmitTextIDNum;
    inputView.delegate = self.delegate;
    [inputView showInView:self.delegate.view animated:YES];
}

- (void)setName:(NSString *)name
{
    _name = name;
    self.nameTextLabel.text = _name;
    [self.nameTextLabel sizeToFit];
}

- (void)setIDNum:(NSString *)IDNum
{
    _IDNum = IDNum;
    self.IDNumTextLabel.text = _IDNum;
    [self.IDNumTextLabel sizeToFit];
}

- (void)setDelegate:(SSViewControllerBase<TTUserProfileInputViewDelegate> *)delegate
{
    _delegate = delegate;
}

@end

@interface TTRealnameAuthSubmitTipView ()

@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedLabel *tipLabel;

@end

@implementation TTRealnameAuthSubmitTipView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _titleLabel = [SSThemedLabel new];
        _tipLabel = [SSThemedLabel new];
        
        [self addSubview:_titleLabel];
        [self addSubview:_tipLabel];
        
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.and.left.and.right.equalTo(self);
    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.and.right.equalTo(self);
        make.top.equalTo(self.titleLabel.mas_bottom).with.offset(15);
    }];
    
    self.titleLabel.text = @"身份信息提取失败，请重新拍摄身份证正反面并上传";
    self.titleLabel.textColorThemeKey = kColorText1;
    self.titleLabel.font = [UIFont systemFontOfSize:12];
    self.tipLabel.text = @"提示：";
    self.tipLabel.textColorThemeKey = kColorText14;
    self.tipLabel.font = [UIFont systemFontOfSize:12];
    
    NSArray<NSString *> *lists = @[@"拍摄时注意对焦；", @"保持证件四角在引导框内；", @"文字数字清晰可见；", @"避免污渍和反光。"];
    
    CGFloat fontSize = [[UIFont systemFontOfSize:12] pointSize];
    
    [lists enumerateObjectsUsingBlock:^(NSString * _Nonnull item, NSUInteger idx, BOOL * _Nonnull stop) {
        SSThemedView *point = [SSThemedView new];
        SSThemedLabel *label = [SSThemedLabel new];
        
        [self addSubview:point];
        [self addSubview:label];
        
        [point mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.mas_equalTo(2);
            make.height.mas_equalTo(8);
            make.left.equalTo(self);
            make.centerY.equalTo(label);
        }];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(point.mas_right).with.offset(7);
            make.top.equalTo(self.tipLabel.mas_bottom).with.offset(10 * (idx+1) + fontSize * idx);
        }];
        
        point.layer.cornerRadius = 1;
        point.layer.masksToBounds = YES;
        point.backgroundColorThemeKey = kColorBackground7;
        label.text = item;
        label.textColorThemeKey = kColorText14;
        label.font = [UIFont systemFontOfSize:12];
    }];
}

@end
