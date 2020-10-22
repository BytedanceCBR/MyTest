//
//  FHHouseDetailReportAddtionViewController.m
//  FHHouseDetail
//
//  Created by wangzhizhou on 2020/10/14.
//

#import "FHHouseDetailReportAddtionViewController.h"
#import "FHMainApi.h"
#import "TTReachability.h"
#import "FRAddMultiImagesView.h"
#import <ByteDanceKit/ByteDanceKit.h>
#import "FHCommonDefines.h"
#import <ReactiveObjC/ReactiveObjC.h>
#import "ToastManager.h"
#import <ios_house_im/FHIMSafeAreasGuide.h>
#import "FHHouseDetailReportViewController.h"
#import "UIViewController+HUD.h"
#import "FRUploadImageManager.h"
#import "TTPostThreadDefine.h"
#import "FHUserTracker.h"

#define FH_HOUSE_DETAIL_ADDITION_TEXT_COUNT_LIMIN 200
#define FHHouseDetailReportItemPhoneNumberDigitCount 11
#define kFHHouseDetailReportPhoneNumberStatusNotification @"kFHHouseDetailReportPhoneNumberStatusNotification"

typedef NS_ENUM(NSUInteger, FHHouseDetailReportAdditionItemType) {
    FHHouseDetailReportAdditionItemType_Problem,
    FHHouseDetailReportAdditionItemType_Name,
    FHHouseDetailReportAdditionItemType_PhoneNumber,
    FHHouseDetailReportAdditionItemType_AdditionContent,
    FHHouseDetailReportAdditionItemType_ReportImages,
    FHHouseDetailReportAdditionItemType_Hint,
};

@interface FHHouseDetailReportAdditionItem: NSObject
@property (nonatomic, assign) FHHouseDetailReportAdditionItemType type;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *detail;
@property (nonatomic, assign) CGFloat height;
@end
@implementation FHHouseDetailReportAdditionItem
@end
@protocol FHHouseDetailReportAdditionCellDelegate <NSObject>
- (void)reloadSection:(NSIndexPath *)indexPath;
- (CGFloat)heightForImageCount:(NSUInteger)count;
- (void)checkIfCanSubmit;
@end

@interface FHHouseDetailReportAdditionCell : UITableViewCell<FRAddMultiImagesViewDelegate, UITextViewDelegate>
@property (nonatomic, strong) NSIndexPath *indexPath;
@property (nonatomic, strong) FHHouseDetailReportAdditionItem *item;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) FHHouseDetailReportPhoneNumberInvalidTextField *phoneTextField;
@property (nonatomic, strong) UILabel *textViewRightLabel;
@property (nonatomic, strong) UITextView *inputTextView;
@property (nonatomic, strong) UILabel *inputTextViewLimitLabel;
@property (nonatomic, strong) FRAddMultiImagesView *imagesView;
@property (nonatomic, strong) UILabel *hintLabel;
@property (nonatomic, strong) UIView *bottomLine;

@property (nonatomic, assign) id<FHHouseDetailReportAdditionCellDelegate> delegate;

+ (instancetype)createCell;
- (void)checkIfValidForSubmit;
@end

@implementation FHHouseDetailReportAdditionCell

+ (instancetype)createCell {
    return [[FHHouseDetailReportAdditionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
}

- (void)checkIfValidForSubmit {
    if(self.delegate && [self.delegate respondsToSelector:@selector(checkIfCanSubmit)]) {
        [self.delegate checkIfCanSubmit];
    }
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.textColor = [UIColor themeGray1];
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UILabel *)detailLabel {
    if(!_detailLabel) {
        _detailLabel = [UILabel new];
        _detailLabel.textColor = [UIColor themeGray1];
        _detailLabel.font = [UIFont themeFontRegular:16];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _detailLabel;
}

- (FHHouseDetailReportPhoneNumberInvalidTextField *)phoneTextField {
    if(!_phoneTextField) {
        _phoneTextField = [FHHouseDetailReportPhoneNumberInvalidTextField new];
        _phoneTextField.textColor = [UIColor themeGray1];
        _phoneTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请填写" attributes:@{
            NSForegroundColorAttributeName: [UIColor themeGray3],
            NSFontAttributeName: [UIFont themeFontRegular:16]
        }];
        _phoneTextField.keyboardType = UIKeyboardTypeNumberPad;
        _phoneTextField.rightView = self.textViewRightLabel;
        _phoneTextField.rightViewMode = UITextFieldViewModeAlways;
        
        NSUInteger validPhoneNumberDigitCount = FHHouseDetailReportItemPhoneNumberDigitCount;
        @weakify(self);
        [[[_phoneTextField.rac_textSignal distinctUntilChanged] deliverOnMainThread] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            [self updatePhoneNumberHint:nil isShow:NO];
            if(x.length > validPhoneNumberDigitCount) {
                x = [x substringWithRange:NSMakeRange(0, validPhoneNumberDigitCount)];
                self.phoneTextField.text = x;
            }
            self.item.detail = x;
            [self checkIfValidForSubmit];
            
        }];
        
        [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:kFHHouseDetailReportPhoneNumberStatusNotification object:nil] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable x) {
            @strongify(self);
            [self updatePhoneNumberHint:@"手机号格式错误" isShow:YES];
        }];
    }
    return _phoneTextField;
}

