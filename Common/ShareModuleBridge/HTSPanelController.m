//
//  HTSPanelController.m
//  Article
//
//  Created by 王霖 on 16/6/24.
//
//

#import "HTSPanelController.h"
#import "HTSPanelControllerItem.h"
#import <BDWebImage/SDWebImageAdapter.h>

#import "UIViewAdditions.h"
#import "SSThemed.h"
#import "TTThemeManager.h"

#import <Masonry/Masonry.h>
#import "UIImage+TTThemeExtension.h"
#import "TTDeviceHelper.h"



#define kFRPanelSingleCellHeight    116
#define kFRPanelTopPadding          10
#define kFRPanelCancelButtonHeight  48
#define kFRPanelCellWidth           72

#define kRootViewWillTransitionToSize       @"kRootViewWillTransitionToSize"

@interface HTSPanelThemedButton : SSThemedButton

@property (nonatomic, assign) int row;
@property (nonatomic, assign) int index;
@property (nonatomic, assign) int amount;   //小于4时，均匀分布在
@property (nonatomic, strong) SSThemedImageView *iconImage;
@property (nonatomic, strong) SSThemedImageView *selectedIconImage;
@property (nonatomic, strong) SSThemedLabel * nameLabel;
@property (nonatomic, assign) CGRect originFrame;// 未留白时原始frame
@property (nonatomic, assign) BOOL needLeaveWhite;//ipad 需要留白

- (instancetype)initWithFrame:(CGRect)frame item:(HTSPanelControllerItem *)item row:(int)row index:(int)index amount:(int)amount needLeaveWhite:(BOOL)needLeaveWhite;

- (void)setSelected:(BOOL)selected;

//- (void)doZoomInAnimation;

@end

@implementation HTSPanelThemedButton


- (instancetype)initWithFrame:(CGRect)frame item:(HTSPanelControllerItem *)item row:(int)row index:(int)index amount:(int)amount needLeaveWhite:(BOOL)needLeaveWhite
{
    self.amount = amount;
    self.needLeaveWhite = needLeaveWhite;
    self.originFrame = frame;
    self = [super initWithFrame:frame];
    if (self) {
        SSThemedImageView *iconImage = [[SSThemedImageView alloc] initWithFrame:CGRectMake(6, 12, 60, 60)];
        switch (item.itemType) {
            case HTSPanelControllerItemTypeIcon:
            {
                if (item.iconImage) {
                    iconImage.image = item.iconImage;
                } else {
                    iconImage.imageName = item.iconKey;
                    //                    iconImage.highlightedImageName = [NSString stringWithFormat:@"%@_press", item.iconKey];
                }
                self.iconImage = iconImage;
                break;
            }
            case HTSPanelControllerItemTypeSelectedIcon:
            {
                iconImage.imageName = item.iconKey;
                //                iconImage.highlightedImageName = [NSString stringWithFormat:@"%@_press", item.iconKey];
                self.iconImage = iconImage;
                
                self.selectedIconImage = [[SSThemedImageView alloc] initWithFrame:CGRectMake(6, 12, 60, 60)];
                NSString * selectedImageName = [NSString stringWithFormat:@"%@_selected", item.iconKey];
                if (![UIImage themedImageNamed:selectedImageName]) {
                    selectedImageName = item.iconKey;
                }
                self.selectedIconImage.imageName = selectedImageName;
                //                self.selectedIconImage.highlightedImageName = [NSString stringWithFormat:@"%@_press", selectedImageName];
                self.selectedIconImage.hidden = YES;
                break;
            }
            case HTSPanelControllerItemTypeAvatar:
            {
                iconImage.layer.cornerRadius = 30.0f;
                NSString *borderColor = [[[TTThemeManager sharedInstance_tt] currentThemeName] isEqualToString:@"night"] ? @"363636" : @"cacaca";
                iconImage.layer.borderColor = [UIColor colorWithHexString:borderColor].CGColor;
                iconImage.layer.masksToBounds = YES;
                iconImage.layer.borderWidth = [TTDeviceHelper ssOnePixel];
                iconImage.enableNightCover = YES;
                [iconImage sda_setImageWithURL:[NSURL URLWithString:item.iconKey] placeholderImage:nil];
                self.iconImage = iconImage;
                break;
            }
            case HTSPanelControllerItemTypeSelectedDigIcon:
            {
                iconImage.imageName = item.iconKey;
                
                self.iconImage = iconImage;
                
                self.selectedIconImage = [[SSThemedImageView alloc] initWithFrame:CGRectMake(6, 12, 60, 60)];
                NSString * selectedImageName = [NSString stringWithFormat:@"%@_selected", item.iconKey];
                if (![UIImage themedImageNamed:selectedImageName]) {
                    selectedImageName = item.iconKey;
                }
                self.selectedIconImage.imageName = selectedImageName;
                
                self.selectedIconImage.hidden = YES;
                
                break;
            }
            default:
                break;
        }
        SSThemedLabel *nameLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 78, 72, 12)];
        nameLabel.font = [UIFont systemFontOfSize:10.0f];
        nameLabel.textColorThemeKey = kColorText1;
        nameLabel.backgroundColor = [UIColor clearColor];
        nameLabel.textAlignment = NSTextAlignmentCenter;
        if (item.itemType == HTSPanelControllerItemTypeSelectedDigIcon) {
            nameLabel.text = [NSString stringWithFormat:@"%@%@",item.title,item.count];
        }
        else{
            nameLabel.text = item.title;
        }
        self.nameLabel = nameLabel;
        
        self.backgroundColor = [UIColor clearColor];
        self.row = row;
        self.index = index;
        [self addSubview:iconImage];
        [self addSubview:nameLabel];
        
        if (self.selectedIconImage) {
            [self addSubview:self.selectedIconImage];
        }
    }
    
    return self;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    [self layoutButtons];
}

