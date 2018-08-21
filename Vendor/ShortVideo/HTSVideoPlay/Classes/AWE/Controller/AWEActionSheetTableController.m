//  AWEActionSheeAWEableController.m
//  Article
//
//  Created by zhaoqin on 8/27/16.
//
//

#import "TTDeviceHelper.h"
#import "AWEActionSheetTableController.h"
#import "AWEActionSheetModel.h"
#import "AWEActionSheetConst.h"
#import "AWEActionSheetTableCell.h"
#import "AWEVideoCommentDataManager.h"
#import "TTKeyboardListener.h"
#import "AWEActionSheetCellModel.h"
#import "AWEActionSheetTextController.h"
#import "AWEActionSheetAnimated.h"
#import "AWEActionSheetTitleView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTUIResponderHelper.h"
#import "AWEActionSheetWriteCommentCell.h"
#import <SSThemed.h>
#import "UIViewAdditions.h"
#import "UIButton+TTAdditions.h"

@interface AWEActionSheetTableController ()<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SSThemedButton *finishedButton;
@property (nonatomic, strong) SSThemedView *bottomSafeAreaView;
@property (nonatomic, assign) NSInteger numberOfRows;
@property (nonatomic, strong) AWEActionSheetTitleView *titleView;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@end

@implementation AWEActionSheetTableController

- (void)dealloc
{
    _tableView.dataSource = nil;
    _tableView.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configViews];
    
    [self.view setBackgroundColor:[UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.titleView.hidden = NO;
    self.tableView.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.titleView.hidden = YES;
    self.tableView.hidden = YES;
    [self resignFirstResponder];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    
    CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    CGFloat padding = [TTUIResponderHelper paddingForViewWidth:screenWidth];
    CGFloat width = screenWidth - 2 * padding;

    
    NSArray *windowViewControllers = self.navigationController.viewControllers;
    
    if ([self isEqual:[windowViewControllers lastObject]]) {
        
        
        [self.tableView setNeedsLayout];
        [self.titleView setNeedsLayout];
        
        if (self.numberOfRows * AWEActionSheetTableCellHeight + AWEActionSheetNavigationBarHeight > screenHeight) {
            self.navigationController.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        }
        else {
            self.navigationController.view.frame = CGRectMake(0, screenHeight - self.finishedButton.bottom - bottomInset, self.navigationController.view.frame.size.width, self.finishedButton.bottom + bottomInset);
        }
        
        if (self.model.dataArray.count == 0) {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, AWEActionSheetFinishedButtonHeight)];
        }
        else {
            if (self.numberOfRows * AWEActionSheetTableCellHeight + AWEActionSheetNavigationBarHeight + AWEActionSheetFinishedButtonHeight > screenHeight) {
                self.tableView.frame = CGRectMake(0, AWEActionSheetNavigationBarHeight, screenWidth, screenHeight - AWEActionSheetNavigationBarHeight - AWEActionSheetFinishedButtonHeight - bottomInset);
            }
            else {
                self.tableView.frame = CGRectMake(0, AWEActionSheetNavigationBarHeight, screenWidth, self.numberOfRows * AWEActionSheetTableCellHeight);
            }
        }
        
        self.finishedButton.frame = CGRectMake(padding, self.tableView.bottom, width, AWEActionSheetFinishedButtonHeight);
        self.bottomSafeAreaView.frame = CGRectMake(padding, self.finishedButton.bottom, width, bottomInset);
    }
}

