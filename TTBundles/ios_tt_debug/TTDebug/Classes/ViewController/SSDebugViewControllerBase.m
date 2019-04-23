//
//  SSDebugViewControllerBase.m
//  Article
//
//  Created by liufeng on 2017/8/14.
//
//

#if INHOUSE

#import "SSDebugViewControllerBase.h"
#import "SSQRCodeScanViewController.h"
#import "SSWebViewController.h"
#import "SSLocationPickerController.h"
#import "TTArticleCategoryManager.h"
#import "MBProgressHUD.h"
#import "SSDebugPingViewController.h"
#import "SSDebugDNSViewController.h"
#import "DebugUmengIndicator.h"
#import "SSDebugUserDefaultsViewController.h"
#import "TTInstallIDManager.h"
#import "TTIndicatorView.h"
#import "TTThemedAlertController.h"
#import "TTLocationManager.h"
#import "TTNetworkManager.h"
#import "TTLocationManager.h"
#import "NewsUserSettingManager.h"
#import "FLEXManager.h"
#import "TTMemoryMonitor.h"
#import "TTTrackerWrapper.h"
#import "TTRoute.h"
#import "TTSandBoxHelper.h"
//#import <TTLiveMainUI/TTLiveMainViewController.h>

#import "ArticleMobileSettingViewController.h"
#import "TTPersistence.h"
#import "TTURLUtils.h"
#import "WDCommonLogic.h"

#import "ExploreCellHelper.h"
#import "TTStringHelper.h"

#import "TTVideoTip.h"
#import "TTLogServer.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"

//#import "SSADManager.h"

#import <TTAccountBusiness.h>

//#import "TTABAuthorizationManager.h"
#import "TTCanvasBundleManager.h"
#import <TTServiceKit/TTServiceCenter.h>
#import "TTAdManagerProtocol.h"

@implementation STTableViewCellItem

- (instancetype) initWithTitle:(NSString *)title target:(id)target action:(SEL)action {
    self = [super init];
    if (self) {
        self.title = title;
        self.target = target;
        self.action = action;
    }
    return self;
}

@end

@implementation STTableViewSectionItem

- (instancetype)initWithSectionTitle:(NSString *)title items:(NSArray *)items {
    return [self initWithSectionHeaderTitle:title footerTitle:nil items:items];
}

- (instancetype)initWithSectionHeaderTitle:(NSString *)title footerTitle:(NSString *)footerTitle items:(NSArray *)items {
    self = [super init];
    if (self) {
        self.headerTitle = title;
        self.footerTitle = footerTitle;
        self.items = items;
    }
    return self;
}

@end

@interface STTableViewCell : SSThemedTableViewCell<UITextFieldDelegate>


@property(nonatomic, strong) UISwitch   *switchView;
@property(nonatomic, strong) STTableViewCellItem   *cellItem;
@property(nonatomic, strong) SSThemedTextField *textFieldView;
@end