- (UILabel *)textViewRightLabel {
    if(!_textViewRightLabel) {
        _textViewRightLabel = [UILabel new];
        _textViewRightLabel.font = [UIFont themeFontLight:12];
        _textViewRightLabel.textColor = [UIColor redColor];
        _textViewRightLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _textViewRightLabel;
}

- (void)updatePhoneNumberHint:(NSString *)hint isShow:(BOOL)show {
    self.textViewRightLabel.text = show ? hint : @"";
    self.phoneTextField.textColor = show ? self.textViewRightLabel.textColor : [UIColor themeGray1];
}

- (UITextView *)inputTextView {
    if(!_inputTextView) {
        _inputTextView = [UITextView new];
        _inputTextView.textColor = [UIColor themeGray1];
        _inputTextView.font = [UIFont themeFontRegular:16];
        _inputTextView.btd_attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请描述/上传相关内容以证明举报属实，如微聊记录等" attributes:@{
            NSForegroundColorAttributeName: [UIColor themeGray3],
            NSFontAttributeName: [UIFont themeFontRegular:16]
        }];
        _inputTextView.btd_placeholderBackgroundColor = UIColor.clearColor;
        _inputTextView.showsVerticalScrollIndicator = YES;
        _inputTextView.showsHorizontalScrollIndicator = NO;
        _inputTextView.delegate = self;
        @weakify(self);
        [[[self.inputTextView.rac_textSignal deliverOnMainThread] distinctUntilChanged] subscribeNext:^(NSString * _Nullable x) {
            @strongify(self);
            self.inputTextViewLimitLabel.attributedText = [self textViewLimitTip];
            self.item.detail = x;
            [self checkIfValidForSubmit];
        }];
    }
    return _inputTextView;
}

- (UILabel *)inputTextViewLimitLabel {
    if(!_inputTextViewLimitLabel) {
        _inputTextViewLimitLabel = [UILabel new];
        _inputTextViewLimitLabel.textColor = [UIColor themeGray1];
        _inputTextViewLimitLabel.font = [UIFont themeFontRegular:16];
    }
    return _inputTextViewLimitLabel;
}

- (NSAttributedString *)textViewLimitTip {
    NSString *countString = [NSString stringWithFormat:@"%@/%@",@(self.inputTextView.text.length), @(FH_HOUSE_DETAIL_ADDITION_TEXT_COUNT_LIMIN)];
    NSMutableAttributedString *ret = [[NSMutableAttributedString alloc] initWithString:countString];
    NSRange range = [countString rangeOfString:@"/"];
    if(range.location != NSNotFound) {
        [ret addAttributes:@{
                    NSForegroundColorAttributeName: [UIColor themeGray1],
                    NSFontAttributeName: [UIFont themeFontRegular:16]
        } range:NSMakeRange(0, range.location)];
        
        [ret addAttributes:@{
            NSForegroundColorAttributeName: [UIColor themeGray3],
            NSFontAttributeName: [UIFont themeFontRegular:16]
        } range:NSMakeRange(range.location, countString.length - range.location)];
    }
    return ret.copy;
}

- (FRAddMultiImagesView *)imagesView {
    if(!_imagesView) {
        _imagesView = [[FRAddMultiImagesView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH - 40, 122) assets:nil images:nil];
        _imagesView.delegate = self;
        _imagesView.hideAddImagesButtonWhenEmpty = NO;
        _imagesView.selectionLimit = 9;
        [_imagesView startTrackImagepicker];
    }
    return _imagesView;
}

- (UILabel *)hintLabel {
    if(!_hintLabel) {
        _hintLabel = [UILabel new];
        _hintLabel.textColor = [UIColor themeGray3];
        _hintLabel.font = [UIFont themeFontRegular:14];
        _hintLabel.numberOfLines = 0;
    }
    return _hintLabel;
}

- (UIView *)bottomLine {
    if(!_bottomLine) {
        _bottomLine = [UIView new];
        _bottomLine.backgroundColor = [UIColor themeGray6];
    }
    return _bottomLine;
}

- (void)setItem:(FHHouseDetailReportAdditionItem *)item {
    
    _item = item;
    
    [self layoutContent];
}

