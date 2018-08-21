//
//  TTOccupationalCertificationViewController.m
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "TTOccupationalCertificationViewController.h"
#import "TTHorizontalPagingSegmentView.h"
#import "TTCertificationOperationView.h"
#import "TTCertificationOccupationalPhotoView.h"
#import "TTCertificationPreviewView.h"
#import "TTCertificationTakePhotoViewController.h"
#import "TTCertificationManager.h"
#import "TTIndicatorView.h"
#import "TTCertificationInReviewViewController.h"
#import "TTCertificationRootViewController.h"
#import "TTCertificationOrganizationViewController.h"
#import "TTCertificationTakePhotoTipView.h"
#import "NetworkUtilities.h"
#import "TTIndicatorView.h"
#import "TTNavigationController.h"
#import "TTThemedAlertController.h"
#import "TTCertificationConfirmCertificationViewController.h"
#import "TTCertificationConst.h"

#define kSegmentViewHeight 41
#define kTopNavViewHeight (TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height)

@interface TTCertificationSupplementView : SSThemedView <UITextViewDelegate>
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) SSThemedTextView *contentView;
@property (nonatomic, strong) TTCertificationEditModel *certificationModel;
@end

@implementation TTCertificationSupplementView

- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColorThemeKey = kColorBackground4;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview {
    [self addSubview:self.titleLabel];
    [self addSubview:self.contentView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.titleLabel.top = [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.left = [TTDeviceUIUtils tt_newPadding:15];
    self.titleLabel.size = CGSizeMake([TTDeviceUIUtils tt_newPadding:80], [TTDeviceUIUtils tt_newPadding:22]);
    
    self.contentView.top = self.titleLabel.bottom;
    self.contentView.left = self.titleLabel.left;
    self.contentView.width = self.width - 2 * self.titleLabel.left;
    self.contentView.height = self.height - self.contentView.top - [TTDeviceUIUtils tt_newPadding:10];
}

- (void)setCertificationModel:(TTCertificationEditModel *)certificationModel {
    _certificationModel = certificationModel;
    if ([certificationModel.content length] <= 50) {
        self.contentView.text = certificationModel.content;
    }
    self.titleLabel.text = certificationModel.title;
    self.contentView.placeHolder = certificationModel.placeholder;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:16]];
        _titleLabel.textColorThemeKey = kColorText1;
    }
    return _titleLabel;
}

- (SSThemedTextView *)contentView {
    if (!_contentView) {
        _contentView = [[SSThemedTextView alloc] init];
        _contentView.textColorThemeKey = kColorText1;
        _contentView.backgroundColorThemeKey = kColorBackground4;
        _contentView.textContainer.lineFragmentPadding = 0;
        if ([TTDeviceHelper getDeviceType] == TTDeviceMode568 || [TTDeviceHelper getDeviceType] == TTDeviceMode480) {
            _contentView.placeHolderFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
            _contentView.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12]];
        } else {
            _contentView.placeHolderFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
            _contentView.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        }
        _contentView.placeHolderEdgeInsets = UIEdgeInsetsMake(0, -5, 0, -5);
        _contentView.placeholderColorThemeKey = kColorText3;
        _contentView.textContainer.lineBreakMode = NSLineBreakByCharWrapping;
        _contentView.delegate = self;
    }
    return _contentView;
}

#pragma mark - UITextViewDelegate

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    NSInteger originLength = textView.text.length;
    if (originLength - range.length + text.length <= 50) {
        return YES;
    }
    return NO;
}

- (void)textViewDidChange:(UITextView *)textView
{
    if (textView.text.length > 50) {
        textView.text = [textView.text substringToIndex:50];
    }
    _certificationModel.content = textView.text;
}

@end

@interface TTOccupationalCertificationViewController ()<TTHorizontalPagingSegmentViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) TTHorizontalPagingSegmentView *segmentView;
@property (nonatomic, strong) SSThemedScrollView *scrollView;
@property (nonatomic, strong) TTCertificationOperationView *operationView;
@property (nonatomic, strong) SSThemedView *bgView;
@property (nonatomic, strong) TTCertificationSupplementView *supplementView;
@property (nonatomic, strong) TTCertificationPreviewView *previewView;
@property (nonatomic, strong) TTCertificationOccupationalPhotoView *photoView;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) TTCertificationOrganizationViewController *organizationVC;
@property (nonatomic, weak) TTCertificationTakePhotoTipView *takePhotoTipView;
@property (nonatomic, strong) SSThemedButton *questionButton;
@end