- (void)layoutButtons{
    CGFloat leftPading = 0;
    CGFloat windowWidth = self.window.size.width;
    if ([TTDeviceHelper isPadDevice] && _needLeaveWhite) {
        leftPading = [TTUIResponderHelper paddingForViewWidth:0];
        CGRect frame = self.originFrame;
        frame.origin.x += leftPading;
        self.frame = frame;
    }
    else if(self.amount != 0){
        CGFloat internalWidth = windowWidth * 0.0625;
        leftPading = (windowWidth-kFRPanelCellWidth*self.amount-internalWidth*(self.amount-1))/2;
        leftPading += self.index*(internalWidth+kFRPanelCellWidth);
        CGRect frame = self.frame;
        frame.origin.x = leftPading;
        self.frame = frame;
    }
}

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    self.iconImage.hidden = selected;
    self.selectedIconImage.hidden = !selected;
}

- (void)setHighlighted:(BOOL)highlighted
{
    [super setHighlighted:highlighted];
    if (highlighted) {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.iconImage.transform = CGAffineTransformMakeScale(0.9, 0.9);
        } completion:nil];
    } else {
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.3 initialSpringVelocity:0.1 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.iconImage.transform = CGAffineTransformIdentity;
        } completion:nil];
    }
}
//产品说先不加 顶踩的加1 动画
//- (void)doZoomInAnimation
//{
//    UIView *motionView = [[UIImageView alloc] initWithImage:[UIImage themedImageNamed:@"add_all_dynamic.png"]];
//    CGPoint center = CGPointMake(self.center.x, self.center.y - 38);
//    motionView.center = center;
//    [self addSubview:motionView];
//
//    float storedAlpha = motionView.alpha;
//    motionView.alpha = 0.f;
//    motionView.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
//    [UIView animateWithDuration:0.3f delay:0.f options:UIViewAnimationOptionCurveLinear animations:^{
//        motionView.alpha = 1.f;
//        motionView.transform = CGAffineTransformMakeScale(1.f, 1.f);
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
//                motionView.alpha = storedAlpha;
//                motionView.transform = CGAffineTransformMakeScale(1.3, 1.3);
//        } completion:^(BOOL finished) {
//            [motionView removeFromSuperview];
//        }];
//    }];
//
//}

@end

@interface HTSPanelControllerWindow : UIWindow

@property (strong, nonatomic) HTSPanelController *panel;
@end

@implementation HTSPanelControllerWindow

@end

@interface HTSPanelRootViewController : UIViewController
@end

@implementation HTSPanelRootViewController

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

@end

@interface HTSPanelController ()
{
    CGFloat _cellWidth;
    BOOL moviePaused;
}