- (void)showMustRequiredTitle:(BOOL)isRequired text:(NSString *)showText {
    NSString *requiredText = showText;
    if(isRequired) {
        if(![self.titleLabel.text containsString:requiredText]) {
            NSAttributedString *requiredAttributeText = [[NSAttributedString alloc] initWithString:requiredText attributes:@{
                NSForegroundColorAttributeName: [UIColor themeGray3],
                NSFontAttributeName: self.titleLabel.font
            }];
            NSMutableAttributedString *titleAttributeText = [[NSMutableAttributedString alloc] initWithString:self.titleLabel.text attributes:@{
                NSForegroundColorAttributeName: self.titleLabel.textColor,
                NSFontAttributeName: self.titleLabel.font
            }];
            [titleAttributeText appendAttributedString:requiredAttributeText];
            self.titleLabel.attributedText = titleAttributeText;
        }
    } else {
        if(requiredText.length > 0 && [self.titleLabel.text containsString:requiredText]) {
            NSString *title = [self.titleLabel.text stringByReplacingOccurrencesOfString:requiredText withString:@""];
            NSMutableAttributedString *titleAttributeText = [[NSMutableAttributedString alloc] initWithString:title attributes:@{
                NSForegroundColorAttributeName: self.titleLabel.textColor,
                NSFontAttributeName: self.titleLabel.font
            }];
            self.titleLabel.attributedText = titleAttributeText;
        }
    }
}

- (void)layoutContent {
        
    [self.contentView addSubview:self.bottomLine];
    self.bottomLine.hidden = YES;
    [self.bottomLine mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(20);
        make.right.equalTo(self.contentView).offset(-20);
        make.height.mas_equalTo(1);
        make.bottom.equalTo(self.contentView);
    }];
    
    [self showMustRequiredTitle:NO text:nil];
    switch (self.item.type) {
        case FHHouseDetailReportAdditionItemType_Problem:
        case FHHouseDetailReportAdditionItemType_Name:
        {
            [self.contentView addSubview:self.titleLabel];
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(20);
                make.centerY.equalTo(self.contentView);
                make.height.mas_equalTo(self.item.height);
                make.top.bottom.equalTo(self.contentView);
                make.width.mas_equalTo([self.item.title btd_sizeWithFont:self.titleLabel.font width:SCREEN_WIDTH].width);
            }];
                        
            [self.contentView addSubview:self.detailLabel];
            [self.detailLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(self.titleLabel.mas_right).offset(10);
                make.right.equalTo(self.contentView).offset(-20);
                make.top.bottom.equalTo(self.contentView);
            }];
            
            [self.titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];

            self.titleLabel.text = self.item.title;
            self.detailLabel.text = self.item.detail;
        }
            break;
        case FHHouseDetailReportAdditionItemType_PhoneNumber:
        {
            [self.contentView addSubview:self.titleLabel];
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(20);
                make.centerY.equalTo(self.contentView);
                make.top.bottom.equalTo(self.contentView);
                make.height.mas_equalTo(self.item.height);
            }];
            
            [self.contentView addSubview:self.phoneTextField];
            [self.phoneTextField mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(self.contentView);
                make.left.equalTo(self.titleLabel.mas_right).offset(15);
                make.right.equalTo(self.contentView).offset(-20);
                make.top.bottom.equalTo(self.contentView);
            }];
            
            [self.titleLabel setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
            
            self.titleLabel.text = self.item.title;
            self.phoneTextField.text = self.item.detail;
            self.bottomLine.hidden = NO;
        }
            break;
        case FHHouseDetailReportAdditionItemType_AdditionContent:
        {
            [self.contentView addSubview:self.titleLabel];
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(20);
                make.top.equalTo(self.contentView).offset(14);
                make.right.equalTo(self.contentView).offset(-20);
                make.height.mas_equalTo(22);
            }];
            
            [self.contentView addSubview:self.inputTextView];
            [self.inputTextView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(15);
                make.right.equalTo(self.contentView).offset(-15);
                make.top.equalTo(self.titleLabel.mas_bottom).offset(15);
                make.bottom.equalTo(self.contentView).offset(-45);
                make.height.mas_equalTo(88);
            }];
                        
            [self.contentView addSubview:self.inputTextViewLimitLabel];
            [self.inputTextViewLimitLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.right.equalTo(self.contentView).offset(-20);
                make.height.mas_equalTo(22);
            }];
            
            self.titleLabel.text = self.item.title;
            self.inputTextView.text = self.item.detail;
            self.inputTextViewLimitLabel.attributedText = [self textViewLimitTip];
            [self showMustRequiredTitle:YES text:@"（必填）"];
        }
            break;
        case FHHouseDetailReportAdditionItemType_ReportImages:
        {
            [self.contentView addSubview:self.titleLabel];
            [self.titleLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(self.contentView).offset(20);
                make.top.equalTo(self.contentView).offset(14);
                make.right.equalTo(self.contentView).offset(-20);
                make.height.mas_equalTo(22);
            }];
            
            [self.contentView addSubview:self.imagesView];
            [self.imagesView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.titleLabel.mas_bottom).offset(20);
                make.left.right.equalTo(self.titleLabel);
                make.height.mas_equalTo(self.item.height);
                make.bottom.equalTo(self.contentView).offset(-24);
            }];
            
            self.titleLabel.text = self.item.title;
            [self showMustRequiredTitle:YES text:@"（必填，支持多张图片）"];
        }
            break;
        case FHHouseDetailReportAdditionItemType_Hint:
        {
            [self.contentView addSubview:self.hintLabel];
            [self.hintLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.top.equalTo(self.contentView).offset(14);
                make.left.equalTo(self.contentView).offset(20);
                make.bottom.equalTo(self.contentView).offset(-14);
                make.right.equalTo(self.contentView).offset(-20);
            }];
            
            self.hintLabel.text = self.item.detail;
        }
            break;
        default:
            break;
    }
}