@implementation TTOccupationalCertificationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"爱看认证";
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    [self setupSubview];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePhoto) name:kDeletePhotoNotification object:nil];
    [[TTCertificationEditViewMetaDataManager sharedInstance] updateModelHeight];
    self.ttDisableDragBack = YES;
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [self.view addGestureRecognizer:pan];
}

- (void)themeChanged:(NSNotification*)notification {
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
}

- (TTHorizontalPagingSegmentView *)segmentView
{
    if(!_segmentView) {
        _segmentView = [[TTHorizontalPagingSegmentView alloc] initWithFrame:CGRectMake((self.view.width - [TTDeviceUIUtils tt_newPadding:160]) / 2, kTopNavViewHeight, [TTDeviceUIUtils tt_newPadding:160], kSegmentViewHeight)];
        _segmentView.type = TTPagingSegmentViewContentHorizontalAlignmentEqually;
        _segmentView.delegate = self;
        _segmentView.bottomLine.hidden = YES;
        [_segmentView setUpTitleEffect:^(NSString *__autoreleasing *titleScrollViewColorKey, NSString *__autoreleasing *norColorKey, NSString *__autoreleasing *selColorKey, UIFont *__autoreleasing *titleFont) {
            *norColorKey = kColorText1;
            *selColorKey = kColorText4;
            *titleFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:15]];
        }];
        _segmentView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [_segmentView setUpUnderLineEffect:^(BOOL *isUnderLineDelayScroll, CGFloat *underLineH, NSString *__autoreleasing *underLineColorKey, BOOL *isUnderLineEqualTitleWidth) {
            *isUnderLineDelayScroll = NO;
            *underLineH = 2;
            *underLineColorKey = kColorBackground7;
            *isUnderLineEqualTitleWidth = YES;
        }];
    }
    _segmentView.backgroundColorThemeKey = kColorBackground4;
    return _segmentView;
}

- (TTCertificationEditView *)editView
{
    if(!_editView) {
        _editView = [[TTCertificationEditView alloc] initWithFrame:CGRectMake(0,[TTDeviceUIUtils tt_newPadding:6], self.view.width, 0)];
        _editView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        __weak typeof(self) weakSelf = self;
        _editView.heightChangeBlock = ^{
            [weakSelf updateFrame];
        };
        _editView.textChangeBlock = ^(TTCertificationEditModel *changeModel) {
            [weakSelf textFiledTextChange:changeModel];
        };
    }
    return _editView;
}

- (SSThemedView *)bgView
{
    if(!_bgView) {
        _bgView = [[SSThemedView alloc] init];
        _bgView.backgroundColorThemeKey = kColorBackground4;
        _bgView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _bgView.left = 0;
        _bgView.width = self.scrollView.width;
    }
    return _bgView;
}

