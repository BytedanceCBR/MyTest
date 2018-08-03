//
//  TTDislikeViewController.m
//  Article
//
//  Created by zhaoqin on 27/02/2017.
//
//

#import "TTDislikeViewController.h"
#import "TTDislikeView.h"
#import "TTDislikeComplainView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTDetailModel.h"
#import "TTActionSheetCellModel.h"

@interface TTDislikeViewController ()
@property (nonatomic, strong) SSViewBase *maskView;
@property (nonatomic, strong) TTDislikeView *dislikeView;
@property (nonatomic, strong) TTDislikeComplainView *complainView;
@property (nonatomic, strong) NSArray *dislikeOptions;
@property (nonatomic, strong) NSArray *reportOptions;
@end

@implementation TTDislikeViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillLayoutSubviews {
    if (self.maskView.alpha == 1.f) {
        if (self.type == TTDislikeTypeOnlyReport) {
            self.dislikeView.top = self.view.height - [self calculateOnlyReportHeight];
        }
        else {
            self.dislikeView.top = self.view.height - [self calculateDislikeViewHeight];
        }
        self.dislikeView.width = self.view.width;
        self.maskView.width = self.view.width;
        self.complainView.top = self.view.height - [self calculateComplainViewHeight];
        self.complainView.width = self.view.width;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.maskView.alpha = 0;
    self.dislikeView.top += self.dislikeView.height;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [UIView animateWithDuration:0.25f animations:^{
        self.maskView.alpha = 1.f;
        self.dislikeView.top -= self.dislikeView.height;
    } completion:^(BOOL finished) {
        
    }];
}

#pragma mark - public method
- (void)insertDislikeOptions:(NSArray * _Nonnull)dislikeOptions reportOptions:(NSArray * _Nonnull)reportOptions {
    self.dislikeOptions = dislikeOptions;
    self.reportOptions = reportOptions;
    [self.dislikeView insertDislikeOptions:dislikeOptions reportOptions:reportOptions];
}

- (void)insertExtraDict:(NSMutableDictionary *)extraDict {
    [self.complainView insertExtraDict:extraDict];
    if ([extraDict tt_stringValueForKey:@"criticism"].length > 0) {
        [self.dislikeView setComplainMessage:YES];
    }
}

- (void)updateComplainMessage:(BOOL)isMessage {
    [self.dislikeView setComplainMessage:isMessage];
}

#pragma mark - private method
- (void)initViews {
    [self.view addSubview:self.maskView];
    [self.view addSubview:self.dislikeView];
}

- (void)dismissViewController {
    [UIView animateWithDuration:0.25f animations:^{
        self.maskView.alpha = 0;
        if (self.dislikeView.alpha == 0) {
            self.complainView.top += self.complainView.height;
        }
        else {
            self.dislikeView.top += self.dislikeView.height;
        }
    } completion:^(BOOL finished) {
        if (self.dismissComplete) {
            self.dismissComplete(YES);
        }
        [self dismissViewControllerAnimated:NO completion:nil];
    }];
}

- (void)showComplainView {
    [UIView animateWithDuration:0.25f animations:^{
        self.dislikeView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.view addSubview:self.complainView];
        self.complainView.alpha = 1;
        self.complainView.top += self.complainView.height;
        [self.complainView willAppear];
        [UIView animateWithDuration:0.25f animations:^{
            self.complainView.top -= self.complainView.height;
        } completion:^(BOOL finished) {
        }];
    }];
}

- (void)dismissComplainView {
    [UIView animateWithDuration:0.25f animations:^{
        self.complainView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.complainView removeFromSuperview];
        self.dislikeView.alpha = 1;
        self.dislikeView.top += self.dislikeView.height;
        [UIView animateWithDuration:0.25f animations:^{
            self.dislikeView.top -= self.dislikeView.height;
        }];
    }];;
}