@property (strong, nonatomic) NSMutableArray *collectionViews;
@property (strong, nonatomic) SSThemedView *backView;
@property (strong, nonatomic) SSThemedView *maskView;
@property (strong, nonatomic) SSThemedButton *cancelButton;
@property (strong, nonatomic) HTSPanelControllerWindow *backWindow;
@property (strong, nonatomic) HTSPanelRootViewController *rootViewController;
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSString *cancelTitle;
@property (nonatomic, strong) HTSPanelControllerCancelBlock cancelBlock;

@end

@implementation HTSPanelController

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithItems:(NSArray *)items cancelTitle:(NSString *)cancelTitle;
{
    return [self initWithItems:items cancelTitle:cancelTitle cancelBlock:nil];
}

- (instancetype)initWithItems:(NSArray *)items cancelTitle:(NSString *)cancelTitle cancelBlock:(HTSPanelControllerCancelBlock)cancelBlock
{
    self = [super init];
    if (self) {
        self.data = items;
        self.collectionViews = [NSMutableArray array];
        self.cancelTitle = cancelTitle;
        self.cancelBlock = cancelBlock;
        
        //熊zi: 分享中，iPhone6下，分享间距需要单图调整，统一间距要增加4PX（2X）保证分享露出半个图标，不然不知道还可以滑动
        _cellWidth = kFRPanelCellWidth + ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice] ? 8 : 0);
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rootViewWillTransitionToSize:) name:kRootViewWillTransitionToSize object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationStautsBarDidRotate) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
        
        _backWindow = [[HTSPanelControllerWindow alloc] init];
        _backWindow.frame = [UIApplication sharedApplication].keyWindow.bounds;
        _backWindow.rootViewController = self.rootViewController;
        _backWindow.backgroundColor = [UIColor clearColor];
        _backWindow.windowLevel = UIWindowLevelNormal;
        [_backWindow makeKeyAndVisible];
        _backWindow.hidden = YES;
        
        [self commonInit];
    }
    
    return self;
}

- (void)applicationStautsBarDidRotate
{
    [self willTransitionToSize:[UIApplication sharedApplication].keyWindow.bounds.size];
}

- (void)rootViewWillTransitionToSize:(NSNotification *)noti
{
    CGSize size = [noti.object CGSizeValue];
    [self willTransitionToSize:size];
}

- (void)willTransitionToSize:(CGSize)size
{
    CGRect frame = CGRectZero;
    frame.size = size;
    self.backWindow.frame = frame;
}

- (void)commonInit
{
    for (int i=0; i<self.data.count; i++) {
        SSThemedScrollView *view = [self createCollectionViewWithIndex:i];
        CGPoint contentOffset = view.contentOffset;
        contentOffset.x = -view.contentInset.left;
        view.contentOffset = contentOffset;
        
        [self.collectionViews addObject:view];
        [self.backView addSubview:view];
        BOOL isLast = (i == (self.data.count - 1));
        UIView *line = [self lineViewWithIndex:i isLast:isLast];
        [self.backView addSubview:line];
        
        CGFloat lineGap = 22.0f;
        [line mas_makeConstraints:^(MASConstraintMaker *make) {
            make.height.mas_equalTo([TTDeviceHelper ssOnePixel]);
            make.bottom.equalTo(view);
            if (isLast) {
                make.left.right.equalTo(self.backView);
            } else {
                make.left.equalTo(self.backView).offset(lineGap);
                make.right.equalTo(self.backView).offset(-lineGap);
            }
        }];
        
        CGFloat offsetY = kFRPanelTopPadding + kFRPanelSingleCellHeight * i;
        if ([TTDeviceHelper OSVersionNumber] < 8.f) {
            view.autoresizingMask = UIViewAutoresizingFlexibleWidth;
            view.height = kFRPanelSingleCellHeight;
            view.top = offsetY;
        }
        else {
            [view mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.right.equalTo(self.backView);
                make.height.mas_equalTo(kFRPanelSingleCellHeight);
                make.top.equalTo(self.backView).offset(offsetY);
            }];
        }
    }
    [self.rootViewController.view addSubview:self.maskView];
    [self.maskView addSubview:self.backView];
    [self.backView addSubview:self.cancelButton];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelButtonAction:)];
    [self.maskView addGestureRecognizer:tap];
    
    [self.cancelButton setTitle:self.cancelTitle forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(cancelButtonAction:) forControlEvents:UIControlEventTouchUpInside];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    if ([TTDeviceHelper OSVersionNumber] < 8.f) {
        //avoid autolayout crash in ios7
        self.maskView.frame = CGRectMake(0, 0, screenWidth, screenHeight);
    }
    else {
        [self.maskView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.backWindow);
        }];
    }
    
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(kFRPanelCancelButtonHeight);
        make.left.right.bottom.equalTo(self.backView);
    }];
    
    //backView赋初值，防止show时计算不对
    CGFloat backHeight = kFRPanelTopPadding + kFRPanelSingleCellHeight * self.data.count + kFRPanelCancelButtonHeight;
    _backView.frame = CGRectMake(0, screenHeight-backHeight, screenWidth, backHeight);
    [self.backView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(backHeight);
        make.left.right.bottom.equalTo(self.maskView);
    }];
}