#pragma mark - FRAddMultiImagesViewDelegate

- (void)addMultiImagesView:(FRAddMultiImagesView *)addMultiImagesView changeToSize:(CGSize)size {
    if(size.height > 0 && self.item.height != size.height) {
        self.item.height = size.height;
        if(self.delegate && [self.delegate respondsToSelector:@selector(reloadSection:)]) {
            [self.delegate reloadSection:self.indexPath];
        }
    }
    [self checkIfValidForSubmit];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    NSString *replacedString = [textView.text stringByReplacingCharactersInRange:range withString:text];
    return ![text isEqualToString:@"\n"] && replacedString.length <= FH_HOUSE_DETAIL_ADDITION_TEXT_COUNT_LIMIN;
    
}
@end

typedef NS_ENUM(NSUInteger, FHHouseDetailReportInfoState) {
    FHHouseDetailReportInfoState_Unknown,
    FHHouseDetailReportInfoState_OutDate,
    FHHouseDetailReportInfoState_UnCompleted,
    FHHouseDetailReportInfoState_Submitted
};

@interface FHHouseDetailRerportInfoDataModel : JSONModel
@property (nonatomic, copy) NSString *houseName;
@property (nonatomic, copy) NSString *problem;
@property (nonatomic, assign) FHHouseDetailReportInfoState status;
@property (nonatomic, copy) NSString *ticketId;
@end
@implementation FHHouseDetailRerportInfoDataModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
+ (JSONKeyMapper*)keyMapper
{
  NSDictionary *dict = @{
    @"houseName": @"house_name",
    @"problem": @"problem",
    @"status": @"status",
    @"ticketId": @"ticket_id",
  };
  return [[JSONKeyMapper alloc]initWithModelToJSONBlock:^NSString *(NSString *keyName) {
     return dict[keyName]?:keyName;
  }];
}
@end
@interface FHHouseDetailRerportInfoModel : JSONModel<FHBaseModelProtocol>
@property (nonatomic, copy , nullable) NSString *status;
@property (nonatomic, copy , nullable) NSString *message;
@property (nonatomic, strong , nullable) FHHouseDetailRerportInfoDataModel *data ;
@end
@implementation FHHouseDetailRerportInfoModel
+ (BOOL)propertyIsOptional:(NSString *)propertyName {
    return YES;
}
@end

@interface FHHouseDetailReportAddtionViewController ()<UITableViewDelegate, UITableViewDataSource, FHHouseDetailReportAdditionCellDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *statusView;
@property (nonatomic, strong) UIView *statusContentView;
@property (nonatomic, strong) UIImageView *statusBgImageView;
@property (nonatomic, strong) UILabel *statusTitleLabel;
@property (nonatomic, strong) UILabel *statusSubtitleLabel;
@property (nonatomic, strong) NSArray<NSArray<FHHouseDetailReportAdditionItem *> *> *items;
@property (nonatomic, strong) UIView *submitView;
@property (nonatomic, strong) UIButton *submitButton;
@property (nonatomic, strong) FHHouseDetailReportAdditionCell *problemCell;
@property (nonatomic, strong) FHHouseDetailReportAdditionCell *nameCell;
@property (nonatomic, strong) FHHouseDetailReportAdditionCell *phoneCell;
@property (nonatomic, strong) FHHouseDetailReportAdditionCell *additionCell;
@property (nonatomic, strong) FHHouseDetailReportAdditionCell *imagesCell;
@property (nonatomic, strong) FHHouseDetailReportAdditionCell *hintCell;

// 数据
@property (nonatomic, copy  ) NSString *ticketID;
@property (nonatomic, copy  ) NSString *houseId;
@property (nonatomic, copy  ) NSString *houseType;
@property (nonatomic, strong) FRUploadImageManager *uploadImageManager;
@end

@implementation FHHouseDetailReportAddtionViewController

+ (void)gotoReportAdditionPageWithUserInfoDict:(NSDictionary *)userInfoDict {
    TTRouteUserInfo *userInfo = [[TTRouteUserInfo alloc] initWithInfo:userInfoDict];
    [[TTRoute sharedRoute] openURLByPushViewController:[NSURL URLWithString:@"sslocal://house_report_additional"] userInfo:userInfo];
}

