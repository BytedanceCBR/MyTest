//
//  TTArticleDetailMenuController.m
//  Article
//
//  Created by zhaoqin on 11/10/2016.
//
//

#import "TTArticleDetailMenuController.h"
#import "UIColor+TTThemeExtension.h"

#import "TTRoute.h"
#import "SSThemed.h"
#import "Article.h"

#define TTArticleDetailMenuTitleViewHeight [TTDeviceUIUtils tt_padding:59.f]
#define TTArticleDetailMenuCellHeight [TTDeviceUIUtils tt_padding:44.f]
#define TTArticleDetailMenuFinishedButtonHeight [TTDeviceUIUtils tt_padding:48.f]
#define TTArticleDetailMenuCellIdentifier @"TTArticleDetailMenuCellIdentifier"
#define TTArticleDetailMenuAnimationDuration 0.25f

@interface TTArticleDetailMenuRootController : UIViewController

@end

@implementation TTArticleDetailMenuRootController

//- (BOOL)shouldAutorotate {
//    return YES;
//}
//
//- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
//    return UIInterfaceOrientationMaskAll;
//}

@end

@interface TTArticleDetailMenuTitleView : SSThemedView
@property (nonatomic, strong) UILabel *titleLabel;
@end

@implementation TTArticleDetailMenuTitleView

- (instancetype)init {
    if (self = [super init]) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_fontSize:17.f]];
        _titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        [self addSubview:_titleLabel];
        self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(0, 0, self.width, self.height);
}

@end

@interface TTArticleDetailMenuModel : NSObject
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *menuID;
@end

@implementation TTArticleDetailMenuModel

@end

@interface TTArticleDetailMenuCell : SSThemedTableViewCell
@property (nonatomic, strong) SSThemedLabel *contentLabel;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) SSThemedView *seperatorView;
@end

@implementation TTArticleDetailMenuCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _contentLabel = [[SSThemedLabel alloc] init];
        _contentLabel.textColorThemeKey = kColorText1;
        _arrowImageView = [[UIImageView alloc] init];
        _seperatorView = [[SSThemedView alloc] init];
        self.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
        
        [self.contentView addSubview:_contentLabel];
        [self.contentView addSubview:_arrowImageView];
        [self.contentView addSubview:_seperatorView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat padding = [TTDeviceUIUtils tt_padding:32];
    self.contentLabel.frame = CGRectMake(padding, 0, self.contentView.width - 2 * padding - 15, self.contentView.height);
    self.arrowImageView.frame = CGRectMake(0, 0, 15, 15);
    if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
        self.arrowImageView.image = [UIImage imageNamed:@"all_arrow_unlike"];
    }
    else {
        self.arrowImageView.image = [UIImage imageNamed:@"all_arrow_unlike_night"];
    }
    self.arrowImageView.transform = CGAffineTransformMakeRotation(M_PI);
    self.arrowImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.arrowImageView.left = self.contentLabel.right;
    self.arrowImageView.centerY = self.contentView.centerY;
    self.seperatorView.backgroundColorThemeKey = kColorLine1;
    self.seperatorView.frame = CGRectMake(padding, self.contentView.height - 1, self.contentView.width - 2 * padding, 0.5);
}

@end

@protocol TTArticleDetailMenuDelegate <NSObject>
- (void)dismissMenu;
@end

@interface TTArticleDetailMenuViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) TTArticleDetailMenuTitleView *titleView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *modelArray;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, assign) CGFloat paddingForPad;
@property (nonatomic, strong) SSThemedButton *finishedButton;
@property (nonatomic, weak) id<TTArticleDetailMenuDelegate> delegate;
@property (nonatomic, strong) Article *article;
@end

