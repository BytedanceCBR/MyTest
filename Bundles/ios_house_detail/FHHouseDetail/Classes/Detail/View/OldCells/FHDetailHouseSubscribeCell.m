//
//  FHDetailHouseSubscribeCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/3/19.
//

#import "FHDetailHouseSubscribeCell.h"
#import "UILabel+House.h"
#import "FHTextField.h"
#import "FHEnvContext.h"
#import "ToastManager.h"

extern NSString *const kFHPhoneNumberCacheKey;

@interface FHDetailHouseSubscribeCell()<UITextFieldDelegate>

@property(nonatomic, strong) UIButton *subscribeBtn;
@property(nonatomic, strong) UILabel *tipLabel;
@property(nonatomic, strong) FHTextField *textField;
@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, strong) UIImageView *subscribeIcon;
@property(nonatomic, assign) CGFloat offsetY;
@property(nonatomic, strong) NSString *phoneNum;

@end

@implementation FHDetailHouseSubscribeCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHDetailHouseSubscribeModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailHouseSubscribeModel *model = (FHDetailHouseSubscribeModel *)data;
    model.cell = self;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
        [self setPhoneNumber];
        [self initNotification];
    }
    return self;
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"report";
}

- (void)setupUI {
    
    _bgView = [[UIView alloc] init];
    _bgView.backgroundColor = [UIColor themeGray7];
    _bgView.layer.cornerRadius = 4;
    _bgView.layer.masksToBounds = YES;
    [self.contentView addSubview:_bgView];
    
    _subscribeIcon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"detail_subscribe_bg"]];
    _subscribeIcon.contentMode = UIViewContentModeScaleAspectFill;
    [self.bgView addSubview:_subscribeIcon];

    _tipLabel = [UILabel createLabel:@"订阅房源动态" textColor:@"" fontSize:16];
    _tipLabel.textColor = [UIColor themeGray1];
    _tipLabel.font = [UIFont themeFontMedium:16];
    [self.bgView addSubview:_tipLabel];
    
    _subscribeBtn = [[UIButton alloc] init];
    _subscribeBtn.backgroundColor = [UIColor themeRed1];
    [_subscribeBtn setTitle:@"订阅动态" forState:UIControlStateNormal];
    [_subscribeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _subscribeBtn.titleLabel.font = [UIFont themeFontRegular:14];
    _subscribeBtn.layer.cornerRadius = 4;
    _subscribeBtn.layer.masksToBounds = YES;
    _subscribeBtn.enabled = NO;
    _subscribeBtn.alpha = 0.6;
    [_subscribeBtn addTarget:self action:@selector(subscribe) forControlEvents:UIControlEventTouchUpInside];
    [self.bgView addSubview:_subscribeBtn];

    _textField = [[FHTextField alloc] init];
    _textField.edgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
    _textField.tintColor = [UIColor themeRed3];
    _textField.backgroundColor = [UIColor whiteColor];
    _textField.font = [UIFont themeFontRegular:14];
    _textField.textColor = [UIColor themeGray1];
    _textField.keyboardType = UIKeyboardTypeNumberPad;
    _textField.placeholder = @"填写手机号";
    [_textField setValue:[UIColor themeGray4] forKeyPath:@"_placeholderLabel.textColor"];
    _textField.layer.cornerRadius = 4;
    _textField.layer.masksToBounds = YES;
    _textField.delegate = self;
    [self.bgView addSubview:_textField];

    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.bottom.mas_equalTo(-20);
        make.left.mas_equalTo(15);
        make.right.mas_equalTo(-15);
        make.height.mas_equalTo(94);
    }];
    
    [self.subscribeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.left.mas_equalTo(self.bgView);
    }];
    
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.bgView).offset(15);
        make.left.mas_equalTo(self.bgView).offset(15);
        make.height.mas_equalTo(22);
    }];
    
    [self.subscribeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(10);
        make.right.mas_equalTo(-15);
        make.width.mas_equalTo(82);
        make.height.mas_equalTo(32);
    }];
    
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(10);
        make.right.mas_equalTo(self.subscribeBtn.mas_left).offset(-20);
        make.height.mas_equalTo(32);
    }];
}

- (void)setPhoneNumber {
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    self.phoneNum = (NSString *)[sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    [self showFullPhoneNum:NO];
}

- (void)showFullPhoneNum:(BOOL)isShow {
    if (self.phoneNum.length > 0) {
        if(isShow){
            self.textField.text = self.phoneNum;
        }else{
            // 显示 151*****010
            NSString *tempPhone = self.phoneNum;
            if (self.phoneNum.length == 11 && [self.phoneNum hasPrefix:@"1"] && [self isPureInt:self.phoneNum]) {
                tempPhone = [NSString stringWithFormat:@"%@*****%@",[self.phoneNum substringToIndex:3],[self.phoneNum substringFromIndex:7]];
            }
            self.textField.text = tempPhone;
            if (self.textField.text.length > 0) {
                self.subscribeBtn.enabled = YES;
                self.subscribeBtn.alpha = 1;
            }else {
                self.subscribeBtn.enabled = NO;
                self.subscribeBtn.alpha = 0.6;
            }
        }
    }
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)subscribe {
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
    tracerDic[@"postiton"] = @"card";
    [FHUserTracker writeEvent:@"click_confirm" params:tracerDic];
    
    NSString *phoneNum = self.phoneNum;
    if (phoneNum.length == 11 && [phoneNum hasPrefix:@"1"] && [self isPureInt:phoneNum]) {
        if(self.subscribeBlock){
            self.subscribeBlock(self.phoneNum);
        }
    }else {
        [[ToastManager manager] showToast:@"手机格式错误"];
        self.textField.textColor = [UIColor themeRed1];
    }
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

#pragma mark - 键盘通知
- (void)keyboardWillShowNotifiction:(NSNotification *)notification {
    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
    
    CGRect frame = [self convertRect:self.bounds toView:nil];
    CGFloat y = [UIScreen mainScreen].bounds.size.height - frame.origin.y - frame.size.height - height;
    self.offsetY = y;
    
    if(y < 0){
        [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            FHDetailHouseSubscribeModel *model = (FHDetailHouseSubscribeModel *)self.currentData;
            CGPoint point = model.tableView.contentOffset;
            point.y -= y;
            model.tableView.contentOffset = point;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
    self.offsetY = 0;
}

#pragma mark -- UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
    tracerDic[@"postiton"] = @"card";
    [FHUserTracker writeEvent:@"inform_show" params:tracerDic];
    
    [self showFullPhoneNum:YES];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    NSArray *modes = @[NSDefaultRunLoopMode];
    [self performSelector:@selector(showFullPhoneNum:) withObject:[NSNumber numberWithBool:NO] afterDelay:0 inModes:modes];
//    [self showFullPhoneNum:NO];
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    if (self.textField.text.length > 11) {
        self.textField.text = [self.textField.text substringToIndex:11];
    }
    
    self.textField.textColor = [UIColor themeGray1];
    self.phoneNum = self.textField.text;
    
    if (self.textField.text.length > 0) {
        self.subscribeBtn.enabled = YES;
        self.subscribeBtn.alpha = 1;
    }else {
        self.subscribeBtn.enabled = NO;
        self.subscribeBtn.alpha = 0.6;
    }
}

@end


@implementation FHDetailHouseSubscribeModel

@end