- (void)configViews {

    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    
    self.titleView = [[AWEActionSheetTitleView alloc] init];
    WeakSelf;
    [self.titleView.backButton addTarget:self withActionBlock:^{
        [UIView animateWithDuration:AWEActionSheetAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            StrongSelf;
            self.navigationController.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            StrongSelf;
            [self.navigationController popViewControllerAnimated:YES];
        }];
    } forControlEvent:UIControlEventTouchUpInside];
    
    if (self.navigationController.topViewController == self.navigationController.viewControllers[0]) {
        self.titleView.backButton.hidden = YES;
    }
    
    [self.view addSubview:self.titleView];
    self.navigationController.navigationBar.hidden = YES;
    self.titleView.title = @"举报";
    
    if (self.model.dataArray.count == 0) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, AWEActionSheetFinishedButtonHeight)];
    }
    else {
        if (self.numberOfRows * AWEActionSheetTableCellHeight + AWEActionSheetNavigationBarHeight + AWEActionSheetFinishedButtonHeight > screenHeight) {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, AWEActionSheetNavigationBarHeight, screenWidth, screenHeight - AWEActionSheetNavigationBarHeight - AWEActionSheetFinishedButtonHeight)];
        }
        else {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, AWEActionSheetNavigationBarHeight, screenWidth, self.numberOfRows * AWEActionSheetTableCellHeight)];
        }
    }
    
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    
    [self.tableView setBackgroundColor:[UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"]];
    [self.tableView registerClass:[AWEActionSheetTableCell class] forCellReuseIdentifier:AWEActionSheetTableCellIdentifier];
    [self.tableView registerClass:[AWEActionSheetWriteCommentCell class] forCellReuseIdentifier:AWEActionSheetWriteCommentCellIdentifier];
     
    CGFloat padding = [TTUIResponderHelper paddingForViewWidth:screenWidth];
    CGFloat width = screenWidth - 2 * padding;
    
    self.finishedButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(padding, self.tableView.bottom, width, AWEActionSheetFinishedButtonHeight)];
    [self.finishedButton setTitle:@"完成" forState:UIControlStateNormal];
    self.finishedButton.titleColorThemeKey = kColorText1;
    self.finishedButton.highlightedTitleColorThemeKey = kColorText1Highlighted;
    self.finishedButton.backgroundColorThemeKey = kColorBackground4;
    self.finishedButton.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
    self.finishedButton.titleLabel.font = [UIFont systemFontOfSize:17.0];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.finishedButton.frame.size.width, 0.5)];
    lineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    [self.finishedButton addSubview:lineView];
    [self.finishedButton addTarget:self withActionBlock:^{
        StrongSelf;
        if ([self.titleView.title isEqualToString:@"不喜欢"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:AWEActionSheetFinishedClickNotification object:nil userInfo:@{@"source": @"dislike_finish"}];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:AWEActionSheetFinishedClickNotification object:nil userInfo:@{@"source": @"report_finish"}];
        }
    } forControlEvent:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.finishedButton];
    
    CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    
    if (bottomInset > 0) {
        self.bottomSafeAreaView = [[SSThemedView alloc] initWithFrame:CGRectMake(padding, self.finishedButton.bottom, width, bottomInset)];
        self.bottomSafeAreaView.backgroundColorThemeKey = kColorBackground4;
        [self.view addSubview:self.bottomSafeAreaView];
    }
    
    self.viewHeight = self.tableView.height + self.finishedButton.height + self.titleView.height + bottomInset;
    
    if (self.numberOfRows * AWEActionSheetTableCellHeight + AWEActionSheetNavigationBarHeight > screenHeight) {
        self.navigationController.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    }
    else {
        self.navigationController.view.frame = CGRectMake(0, screenHeight - self.finishedButton.bottom - bottomInset, self.navigationController.view.frame.size.width, self.finishedButton.bottom + bottomInset);
    }
    
    
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.model.dataArray.count == 0) {
        return AWEActionSheetFinishedButtonHeight;
    }
    else {
        return AWEActionSheetTableCellHeight;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == self.numberOfRows - 1) {
        AWEActionSheetWriteCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:AWEActionSheetWriteCommentCellIdentifier forIndexPath:indexPath];
        AWEActionSheetCellModel *cellModel = self.model.dataArray[indexPath.row];
        cell.contentLabel.text = cellModel.text;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        AWEActionSheetTableCell *cell = [tableView dequeueReusableCellWithIdentifier:AWEActionSheetTableCellIdentifier forIndexPath:indexPath];
        AWEActionSheetCellModel *cellModel = self.model.dataArray[indexPath.row];
        [cell configCellWithModel:cellModel];
        cell.seperatorView.hidden = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
        
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    AWEActionSheetTableCell *cell = (AWEActionSheetTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];

    if (indexPath.row == self.numberOfRows - 1) {
        AWEActionSheetTextController *nextController = [[AWEActionSheetTextController alloc] init];
        nextController.manager = self.manager;
        nextController.type = self.reportType;
        [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.navigationController.view.alpha = 0.0f;
        } completion:^(BOOL finished) {
            [self.navigationController pushViewController:nextController animated:YES];
        }];
        
    }
    else {
        AWEActionSheetCellModel *cellModel = self.model.dataArray[indexPath.row];
        if (cellModel.isSelected) {
            cellModel.isSelected = NO;
        }
        else {
            cellModel.isSelected = YES;
        }
        [cell configCellWithModel:cellModel];
    }
}

- (NSInteger)numberOfRows {
   return self.model.dataArray.count;
}

@end