- (void)show
{
    //    //layout一下使autoLayout生效，或者给backView赋初值
    //    [self.backWindow layoutIfNeeded];
    self.backWindow.panel = self;
    
    CGFloat bottom = self.backView.bottom;
    self.backView.bottom = bottom + self.backView.height;
    self.backWindow.alpha = 0.0f;
    
    self.backWindow.hidden = NO;
    
    [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.backView.bottom = bottom;
        self.backWindow.alpha = 1.0f;
    } completion:nil];
    
    for (int i=0; i<self.data.count; i++) {
        UIScrollView *scroll = self.collectionViews[i];
        
        if (self.data.count == 1 && [(NSArray *)self.data[0] count] < 4) {
            scroll.contentInset = UIEdgeInsetsZero;
        }
        
        for (int j=0; j<[(NSArray *)self.data[i] count]; j++) {
            HTSPanelThemedButton *view = [self cellViewWithRow:i index:j item:self.data[i][j]];
            
            CGFloat top = view.top;
            view.top = 100;
            view.alpha = 0.0f;
            
            NSTimeInterval delay = 0.1f;
            NSTimeInterval delayI = 0.1f;
            NSTimeInterval delayJ = 0.025f;
            
            [UIView animateWithDuration:0.5 delay:delay + i * delayI + j * delayJ usingSpringWithDamping:0.6 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                view.top = top;
                view.alpha = 1.0f;
            } completion:nil];
            
            [scroll addSubview:view];
        }
        
        CGFloat width = _cellWidth*[(NSArray *)self.data[i] count];
        scroll.contentSize = CGSizeMake(width, kFRPanelSingleCellHeight);
        scroll.alwaysBounceHorizontal = YES;
    }
}

- (void)hideWithBlock:(void (^)(void))block
{
    [self cancelWithBlock:block];
}

- (void)hideWithBlock:(void (^)(void))block animation:(BOOL)animated
{
    [self cancelWithBlock:block animation:animated];
}

- (void)selectedDigIconButtonAction:(HTSPanelThemedButton *)sender
{
    HTSPanelControllerItem * item = self.data[sender.row][sender.index];
    if (item.clickAction) {
        item.clickAction();
    }
    for (int i = 0; i < [self.data count]; i++) {
        for (int j = 0; j< [(NSArray *)self.data[i] count]; j++) {
            HTSPanelControllerItem * itemOfIJ = self.data[i][j];
            if (itemOfIJ.banDig) {
                return;
            }
        }
    }
    if (sender.selected == NO) {
        sender.selected = YES;
        item.banDig = YES;
        int count = [item.count intValue];
        count ++;
        item.count = [NSString stringWithFormat:@"%d",count];
        sender.nameLabel.text = [NSString stringWithFormat:@"%@%@",item.title,item.count];
    }
}

- (void)selectedIconButtonAction:(HTSPanelThemedButton *)sender
{
    sender.selected = !sender.selected;
    //    sender.selectedIconImage.hidden = !sender.selected;
    //    sender.iconImage.hidden = sender.selected;
    
    HTSPanelControllerItem *item = self.data[sender.row][sender.index];
    
    if (item.clickAction) {
        item.clickAction();
    }
}

- (void)buttonClickAction:(HTSPanelThemedButton *)sender
{
    HTSPanelControllerItem *item = self.data[sender.row][sender.index];
    
    [self cancelWithBlock:item.clickAction];
}

- (void)cancelButtonAction:(id)sender
{
    [self cancelWithBlock:_cancelBlock];
}

