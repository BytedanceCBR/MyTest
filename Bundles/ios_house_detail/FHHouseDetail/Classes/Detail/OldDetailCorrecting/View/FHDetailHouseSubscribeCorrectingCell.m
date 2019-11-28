//
//  FHDetailHouseSubscribeCorrectingCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2019/3/19.
//

#import "FHDetailHouseSubscribeCorrectingCell.h"
#import "UILabel+House.h"
#import "FHTextField.h"
#import "FHEnvContext.h"
#import "ToastManager.h"

extern NSString *const kFHPhoneNumberCacheKey;

@interface FHDetailHouseSubscribeCorrectingCell()<UITextFieldDelegate>

@property(nonatomic, weak) UIButton *subscribeBtn;
@property(nonatomic, weak) UILabel *tipLabel;
//@property(nonatomic, strong) FHTextField *textField;
//@property(nonatomic, strong) UIView *bgView;
@property(nonatomic, weak) UIImageView *subscribeIcon;
@property (nonatomic, weak) UIImageView *shadowImage;
//@property(nonatomic, assign) CGFloat offsetY;
//@property(nonatomic, strong) NSString *phoneNum;
//@property(nonatomic, strong) UILabel *legalAnnouncement;

@end

@implementation FHDetailHouseSubscribeCorrectingCell

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
    if (self.currentData == data || ![data isKindOfClass:[FHDetailHouseSubscribeCorrectingModel class]]) {
        return;
    }
    self.currentData = data;
    FHDetailHouseSubscribeCorrectingModel *model = (FHDetailHouseSubscribeCorrectingModel *)data;
    self.shadowImage.image = [UIImage imageNamed:model.bacImageName];
    model.cell = self;
}


-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
//        [self setPhoneNumber];
//        [self initNotification];
    }
    return self;
}

- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"report";
}

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        shadowImage.image = [[UIImage imageNamed:@"left_top_right"]resizableImageWithCapInsets:UIEdgeInsetsMake(20,20,20,20) resizingMode:UIImageResizingModeStretch];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (UIImageView *)subscribeIcon {
    if (!_subscribeIcon) {
        UIImageView *subscribeIcon = [[UIImageView alloc]init];
        subscribeIcon.image = [UIImage imageNamed:@"detail_subscribe_bg"];
        subscribeIcon.contentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:subscribeIcon];
        _subscribeIcon = subscribeIcon;
    }
    return  _subscribeIcon;
}

- (UILabel *)tipLabel {
    if (!_tipLabel){
        UILabel *tipLabel = [UILabel createLabel:@"随时掌握房源最新动态" textColor:@"" fontSize:16];
        tipLabel.textColor = [UIColor colorWithHexStr:@"#4a4a4a"];
        tipLabel.font = [UIFont themeFontMedium:16];
        [self.contentView addSubview:tipLabel];
        _tipLabel = tipLabel;
    }
    return _tipLabel;
}

- (UIButton *)subscribeBtn {
    if (!_subscribeBtn) {
        UIButton *subscribeBtn = [[UIButton alloc] init];
//        subscribeBtn.backgroundColor = [UIColor themeRed1];
        [subscribeBtn setTitle:@"订阅动态" forState:UIControlStateNormal];
        [subscribeBtn setTitleColor:[UIColor colorWithHexStr:@"#4a4a4a"] forState:UIControlStateNormal];
        subscribeBtn.titleLabel.font = [UIFont themeFontSemibold:14];
        subscribeBtn.layer.cornerRadius = 16;
        subscribeBtn.layer.borderColor = [UIColor colorWithHexStr:@"#d8d8d8"].CGColor;
        subscribeBtn.layer.borderWidth = 0.5;
//        subscribeBtn.enabled = NO;
//        subscribeBtn.alpha = 0.6;
        [subscribeBtn addTarget:self action:@selector(subscribe) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:subscribeBtn];
        _subscribeBtn = subscribeBtn;
    }
    return _subscribeBtn;
}