- (SSThemedScrollView *)scrollView
{
    if(!_scrollView) {
        _scrollView = [[SSThemedScrollView alloc] init];
        _scrollView.backgroundColorThemeKey = kColorBackground3;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _scrollView.left = 0;
        _scrollView.delegate = self;
        _scrollView.top = self.segmentView.bottom;
        _scrollView.width = self.view.width;
        _scrollView.height = self.view.height - _scrollView.top - [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [_scrollView addGestureRecognizer:tap];
    }
    return _scrollView;
}

- (TTCertificationOperationView *)operationView
{
    if(!_operationView) {
        _operationView = [TTCertificationOperationView buttonWithType:UIButtonTypeCustom];
        _operationView.left = [TTDeviceUIUtils tt_newPadding:15];
        _operationView.height = [TTDeviceUIUtils tt_newPadding:44];
        _operationView.width = self.view.width - 2 * _operationView.left;
        [_operationView setTitle:@"提交" forState:UIControlStateNormal];
        _operationView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_operationView addTarget:self action:@selector(operationViewClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _operationView;
}

- (TTCertificationSupplementView *)supplementView {
    if (!_supplementView) {
        _supplementView = [[TTCertificationSupplementView alloc] init];
        _supplementView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _supplementView.frame = CGRectMake(0, self.editView.bottom + [TTDeviceUIUtils tt_newPadding:6], self.view.width, [TTDeviceUIUtils tt_newPadding:97]);
    }
    return _supplementView;
}

- (TTCertificationPreviewView *)previewView
{
    if(!_previewView) {
        _previewView = [[TTCertificationPreviewView alloc] init];
        _previewView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _previewView.frame = CGRectMake(0, self.supplementView.bottom + [TTDeviceUIUtils tt_newPadding:6], self.view.width, [TTDeviceUIUtils tt_newPadding:117.5]);
    }
    return _previewView;
}

- (TTCertificationOccupationalPhotoView *)photoView
{
    if(!_photoView) {
        _photoView = [[TTCertificationOccupationalPhotoView alloc] init];
        _photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        _photoView.frame = CGRectMake(0, self.previewView.bottom + [TTDeviceUIUtils tt_newPadding:6], self.view.width, [TTDeviceUIUtils tt_newPadding:212.5]);
        __weak typeof(self) weakSelf = self;
        _photoView.takePhotoBlock = ^{
            [weakSelf takePhoto];
        };
    }
    return _photoView;
}

- (SSThemedButton *)questionButton {
    if (!_questionButton) {
        _questionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _questionButton.width = [TTDeviceUIUtils tt_newPadding:70];
        _questionButton.height = [TTDeviceUIUtils tt_newPadding:20];
        _questionButton.centerX = self.view.centerX;
        _questionButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        _questionButton.hitTestEdgeInsets = UIEdgeInsetsMake(-8, -8, -8, -8);
        [_questionButton setTitle:@"常见问题" forState:UIControlStateNormal];
        _questionButton.titleColorThemeKey = kColorText6;
        _questionButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14]];
        [_questionButton addTarget:self action:@selector(questionButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _questionButton;
}

- (TTCertificationOrganizationViewController *)organizationVC
{
    if(!_organizationVC) {
        _organizationVC = [[TTCertificationOrganizationViewController alloc] init];
    }
    return _organizationVC;
}

- (void)setupSubview
{
    [self.view addSubview:self.segmentView];
    self.segmentView.titles = @[@"个人",@"机构"];
    SSThemedView *bottomLine = [[SSThemedView alloc] init];
    bottomLine.backgroundColorThemeKey = kColorLine1;
    bottomLine.frame = CGRectMake(0, self.segmentView.bottom - [TTDeviceHelper ssOnePixel], self.view.width, [TTDeviceHelper ssOnePixel]);
    [self.view addSubview:bottomLine];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.bgView];
    [self.scrollView addSubview:self.editView];
    [self.scrollView addSubview:self.supplementView];
    [self.scrollView addSubview:self.previewView];
    [self.scrollView addSubview:self.photoView];
    [self.scrollView addSubview:self.operationView];
    [self.scrollView addSubview:self.questionButton];
}


- (void)setOccupationalEditModels:(NSArray<TTCertificationEditModel *> *)occupationalEditModels
{
    _occupationalEditModels = occupationalEditModels;
    self.editView.editModels = occupationalEditModels;
    [self textFiledTextChange:nil];
}

- (void)setSupplementModel:(TTCertificationEditModel *)supplementModel {
    _supplementModel = supplementModel;
    self.supplementView.certificationModel = supplementModel;
}

- (void)tapClick
{
    [self.editView endEditing:YES];
    [self.supplementView endEditing:YES];
}

- (void)questionButtonClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCertificationPressQuestionsEntranceNotification object:nil];
}

- (void)updateFrame
{
    self.supplementView.top = self.editView.bottom + [TTDeviceUIUtils tt_newPadding:6];
    self.previewView.top = self.supplementView.bottom + [TTDeviceUIUtils tt_newPadding:6];
    self.photoView.top = self.previewView.bottom + [TTDeviceUIUtils tt_newPadding:6];
    if(self.photoView.bottom + [TTDeviceUIUtils tt_newPadding:20] + self.operationView.height + [TTDeviceUIUtils tt_newPadding:55] + self.questionButton.height + [TTDeviceUIUtils tt_newPadding:10] > self.scrollView.height) {
        self.operationView.top = self.photoView.bottom + [TTDeviceUIUtils tt_newPadding:20];
        self.questionButton.top = self.operationView.bottom + [TTDeviceUIUtils tt_newPadding:55];
        self.scrollView.contentSize = CGSizeMake(0, self.questionButton.bottom + [TTDeviceUIUtils tt_newPadding:10]);
    } else {
        self.scrollView.contentSize = CGSizeMake(0, self.scrollView.height);
        self.operationView.top = self.photoView.bottom + [TTDeviceUIUtils tt_newPadding:20];
        self.questionButton.bottom = self.scrollView.height - [TTDeviceUIUtils tt_newPadding:10];
    }
    self.bgView.top = self.photoView.bottom;
    self.bgView.height = self.scrollView.contentSize.height;
    [self updateOperationViewStyle];
}

- (void)updateOperationViewStyle
{
    BOOL isCompleted = YES;
    for(TTCertificationEditModel *model in self.editView.editModels) {
        if(!model.isCompleted) {
            isCompleted = NO;
            break;
        }
    }
    isCompleted = [self.photoView isCompleted] && isCompleted;
    if(isCompleted) {
        self.operationView.style = TTCertificationOperationViewStyleRed;
        self.operationView.userInteractionEnabled = YES;
    } else {
        self.operationView.style = TTCertificationOperationViewStyleLightRed;
        self.operationView.userInteractionEnabled = NO;
    }
}

- (void)takePhoto
{
    [TTTrackerWrapper eventV3:@"certificate_identity_add" params:@{@"from" : @"professional"}];
    UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self.view];
    TTCertificationTakePhotoTipView *takePhotoTipView = [[TTCertificationTakePhotoTipView alloc] initWithFrame:nav.view.bounds];
    takePhotoTipView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    takePhotoTipView.imageName = @"certification_occupational";
    takePhotoTipView.titleModels = [self takePhotoTipModels];
    [nav.view addSubview:takePhotoTipView];
    self.takePhotoTipView = takePhotoTipView;
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍照", nil), NSLocalizedString(@"从相册选择", nil), nil];
    [actionSheet showInView:nav.view];
}

