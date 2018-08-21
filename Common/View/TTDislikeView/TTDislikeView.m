//
//  TTDislikeView.m
//  Article
//
//  Created by zhaoqin on 27/02/2017.
//
//

#import "TTDislikeView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTAlphaThemedButton.h"
#import "TTActionSheetCellModel.h"
#import "TTDetailModel.h"
#import "WDFontDefines.h"


#define TTDislikeCellIdentifier @"TTDislikeCellIdentifier"
#define TTDislikeOptionHeaderViewIdentifier @"TTDislikeOptionHeaderViewIdentifier"

@interface TTDislikeOptionCell ()
@property (nonatomic, strong) TTAlphaThemedButton *titleButton;
@property (nonatomic, strong) TTActionSheetCellModel *model;
@end

@implementation TTDislikeOptionCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleButton];
    }
    return self;
}

- (TTAlphaThemedButton *)titleButton {
    if (!_titleButton) {
        _titleButton = [[TTAlphaThemedButton alloc] initWithFrame:self.bounds];
        _titleButton.backgroundColorThemeKey = kColorBackground4;
        _titleButton.titleColorThemeKey = kColorText1;
        _titleButton.enableHighlightAnim = NO;
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
        _titleButton.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:4.f];
        _titleButton.layer.masksToBounds = YES;
        _titleButton.layer.borderWidth = [TTDeviceUIUtils tt_newPadding:1.f];
        WeakSelf;
        [_titleButton addTarget:self withActionBlock:^{
            StrongSelf;
            if (self.didSelectedComplete) {
                self.didSelectedComplete();
            }
        } forControlEvent:UIControlEventTouchUpInside];
    }
    return _titleButton;
}

- (void)configModel:(TTActionSheetCellModel * _Nonnull)model {
    if (model.isSelected) {
        _titleButton.layer.borderColor  = [UIColor tt_themedColorForKey:kColorLine2].CGColor;
        _titleButton.titleColorThemeKey = kColorText4;
        _titleButton.titleLabel.font = [UIFont boldSystemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
    }
    else {
        _titleButton.layer.borderColor = [UIColor tt_themedColorForKey:kColorBackground4].CGColor;
        _titleButton.titleColorThemeKey = kColorText1;
        _titleButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
    }
    if (_showArrow) {
        NSMutableAttributedString *attriTitle = [[NSMutableAttributedString alloc] initWithString:model.text attributes:@{NSFontAttributeName: [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]], NSForegroundColorAttributeName: [UIColor tt_themedColorForKey:kColorText1]}];
        [attriTitle appendAttributedString:({
            NSAttributedString *attriArrow = [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" %@", ask_arrow_right] attributes:@{NSBaselineOffsetAttributeName: @(1.5), NSFontAttributeName: [UIFont fontWithName:wd_iconfont size:[TTDeviceUIUtils tt_newFontSize:10.f]], NSForegroundColorAttributeName: [UIColor tt_themedColorForKey:kColorText1]}];
            attriArrow;
        })];
        [_titleButton setAttributedTitle:attriTitle forState:UIControlStateNormal];
    }
    else {
        [_titleButton setAttributedTitle:nil forState:UIControlStateNormal];
        [_titleButton setTitle:model.text forState:UIControlStateNormal];
    }
    
    self.model = model;
}

- (void)setShowArrow:(BOOL)showArrow {
    _showArrow = showArrow;
}

@end

@interface TTDislikeOptionHeaderView ()
@property (nonatomic, strong) SSThemedLabel *titleLabel;
@property (nonatomic, strong) TTAlphaThemedButton *commitButton;
@end

@implementation TTDislikeOptionHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.commitButton];
    }
    return self;
}

- (void)layoutSubviews {
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    CGFloat padding = [TTUIResponderHelper paddingForViewWidth:screenWidth];
    CGFloat width = screenWidth - 2 * padding;
    self.titleLabel.left = [TTDeviceUIUtils tt_newPadding:20.f];
    self.titleLabel.height = self.height;
    if ([TTDeviceHelper isPadDevice]) {
        self.commitButton.centerX = width - 20.f/375.f * width - [TTDeviceUIUtils tt_newPadding:160.5f] / 2;
    }
    else if ([TTDeviceHelper is736Screen]) {
        self.commitButton.centerX = [TTDeviceUIUtils tt_newPadding:34.f] + 180.f / 2 + 180.f;
    }
    else {
        self.commitButton.centerX = width - 20.f/375.f * width - 160.5f/375.f * width / 2;
    }
    self.commitButton.centerY = self.titleLabel.centerY;
}

