//
//  TTCertificationBaseInfoViewController.m
//  Article
//
//  Created by wangdi on 2017/5/16.
//
//

#import "TTCertificationBaseInfoViewController.h"
#import "TTHorizontalPagingSegmentView.h"
#import "TTThemeManager.h"
#import "TTBaseInfoPhotoView.h"
#import "TTCertificationOperationView.h"
#import "TTCertificationTakePhotoViewController.h"
#import "TTCertificationOrganizationViewController.h"
#import "TTCertificationTakePhotoTipView.h"
#import "TTCertificationConst.h"

#define kSegmentViewHeight 41
#define kTopNavViewHeight (TTNavigationBarHeight + [UIApplication sharedApplication].statusBarFrame.size.height)

@interface TTCertificationBaseInfoViewController ()<TTHorizontalPagingSegmentViewDelegate,UIActionSheetDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UIScrollViewDelegate>

@property (nonatomic, strong) TTHorizontalPagingSegmentView *segmentView;
@property (nonatomic, strong) SSThemedScrollView *scrollView;
@property (nonatomic, strong) TTBaseInfoPhotoView *photoView;
@property (nonatomic, strong) TTCertificationOperationView *operationView;
@property (nonatomic, strong) SSThemedView *bgView;
@property (nonatomic, assign) TTPhotoType photoType;
@property (nonatomic, strong) TTCertificationOrganizationViewController *organizationVC;
@property (nonatomic, weak) TTCertificationTakePhotoTipView *takePhotoTipView;
@property (nonatomic, strong) SSThemedButton *questionButton;
@end

@implementation TTCertificationBaseInfoViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"爱看认证";
    self.view.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];

    [[TTCertificationEditViewMetaDataManager sharedInstance] updateModelHeight];
    [self setupSubview];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deletePhoto) name:kDeletePhotoNotification object:nil];
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
        _segmentView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [_segmentView setUpTitleEffect:^(NSString *__autoreleasing *titleScrollViewColorKey, NSString *__autoreleasing *norColorKey, NSString *__autoreleasing *selColorKey, UIFont *__autoreleasing *titleFont) {
            *norColorKey = kColorText1;
            *selColorKey = kColorText4;
            *titleFont = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:15]];
        }];
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
    }
    return _editView;
}

- (TTBaseInfoPhotoView *)photoView
{
    if(!_photoView) {
        _photoView = [[TTBaseInfoPhotoView alloc] init];
        _photoView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        __weak typeof(self) weakSelf = self;
        _photoView.takePhotoBlock = ^(TTPhotoType photoType) {
            [weakSelf takePhotoWithType:photoType];
        };
        _photoView.left = 0;
        _photoView.top = self.editView.bottom + [TTDeviceUIUtils tt_newPadding:10];
        _photoView.height = [TTDeviceUIUtils tt_newPadding:212.5];
        _photoView.width = self.view.width;
    }
    return _photoView;
}