- (void)cancelWithBlock:(HTSPanelButtonClick)block
{
    NSLog(@"backWindow %@, maskView %@, backView %@, rootVCView %@", NSStringFromCGRect(_backWindow.frame), NSStringFromCGRect(_maskView.frame), NSStringFromCGRect(_backView.frame), NSStringFromCGRect(_rootViewController.view.frame));
    return [self cancelWithBlock:block animation:YES];
}

- (void)cancelWithBlock:(HTSPanelButtonClick)block animation:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:1.0 initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.backView.center = CGPointMake(self.backView.center.x, self.backView.center.y+self.backView.frame.size.height);
            self.backWindow.alpha = 0.0f;
        } completion:^(BOOL finished) {
            _backWindow.hidden = YES;
            _backWindow.panel = nil;
            _backWindow = nil;
            if (block) {
                block();
            }
        }];
    }
    else {
        _backWindow.hidden = YES;
        _backWindow.panel = nil;
        _backWindow = nil;
        if (block) {
            block();
        }
    }
}

#pragma mark - UI
- (SSThemedView *)lineViewWithIndex:(int)index isLast:(BOOL)isLast
{
    SSThemedView *line = [[SSThemedView alloc] init];
    line.backgroundColor = [UIColor colorWithHexString:@"#EDEDED"];
    return line;
}

- (HTSPanelThemedButton *)cellViewWithRow:(int)row index:(int)index item:(HTSPanelControllerItem *)item
{
    CGRect frame;
    HTSPanelThemedButton *view = nil;
    CGFloat amount = [(NSArray *)self.data[0] count];
    if (self.data.count == 1 && amount < 4) {
        UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
        CGFloat windowWidth = keyWindow.size.width;
        CGFloat internalWidth = windowWidth * 0.0625;
        CGFloat leftPading = (windowWidth-kFRPanelCellWidth*amount-internalWidth*(amount-1))/2;
        frame = CGRectMake(leftPading+index*(internalWidth+kFRPanelCellWidth), 0, kFRPanelCellWidth, kFRPanelSingleCellHeight);
        view = [[HTSPanelThemedButton alloc] initWithFrame:frame item:item row:row index:index amount:amount needLeaveWhite:NO];//不需要留白
    } else {
        frame = CGRectMake(index*_cellWidth, 0, _cellWidth, kFRPanelSingleCellHeight);
        view = [[HTSPanelThemedButton alloc] initWithFrame:frame item:item row:row index:index amount:0 needLeaveWhite:YES];//需要留白
    }
//    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if (item.itemType == HTSPanelControllerItemTypeSelectedDigIcon) {
        [view addTarget:self action:@selector(selectedDigIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        view.selected = item.selected;
    }
    else if (item.itemType == HTSPanelControllerItemTypeSelectedIcon) {
        [view addTarget:self action:@selector(selectedIconButtonAction:) forControlEvents:UIControlEventTouchUpInside];
        view.selected = item.selected;
    } else {
        [view addTarget:self action:@selector(buttonClickAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return view;
}

- (HTSPanelRootViewController *)rootViewController
{
    if (!_rootViewController) {
        _rootViewController = [[HTSPanelRootViewController alloc] init];
    }
    return _rootViewController;
}


- (SSThemedScrollView *)createCollectionViewWithIndex:(int)index
{
    SSThemedScrollView *scrollView = [[SSThemedScrollView alloc] init];
    scrollView.backgroundColor = [UIColor clearColor];
    scrollView.clipsToBounds = NO;
    scrollView.tag = index;
    scrollView.contentInset = UIEdgeInsetsMake(0, 16, 0, 16);
    scrollView.showsHorizontalScrollIndicator = NO;
    scrollView.showsVerticalScrollIndicator = NO;
    
    return scrollView;
}

- (SSThemedView *)backView
{
    if (!_backView) {
        _backView = [[SSThemedView alloc] init];
        _backView.backgroundColorThemeKey = kColorBackground21;
    }
    
    return _backView;
}

- (SSThemedButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [[SSThemedButton alloc] init];
        _cancelButton.titleLabel.font = [UIFont systemFontOfSize:17.0f];
        _cancelButton.titleColorThemeKey = kColorText1;
    }
    
    return _cancelButton;
}

- (SSThemedView *)maskView
{
    if (!_maskView) {
        _maskView = [[SSThemedView alloc] init];
    }
    
    return _maskView;
}

@end