- (instancetype)initWithRouteParamObj:(TTRouteParamObj *)paramObj {
    if(self = [super initWithRouteParamObj:paramObj]) {
        self.ticketID = [paramObj.allParams btd_stringValueForKey:@"ticket_id"];
        self.houseId = [paramObj.allParams btd_stringValueForKey:@"house_id"];
        self.houseType = [paramObj.allParams btd_stringValueForKey:@"house_type"];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor themeWhite];
    [self setupDefaultNavBar:NO];
    self.customNavBarView.title.text = @"房源举报信息补充";
    [self configStatusView];
    
    
    [self.submitView addSubview:self.submitButton];
    [self.submitButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.submitView).offset(20);
        make.right.equalTo(self.submitView).offset(-20);
        make.bottom.equalTo(self.submitView).offset(-10);
        make.top.equalTo(self.submitView).offset(10);
    }];
    
    [self.view addSubview:self.submitView];
    [self.submitView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.tableView.mas_bottom);
        make.height.mas_equalTo(64);
        make.bottom.equalTo(self.view).offset(-FHIMAreaInsetsBottom());
    }];
    
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.customNavBarView.mas_bottom);
        make.bottom.equalTo(self.submitView.mas_top);
    }];
    
    @weakify(self);
    [[[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardWillChangeFrameNotification object:nil] deliverOnMainThread] subscribeNext:^(NSNotification * _Nullable notification) {
        @strongify(self);

        CGRect rect = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardOriginY = rect.origin.y;
        CGFloat keyboardHeight = rect.size.height;
        BOOL isShow = keyboardOriginY < SCREEN_HEIGHT;
        CGFloat duration = [notification.userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        [UIView animateWithDuration:duration animations:^{
            [self.submitView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.bottom.equalTo(self.view).offset(-(isShow ? keyboardHeight : FHIMAreaInsetsBottom() ));
            }];

            [self.view setNeedsLayout];
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self scrollToDisplayFirstResponder];
        }];
    }];
    
    [self loadData];
    
    [self adddGoDetail];
}

- (void)adddGoDetail {
    NSMutableDictionary *reportParams = [NSMutableDictionary dictionary];
    reportParams[UT_ORIGIN_FROM] = self.tracerDict[UT_ORIGIN_FROM]?:UT_BE_NULL;
    reportParams[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
    reportParams[UT_PAGE_TYPE] = [self pageType];
    reportParams[@"event_tracking_id"] = @"113178";
    TRACK_EVENT(UT_GO_DETAIL, reportParams);
}

- (NSString *)pageType {
    return @"feedback_AddInfo_detail";
}

- (void)loadData {
    
    if(![TTReachability isNetworkConnected]) {
        [self.emptyView showEmptyWithType:FHEmptyMaskViewTypeNoNetWorkAndRefresh];
        return;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"ticket_id"] = self.ticketID;
    
    [self startLoading];
    [FHMainApi requestHouseFeedbackInfo:params completion:^(NSError * _Nonnull error, id  _Nonnull jsonObj) {
        [self endLoading];
        // 处理请求结果
        if(error) {
            [[ToastManager manager] showToast:@"网络错误，请稍后重试"];
            return;
        }
        else {
            
            NSError *error = nil;
            FHHouseDetailRerportInfoModel *model = [[FHHouseDetailRerportInfoModel alloc] initWithDictionary:jsonObj error:&error];
            if(model && [model.status isEqual:@"0"]) {
                switch (model.data.status) {
                    case FHHouseDetailReportInfoState_Submitted:
                    {
                        [self showSubmitted];
                    }
                        break;
                    case FHHouseDetailReportInfoState_OutDate:
                    {
                        [self showOutDated];
                    }
                        break;
                    case FHHouseDetailReportInfoState_UnCompleted:
                    {
                        FHHouseDetailReportAdditionItem *problemItem = [FHHouseDetailReportAdditionItem new];
                        problemItem.type = FHHouseDetailReportAdditionItemType_Problem;
                        problemItem.height = 50;
                        problemItem.title = @"反馈问题:";
                        problemItem.detail = model.data.problem;
                        FHHouseDetailReportAdditionItem *nameItem = [FHHouseDetailReportAdditionItem new];
                        nameItem.type = FHHouseDetailReportAdditionItemType_Name;
                        nameItem.height = 50;
                        nameItem.title = @"房源名称:";
                        nameItem.detail = model.data.houseName;
                        
//                        FHHouseDetailReportAdditionItem *phoneItem = [FHHouseDetailReportAdditionItem new];
//                        phoneItem.type = FHHouseDetailReportAdditionItemType_PhoneNumber;
//                        phoneItem.height = 50;
//                        phoneItem.title = @"联系电话";
//                        phoneItem.detail = @"";
                        
                        FHHouseDetailReportAdditionItem *additionItem = [FHHouseDetailReportAdditionItem new];
                        additionItem.type = FHHouseDetailReportAdditionItemType_AdditionContent;
                        additionItem.height = 190;
                        additionItem.title = @"补充信息";
                        additionItem.detail = @"";
                        
                        FHHouseDetailReportAdditionItem *imagesItem = [FHHouseDetailReportAdditionItem new];
                        imagesItem.type = FHHouseDetailReportAdditionItemType_ReportImages;
                        imagesItem.height = [self heightForImageCount:0];
                        imagesItem.title = @"上传凭证";
                        imagesItem.detail = @"";
                        
                        FHHouseDetailReportAdditionItem *hintItem = [FHHouseDetailReportAdditionItem new];
                        hintItem.type = FHHouseDetailReportAdditionItemType_Hint;
                        hintItem.height = 108;
                        hintItem.title = @"";
                        hintItem.detail = @"为了更好的解决您反馈的房源问题，提高核实效率，请您上传该房源的举报凭证，包括但不限于聊天记录等。该链接有效期为3个自然日，我们会在收到后尽快核实回复，感谢您的配合！";
                        
                        self.items = @[
                            @[problemItem,nameItem],
                            @[additionItem],
                            @[imagesItem],
                            @[hintItem],
                        ];
                        [self.tableView reloadData];
                        self.submitView.hidden = NO;
                    }
                        break;
                    default:
                        break;
                }
            }
        }
    }];
}

- (void)retryLoadData {
    [self loadData];
}

- (void)configStatusView {
    [self.view addSubview:self.statusView];
    [self.statusView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.bottom.right.equalTo(self.view);
        make.top.equalTo(self.customNavBarView.mas_bottom);
    }];
}

