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
@property(nonatomic, weak) FHTextField *textField;
@property(nonatomic, weak) UIImageView *bacIma;
@property(nonatomic, weak) UIImageView *titleImage;
@property (nonatomic, weak) UIImageView *shadowImage;
@property(nonatomic, assign) CGFloat offsetY;
@property(nonatomic, strong) NSString *phoneNum;
@property(nonatomic, weak) UILabel *legalAnnouncement;

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
    self.shadowImage.image = model.shadowImage;
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeBottomAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeTopAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView);
        }];
    }
    if(model.shdowImageScopeType == FHHouseShdowImageScopeTypeAll){
        [self.shadowImage mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.bottom.equalTo(self.contentView);
        }];
    }
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

- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}

- (UIImageView *)bacIma {
    if (!_bacIma) {
        UIImageView *bacIma = [[UIImageView alloc]init];
        bacIma.image = [UIImage imageNamed:@"houseSubscribeBac"];
        [self.contentView addSubview:bacIma];
        _bacIma = bacIma;
    }
    return  _bacIma;
}

- (UIImageView *)titleImage {
    if (!_titleImage) {
        UIImageView *titleImage = [[UIImageView alloc]init];
        titleImage.image = [UIImage imageNamed:@"houseSubscribe"];
        self.bacIma.userInteractionEnabled = YES;
        [self.bacIma addSubview:titleImage];
        _titleImage = titleImage;
    }
    return  _titleImage;
}

- (UIButton *)subscribeBtn {
    if (!_subscribeBtn) {
        UIButton *subscribeBtn = [[UIButton alloc] init];
        //        subscribeBtn.backgroundColor = [UIColor themeRed1];
        [subscribeBtn setTitle:@"订阅动态" forState:UIControlStateNormal];
        [subscribeBtn setTitleColor:[UIColor colorWithHexStr:@"#b5915c"] forState:UIControlStateNormal];
        subscribeBtn.titleLabel.font = [UIFont themeFontSemibold:16];
        subscribeBtn.layer.cornerRadius = 16;
        subscribeBtn.layer.borderColor = [UIColor colorWithHexStr:@"#d7bd96"].CGColor;
        subscribeBtn.layer.borderWidth = 0.5;
        //        subscribeBtn.enabled = NO;
        //        subscribeBtn.alpha = 0.6;
        [subscribeBtn addTarget:self action:@selector(subscribe) forControlEvents:UIControlEventTouchUpInside];
        [self.bacIma addSubview:subscribeBtn];
        _subscribeBtn = subscribeBtn;
    }
    return _subscribeBtn;
}

- (FHTextField *)textField {
    if (!_textField) {
        FHTextField *textField = [[FHTextField alloc] init];
        textField.edgeInsets = UIEdgeInsetsMake(0, 10, 0, -10);
        textField.tintColor = [UIColor themeRed3];
        textField.backgroundColor = [UIColor whiteColor];
        textField.font = [UIFont themeFontRegular:14];
        textField.textColor = [UIColor themeGray1];
        textField.layer.borderColor = [UIColor colorWithHexStr:@"#f9e7d5"].CGColor;
        textField.layer.borderWidth  = 0.5;
        textField.keyboardType = UIKeyboardTypeNumberPad;
        textField.placeholder = @"填写手机号";
        textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"填写手机号" attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexStr:@"#d9d9d9"]}];
        textField.layer.cornerRadius = 16;
        textField.layer.masksToBounds = YES;
        textField.delegate = self;
        [self.bacIma addSubview:textField];
        _textField = textField;
    }
    return _textField;
}