- (void)clickMaskView {
    NSMutableDictionary *extra = [[NSMutableDictionary alloc] init];
    [extra setValue:self.detailModel.article.itemID forKey:@"item_id"];
    
    if (self.type == TTDislikeTypeOnlyReport) {
        NSMutableArray *reportTypes = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.reportOptions.count; i++) {
            TTActionSheetCellModel *model = [self.reportOptions objectAtIndex:i];
            if (model.isSelected) {
                [reportTypes addObject:model.identifier];
            }
        }
        [extra setValue:@(reportTypes.count) forKey:@"report"];
        [extra setValue:@"report" forKey:@"style"];
        wrapperTrackEventWithCustomKeys(@"detail", @"report_cancel_click_shadow", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
    }
    else {
        NSMutableArray *dislikeTypes = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.dislikeOptions.count; i++) {
            TTActionSheetCellModel *model = [self.dislikeOptions objectAtIndex:i];
            if (model.isSelected) {
                [dislikeTypes addObject:model.identifier];
            }
        }
        NSMutableArray *reportTypes = [[NSMutableArray alloc] init];
        for (int i = 0; i < self.reportOptions.count; i++) {
            TTActionSheetCellModel *model = [self.reportOptions objectAtIndex:i];
            if (model.isSelected) {
                [reportTypes addObject:model.identifier];
            }
        }
        
        [extra setValue:@(dislikeTypes.count) forKey:@"dislike"];
        [extra setValue:@(reportTypes.count) forKey:@"report"];
        [extra setValue:@"report_and_dislike" forKey:@"style"];
        wrapperTrackEventWithCustomKeys(@"detail", @"report_and_dislike_cancel_click_shadow", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);

    }

    [self dismissViewController];
}

#pragma mark - get method
- (SSViewBase *)maskView {
    if (!_maskView) {
        _maskView = [[SSViewBase alloc] initWithFrame:self.view.frame];
//        _maskView.backgroundColor = [UIColor colorWithHexString:@"0000004C"];
        _maskView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground9];
        UITapGestureRecognizer *panGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickMaskView)];
        [_maskView addGestureRecognizer:panGesture];
    }
    return _maskView;
}

- (TTDislikeView *)dislikeView {
    if (!_dislikeView) {
        _dislikeView = [[TTDislikeView alloc] initWithFrame:CGRectMake(0, self.view.height - [self calculateDislikeViewHeight], self.view.width, [self calculateDislikeViewHeight])];
        _dislikeView.detailModel = self.detailModel;
        WeakSelf;
        _dislikeView.cancelComplete = ^(){
            StrongSelf;
            if (self.dismissComplete) {
                self.dismissComplete();
            }
            [self dismissViewController];
        };
        _dislikeView.commitComplete = ^{
            StrongSelf;
            if (self.commitComplete) {
                self.commitComplete();
            }
            [self dismissViewController];
        };
        _dislikeView.extraComeplete = ^{
            StrongSelf;
            [self showComplainView];
        };
    }
    return _dislikeView;
}

- (TTDislikeComplainView *)complainView {
    if (!_complainView) {
        _complainView = [[TTDislikeComplainView alloc] initWithFrame:CGRectMake(0, self.view.height - [self calculateComplainViewHeight], self.view.width, [self calculateComplainViewHeight])];
        WeakSelf;
        _complainView.dismissComplete = ^{
            StrongSelf;
            [self dismissComplainView];
        };
        _complainView.showKeyboardComeplete = ^(CGFloat keyboardHeight){
            StrongSelf;
            [UIView animateWithDuration:0.25f animations:^{
                self.complainView.top = self.view.height - [self calculateComplainViewHeight] - keyboardHeight;
            }];
        };
        _complainView.dismissKeyboardComeplete = ^{
            StrongSelf;
            [UIView animateWithDuration:0.25f animations:^{
                self.complainView.top = self.view.height - [self calculateComplainViewHeight];
            }];
        };
        _complainView.sendComplainComplete = ^{
            StrongSelf;
            if (self.commitComplete) {
                self.commitComplete();
            }
            [self dismissViewController];
        };
        _complainView.hasComplainMessage = ^(BOOL isMessage) {
            StrongSelf;
            if (self.hasComplainMessage) {
                self.hasComplainMessage(isMessage);
            }
        };
    }
    return _complainView;
}

- (void)setType:(TTDislikeType)type {
    _type = type;
    if (_type == TTDislikeTypeOnlyReport) {
        self.dislikeView.frame = CGRectMake(0, self.view.height - [self calculateOnlyReportHeight], self.view.width, [self calculateOnlyReportHeight]);
    }
    else {
        self.dislikeView.frame = CGRectMake(0, self.view.height - [self calculateDislikeViewHeight], self.view.width, [self calculateDislikeViewHeight]);
    }
    self.dislikeView.type = _type;

}

#pragma mark - Utils
- (CGFloat)calculateDislikeViewHeight {
    CGFloat height = [TTDeviceUIUtils tt_newPadding:454.f];
    if (self.dislikeOptions.count < 3) {
        height -= [TTDeviceUIUtils tt_newPadding:48.f];
    }
    return height;
}

- (CGFloat)calculateOnlyReportHeight {
    CGFloat height = 0;
    height = [TTDeviceUIUtils tt_newPadding:326.f];
    return height;
}

- (CGFloat)calculateComplainViewHeight {
    return [TTDeviceUIUtils tt_newPadding:160.f];
}

@end