- (UIView *)statusView {
    if(!_statusView) {
        _statusView = [UIView new];
        _statusView.backgroundColor = [UIColor themeWhite];
        
        [_statusView addSubview:self.statusContentView];
        [self.statusContentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.statusView);
            make.centerY.equalTo(self.statusView).offset(-44);
            make.width.equalTo(self.statusView);
            make.height.mas_equalTo(165);
        }];
    }
    return _statusView;
}

- (UIView *)statusContentView {
    if(!_statusContentView) {
        _statusContentView = [UIView new];
        
        [_statusContentView addSubview:self.statusBgImageView];
        [self.statusBgImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.width.height.mas_equalTo(115);
            make.top.equalTo(self.statusContentView);
            make.centerX.equalTo(self.statusContentView);
        }];
        
        [_statusContentView addSubview:self.statusTitleLabel];
        [self.statusTitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.statusContentView);
            make.top.equalTo(self.statusBgImageView.mas_bottom).offset(10);
        }];
        
        [_statusContentView addSubview:self.statusSubtitleLabel];
        [self.statusSubtitleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.statusContentView);
            make.top.equalTo(self.statusTitleLabel.mas_bottom).offset(3);
            make.bottom.equalTo(self.statusContentView);
        }];
    }
    return _statusContentView;
}

- (UIImageView *)statusBgImageView {
    if(!_statusBgImageView) {
        _statusBgImageView = [UIImageView new];
        _statusBgImageView.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _statusBgImageView;
}

- (UILabel *)statusTitleLabel {
    if(!_statusTitleLabel) {
        _statusTitleLabel = [UILabel new];
        _statusTitleLabel.font = [UIFont themeFontRegular:14];
        _statusTitleLabel.textColor = [UIColor themeGray2];
    }
    return _statusTitleLabel;
}

- (UILabel *)statusSubtitleLabel {
    if(!_statusSubtitleLabel) {
        _statusSubtitleLabel = [UILabel new];
        _statusSubtitleLabel.textColor = [UIColor themeGray3];
        _statusSubtitleLabel.font = [UIFont themeFontRegular:12];
    }
    return _statusSubtitleLabel;
}

- (void)showSubmitted {
    UIImage *image = [UIImage imageNamed:kFHErrorMaskNetWorkErrorImageName];
    self.statusBgImageView.image = image;
    self.statusTitleLabel.text = @"补充信息已提交";
    self.statusSubtitleLabel.text = @"反馈进度可在房源举报反馈通知中查看";
    [self.view bringSubviewToFront:self.statusView];
}

- (void)showOutDated {
    UIImage *image = [UIImage imageNamed:@"fh_ugc_home_page_no_auth"];
    self.statusBgImageView.image = image;
    self.statusTitleLabel.text = @"链接已过期";
    self.statusSubtitleLabel.text = @"如需举报，可至房源详情页重新提交";
    [self.view bringSubviewToFront:self.statusView];
}

- (UITableView *)tableView{
    if(!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [_tableView addGestureRecognizer:tap];
        _tableView.backgroundColor = [UIColor themeWhite];
        _tableView.rowHeight = UITableViewAutomaticDimension;
        _tableView.estimatedRowHeight = UITableViewAutomaticDimension;
        _tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, CGFLOAT_MIN)];
        
        
        self.problemCell = [FHHouseDetailReportAdditionCell createCell];
        self.nameCell = [FHHouseDetailReportAdditionCell createCell];
        self.phoneCell = [FHHouseDetailReportAdditionCell createCell];
        self.phoneCell.delegate = self;
        self.additionCell = [FHHouseDetailReportAdditionCell createCell];
        self.additionCell.delegate = self;
        self.imagesCell = [FHHouseDetailReportAdditionCell createCell];
        self.imagesCell.delegate = self;
        self.hintCell = [FHHouseDetailReportAdditionCell createCell];
    }
    return _tableView;
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self.view endEditing:YES];
}