- (void)setupUI {
    
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView);
        make.height.equalTo(self.contentView);
    }];
    [self.subscribeIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(31);
        make.centerY.equalTo(self.contentView);
        make.size.mas_offset(CGSizeMake(16, 16));
    }];
    [self.subscribeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.contentView).offset(25);
        make.centerY.equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView).offset(-31);
        make.width.mas_offset(93);
        make.height.mas_equalTo(32);
    }];
    [self.tipLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.subscribeIcon).offset(6);
        make.centerY.equalTo(self.contentView);
        make.right.mas_equalTo(self.subscribeBtn.mas_left).offset(-6);
    }];
//    _bgView = [[UIView alloc] init];
//    _bgView.backgroundColor = [UIColor themeGray7];
//    _bgView.layer.cornerRadius = 4;
//    _bgView.layer.masksToBounds = YES;
//    [self.contentView addSubview:_bgView];

    


//    _textField = [[FHTextField alloc] init];
//    _textField.edgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
//    _textField.tintColor = [UIColor themeRed3];
//    _textField.backgroundColor = [UIColor whiteColor];
//    _textField.font = [UIFont themeFontRegular:14];
//    _textField.textColor = [UIColor themeGray1];
//    _textField.keyboardType = UIKeyboardTypeNumberPad;
//    _textField.placeholder = @"填写手机号";
//    [_textField setValue:[UIColor themeGray4] forKeyPath:@"_placeholderLabel.textColor"];
//    _textField.layer.cornerRadius = 4;
//    _textField.layer.masksToBounds = YES;
//    _textField.delegate = self;
//    [self.bgView addSubview:_textField];

//    _legalAnnouncement = [[UILabel alloc] initWithFrame:CGRectZero];
//    _legalAnnouncement.textColor = [UIColor themeGray3];
//    _legalAnnouncement.textAlignment = NSTextAlignmentLeft;
//    NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"点击订阅即视为同意《个人信息保护声明》"];
//    [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(10, @"个人信息保护声明".length)];
//    _legalAnnouncement.attributedText = [attrStr copy];
//    _legalAnnouncement.font = [UIFont themeFontRegular:12];
//    UITapGestureRecognizer *tipTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(legalAnnouncementClick)];
//    _legalAnnouncement.userInteractionEnabled = YES;
//    [_legalAnnouncement addGestureRecognizer:tipTap];
//    [self.bgView addSubview:_legalAnnouncement];

//    [self.bgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(0);
//        make.left.mas_equalTo(20);
//        make.right.mas_equalTo(-20);
//        make.bottom.mas_equalTo(-20);
//        make.height.mas_equalTo(121);
//    }];

//    [self.legalAnnouncement mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.top.mas_equalTo(self.textField.mas_bottom).offset(10);
//        make.left.mas_equalTo(self.textField);
//        make.right.mas_equalTo(self.bgView);
//        make.height.mas_equalTo(17);
//    }];
//    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.mas_equalTo(15);
//        make.top.mas_equalTo(self.tipLabel.mas_bottom).offset(10);
//        make.right.mas_equalTo(self.subscribeBtn.mas_left).offset(-20);
//        make.height.mas_equalTo(32);
//    }];
}

