//
//  TTPersonalHomeBottomPopView.m
//  Article
//
//  Created by wangdi on 2017/3/27.
//
//

#import "TTPersonalHomeBottomPopView.h"
#import "NetworkUtilities.h"

#define kCellHeight 40

@interface TTPersonalHomeBottomPopCell : SSThemedTableViewCell

@property (nonatomic, weak) SSThemedLabel *titleLabel;
@property (nonatomic, weak) SSThemedView *bottomLine;

@end

@implementation TTPersonalHomeBottomPopCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    SSThemedLabel *titleLabel = [[SSThemedLabel alloc] init];
    titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:15]];
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.textColorThemeKey = kColorText1;
    [self.contentView addSubview:titleLabel];
    self.titleLabel = titleLabel;
    
    SSThemedView *bottomLine = [[SSThemedView alloc] init];
    bottomLine.backgroundColorThemeKey = kColorLine1;
    [self.contentView addSubview:bottomLine];
    self.bottomLine = bottomLine;
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.titleLabel.frame = self.bounds;
    
    self.bottomLine.left = 15;
    self.bottomLine.width = self.width - 2 * self.bottomLine.left;
    self.bottomLine.height = [TTDeviceHelper ssOnePixel];
    self.bottomLine.top = self.height - self.bottomLine.height;
}

@end

@interface TTPersonalHomeBottomPopView()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, weak) UIImageView *bgImageView;
@property (nonatomic, weak) UITableView *listView;
@property (nonatomic, weak) UIView *coverView;
@property (nonatomic, strong) NSArray<TTPersonalHomeUserInfoDataBottomItemResponseModel *> *dataSource;

@end

@implementation TTPersonalHomeBottomPopView

- (instancetype)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(themedChange) name:TTThemeManagerThemeModeChangedNotification object:nil];
        [self setupSubview];
    }
    return self;
}

- (void)setupSubview
{
    UIImageView *bgImageView = [[UIImageView alloc] init];
    [self addSubview:bgImageView];
    self.bgImageView = bgImageView;
    [self themedChange];
    
    UITableView *listView = [[UITableView alloc] init];
    listView.backgroundColor = [UIColor clearColor];
    listView.scrollsToTop = NO;
    listView.scrollEnabled = NO;
    listView.backgroundView = nil;
    listView.separatorStyle = UITableViewCellSeparatorStyleNone;
    listView.delegate = self;
    listView.dataSource = self;
    [self addSubview:listView];
    self.listView = listView;
}

- (UIImage *)stretchImageWithImageName:(NSString *)imageName
{
    if(isEmptyString(imageName)) return nil;
    UIImage *oldImage = [UIImage imageNamed:imageName];
    UIImage *newImage = [oldImage stretchableImageWithLeftCapWidth:oldImage.size.width * 0.5 topCapHeight:oldImage.size.height * 0.5];
    return newImage;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *ID = @"cell";
    TTPersonalHomeBottomPopCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell) {
        cell = [[TTPersonalHomeBottomPopCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    }
    TTPersonalHomeUserInfoDataBottomItemResponseModel *model = self.dataSource[indexPath.row];
    cell.titleLabel.text = model.name;
    cell.bottomLine.hidden = indexPath.row == self.dataSource.count - 1 ? YES : NO;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return kCellHeight;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self tapClick];
    if(!TTNetworkConnected()) return;
    TTPersonalHomeUserInfoDataBottomItemResponseModel *model = self.dataSource[indexPath.row];
    //sslocal://webview?url=encode
    NSString *urlStr = [TTURLUtils queryItemAddingPercentEscapes:model.value];
    urlStr = [NSString stringWithFormat:@"sslocal://webview?url=%@",urlStr];
    NSURL *url = [TTURLUtils URLWithString:urlStr];
    [[TTRoute sharedRoute] openURLByPushViewController:url];
}

- (void)showFromPoint:(CGPoint)point superView:(UIView *)superView dataSource:(NSArray<TTPersonalHomeUserInfoDataBottomItemResponseModel *> *)dataSource
{
#if DEBUG
    NSAssert(superView, @"superView 不能为空");
#endif
    self.dataSource = dataSource;
    CGFloat commonMargin = 10;
    CGFloat bottomMargin = 15;
    self.width = self.bgImageView.image.size.width;
    self.height = dataSource.count * kCellHeight + commonMargin + bottomMargin;
    self.centerX = point.x;
    self.top = point.y - self.height + 10;
    
    self.bgImageView.frame = self.bounds;
    
    self.listView.left = commonMargin;
    self.listView.height = dataSource.count * kCellHeight;
    self.listView.width = self.width - 2 * self.listView.left;
    self.listView.top = self.height - bottomMargin - self.listView.height;
    
    [self.listView reloadData];
    
    UIView *coverView = [[UIView alloc] init];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapClick)];
    [coverView addGestureRecognizer:tap];
    coverView.frame = superView.bounds;
    coverView.backgroundColor = [UIColor clearColor];
    [superView addSubview:coverView];
    self.coverView = coverView;
    
    [superView addSubview:self];
}

- (void)tapClick
{
    [self removeFromSuperview];
    [self.coverView removeFromSuperview];
}

#pragma mark 切换日夜间通知回调
- (void)themedChange
{
    if([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeDay) {
        self.bgImageView.image = [self stretchImageWithImageName:@"popup"];
    } else if([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight) {
        self.bgImageView.image = [self stretchImageWithImageName:@"popup_night"];
    }
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