- (NSArray *)takePhotoTipModels
{
    TTCertificationTakePhotoTipModel *model1 = [[TTCertificationTakePhotoTipModel alloc] init];
    model1.title = @"职业资料拍摄:";
    model1.textColor = [UIColor colorWithHexString:@"#2A90D7"];
    
    TTCertificationTakePhotoTipModel *model2 = [[TTCertificationTakePhotoTipModel alloc] init];
    model2.title = @"1.工牌、在职证明、职业资质证明均可";
    model2.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
    
    TTCertificationTakePhotoTipModel *model3 = [[TTCertificationTakePhotoTipModel alloc] init];
    model3.title = @"2.确保公司、职位、姓名清晰可确认";
    model3.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
    
    TTCertificationTakePhotoTipModel *model4 = [[TTCertificationTakePhotoTipModel alloc] init];
    model4.title = @"3.若有多份材料更佳，请拍摄合照";
    model4.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
    
    return  @[model1,model2,model3,model4];
}

- (void)deletePhoto
{
    [self updateOperationViewStyle];
}

- (void)operationViewClick
{
    if(!TTNetworkConnected()) {
         [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:@"网络异常" indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        return;
    }
    [TTTrackerWrapper eventV3:@"certificate_submit" params:nil];
    UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self.view];
    nav.view.userInteractionEnabled = NO;
    TTIndicatorView *indicatorView = [[TTIndicatorView alloc] initWithIndicatorStyle:TTIndicatorViewStyleWaitingView indicatorText:@"正在加载..." indicatorImage:nil dismissHandler:nil];
    indicatorView.autoDismiss = NO;
    [indicatorView showFromParentView:self.view];
    if(!self.isModify) {
        TTPostCertificationRequestModel *requestModel = [self buildRequestModel];
        [[TTCertificationManager sharedInstance] postCertificationWithRequestModel:requestModel completion:^(NSError *error, NSDictionary *result) {
            [indicatorView dismissFromParentView];
            
            [self refreshShowNumberLogic];
            [self setupSkipWithError:error result:result];
        }];
    } else {
        TTModifyCertificationRequestModel *requestModel = [self buildModifyRequestModel];
        [[TTCertificationManager sharedInstance] postModofyCertificationWithRequestModel:requestModel completion:^(NSError *error, NSDictionary *result) {
            [indicatorView dismissFromParentView];
            
            [self setupSkipWithError:error result:result];
        }];
    }
}

- (void)refreshShowNumberLogic {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *applyMonth = [userDefaults stringForKey:kCertificaitonMonthApplyMonthKey];
    NSInteger applyNumber = [userDefaults integerForKey:kCertificaitonMonthApplyDateKey];
    NSDate *date = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyyMM"];
    NSString *nowMonth = [formatter stringFromDate:date];
    if ([nowMonth isEqualToString:applyMonth]) {
        applyNumber++;
    } else {
        applyNumber = 1;
        applyMonth = nowMonth;
    }
    
    [userDefaults setInteger:applyNumber forKey:kCertificaitonMonthApplyDateKey];
    [userDefaults setObject:applyMonth forKey:kCertificaitonMonthApplyMonthKey];
    [userDefaults setBool:NO forKey:kCertificaitonHasBeenRejectedKey];
    [userDefaults synchronize];
}