//- (void)setPhoneNumber {
//    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
//    self.phoneNum = (NSString *)[sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
//    [self showFullPhoneNum:NO];
//}
//
//- (void)showFullPhoneNum:(BOOL)isShow {
//    if (self.phoneNum.length > 0) {
//        if(isShow){
//            self.textField.text = self.phoneNum;
//        }else{
//            // 显示 151*****010
//            NSString *tempPhone = self.phoneNum;
//            if (self.phoneNum.length == 11 && [self.phoneNum hasPrefix:@"1"] && [self isPureInt:self.phoneNum]) {
//                tempPhone = [NSString stringWithFormat:@"%@*****%@",[self.phoneNum substringToIndex:3],[self.phoneNum substringFromIndex:7]];
//            }
//            self.textField.text = tempPhone;
//            if (self.textField.text.length > 0) {
//                self.subscribeBtn.enabled = YES;
//                self.subscribeBtn.alpha = 1;
//            }else {
//                self.subscribeBtn.enabled = NO;
//                self.subscribeBtn.alpha = 0.6;
//            }
//        }
//    }
//}
//
//- (void)initNotification {
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillShowNotifiction:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillHideNotifiction:) name:UIKeyboardWillHideNotification object:nil];
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
//}
//
//- (void)subscribe {
//    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
//    tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
//    tracerDic[@"position"] = @"card";
//    [FHUserTracker writeEvent:@"click_confirm" params:tracerDic];
//    
//    NSString *phoneNum = self.phoneNum;
//    if (phoneNum.length == 11 && [phoneNum hasPrefix:@"1"] && [self isPureInt:phoneNum]) {
//        if(self.subscribeBlock){
//            self.subscribeBlock(self.phoneNum);
//        }
//    }else {
//        [[ToastManager manager] showToast:@"手机格式错误"];
//        self.textField.textColor = [UIColor themeRed1];
//    }
//}
//
//- (BOOL)isPureInt:(NSString*)string{
//    NSScanner* scan = [NSScanner scannerWithString:string];
//    int val;
//    return[scan scanInt:&val] && [scan isAtEnd];
//}
//
//#pragma mark - 键盘通知
//- (void)keyboardWillShowNotifiction:(NSNotification *)notification {
//    if (!self.textField.isFirstResponder) {
//        return;
//    }
//    NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
//    NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
//    CGFloat height = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue].size.height;
//    
//    CGRect frame = [self convertRect:self.bounds toView:nil];
//    CGFloat y = [UIScreen mainScreen].bounds.size.height - frame.origin.y - frame.size.height - height;
//    self.offsetY = y;
//    
//    if(y < 0){
//        [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
//            [UIView setAnimationBeginsFromCurrentState:YES];
//            FHDetailHouseSubscribeCorrectingModel *model = (FHDetailHouseSubscribeCorrectingModel *)self.currentData;
//            CGPoint point = model.tableView.contentOffset;
//            point.y -= y;
//            model.tableView.contentOffset = point;
//        } completion:^(BOOL finished) {
//            
//        }];
//    }
//}
//
//- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
//    self.offsetY = 0;
//    FHDetailHouseSubscribeCorrectingModel *model = (FHDetailHouseSubscribeCorrectingModel *)self.currentData;
//    if(model.tableView.contentOffset.y + model.tableView.frame.size.height > model.tableView.contentSize.height){
//        //剩余不满一屏幕
//        NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
//        NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
//        [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
//            [UIView setAnimationBeginsFromCurrentState:YES];
//            FHDetailHouseSubscribeCorrectingModel *model = (FHDetailHouseSubscribeCorrectingModel *)self.currentData;
//            CGPoint point = model.tableView.contentOffset;
//            point.y = (model.tableView.contentSize.height - model.tableView.frame.size.height);
//            model.tableView.contentOffset = point;
//        } completion:^(BOOL finished) {
//            
//        }];
//    }
//}
//
//-(void)legalAnnouncementClick{
//    if(self.legalAnnouncementClickBlock){
//        self.legalAnnouncementClickBlock();
//    }
//}
//
//#pragma mark -- UITextFieldDelegate
//
//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
//    NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
//    tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
//    tracerDic[@"position"] = @"card";
//    [FHUserTracker writeEvent:@"inform_show" params:tracerDic];
//    
//    [self showFullPhoneNum:YES];
//    return YES;
//}
//
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
////    NSArray *modes = @[NSDefaultRunLoopMode];
////    [self performSelector:@selector(showFullPhoneNum:) withObject:[NSNumber numberWithBool:NO] afterDelay:0 inModes:modes];
////    [self showFullPhoneNum:NO];
//    return YES;
//}
//
//- (void)textFieldDidChange:(NSNotification *)notification {
//    if (!self.textField.isFirstResponder) {
//        return;
//    }
//    if (self.textField.text.length > 11) {
//        self.textField.text = [self.textField.text substringToIndex:11];
//    }
//    
//    self.textField.textColor = [UIColor themeGray1];
//    self.phoneNum = self.textField.text;
//    
//    if (self.textField.text.length > 0) {
//        self.subscribeBtn.enabled = YES;
//        self.subscribeBtn.alpha = 1;
//    }else {
//        self.subscribeBtn.enabled = NO;
//        self.subscribeBtn.alpha = 0.6;
//    }
//}

@end


@implementation FHDetailHouseSubscribeCorrectingModel

@end