@implementation TTArticleDetailMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.rowHeight = TTArticleDetailMenuCellHeight;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[TTArticleDetailMenuCell class] forCellReuseIdentifier:TTArticleDetailMenuCellIdentifier];
    
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.view.width = self.screenWidth;
    self.titleView.frame = CGRectMake(self.paddingForPad, 0, self.view.width - 2 * self.paddingForPad, TTArticleDetailMenuTitleViewHeight);
    CGFloat maxHeight = self.modelArray.count * TTArticleDetailMenuCellHeight + TTArticleDetailMenuTitleViewHeight + TTArticleDetailMenuFinishedButtonHeight;
    if (self.screenHeight > maxHeight) {
        self.tableView.frame = CGRectMake(self.paddingForPad, self.titleView.bottom, self.view.width - 2 * self.paddingForPad, self.modelArray.count * TTArticleDetailMenuCellHeight);
    }
    else {
        self.tableView.frame = CGRectMake(self.paddingForPad, self.titleView.bottom, self.view.width - 2 * self.paddingForPad, self.screenHeight - TTArticleDetailMenuTitleViewHeight - TTArticleDetailMenuFinishedButtonHeight);
    }
    self.finishedButton.frame = CGRectMake(self.paddingForPad, self.tableView.bottom, self.view.width - 2 * self.paddingForPad, TTArticleDetailMenuFinishedButtonHeight);
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.finishedButton.frame.size.width, 0.5)];
    lineView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
    [_finishedButton addSubview:lineView];
    
    if (self.screenHeight > maxHeight) {
        self.view.height = maxHeight;
        self.view.top = self.screenHeight - self.view.height;
    }
    else {
        self.view.height = self.screenHeight;
        self.view.top = 0;
    }

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.modelArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TTArticleDetailMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:TTArticleDetailMenuCellIdentifier forIndexPath:indexPath];
    TTArticleDetailMenuModel *model = self.modelArray[indexPath.row];
    cell.contentLabel.text = model.name;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (indexPath.row == self.modelArray.count - 1) {
        cell.seperatorView.hidden = YES;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TTArticleDetailMenuModel *model = self.modelArray[indexPath.row];
    TTRoute *route = [TTRoute sharedRoute];
    [self.delegate dismissMenu];
    [route openURLByPushViewController:[NSURL URLWithString:model.value]];
    NSMutableDictionary *extraDic = [[NSMutableDictionary alloc] init];
    [extraDic setObject:self.article.itemID forKey:@"item_id"];
    [extraDic setObject:@"pgc_author_card_menu" forKey:@"card_type"];
    [extraDic setObject:model.menuID forKey:@"firstmenu_id"];
    [extraDic setObject:self.article.mediaInfo[@"media_id"] forKey:@"card_id"];
    [extraDic setObject:@(indexPath.row) forKey:@"secondmenu_id"];
    [extraDic setObject:self.article.mediaInfo[@"media_id"] forKey:@"card_mid"];
    wrapperTrackEventWithCustomKeys(@"detail", @"click_card_secondmenu", self.article.groupModel.groupID, nil, extraDic);
}

- (TTArticleDetailMenuTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[TTArticleDetailMenuTitleView alloc] init];
        [self.view addSubview:_titleView];
    }
    return _titleView;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] init];
        _tableView.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
        [self.view addSubview:_tableView];
    }
    return _tableView;
}

- (SSThemedButton *)finishedButton {
    if (!_finishedButton) {
        _finishedButton = [[SSThemedButton alloc] init];
        [_finishedButton setTitle:@"取消" forState:UIControlStateNormal];
        _finishedButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_fontSize:17.0f]];
        _finishedButton.titleColorThemeKey = kColorText1;
        _finishedButton.highlightedTitleColorThemeKey = kColorText1Highlighted;
        _finishedButton.backgroundColorThemeKey = kColorBackground4;
        WeakSelf;
        [_finishedButton addTarget:self withActionBlock:^{
            StrongSelf;
            [self.delegate dismissMenu];
        } forControlEvent:UIControlEventTouchUpInside];
        [self.view addSubview:_finishedButton];
    }
    return _finishedButton;
}

@end

@interface TTArticleDetailMenuController () <TTArticleDetailMenuDelegate>
@property (nonatomic, strong) UIWindow *backWindow;
@property (nonatomic, strong) TTArticleDetailMenuRootController *rootViewController;
@property (nonatomic, strong) TTArticleDetailMenuViewController *viewController;
@property (nonatomic, strong) UIView *maskView;
@property (nonatomic, assign) CGFloat screenWidth;
@property (nonatomic, assign) CGFloat screenHeight;
@property (nonatomic, strong) void(^dismissBlock)() ;
@end

@implementation TTArticleDetailMenuController

- (instancetype)init {
    if (self = [super init]) {
        _backWindow = [[UIWindow alloc] init];
        _backWindow.frame = [UIApplication sharedApplication].keyWindow.bounds;
        _backWindow.windowLevel = UIWindowLevelAlert;
        _backWindow.rootViewController = self.rootViewController;
        _backWindow.backgroundColor = [UIColor clearColor];
        _backWindow.hidden = YES;
        
        self.screenWidth = [UIScreen mainScreen].bounds.size.width;
        self.screenHeight = [UIScreen mainScreen].bounds.size.height;
        if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
            CGFloat temp = self.screenWidth;
            self.screenWidth = self.screenHeight;
            self.screenHeight = temp;
        }
        self.viewController.screenWidth = self.screenWidth;
        self.viewController.screenHeight = self.screenHeight;
        self.viewController.paddingForPad = [TTUIResponderHelper paddingForViewWidth:self.screenWidth];
        [self.rootViewController.view addSubview:self.maskView];
        [self.rootViewController.view addSubview:self.viewController.view];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(ttapplicationStautsBarDidRotate) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
   
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
}