- (void)setupSkipWithError:(NSError *)error result:(NSDictionary *)result
{
    UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self.view];
    nav.view.userInteractionEnabled = YES;
    error = nil;
    if(!error) {
        TTCertificationInReviewViewController *inReviewVC = [[TTCertificationInReviewViewController alloc] init];
        inReviewVC.questionUrl = self.questionUrl;
        [nav pushViewController:inReviewVC animated:YES];
        inReviewVC.timeLabel.text = result[@"data"][@"auditing_show_info"];
        inReviewVC.descLabel.text = @"申请提交成功，审核中";
        if (self.isCertificationV) {
            inReviewVC.iconView.imageName = @"v_Information_passing";
        } else {
            inReviewVC.iconView.imageName = @"Information_passing";
        }
        [self popControllerWithTopController:inReviewVC];
    } else {
        NSString *desc = error.userInfo[@"description"];
        if(!isEmptyString(desc)) {
            [TTIndicatorView showWithIndicatorStyle:TTIndicatorViewStyleImage indicatorText:desc indicatorImage:nil autoDismiss:YES dismissHandler:nil];
        }
        
        NSMutableDictionary *extra = [NSMutableDictionary dictionary];
        if(!isEmptyString(error.description)) {
            [extra setObject:error.description forKey:@"error_description"];
        }
        [extra setObject:@(error.code) forKey:@"error_code"];
        NSInteger status = 0;
        if(self.isModify) {
            status = 1;
        } else {
            status = 2;
        }
        [[TTMonitor shareManager] trackService:@"certification_native_cancel" status:status extra:extra];
    }
}

- (void)popControllerWithTopController:(UIViewController *)topViewController
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self.view];
        NSMutableArray *controllers = [NSMutableArray array];
        for(UIViewController *controller in nav.viewControllers) {
            if([controller isKindOfClass:[TTCertificationRootViewController class]]) {
                break;
            } else {
                [controllers addObject:controller];
            }
        }
        [controllers addObject:topViewController];
        nav.viewControllers = controllers;
    });
}

- (TTModifyCertificationRequestModel *)buildModifyRequestModel
{
    TTModifyCertificationRequestModel *requestModel = [[TTModifyCertificationRequestModel alloc] init];
    TTCertificationEditModel *unitModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeUnit];
    requestModel.company = unitModel.content;
    TTCertificationEditModel *occupationalModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeOccupational];
    requestModel.profession = occupationalModel.content;
    TTCertificationEditModel *supplementModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeSupplement];
    requestModel.additional = supplementModel.content;
    requestModel.image = self.image;
    requestModel.apply_vtag = self.isCertificationV ? @"1" : @"0";
    return requestModel;
}

- (TTPostCertificationRequestModel *)buildRequestModel
{
    TTPostCertificationRequestModel *requestModel = [[TTPostCertificationRequestModel alloc] init];
    TTCertificationEditModel *realNameModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeRealName];
    requestModel.real_name = realNameModel.content;
    
    TTCertificationEditModel *idNumberModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeIdNumber];
    requestModel.id_number = idNumberModel.content;
    
    TTCertificationEditModel *industryModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeIndustry];
    requestModel.auth_class_2 = industryModel.content;
    
    TTCertificationEditModel *supplementModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeSupplement];
    requestModel.additional = supplementModel.content;
    
    TTCertificationEditModel *unitModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeUnit];
    requestModel.company = unitModel.content;
    TTCertificationEditModel *occupationalModel = [[TTCertificationEditViewMetaDataManager sharedInstance] editModelWithType:TTCertificationEditModelTypeOccupational];
    requestModel.profession = occupationalModel.content;
    
    NSMutableDictionary *images = [NSMutableDictionary dictionaryWithDictionary:self.images];
    [images setValue:self.image  forKey:@"verified_material1"];
    requestModel.images = images;
    return requestModel;
}