- (FRUploadImageManager *)uploadImageManager {
    if (!_uploadImageManager) {
        _uploadImageManager = [[FRUploadImageManager alloc] init];
    }
    return _uploadImageManager;
}

#pragma mark UITableViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    UIView *footer = [UIView new];
    footer.backgroundColor = [UIColor themeGray7];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section != self.items.count - 1) {
        return 12;
    }
    return CGFLOAT_MIN;
}

- (UIView *)submitView {
    if(!_submitView) {
        _submitView = [UIView new];
        _submitView.backgroundColor = [UIColor themeWhite];
        _submitView.hidden = YES;
    }
    return _submitView;
}

- (UIButton *)submitButton {
    if(!_submitButton) {
        _submitButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _submitButton.layer.cornerRadius = 22;
        _submitButton.layer.masksToBounds = YES;
        [_submitButton setTitle:@"提交举报" forState:UIControlStateNormal];
        _submitButton.titleLabel.font = [UIFont themeFontSemibold:16];
        _submitButton.backgroundColor = [UIColor colorWithHexStr:@"FF9629"];
        [self updateSubmitButtonStatus:NO];
        
        @weakify(self);
        [[[[_submitButton rac_signalForControlEvents:UIControlEventTouchUpInside] deliverOnMainThread] throttle:0.3] subscribeNext:^(__kindof UIControl * _Nullable x) {
            @strongify(self);
            [self submitAction];
        }];
    }
    return _submitButton;
}

- (void)updateSubmitButtonStatus:(BOOL)isEnable {
    self.submitButton.enabled = isEnable;
    self.submitButton.alpha = isEnable ? 1 : 0.4;
}

- (void)checkIfCanSubmit {
    
//    BOOL isPhoneValid = [self.phoneCell.item.detail validateContactNumber];
//    if(!isPhoneValid && self.phoneCell.item.detail.length == FHHouseDetailReportItemPhoneNumberDigitCount) {
//        [[NSNotificationCenter defaultCenter] postNotificationName:kFHHouseDetailReportPhoneNumberStatusNotification object:nil];
//    }
    BOOL isAdditionContentValid = self.additionCell.item.detail.length > 0;
    BOOL isImagesValid = self.imagesCell.imagesView.selectedImageCacheTasks.count > 0;

    BOOL isEnableSubmit = isAdditionContentValid && isImagesValid;
    [self updateSubmitButtonStatus: isEnableSubmit];
}