- (void)setTitle:(NSString *)title {
    if (_title == title) {
        return;
    }
    _titleLabel.text = title;
    _title = title;
}

- (void)setType:(TTDislikeOptionHeaderViewType)type {
    if (_type == type) {
        return;
    }
    if (type == TTDislikeOptionHeaderViewTypeNOCommitButton) {
        self.commitButton.hidden = YES;
    }
    else {
        self.commitButton.hidden = NO;
    }
    _type = type;
}

- (SSThemedLabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[SSThemedLabel alloc] initWithFrame:CGRectMake([TTDeviceUIUtils tt_newPadding:21.f], 0, [TTDeviceUIUtils tt_newPadding:160.5f], self.height)];
        _titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:12.f]];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
        _titleLabel.textColorThemeKey = kColorText3;
    }
    return _titleLabel;
}

- (TTAlphaThemedButton *)commitButton {
    if (!_commitButton) {
        _commitButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(0, 0, [TTDeviceUIUtils tt_newPadding:140.f], [TTDeviceUIUtils tt_newPadding:40.f])];
        _commitButton.layer.cornerRadius = [TTDeviceUIUtils tt_newPadding:20.f];
        _commitButton.layer.masksToBounds = YES;
        _commitButton.backgroundColorThemeKey = kColorBackground7;
        _commitButton.titleColorThemeKey = kColorText12;
        [_commitButton setTitle:@"确定" forState:UIControlStateNormal];
        _commitButton.titleLabel.font = [UIFont systemFontOfSize:[TTDeviceUIUtils tt_newFontSize:14.f]];
        WeakSelf;
        [_commitButton addTarget:self withActionBlock:^{
            StrongSelf;
            if (self.commitComplete) {
                self.commitComplete();
            }
        } forControlEvent:UIControlEventTouchUpInside];
    }
    return _commitButton;
}

@end


@interface TTDislikeView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) NSArray * dislikeOptions;
@property (nonatomic, strong) NSArray * reportOptions;
@property (nonatomic, strong) UICollectionView *collectionView;
@property (nonatomic, strong) TTAlphaThemedButton *cancelButton;
@property (nonatomic, assign) BOOL hasComplainMessage;
@end

@implementation TTDislikeView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.collectionView];
        [self addSubview:self.cancelButton];
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            self.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
        }
        else {
            self.backgroundColor = [UIColor colorWithHexString:@"1B1B1B"];
        }
    }
    return self;
}

- (void)layoutSubviews {
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    if ([TTDeviceHelper OSVersionNumber] < 8.0f && UIInterfaceOrientationIsLandscape([UIApplication sharedApplication].statusBarOrientation)) {
        CGFloat temp = screenWidth;
        screenWidth = screenHeight;
        screenHeight = temp;
    }
    CGFloat padding = [TTUIResponderHelper paddingForViewWidth:screenWidth];
    CGFloat width = screenWidth - 2 * padding;
    
    UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
    
    if ([TTDeviceHelper is736Screen]) {
        flowLayout.itemSize = CGSizeMake(180.f, 40.f);
    }
    else if ([TTDeviceHelper is667Screen] || [TTDeviceHelper isIPhoneXDevice] || [TTDeviceHelper isPadDevice]) {
        flowLayout.itemSize = CGSizeMake([TTDeviceUIUtils tt_newPadding:158.5f], [TTDeviceUIUtils tt_newPadding:40.f]);
    }
    else {
        flowLayout.itemSize = CGSizeMake([TTDeviceUIUtils tt_newPadding:150.f], [TTDeviceUIUtils tt_newPadding:40.f]);
    }
    
    flowLayout.minimumLineSpacing = [TTDeviceUIUtils tt_paddingForMoment:8.f];
    flowLayout.minimumInteritemSpacing = [TTDeviceUIUtils tt_newPadding:14.f];
    flowLayout.sectionInset = UIEdgeInsetsMake(0, [TTDeviceUIUtils tt_newPadding:20.f], 0, [TTDeviceUIUtils tt_newPadding:20.f]);
    
    self.collectionView.frame = CGRectMake(padding, 0, width, self.height - self.cancelButton.height);
    self.collectionView.collectionViewLayout = flowLayout;
    self.cancelButton.frame = CGRectMake(padding, self.height - [TTDeviceUIUtils tt_newPadding:48.f], width, [TTDeviceUIUtils tt_newPadding:48.f]);
}