- (void)textFiledTextChange:(TTCertificationEditModel *)changeModel
{
    NSString *unitText = nil;
    NSString *occupationalText = nil;
    for(TTCertificationEditModel *model in self.occupationalEditModels) {
        if(model.type == TTCertificationEditModelTypeUnit) {
            unitText = model.content;
        } else if(model.type == TTCertificationEditModelTypeOccupational) {
            occupationalText = model.content;
        }
    }
    NSMutableString *string = [NSMutableString string];
    if(!isEmptyString(unitText)) {
        [string appendString:unitText];
    }
    if(!isEmptyString(occupationalText)) {
        [string appendString:occupationalText];
    }
    
    if (isEmptyString(string)) {
        [string appendString:@"单位 职位"];
    }
    [self.previewView setPreViewText:string];
    self.photoView.top = self.previewView.bottom + [TTDeviceUIUtils tt_newPadding:10];
}

- (void)dismissSelf
{
    [self.editView endEditing:YES];
    if([self hasEditInfo]) {
        TTThemedAlertController *alert = [[TTThemedAlertController alloc] initWithTitle:nil message:@"是否退出当前流程?" preferredType:TTThemedAlertControllerTypeAlert];
        [alert addActionWithTitle:@"否" actionType:TTThemedAlertActionTypeCancel actionBlock:nil];
        [alert addActionWithTitle:@"是" actionType:TTThemedAlertActionTypeNormal actionBlock:^{
            [self deleteConfirmCertificationViewControllerIfNeed];
            [self.navigationController popViewControllerAnimated:YES];
        }];
        [alert showFrom:self animated:YES];
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:@"是否退出当前流程?" delegate:self cancelButtonTitle:@"否" otherButtonTitles:@"是", nil];
//        [alert show];
    } else {
        [self deleteConfirmCertificationViewControllerIfNeed];
        [super dismissSelf];
    }
}

- (void)deleteConfirmCertificationViewControllerIfNeed
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self.view];
    for(UIViewController *controller in nav.viewControllers) {
        if(![controller isKindOfClass:[TTCertificationConfirmCertificationViewController class]]) {
            [viewControllers addObject:controller];
        }
    }
    nav.viewControllers = viewControllers;
}

- (BOOL)hasEditInfo
{
    BOOL hasEditInfo = NO;
    for(TTCertificationEditModel *model in self.occupationalEditModels) {
        if(!isEmptyString(model.content)) {
            hasEditInfo = YES;
            break;
        }
    }
    return hasEditInfo || self.image;
}

- (void)setAuthType:(NSString *)authType
{
    if(isEmptyString(authType)) {
        authType = @"0";
    }
    _authType = authType;
    [self.previewView setAuthType:authType];
}

#pragma mark actionSheet 代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.takePhotoTipView removeFromSuperview];
    UIImagePickerController *pick = [[UIImagePickerController alloc] init];
    pick.delegate = self;
    if(buttonIndex == 0) {
        [TTTrackerWrapper eventV3:@"certificate_take_phone" params:@{@"from" : @"professional"}];
        pick.sourceType = UIImagePickerControllerSourceTypeCamera;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self.view];
            [nav presentViewController:pick animated:YES completion:nil];
        });
    } else if(buttonIndex == 1) {
        [TTTrackerWrapper eventV3:@"certificate_upload_photo" params:@{@"from" : @"professional"}];
        pick.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self.view];
            [nav presentViewController:pick animated:YES completion:nil];
        });
    }
}

#pragma mark - uipickerController 代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    UIImage *image = info[UIImagePickerControllerOriginalImage];
    self.image = image;
    [self.photoView setImage:image];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self updateOperationViewStyle];
}

#pragma mark - segmentView 代理
- (void)segmentView:(TTHorizontalPagingSegmentView *)segmentView didSelectedItemAtIndex:(NSInteger)index toIndex:(NSInteger)toIndex
{
    [self tapClick];
    if(toIndex == 1) {
        [TTTrackerWrapper eventV3:@"certificate_identity_click_org" params:@{@"refer" : @"professional"}];
        [self.view addSubview:self.organizationVC.view];
        self.organizationVC.view.left = 0;
        self.organizationVC.view.top = self.segmentView.bottom;
        self.organizationVC.view.width = self.view.width;
        self.organizationVC.view.height = self.view.height - self.organizationVC.view.top;
        self.organizationVC.questionButton.bottom = self.organizationVC.view.height - [TTDeviceUIUtils tt_newPadding:10] - [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    } else {
        [self.organizationVC.view removeFromSuperview];
        self.organizationVC = nil;
    }
}

#pragma mark uiscrollview代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tapClick];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