- (void)uploadImagesWithCompletion:(void(^)(NSArray<FRUploadImageModel*> *uploadImageModels))completion {
    
    NSMutableArray<FRUploadImageModel *> * images = (NSMutableArray<FRUploadImageModel*> *)[NSMutableArray array];
    
    // 图片压缩任务
    NSArray<TTUGCImageCompressTask*> *taskImages = self.imagesCell.imagesView.selectedImageCacheTasks;
    // 选中的图片
    NSArray<UIImage*> *thumbImages = self.imagesCell.imagesView.selectedThumbImages;
    
    // 构造图片上传数据模型
    for (int i = 0; i < [taskImages count]; i ++) {
        TTUGCImageCompressTask* task = [taskImages objectAtIndex:i];
        UIImage* thumbImage = nil;
        if (thumbImages.count > i) {
            thumbImage = thumbImages[i];
        }
        FRUploadImageModel * model = [[FRUploadImageModel alloc] initWithCacheTask:task thumbnail:thumbImage];
        model.webURI = task.assetModel.imageURI;
        model.imageOriginWidth = task.assetModel.width;
        model.imageOriginHeight = task.assetModel.height;
        [images addObject:model];
    }
    
    @weakify(self);
    [self.uploadImageManager uploadPhotos:images extParameter:@{} progressBlock:^(int expectCount, int receivedCount) {
        // TODO: 展示进度
        
    } finishBlock:^(NSError *error, NSArray<FRUploadImageModel*> *finishUpLoadModels) {
        @strongify(self);
        NSError *finishError = nil;
        for (FRUploadImageModel *model in finishUpLoadModels) {
            if (isEmptyString(model.webURI)) {
                finishError = [NSError errorWithDomain:kFRPostThreadErrorDomain code:TTPostThreadErrorCodeUploadImgError userInfo:nil];
                break;
            }
        }
        
        if (error || finishError) {
            [self dismissLoadingAlert];
            //端监控
            //图片上传失败
            NSMutableDictionary * monitorDictionary = [NSMutableDictionary dictionary];
            [monitorDictionary setValue:@(images.count) forKey:@"img_count"];
            NSMutableArray * imageNetworks = [NSMutableArray arrayWithCapacity:images.count];
            
            for (FRUploadImageModel * imageModel in images) {
                NSInteger status = isEmptyString(imageModel.webURI)?0:1;
                NSInteger code = 0;
                if (imageModel.error) {
                    code = imageModel.error.code;
                }
                [imageNetworks addObject:@{@"network":@(imageModel.networkConsume)
                                           , @"local":@(imageModel.localCompressConsume)
                                           , @"status":@(status)
                                           , @"code":@(code)
                                           , @"count":@(imageModel.uploadCount)
                                           , @"size":@(imageModel.size)
                                           , @"gif":@(imageModel.isGIF)
                                           }];
            }
            [monitorDictionary setValue:imageNetworks.copy forKey:@"img_networks"];
            if (error) {
                [monitorDictionary setValue:@(error.code) forKey:@"error"];
            }
            [[ToastManager manager] showToast:@"提交失败！"];
        }
        else {
            if(completion) {
                completion(finishUpLoadModels);
            }
        }
    }];
}
- (void)submitAction {    
    // 埋点
    NSMutableDictionary *reportParams = [NSMutableDictionary dictionary];
    reportParams[UT_ORIGIN_FROM] = self.tracerDict[UT_ORIGIN_FROM]?:UT_BE_NULL;
    reportParams[UT_ENTER_FROM] = self.tracerDict[UT_ENTER_FROM]?:UT_BE_NULL;
    reportParams[UT_PAGE_TYPE] = [self pageType];
    reportParams[@"group_id"] = self.houseId;
    reportParams[@"event_tracking_id"] = @"113181";
    TRACK_EVENT(@"feedback_confirm", reportParams);
    // ---
    
    @weakify(self);
    [self showLoadingAlert:@"正在提交"];
    [self uploadImagesWithCompletion:^(NSArray<FRUploadImageModel *> *uploadImageModels) {
        @strongify(self);
        
        NSMutableArray<NSString *> *image_urls = [NSMutableArray arrayWithCapacity:uploadImageModels.count];
        [uploadImageModels enumerateObjectsUsingBlock:^(FRUploadImageModel * _Nonnull model, NSUInteger idx, BOOL * _Nonnull stop) {
            if (!isEmptyString(model.webURI)) {
                [image_urls addObject:model.webURI];
            }
        }];
        
        // 提交动作
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"ticket_id"] = self.ticketID;
        params[@"uri_list"] = image_urls;
        params[@"more_info"] = self.additionCell.item.detail;
        
        if(![TTReachability isNetworkConnected]) {
            [[ToastManager manager] showToast:@"网络不给力，请重试"];
            return;
        }
        
        @weakify(self);
        [FHMainApi requestHouseFeedbackAddition:params completion:^(NSError * _Nonnull error, id  _Nonnull jsonObj) {
            @strongify(self);
            [self dismissLoadingAlert];
            
            if(error) {
                [[ToastManager manager] showToast:@"网络错误，请稍后重试"];
                return;
            }
            if(jsonObj && [jsonObj[@"status"] longValue] == 0) {
                [[ToastManager manager] showToast:@"提交完成"];
                [self goBack];
            }
            else {
                [[ToastManager manager] showToast:@"网络错误，请稍后重试"];
                return;
            }
        }];
    }];
}
- (void)scrollToDisplayFirstResponder {
    if(self.additionCell.inputTextView.isFirstResponder) {
        [self.tableView scrollToRowAtIndexPath:self.additionCell.indexPath atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}
#pragma mark - FHHouseDetailReportAdditionCellDelegate
- (CGFloat)heightForImageCount:(NSUInteger)count {
    count++;
    NSUInteger rows = (count % 3 == 0) ? count / 3 : (count / 3 + 1);
    return rows * 122 + (rows - 1) * 2;
}
- (void)reloadSection:(NSIndexPath *)indexPath {
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:indexPath.section] withRowAnimation:UITableViewRowAnimationNone];
}
#pragma mark UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return  self.items.count;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items[section].count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    FHHouseDetailReportAdditionItem *item = self.items[indexPath.section][indexPath.row];
    
    FHHouseDetailReportAdditionCell *cell = nil;
    switch (item.type) {
        case FHHouseDetailReportAdditionItemType_Problem:
            cell = self.problemCell;
            break;
        case FHHouseDetailReportAdditionItemType_Name:
            cell = self.nameCell;
            break;
        case FHHouseDetailReportAdditionItemType_PhoneNumber:
            cell = self.phoneCell;
            break;
        case FHHouseDetailReportAdditionItemType_AdditionContent:
            cell = self.additionCell;
            break;
        case FHHouseDetailReportAdditionItemType_ReportImages:
            cell = self.imagesCell;
            break;
        case FHHouseDetailReportAdditionItemType_Hint:
            cell = self.hintCell;
            break;
        default:
            cell = [FHHouseDetailReportAdditionCell createCell];
            break;
    }
    
    cell.item = item;
    cell.indexPath = indexPath;
    cell.delegate = self;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return  UITableViewAutomaticDimension;
}
@end