#pragma mark - public method
- (void)insertDislikeOptions:(NSArray * _Nonnull)dislikeOptions reportOptions:(NSArray * _Nonnull)reportOptions {
    self.dislikeOptions = dislikeOptions;
    self.reportOptions = reportOptions;
}

- (void)setComplainMessage:(BOOL)hasComplainMessage {
    self.hasComplainMessage = hasComplainMessage;
    [self.collectionView reloadData];
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource & UICollectionFlowLayout
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if (self.type == TTDislikeTypeOnlyReport) {
        return 1;
    }
    else {
        return 2;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (self.type == TTDislikeTypeOnlyReport) {
        return self.reportOptions.count;
    }
    else {
        if (section == 0) {
            return self.dislikeOptions.count > 4 ? 4 : self.dislikeOptions.count;
        }
        else if (section == 1) {
            return self.reportOptions.count > 8 ? 8 : self.reportOptions.count;
        }
    }
    
    return 0;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath {
    UICollectionReusableView *reusableView = nil;
    if (self.type == TTDislikeTypeOnlyReport) {
        TTDislikeOptionHeaderView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:TTDislikeOptionHeaderViewIdentifier forIndexPath:indexPath];
        headView.type = TTDislikeOptionHeaderViewTypeNormal;
        headView.title = @"举报文章";
        [headView.commitButton setTitle:@"举报" forState:UIControlStateNormal];
        BOOL enable = NO;
        for (TTActionSheetCellModel *model in self.reportOptions) {
            if (model.isSelected) {
                enable = YES;
            }
        }
        if (self.hasComplainMessage) {
            enable = YES;
        }
        if (headView.commitButton.isEnabled ^ enable) {
            if (enable) {
                headView.commitButton.enabled = YES;
                headView.commitButton.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground7];
            }
            else {
                headView.commitButton.enabled = NO;
                if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
                    headView.commitButton.backgroundColor = [UIColor colorWithHexString:@"CACACA"];
                }
                else {
                    headView.commitButton.backgroundColor = [UIColor colorWithHexString:@"505050"];
                }
            }
        }
        
        WeakSelf;
        headView.commitComplete = ^{
            StrongSelf;
            if (self.commitComplete) {
                self.commitComplete();
            }
        };
        
        reusableView = headView;
    }
    else {
        if (kind == UICollectionElementKindSectionHeader) {
            TTDislikeOptionHeaderView *headView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:TTDislikeOptionHeaderViewIdentifier forIndexPath:indexPath];
            if (indexPath.section == 0) {
                headView.type = TTDislikeOptionHeaderViewTypeNormal;
                headView.title = @"选择理由，精确屏蔽";
                WeakSelf;
                headView.commitComplete = ^{
                    StrongSelf;
                    if (self.commitComplete) {
                        self.commitComplete();
                    }
                };
                reusableView = headView;
            }
            else if (indexPath.section == 1) {
                headView.type = TTDislikeOptionHeaderViewTypeNOCommitButton;
                headView.title = @"举报文章";
                reusableView = headView;
            }
        }
    }
    return reusableView;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TTDislikeOptionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:TTDislikeCellIdentifier forIndexPath:indexPath];
    if (self.type == TTDislikeTypeOnlyReport) {
        if (indexPath.row != self.reportOptions.count - 1) {
            cell.showArrow = NO;
        }
        else {
            cell.showArrow = YES;
        }
        
        TTActionSheetCellModel *model = self.reportOptions[indexPath.row];
        [cell configModel:model];
        __weak typeof(cell) wcell = cell;
        __weak typeof(model) wmodel = model;
        WeakSelf;
        cell.didSelectedComplete = ^{
            StrongSelf;
            __strong typeof(wmodel) model = wmodel;
            if (![model.identifier isEqualToString:@"0"]) {
                model.isSelected = !model.isSelected;
                __strong typeof(wcell) cell = wcell;
                [cell configModel:model];
            }
            else {
                if (self.extraComeplete) {
                    self.extraComeplete();
                }
            }
            [self.collectionView reloadData];
        };
    }
    else {
        if (indexPath.section == 0) {
            TTActionSheetCellModel *model = self.dislikeOptions[indexPath.row];
            cell.showArrow = NO;
            [cell configModel:model];
            __weak typeof(cell) wcell = cell;
            cell.didSelectedComplete = ^{
                model.isSelected = !model.isSelected;
                __strong typeof(wcell) cell = wcell;
                [cell configModel:model];
            };
        }
        else {
            if (indexPath.row != self.reportOptions.count - 1) {
                cell.showArrow = NO;
            }
            else {
                cell.showArrow = YES;
            }
            TTActionSheetCellModel *model = self.reportOptions[indexPath.row];
            [cell configModel:model];
            __weak typeof(cell) wcell = cell;
            __weak typeof(model) wmodel = model;
            WeakSelf;
            cell.didSelectedComplete = ^{
                StrongSelf;
                __strong typeof(wmodel) model = wmodel;
                if (![model.identifier isEqualToString:@"0"]) {
                    model.isSelected = !model.isSelected;
                    __strong typeof(wcell) cell = wcell;
                    [cell configModel:model];
                }
                else {
                    if (self.extraComeplete) {
                        self.extraComeplete();
                    }
                }
            };
        }
    }
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.type == TTDislikeTypeOnlyReport) {
        return CGSizeMake(self.width, [TTDeviceUIUtils tt_newPadding:74.f]);
    }
    else {
        if (section == 0) {
            return CGSizeMake(self.width, [TTDeviceUIUtils tt_newPadding:74.f]);
        }
        else if (section == 1) {
            return CGSizeMake(self.width, [TTDeviceUIUtils tt_newPadding:40.f]);
        }
    }
    
    return CGSizeZero;
}

