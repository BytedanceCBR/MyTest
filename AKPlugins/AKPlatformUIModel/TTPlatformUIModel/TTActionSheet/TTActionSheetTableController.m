//  TTActionSheetTableController.m
//  Article
//
//  Created by zhaoqin on 8/27/16.
//
//

#import "TTActionSheetTableController.h"
#import "TTActionSheetModel.h"
#import "TTActionSheetConst.h"
#import "TTActionSheetTableCell.h"
#import "TTActionSheetManager.h"
#import "TTActionSheetCellModel.h"
#import "TTActionSheetTextController.h"
#import "TTActionSheetAnimated.h"
#import "TTActionSheetTitleView.h"
#import "TTActionSheetWriteCommentCell.h"

#import "TTKeyboardListener.h"
#import "UIColor+TTThemeExtension.h"
#import "TTUIResponderHelper.h"
#import <SSThemed.h>
#import "UIViewAdditions.h"
#import "TTDeviceHelper.h"
#import "TTDeviceUIUtils.h"
#import "UIButton+TTAdditions.h"

@interface TTActionSheetTableController ()<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) SSThemedButton *finishedButton;
@property (nonatomic, strong) SSThemedView   *bottomSafeAreaView;
@property (nonatomic, assign) NSInteger numberOfRows;
@property (nonatomic, strong) TTActionSheetTitleView *titleView;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@end

@implementation TTActionSheetTableController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configViews];
    
    [self.view setBackgroundColor:[UIColor colorWithDayColorName:@"ffffff" nightColorName:@"252525"]];
    
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