@implementation STTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColorThemeKey = kColorBackground4;
        self.backgroundSelectedColorThemeKey = kColorBackground4Highlighted;
        self.separatorColorThemeKey = kColorLine7;
        self.switchView = [[UISwitch alloc] init];
        self.accessoryView = self.switchView;
        self.textFieldView = [[SSThemedTextField alloc] init];
        self.textFieldView.borderStyle = UITextBorderStyleRoundedRect;
        self.textFieldView.keyboardType = UIKeyboardTypeAlphabet;
        self.textFieldView.returnKeyType = UIReturnKeyDone;
        self.textFieldView.textColorThemeKey = kColorText1;
        self.textFieldView.delegate = self;
        [self.switchView addTarget:self action:@selector(_switchActionFired:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

- (BOOL)textFieldShouldEndEditing:(SSThemedTextField *)textField{
    
    [self _textFieldActionFired:textField];
    return YES;
}
- (BOOL)textFieldShouldReturn:(SSThemedTextField *)textField {
    [textField resignFirstResponder];//关闭键盘
    return YES;
}

- (void)setCellItem:(STTableViewCellItem *)cellItem {
    self.accessoryView = cellItem.switchStyle ? self.switchView : nil;
    self.selectionStyle = cellItem.switchStyle ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    self.switchView.on = cellItem.checked;
    if (!self.accessoryView) {
        self.accessoryView = cellItem.textFieldStyle ? self.textFieldView : nil;
        self.textFieldView.text = cellItem.textFieldContent;
        self.textFieldView.tag = cellItem.tag;
        if (cellItem.textFieldStyle) {
            [self.accessoryView setFrame:CGRectMake(0, 10, 50, self.bounds.size.height - 20)];
            [self.accessoryView setBackgroundColor:[UIColor yellowColor]];
        }
        self.selectionStyle = cellItem.textFieldStyle ? UITableViewCellSelectionStyleNone : UITableViewCellSelectionStyleDefault;
    }
    _cellItem = cellItem;
}

- (void)_switchActionFired:(UISwitch *)uiswitch {
    if ([self.cellItem.target respondsToSelector:_cellItem.switchAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.cellItem.target performSelector:_cellItem.switchAction withObject:uiswitch];
#pragma clang diagnostic pop
    }
    self.cellItem.checked = uiswitch.on;
}

- (void)_textFieldActionFired:(SSThemedTextField *)textField{
    if ([self.cellItem.target respondsToSelector:self.cellItem.textFieldAction]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [self.cellItem.target performSelector:_cellItem.textFieldAction withObject:textField];
#pragma clang diagnostic pop
    }
}

@end

@implementation UIScrollView (ScrollToBottom)

- (void)scrollToBottomAnimated:(BOOL)animated {
    CGPoint contentOffset = CGPointMake(0, self.contentSize.height - self.frame.size.height);
    if (contentOffset.y > 0) {
        [self setContentOffset:contentOffset animated:animated];
    }
}

@end


@implementation STDebugTextView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor blackColor];
        self.textColor = [UIColor greenColor];
        if ([self respondsToSelector:@selector(layoutManager)]) {
            self.layoutManager.allowsNonContiguousLayout = NO;
        }
        self.font = [UIFont systemFontOfSize:14];
        self.editable = NO;
    }
    return self;
}

- (void)appendText:(NSString *)text {
    if (isEmptyString(text)) {
        return;
    }
    if (isEmptyString(self.text)) {
        self.text = text;
    } else {
        self.text = [NSString stringWithFormat:@"%@\n%@" , self.text, text];
        [self scrollToBottomAnimated:YES];
    }
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    [self scrollRangeToVisible:NSMakeRange(self.text.length, 0)];
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    NSString *selectorName = NSStringFromSelector(action);
    return [selectorName hasPrefix:@"copy"] || [selectorName hasPrefix:@"select"];
}

@end

@interface SSDebugViewControllerBase ()

@property(nonatomic, strong) UITapGestureRecognizer *tapGestureForResignFirstResponder;

@end

@implementation SSDebugViewControllerBase

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self _setupTableView];
    
    self.tapGestureForResignFirstResponder = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(textFieldResignFirstResponder)];
    _tapGestureForResignFirstResponder.numberOfTapsRequired = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)_setupTableView
{
    self.tableView = [[SSThemedTableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColorThemeKey = kColorBackground4;
    self.tableView.enableTTStyledSeparator = YES;
    self.tableView.separatorColorThemeKey = kColorLine1;
    self.tableView.separatorSecondColorThemeKey = kColorLine1;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.userInteractionEnabled = YES;
    CGFloat top = 44.f + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.tableView.frame = CGRectMake(0, top, self.view.width, self.view.height - top);
    [self.view addSubview:self.tableView];
    
    [self.tableView registerClass:[STTableViewCell class] forCellReuseIdentifier:@"Identifier"];
}

#pragma mark - textFieldResignFirstResponder
- (void)textFieldResignFirstResponder{
    UIResponder *responder = [self.view findFirstResponder];
    if ([responder isKindOfClass:[SSThemedTextField class]]) {
        [responder resignFirstResponder];
        
    }
}

#pragma mark - keyboard show or hide
- (void)keyboardWillShow:(NSNotification *)notification {
    [self.tableView addGestureRecognizer:_tapGestureForResignFirstResponder];
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardHeight = keyboardRect.size.height;
    CGSize  newTableViewContentSize = self.tableView.contentSize;
    newTableViewContentSize.height += keyboardHeight;
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [self.tableView setContentSize:newTableViewContentSize];
    [self.tableView setContentOffset:CGPointMake(0, self.tableView.contentOffset.y + keyboardHeight)];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.tableView removeGestureRecognizer:_tapGestureForResignFirstResponder];
    [[NSNotificationCenter defaultCenter] postNotificationName:kClearCacheHeightNotification object:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSettingFontSizeChangedAheadNotification object:self];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSettingFontSizeChangedNotification object:self];
    NSDictionary* userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.view convertRect:keyboardRect fromView:nil];
    
    CGFloat keyboardHeight = keyboardRect.size.height;
    CGSize  oldTableViewContentSize = self.tableView.contentSize;
    oldTableViewContentSize.height -= keyboardHeight;
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    [self.tableView setContentSize:oldTableViewContentSize];
    [UIView commitAnimations];
}