- (void)ttapplicationStautsBarDidRotate {
    if (self.viewController) {
        [self willTransitionToSize:[UIApplication sharedApplication].keyWindow.bounds.size];
    }
}

- (void)willTransitionToSize:(CGSize)size {
    CGRect frame = CGRectZero;
    frame.size = size;
    self.backWindow.frame = frame;
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    
    self.screenWidth = screenWidth;
    self.screenHeight = screenHeight;
    
    self.viewController.screenWidth = screenWidth;
    self.viewController.screenHeight = screenHeight;
    self.viewController.paddingForPad = [TTUIResponderHelper paddingForViewWidth:self.screenWidth];
    
    self.maskView.frame = CGRectMake(0, 0, self.screenWidth, self.screenHeight);
    
}

- (void)performMenuAndInsertData:(NSDictionary *)data article:(Article *)article dismiss:(void (^)())dismissBlock {
    if (data) {
        NSArray *dataArray = data[@"children"];
        if (SSIsEmptyArray(dataArray)) {
            return;
        }
        NSMutableArray *mutableArray = [[NSMutableArray alloc] init];
        for (NSDictionary *dic in dataArray) {
            if (!isEmptyString([dic tt_stringValueForKey:@"name"]) && !isEmptyString([dic tt_stringValueForKey:@"schema_href"])) {
                TTArticleDetailMenuModel *model = [[TTArticleDetailMenuModel alloc] init];
                model.name = dic[@"name"];
                model.value = dic[@"schema_href"];
                model.type = dic[@"type"];
                model.menuID = data[@"firstmenu_id"];
                [mutableArray addObject:model];
            }
        }
        if (mutableArray.count == 0) {
            return;
        }
        self.viewController.titleView.titleLabel.text = data[@"name"];
        self.viewController.modelArray = mutableArray;
        self.viewController.article = article;
        
        [self.backWindow makeKeyAndVisible];
        [self configGesture];
        
        CGRect beforeRect = self.viewController.view.frame;
        beforeRect.origin.y += beforeRect.size.height;
        self.viewController.view.frame = beforeRect;
        [UIView animateWithDuration:TTArticleDetailMenuAnimationDuration animations:^{
            CGRect afterRect = self.viewController.view.frame;
            afterRect.origin.y -= afterRect.size.height;
            self.viewController.view.frame = afterRect;
        }];
    }
    if (dismissBlock) {
        self.dismissBlock = dismissBlock;
    }
}

- (void)configGesture {
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissMenu)];
    [self.maskView addGestureRecognizer:tap];
}

- (void)dismissMenu {
    [UIView animateWithDuration:TTArticleDetailMenuAnimationDuration animations:^{
        CGRect afterRect = self.viewController.view.frame;
        afterRect.origin.y += afterRect.size.height;
        self.viewController.view.frame = afterRect;
    } completion:^(BOOL finished) {
        self.rootViewController = nil;
        self.backWindow.hidden = YES;
        self.backWindow = nil;
        if (self.dismissBlock) {
            self.dismissBlock();
        }
    }];
}

- (TTArticleDetailMenuRootController *)rootViewController {
    if (!_rootViewController) {
        _rootViewController = [[TTArticleDetailMenuRootController alloc] init];
    }
    return _rootViewController;
}

- (TTArticleDetailMenuViewController *)viewController {
    if (!_viewController) {
        _viewController = [[TTArticleDetailMenuViewController alloc] init];
        _viewController.view.frame = CGRectMake(0, 0, self.screenWidth, self.screenHeight);
        _viewController.view.backgroundColor = [UIColor colorWithDayColorName:@"f8f8f8" nightColorName:@"252525"];
        _viewController.delegate = self;
    }
    return _viewController;
}

- (UIView *)maskView {
    if (!_maskView) {
        _maskView = [[UIView alloc] init];
        _maskView.frame = CGRectMake(0, 0, self.screenWidth, self.screenHeight);
        _maskView.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground9];
    }
    return _maskView;
}


@end