- (void)viewWillLayoutSubviews {
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
        
        if (self.numberOfRows * TTActionSheetTableCellHeight + TTActionSheetNavigationBarHeight > screenHeight) {
            self.navigationController.view.frame = CGRectMake(0, 0, screenWidth, screenHeight);
        }
        else {
            self.navigationController.view.frame = CGRectMake(0, screenHeight - self.finishedButton.bottom - bottomInset, self.navigationController.view.frame.size.width, self.finishedButton.bottom + bottomInset);
        }
        
        if (self.model.dataArray.count == 0) {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, TTActionSheetFinishedButtonHeight)];
        }
        else {
            if (self.numberOfRows * TTActionSheetTableCellHeight + TTActionSheetNavigationBarHeight + TTActionSheetFinishedButtonHeight > screenHeight) {
                self.tableView.frame = CGRectMake(0, TTActionSheetNavigationBarHeight, screenWidth, screenHeight - TTActionSheetNavigationBarHeight - TTActionSheetFinishedButtonHeight - bottomInset);
            }
            else {
                self.tableView.frame = CGRectMake(0, TTActionSheetNavigationBarHeight, screenWidth, self.numberOfRows * TTActionSheetTableCellHeight);
            }
        }
        self.finishedButton.frame = CGRectMake(padding, self.tableView.bottom, width, TTActionSheetFinishedButtonHeight);
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
    
    self.titleView = [[TTActionSheetTitleView alloc] init];
    WeakSelf;
    [self.titleView.backButton addTarget:self withActionBlock:^{
        [UIView animateWithDuration:TTActionSheetAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
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
    
    switch (self.model.type) {
            case TTActionSheetTypeDislike:
            self.titleView.title = @"不喜欢";
            break;
            case TTActionSheetTypeReport: {
                switch (self.source) {
                        case TTActionSheetSourceTypeWendaQuestion:
                        self.titleView.title = @"举报此问题";
                        break;
                        
                        case TTActionSheetSourceTypeWendaAnswer:
                        self.titleView.title = @"举报此回答";
                        break;
                        
                        case TTActionSheetSourceTypeReport:
                        self.titleView.title = @"举报内容问题";
                        break;
                        case TTActionSheetSourceTypeDislike:
                        self.titleView.title = @"举报文章问题";
                        break;
                        case TTActionSheetSourceTypeUser:
                        self.titleView.title = @"举报";
                        break;
                }
            }
            break;
    }
    
    if (self.model.dataArray.count == 0) {
        self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, TTActionSheetFinishedButtonHeight)];
    }
    else {
        if (self.numberOfRows * TTActionSheetTableCellHeight + TTActionSheetNavigationBarHeight + TTActionSheetFinishedButtonHeight > screenHeight) {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TTActionSheetNavigationBarHeight, screenWidth, screenHeight - TTActionSheetNavigationBarHeight - TTActionSheetFinishedButtonHeight)];
        }
        else {
            self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, TTActionSheetNavigationBarHeight, screenWidth, self.numberOfRows * TTActionSheetTableCellHeight)];
        }
    }
    
    [self.view addSubview:self.tableView];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorColor = [UIColor clearColor];
    
    [self.tableView setBackgroundColor:[UIColor colorWithDayColorName:@"ffffff" nightColorName:@"252525"]];
    [self.tableView registerClass:[TTActionSheetTableCell class] forCellReuseIdentifier:TTActionSheetTableCellIdentifier];
    [self.tableView registerClass:[TTActionSheetWriteCommentCell class] forCellReuseIdentifier:TTActionSheetWriteCommentCellIdentifier];
    
    CGFloat padding = [TTUIResponderHelper paddingForViewWidth:screenWidth];
    CGFloat width = screenWidth - 2 * padding;
    
    self.finishedButton = [[SSThemedButton alloc] initWithFrame:CGRectMake(padding, self.tableView.bottom, width, TTActionSheetFinishedButtonHeight)];
    [self.finishedButton setTitle:@"提交" forState:UIControlStateNormal];
    self.finishedButton.titleColorThemeKey = kColorText10;
    self.finishedButton.highlightedTitleColorThemeKey = kColorText1Highlighted;
    self.finishedButton.backgroundColorThemeKey = kFHColorClearBlue;
    self.finishedButton.highlightedBackgroundColorThemeKey = kColorBackground4Highlighted;
    self.finishedButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17.0f]];
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.finishedButton.frame.size.width, 0.5)];
    lineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    [self.finishedButton addSubview:lineView];
    [self.finishedButton addTarget:self withActionBlock:^{
        StrongSelf;
        if ([self.titleView.title isEqualToString:@"不喜欢"]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:TTActionSheetFinishedClickNotification object:nil userInfo:@{@"source": @"dislike_finish"}];
        }
        else {
            [[NSNotificationCenter defaultCenter] postNotificationName:TTActionSheetFinishedClickNotification object:nil userInfo:@{@"source": @"report_finish"}];
        }
    } forControlEvent:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.finishedButton];
    CGFloat bottomInset = [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    
    if (bottomInset > 0){
        self.bottomSafeAreaView = [[SSThemedView alloc] initWithFrame:CGRectMake(padding, self.finishedButton.bottom, width, bottomInset)];
        self.bottomSafeAreaView.backgroundColorThemeKey = kColorBackground4;
        [self.view addSubview:self.bottomSafeAreaView];
    }
    self.viewHeight = self.tableView.height + self.finishedButton.height + self.titleView.height + bottomInset;
    
    if (self.numberOfRows * TTActionSheetTableCellHeight + TTActionSheetNavigationBarHeight > screenHeight) {
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
        return TTActionSheetFinishedButtonHeight;
    }
    else {
        return TTActionSheetTableCellHeight;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.adID integerValue] > 0) {
        TTActionSheetTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TTActionSheetTableCellIdentifier forIndexPath:indexPath];
        TTActionSheetCellModel *cellModel = self.model.dataArray[indexPath.row];
        [cell configCellWithModel:cellModel];
        cell.seperatorView.hidden = NO;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        return cell;
    }
    else {
        if (indexPath.row == self.numberOfRows - 1) {
            TTActionSheetWriteCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:TTActionSheetWriteCommentCellIdentifier forIndexPath:indexPath];
            //下一页面
            switch (self.model.type) {
                    case TTActionSheetTypeDislike:
                    cell.contentLabel.text = @"举报文章问题";
                    break;
                    case TTActionSheetTypeReport:
                    switch (self.source) {
                            case TTActionSheetSourceTypeWendaQuestion:
                            case TTActionSheetSourceTypeWendaAnswer:
                            case TTActionSheetSourceTypeDislike:
                            case TTActionSheetSourceTypeReport:
                            cell.contentLabel.text = @"其他问题，我要吐槽";
                            break;
                            case TTActionSheetSourceTypeUser:
                            cell.contentLabel.text = @"我有话要说";
                            break;
                    }
                    break;
            }
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
        }
        else {
            TTActionSheetTableCell *cell = [tableView dequeueReusableCellWithIdentifier:TTActionSheetTableCellIdentifier forIndexPath:indexPath];
            TTActionSheetCellModel *cellModel = self.model.dataArray[indexPath.row];
            [cell configCellWithModel:cellModel];
            cell.seperatorView.hidden = NO;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            return cell;
            
        }
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TTActionSheetTableCell *cell = (TTActionSheetTableCell *)[self.tableView cellForRowAtIndexPath:indexPath];
    
    if (indexPath.row == self.numberOfRows - 1) {
        if ([cell.contentLabel.text isEqualToString:@"举报文章问题"]) {
            if (self.trackBlock) {
                self.trackBlock();
            }
        }
        switch (self.model.type) {
                case TTActionSheetTypeDislike: {
                    if (!self.manager.reportModel) {
                        return;
                    }
                    TTActionSheetTableController *nextController = [[TTActionSheetTableController alloc] init];
                    nextController.model = self.manager.reportModel;
                    nextController.source = self.source;
                    nextController.manager = self.manager;
                    nextController.manager.source = @"report_finish";
                    [UIView animateWithDuration:0.15f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.navigationController.view.alpha = 0.0f;
                    } completion:^(BOOL finished) {
                        [self.navigationController pushViewController:nextController animated:YES];
                    }];
                }
                break;
                case TTActionSheetTypeReport: {
                    TTActionSheetTextController *nextController = [[TTActionSheetTextController alloc] init];
                    nextController.source = self.source;
                    nextController.manager = self.manager;
                    nextController.manager.source = @"report_finish";
                    [UIView animateWithDuration:0.1f delay:0.0f options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.navigationController.view.alpha = 0.0f;
                    } completion:^(BOOL finished) {
                        [self.navigationController pushViewController:nextController animated:YES];
                    }];
                }
                break;
        }
    }
    else {
        TTActionSheetCellModel *cellModel = self.model.dataArray[indexPath.row];
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
    if ([self.adID integerValue] > 0) {
        return self.model.dataArray.count;
    }
    else {
        if (self.manager.reportModel) {
            return self.model.dataArray.count + 1;
        }
        else {
            return self.model.dataArray.count;
        }
    }
}

@end