#pragma mark - Table view data source
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    STTableViewSectionItem * sectionItem = [self.dataSource objectAtIndex:section];
    if ([sectionItem isKindOfClass:[STTableViewSectionItem class]]) {
        return sectionItem.headerTitle;
    }
    return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    STTableViewSectionItem * sectionItem = [self.dataSource objectAtIndex:section];
    if ([sectionItem isKindOfClass:[STTableViewSectionItem class]]) {
        return sectionItem.footerTitle;
    }
    return nil;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    STTableViewSectionItem * sectionItem = [self.dataSource objectAtIndex:section];
    if ([sectionItem isKindOfClass:[STTableViewSectionItem class]]) {
        return sectionItem.items.count;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    STTableViewCell *tableViewCell = (STTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"Identifier"];
    STTableViewSectionItem *sectionItem = [self.dataSource objectAtIndex:indexPath.section];
    STTableViewCellItem *item = sectionItem.items[indexPath.row];
    if ([item isKindOfClass:[STTableViewCellItem class]]) {
        tableViewCell.tableView = (SSThemedTableView *)tableView;
        tableViewCell.cellIndex = indexPath;
        tableViewCell.textLabel.text = item.title;
        tableViewCell.textLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        tableViewCell.textLabel.backgroundColor = [UIColor clearColor];
        tableViewCell.detailTextLabel.text = item.detail;
        tableViewCell.detailTextLabel.textColor = [UIColor tt_themedColorForKey:kColorText3];
        tableViewCell.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        if ([tableViewCell isKindOfClass:[STTableViewCell class]]) {
            tableViewCell.cellItem = item;
        }
    } else {
        tableViewCell.textLabel.text = @"配置出现问题";
    }
    return tableViewCell;
}


- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    if (![view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        return;
    }
    UILabel * textLabel = ((UITableViewHeaderFooterView * )view).textLabel;
    STTableViewSectionItem * sectionItem = [self.dataSource objectAtIndex:section];
    if ([sectionItem isKindOfClass:[STTableViewSectionItem class]]) {
        textLabel.text = sectionItem.headerTitle;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayFooterView:(UIView *)view forSection:(NSInteger)section {
    if (![view isKindOfClass:[UITableViewHeaderFooterView class]]) {
        return;
    }
    UILabel * textLabel = ((UITableViewHeaderFooterView * )view).textLabel;
    STTableViewSectionItem * sectionItem = [self.dataSource objectAtIndex:section];
    if ([sectionItem isKindOfClass:[STTableViewSectionItem class]]) {
        textLabel.text = sectionItem.footerTitle;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    STTableViewSectionItem * sectionItem = [self.dataSource objectAtIndex:indexPath.section];
    STTableViewCellItem * item = sectionItem.items[indexPath.row];
    if ([item isKindOfClass:[STTableViewCellItem class]] && [item.target respondsToSelector:item.action]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [item.target performSelector:item.action];
#pragma clang diagnostic pop
    }
}

@end

#endif