#pragma mark - get method
- (TTAlphaThemedButton *)cancelButton {
    if (!_cancelButton) {
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:self.width];
        CGFloat width = self.width - 2 * padding;
        _cancelButton = [[TTAlphaThemedButton alloc] initWithFrame:CGRectMake(padding, self.height - [TTDeviceUIUtils tt_newPadding:48.f], width, [TTDeviceUIUtils tt_newPadding:48.f])];
        _cancelButton.backgroundColorThemeKey = kColorBackground4;
        _cancelButton.titleColorThemeKey = kColorText1;
        [_cancelButton setTitle:@"取消" forState:UIControlStateNormal];
        WeakSelf;
        [_cancelButton addTarget:self withActionBlock:^{
            StrongSelf;
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
                wrapperTrackEventWithCustomKeys(@"detail", @"report_cancel_click_button", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
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
                wrapperTrackEventWithCustomKeys(@"detail", @"report_and_dislike_cancel_click_button", self.detailModel.article.groupModel.groupID, self.detailModel.clickLabel, extra);
            }
            
            if (self.cancelComplete) {
                self.cancelComplete();
            }
        } forControlEvent:UIControlEventTouchUpInside];
    }
    return _cancelButton;
}

- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat padding = [TTUIResponderHelper paddingForViewWidth:self.width];
        CGFloat width = self.width - 2 * padding;
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.minimumLineSpacing = [TTDeviceUIUtils tt_paddingForMoment:8.f];
        flowLayout.minimumInteritemSpacing = [TTDeviceUIUtils tt_newPadding:14.f];
        flowLayout.sectionInset = UIEdgeInsetsMake(0, [TTDeviceUIUtils tt_newPadding:20.f], 0, [TTDeviceUIUtils tt_newPadding:20.f]);
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(padding, 0, width, self.height - self.cancelButton.height) collectionViewLayout:flowLayout];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        if ([[TTThemeManager sharedInstance_tt] currentThemeMode] == TTThemeModeDay) {
            _collectionView.backgroundColor = [UIColor colorWithHexString:@"F8F8F8"];
        }
        else {
            _collectionView.backgroundColor = [UIColor colorWithHexString:@"1B1B1B"];
        }
        _collectionView.scrollEnabled = NO;
        [_collectionView registerClass:[TTDislikeOptionCell class] forCellWithReuseIdentifier:TTDislikeCellIdentifier];
        [_collectionView registerClass:[TTDislikeOptionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:TTDislikeOptionHeaderViewIdentifier];
    }
    return _collectionView;
}

- (void)setDislikeOptions:(NSArray *)dislikeOptions {
    _dislikeOptions = dislikeOptions;
}

- (void)setType:(TTDislikeType)type {
    _type = type;
    self.collectionView.height = self.height - self.cancelButton.height;
    self.cancelButton.top = self.height - [TTDeviceUIUtils tt_newPadding:48.f];
}

@end