- (UILabel *)legalAnnouncement {
    if (!_legalAnnouncement) {
        UILabel *legalAnnouncement = [[UILabel alloc] initWithFrame:CGRectZero];
        legalAnnouncement.textColor = [UIColor colorWithHexStr:@"#9c6d4346"];
        legalAnnouncement.textAlignment = NSTextAlignmentLeft;
        NSDictionary *dic = @{NSKernAttributeName:@1.5f};
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:@"点击订阅即视为同意《个人信息保护声明》" attributes:dic];
          [attrStr addAttribute:NSUnderlineStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(10, @"个人信息保护声明".length)];
//        // 下划线
//        NSDictionary *attribtDic = @{NSUnderlineStyleAttributeName: [NSNumber numberWithInteger:NSUnderlineStyleSingle]};
//        NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]initWithString:textStr attributes:attribtDic];
//         NSMutableAttributedString *attribtStr = [[NSMutableAttributedString alloc]init];
        legalAnnouncement.attributedText = [attrStr copy];
        legalAnnouncement.font = [UIFont themeFontRegular:10];
        UITapGestureRecognizer *tipTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(legalAnnouncementClick)];
        legalAnnouncement.userInteractionEnabled = YES;
        [legalAnnouncement addGestureRecognizer:tipTap];
        [self.bacIma addSubview:legalAnnouncement];
        _legalAnnouncement = legalAnnouncement;
    }
    return _legalAnnouncement;
}
- (void)setupUI {
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.mas_equalTo(self.contentView).mas_offset(-12);
        make.height.mas_offset(187);
        make.bottom.mas_equalTo(self.contentView).mas_offset(12);
    }];
    [self.bacIma mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(15);
        make.right.mas_equalTo(self.contentView).offset(-15);
        make.top.mas_equalTo(self.contentView).offset(8);
        make.height.mas_offset(147);
    }];
    
    [self.titleImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.bacIma).offset(30);
        make.top.mas_equalTo(self.bacIma).offset(26);
        make.size.mas_offset(CGSizeMake(117, 24));
    }];
    
    [self.subscribeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.titleImage.mas_bottom).offset(18);
        make.right.mas_equalTo(self.bacIma).offset(-16);
        make.width.mas_equalTo(100);
        make.height.mas_equalTo(32);
    }];
    [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(self.titleImage.mas_bottom).offset(18);
        make.right.mas_equalTo(self.subscribeBtn.mas_left).offset(-10);
        make.height.mas_equalTo(32);
    }];
    [self.legalAnnouncement mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.textField.mas_bottom).offset(10);
        make.left.mas_equalTo(self.textField);
    }];
}

- (void)setPhoneNumber {
    YYCache *sendPhoneNumberCache = [[FHEnvContext sharedInstance].generalBizConfig sendPhoneNumberCache];
    id phoneCache = [sendPhoneNumberCache objectForKey:kFHPhoneNumberCacheKey];
    id loginPhoneCache = [sendPhoneNumberCache objectForKey:kFHPLoginhoneNumberCacheKey];
    
    NSString *phoneNum = nil;
    if ([phoneCache isKindOfClass:[NSString class]]) {
        NSString *cacheNum = (NSString *)phoneCache;
        if (cacheNum.length > 0) {
            phoneNum = cacheNum;
        }
    }else if ([loginPhoneCache isKindOfClass:[NSString class]]) {
        NSString *cacheNum = (NSString *)loginPhoneCache;
        if (cacheNum.length > 0) {
            phoneNum = cacheNum;
        }
    }
    self.phoneNum = phoneNum;
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

    NSString *phoneNum = self.phoneNum;
    if (phoneNum.length == 11 && [phoneNum hasPrefix:@"1"] && [self isPureInt:phoneNum]) {
        
        NSMutableDictionary *tracerDic = self.baseViewModel.detailTracerDic.mutableCopy;
        tracerDic[@"log_pb"] = self.baseViewModel.listLogPB ? self.baseViewModel.listLogPB : @"be_null";
        tracerDic[@"position"] = @"card";
        [FHUserTracker writeEvent:@"click_confirm" params:tracerDic];
        
        if(self.subscribeBlock){
            self.subscribeBlock(self.phoneNum);
        }
    }else {
        [[ToastManager manager] showToast:@"手机格式错误"];
        self.textField.textColor = [UIColor themeOrange1];
    }
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
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
            FHDetailHouseSubscribeCorrectingModel *model = (FHDetailHouseSubscribeCorrectingModel *)self.currentData;
            CGPoint point = model.tableView.contentOffset;
            point.y -= y;
            model.tableView.contentOffset = point;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void)keyboardWillHideNotifiction:(NSNotification *)notification {
    self.offsetY = 0;
    FHDetailHouseSubscribeCorrectingModel *model = (FHDetailHouseSubscribeCorrectingModel *)self.currentData;
    if(model.tableView.contentOffset.y + model.tableView.frame.size.height > model.tableView.contentSize.height){
        //剩余不满一屏幕
        NSNumber *duration = notification.userInfo[UIKeyboardAnimationDurationUserInfoKey];
        NSNumber *curve = notification.userInfo[UIKeyboardAnimationCurveUserInfoKey];
        [UIView animateWithDuration:[duration floatValue] delay:0 options:(UIViewAnimationOptions)[curve integerValue] animations:^{
            [UIView setAnimationBeginsFromCurrentState:YES];
            FHDetailHouseSubscribeCorrectingModel *model = (FHDetailHouseSubscribeCorrectingModel *)self.currentData;
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


@implementation FHDetailHouseSubscribeCorrectingModel

@end
