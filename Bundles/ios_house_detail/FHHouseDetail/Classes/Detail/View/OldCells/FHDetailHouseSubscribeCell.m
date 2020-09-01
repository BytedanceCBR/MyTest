//
//  FHDetailHouseSubscribeCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/3/19.
//

#import "FHDetailHouseSubscribeCell.h"
#import "UILabel+House.h"
#import "FHTextField.h"
#import "ToastManager.h"
#import <FHHouseBase/FHUserInfoManager.h>

@interface FHDetailHouseSubscribeCell()<UITextFieldDelegate>

@property(nonatomic, strong) UIButton *subscribeBtn;
@property(nonatomic, strong) UILabel *tipLabel;
@property(nonatomic, strong) FHTextField *textField;
@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, strong) UIImageView *subscribeIcon;
@property(nonatomic, assign) CGFloat offsetY;
@property(nonatomic, strong) NSString *phoneNum;
@property(nonatomic, strong) UILabel *legalAnnouncement;

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
    _subscribeBtn.backgroundColor = [UIColor themeOrange4];
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
    _textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"填写手机号" attributes:@{NSForegroundColorAttributeName: [UIColor themeGray4]}];
    _textField.layer.cornerRadius = 4;
    _textField.layer.masksToBounds = YES;
    _textField.delegate = self;
    [self.bgView addSubview:_textField];

    _legalAnnouncement = [[UILabel alloc] initWithFrame:CGRectZero];
    _legalAnnouncement.textColor = [UIColor themeGray3];
    _legalAnnouncement.textAlignment = NSTextAlignmentLeft;
    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"点击订阅即视为同意《个人信息保护声明》"];
    [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(10, @"个人信息保护声明".length)];
    _legalAnnouncement.attributedText = [attrStr copy];
    _legalAnnouncement.font = [UIFont themeFontRegular:12];
    UITapGestureRecognizer *tipTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(legalAnnouncementClick)];
    _legalAnnouncement.userInteractionEnabled = YES;
    [_legalAnnouncement addGestureRecognizer:tipTap];
    [self.bgView addSubview:_legalAnnouncement];

    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(20);
        make.right.mas_equalTo(-20);
        make.bottom.mas_equalTo(-20);
        make.height.mas_equalTo(121);
    }];

    [self.legalAnnouncement mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10);
        make.left.mas_equalTo(self.textField);
        make.right.mas_equalTo(self.bgView);
        make.height.mas_equalTo(17);
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
    self.phoneNum = [FHUserInfoManager getPhoneNumberIfExist];
    [self showFullPhoneNum:NO];
}

- (void)showFullPhoneNum:(BOOL)isShow {
    if (self.phoneNum.length > 0) {
        if(isShow){
            if ([FHUserInfoManager isLoginPhoneNumber:self.phoneNum]) {
                self.textField.text = @"";
            } else {
                self.textField.text = self.phoneNum;
            }
        }else{
            self.textField.text = [FHUserInfoManager formattMaskPhoneNumber:self.phoneNum];;
        }
        if (self.textField.text.length > 0) {
            self.subscribeBtn.enabled = YES;
            self.subscribeBtn.alpha = 1;
        }else {
            self.subscribeBtn.enabled = NO;
            self.subscribeBtn.alpha = 0.6;
        }
    }
}

- (void)initNotification {
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)subscribe {
    NSString *phoneNum = self.phoneNum;
    if (phoneNum.length == 11 && [phoneNum hasPrefix:@"1"] && [FHUserInfoManager checkPureIntFormatted:phoneNum]) {
        
        FHDetailHouseSubscribeModel *model = (FHDetailHouseSubscribeModel *)self.currentData;
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
        tracerDic[@"position"] = @"card";
        tracerDic[@"growth_deepevent"] = @(1);
        tracerDic[kFHAssociateInfo] = model.associateInfo.reportFormInfo;
        [FHUserTracker writeEvent:@"click_confirm" params:tracerDic];
        
        if(self.subscribeBlock){
            self.subscribeBlock(self.phoneNum);
        }
    }else {
        [[ToastManager manager] showToast:@"手机格式错误"];
        self.textField.textColor = [UIColor themeOrange1];
    }
}

#pragma mark - 键盘通知
- (void)keyboardWillShowNotifiction:(NSNotification *)notification {
    if (!self.textField.isFirstResponder) {
        return;
    }
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
    FHDetailHouseSubscribeModel *model = (FHDetailHouseSubscribeModel *)self.currentData;
    if(model.tableView.contentOffset.y + model.tableView.frame.size.height > model.tableView.contentSize.height){
        //剩余不满一屏幕
        NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            FHDetailHouseSubscribeModel *model = (FHDetailHouseSubscribeModel *)self.currentData;
            CGPoint point = model.tableView.contentOffset;
            point.y = (model.tableView.contentSize.height - model.tableView.frame.size.height);
            model.tableView.contentOffset = point;
        } completion:^(BOOL finished) {
            
        }];
    }
}

-(void)legalAnnouncementClick{
    if(self.legalAnnouncementClickBlock){
        self.legalAnnouncementClickBlock();
    }
}

#pragma mark -- UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
    tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
    tracerDic[@"position"] = @"card";
    tracerDic[@"growth_deepevent"] = @(1);
    [FHUserTracker writeEvent:@"inform_show" params:tracerDic];
    
    [self showFullPhoneNum:YES];
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
//    NSArray *modes = @[NSDefaultRunLoopMode];
//    [self performSelector:@selector(showFullPhoneNum:) withObject:[NSNumber numberWithBool:NO] afterDelay:0 inModes:modes];
//    [self showFullPhoneNum:NO];
    return YES;
}

- (void)textFieldDidChange:(NSNotification *)notification {
    if (!self.textField.isFirstResponder) {
        return;
    }
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