- (SSThemedScrollView *)scrollView
{
    if(!_scrollView) {
        _scrollView = [[SSThemedScrollView alloc] init];
        _scrollView.backgroundColorThemeKey = kColorBackground3;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.left = 0;
        _scrollView.delegate = self;
        _scrollView.top = self.segmentView.bottom;
        _scrollView.width = self.view.width;
        _scrollView.height = self.view.height - _scrollView.top - [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
        [_scrollView addGestureRecognizer:tap];
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    return _scrollView;
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

- (TTCertificationOperationView *)operationView
{
    if(!_operationView) {
        _operationView = [TTCertificationOperationView buttonWithType:UIButtonTypeCustom];
        _operationView.left = [TTDeviceUIUtils tt_newPadding:15];
        _operationView.height = [TTDeviceUIUtils tt_newPadding:44];
        _operationView.width = self.view.width - 2 * _operationView.left;
        [_operationView setTitle:@"下一步" forState:UIControlStateNormal];
        _operationView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [_operationView addTarget:self action:@selector(operationViewClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _operationView;
}

- (SSThemedButton *)questionButton {
    if (!_questionButton) {
        _questionButton = [SSThemedButton buttonWithType:UIButtonTypeCustom];
        _questionButton.width = [TTDeviceUIUtils tt_newPadding:70];
        _questionButton.height = [TTDeviceUIUtils tt_newPadding:20];
        _questionButton.centerX = self.view.centerX;
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

- (void)endEditing
{
    [self.editView endEditing:YES];
}

- (void)setEditModels:(NSArray<TTCertificationEditModel *> *)editModels
{
    _editModels = editModels;
    self.editView.editModels = editModels;
    
}

- (void)setupSubview
{
    [self.view addSubview:self.segmentView];
    SSThemedView *bottomLine = [[SSThemedView alloc] init];
    bottomLine.backgroundColorThemeKey = kColorLine1;
    bottomLine.frame = CGRectMake(0, self.segmentView.bottom - [TTDeviceHelper ssOnePixel], self.view.width, [TTDeviceHelper ssOnePixel]);
    [self.view addSubview:bottomLine];
    self.segmentView.titles = @[@"个人",@"机构"];
    [self.view addSubview:self.scrollView];
    [self.scrollView addSubview:self.bgView];
    [self.scrollView addSubview:self.editView];
    [self.scrollView addSubview:self.photoView];
    [self.scrollView addSubview:self.operationView];
    [self.scrollView addSubview:self.questionButton];
}

- (void)updateFrame
{
    self.photoView.top = self.editView.bottom + [TTDeviceUIUtils tt_newPadding:6];
    if(self.photoView.bottom + [TTDeviceUIUtils tt_newPadding:20] + self.operationView.height + [TTDeviceUIUtils tt_newPadding:55] + self.questionButton.height + [TTDeviceUIUtils tt_newPadding:10] > self.scrollView.height) {
        self.operationView.top = self.photoView.bottom + [TTDeviceUIUtils tt_newPadding:20];
        self.questionButton.top = self.operationView.bottom + [TTDeviceUIUtils tt_newPadding:55];
        self.scrollView.contentSize = CGSizeMake(0, self.questionButton.bottom + [TTDeviceUIUtils tt_newPadding:10]);
    } else {
        self.scrollView.contentSize = CGSizeMake(0, self.scrollView.height);
        self.operationView.top = self.photoView.bottom + [TTDeviceUIUtils tt_newPadding:20];
        self.questionButton.bottom = self.scrollView.height - [TTDeviceUIUtils tt_newPadding:10];
    }
    self.questionButton.centerX = self.view.centerX;
    self.bgView.top = self.photoView.bottom;
    self.bgView.height = self.scrollView.contentSize.height;
    [self updateOperationViewStyle];
}

- (void)tapClick
{
    [self.editView endEditing:YES];
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

- (void)takePhotoWithType:(TTPhotoType)photoType
{
    self.photoType = photoType;
    UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self.view];
    TTCertificationTakePhotoTipView *takePhotoTipView = [[TTCertificationTakePhotoTipView alloc] initWithFrame:nav.view.bounds];
    takePhotoTipView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    NSString *imageName = nil;
    if(photoType == TTPhotoTypeIDCard) {
        imageName = @"certification_person";
        [TTTrackerWrapper eventV3:@"certificate_identity_add" params:@{@"from" : @"hold_photo"}];
    } else {
        imageName = @"certification_card";
        [TTTrackerWrapper eventV3:@"certificate_identity_add" params:@{@"from" : @"full_face"}];
    }
    takePhotoTipView.imageName = imageName;
    takePhotoTipView.titleModels = [self photoTipModelsWithType:self.photoType];
    [nav.view addSubview:takePhotoTipView];
    self.takePhotoTipView = takePhotoTipView;
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:NSLocalizedString(@"取消", nil) destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"拍照", nil), NSLocalizedString(@"从相册选择", nil), nil];
    [actionSheet showInView:nav.view];
    
}

- (NSArray *)photoTipModelsWithType:(TTPhotoType)type
{
    NSArray *modelArray = nil;
    if(type == TTPhotoTypeIDCard) {
        TTCertificationTakePhotoTipModel *model1 = [[TTCertificationTakePhotoTipModel alloc] init];
        model1.title = @"手持身份证拍摄:";
        model1.textColor = [UIColor colorWithHexString:@"#2A90D7"];
        
        TTCertificationTakePhotoTipModel *model2 = [[TTCertificationTakePhotoTipModel alloc] init];
        model2.title = @"1.手持身份证正面进行拍摄";
        model2.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        
        TTCertificationTakePhotoTipModel *model3 = [[TTCertificationTakePhotoTipModel alloc] init];
        model3.title = @"2.确保脸部和手持动作清晰可见";
        model3.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        
        TTCertificationTakePhotoTipModel *model4 = [[TTCertificationTakePhotoTipModel alloc] init];
        model4.title = @"3.手持身份证正面信息清晰可确认";
        model4.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        modelArray = @[model1,model2,model3,model4];
    } else {
        TTCertificationTakePhotoTipModel *model1 = [[TTCertificationTakePhotoTipModel alloc] init];
        model1.title = @"身份证拍摄:";
        model1.textColor = [UIColor colorWithHexString:@"#2A90D7"];
        
        TTCertificationTakePhotoTipModel *model2 = [[TTCertificationTakePhotoTipModel alloc] init];
        model2.title = @"1.请拍摄含有个人信息的一面";
        model2.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        
        TTCertificationTakePhotoTipModel *model3 = [[TTCertificationTakePhotoTipModel alloc] init];
        model3.title = @"2.确保四周边角全部可见";
        model3.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        
        TTCertificationTakePhotoTipModel *model4 = [[TTCertificationTakePhotoTipModel alloc] init];
        model4.title = @"3.字体清晰可确认";
        model4.textColor = [UIColor colorWithHexString:@"#FFFFFF"];
        modelArray = @[model1,model2,model3,model4];
    }
    
    return modelArray;
}

- (void)deletePhoto
{
    [self updateOperationViewStyle];

}

- (void)operationViewClick
{
    [TTTrackerWrapper eventV3:@"certificate_next" params:nil];
    if(self.opreationViewClickBlock) {
        self.opreationViewClickBlock();
    }
}

- (void)questionButtonClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:kCertificationPressQuestionsEntranceNotification object:nil];
}


- (NSDictionary *)images
{
    return [self.photoView images];
}

- (BOOL)hasEditInfo
{
    BOOL hasEditInfo = NO;
    for(TTCertificationEditModel *model in self.editModels) {
        if(!isEmptyString(model.content)) {
            hasEditInfo = YES;
            break;
        }
    }
    return hasEditInfo || [self images].count > 0;
}

#pragma mark actionSheet 代理
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [self.takePhotoTipView removeFromSuperview];
    UIImagePickerController *pick = [[UIImagePickerController alloc] init];
    pick.delegate = self;
    if(buttonIndex == 0) {
        
        if(self.photoType == TTPhotoTypeIDCard) {
            [TTTrackerWrapper eventV3:@"certificate_take_photo" params:@{@"from" : @"hold_photo"}];
            pick.sourceType = UIImagePickerControllerSourceTypeCamera;
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self.view];
                [nav presentViewController:pick animated:YES completion:nil];
            });
            
        } else {
            TTCertificationTakePhotoViewController *takePhotoViewController = [[TTCertificationTakePhotoViewController alloc] init];
            [TTTrackerWrapper eventV3:@"certificate_take_photo" params:@{@"from" : @"full_face"}];
            takePhotoViewController.needEdging = YES;
            __weak typeof(self) weakSelf = self;
            takePhotoViewController.didFinishBlock = ^(UIImage *image) {
                [weakSelf.photoView setImage:image photoType:weakSelf.photoType];
                [weakSelf updateOperationViewStyle];
            };
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                UINavigationController *nav = [TTUIResponderHelper topNavigationControllerFor:self.view];
                [nav presentViewController:takePhotoViewController animated:YES completion:nil];
            });
        }
    } else if(buttonIndex == 1) {
        if(self.photoType == TTPhotoTypeIDCard) {
            [TTTrackerWrapper eventV3:@"certificate_upload_photo" params:@{@"from" : @"hold_photo"}];
        } else {
            [TTTrackerWrapper eventV3:@"certificate_upload_photo" params:@{@"from" : @"full_face"}];
        }
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
    [self.photoView setImage:image photoType:self.photoType];
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self updateOperationViewStyle];
}

#pragma mark - segmentView 代理
- (void)segmentView:(TTHorizontalPagingSegmentView *)segmentView didSelectedItemAtIndex:(NSInteger)index toIndex:(NSInteger)toIndex
{
    [self tapClick];
    if(toIndex == 1) {
        [TTTrackerWrapper eventV3:@"certificate_identity_click_org" params:@{@"refer" : @"identity"}];
        [self.view addSubview:self.organizationVC.view];
        self.organizationVC.view.left = 0;
        self.organizationVC.view.top = self.segmentView.bottom;
        self.organizationVC.view.width = self.view.width;
        self.organizationVC.view.height = self.view.height - self.organizationVC.view.top;
        self.organizationVC.questionButton.bottom = self.organizationVC.view.height - [TTDeviceUIUtils tt_newPadding:10] - self.organizationVC.view.tt_safeAreaInsets.bottom;
    } else {
        [self.organizationVC.view removeFromSuperview];
        self.organizationVC = nil;
    }
}

#pragma mark scrollview代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self tapClick];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
