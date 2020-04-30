//
//  FHUGCToolbar.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2020/1/10.
//

#import "FHUGCToolbar.h"
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "Masonry.h"
#import "FHUserTracker.h"
#import "TTDeviceHelper.h"

#define EMOJI_INPUT_VIEW_HEIGHT ([TTDeviceHelper isScreenWidthLarge320] ? 216.f : 193.f)

@implementation FHUGCToolbarReportModel
@end

@implementation FHUGCToolBarTag
- (BOOL)isEqual:(id)object {
    if(self == object) {
        return YES;
    }
    
    if(![object isKindOfClass:[FHUGCToolBarTag class]]) {
        return NO;
    }
    
    FHUGCToolBarTag *tagInfo = (FHUGCToolBarTag *)object;
    
    return [self.groupId isEqualToString:tagInfo.groupId];
    
}
-(NSUInteger)hash {
    return self.groupId.hash;
}
@end

@interface FHUGCToolbarTagCollectionViewCell : UICollectionViewCell
@property (nonatomic, strong) UILabel *tagLabel;

+ (NSString *)reuseIdentifier;

@end

@implementation FHUGCToolbarTagCollectionViewCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self addSubview:self.tagLabel];
        
        [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
    return self;
}

- (UILabel *)tagLabel {
    if(!_tagLabel) {
        _tagLabel = [UILabel new];
        _tagLabel.font = [UIFont themeFontRegular:16];
        _tagLabel.textColor = [UIColor themeGray1];
        _tagLabel.backgroundColor = [UIColor themeGray7];
        _tagLabel.layer.cornerRadius = 4;
        _tagLabel.layer.masksToBounds = YES;
        _tagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tagLabel;
}

@end

#define FHUGCToolbarHeight  80
#define LEFT_PADDING        20
#define RIGHT_PADDING       20
#define TIPS_HEIGHT         25
#define SELECT_ENTRY_HEIGHT 44
#define TAGS_VIEW_HEIGHT    58
#define TAG_BUTTON_HEIGHT   32

@interface FHUGCToolbar() <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, FHPostUGCMainViewDelegate>
@property (nonatomic, strong) UICollectionView *tagSelectCollectionView;
@property (nonatomic, assign) FHPostUGCMainViewType type;
@property (nonatomic, strong) NSMutableArray<FHUGCToolBarTag *> *tags;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, assign) BOOL isReportedTagsCollectionViewShow;
@property (nonatomic, strong) NSMutableSet<NSString *> *tagShowReportOnceSet;
@property (nonatomic, strong) NSMutableArray<FHUGCToolBarTag *> *stageStack;
@property (nonatomic, assign) CGPoint toolbarViewOriginWhenInit;
@property (nonatomic, assign) CGPoint toolbarViewOrigin;
@property (nonatomic, assign) BOOL executeOnceFlag;
@end

@implementation FHUGCToolbar


+ (CGFloat)toolbarHeightWithTags:(NSArray *)tags hasSelected:(BOOL)isSelected {
    if(isSelected) {
        return FHUGCToolbarHeight + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    } else {
        return FHUGCToolbarHeight + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom + SELECT_ENTRY_HEIGHT + (tags.count > 0 ? TAGS_VIEW_HEIGHT : 0);
    }
}

- (instancetype)initWithFrame:(CGRect)frame type:(FHPostUGCMainViewType)type {
    if(self = [super initWithFrame:frame]) {
        self.isReportedTagsCollectionViewShow = NO;
        self.tagShowReportOnceSet = [NSMutableSet set];
        self.stageStack = [NSMutableArray array];
        
        self.type = type;
        self.userInteractionEnabled = YES;
        
        [self addSubview:self.tipLabel];
        [self addSubview:self.socialGroupSelectEntry];
        [self addSubview:self.tagSelectCollectionView];
        
        // 修改父类控制布局
        [self layoutSuperView];
    }
    return self;
}

- (void)layoutSuperView {
    CGPoint toolbarOrigin = CGPointMake(0, self.tagSelectCollectionView.bottom);
    [self layoutToolbarViewWithOrigin:toolbarOrigin];
}

#pragma mark - 成员懒加载

- (UILabel *)tipLabel {
    if(!_tipLabel) {
        _tipLabel = [[UILabel alloc] initWithFrame:CGRectMake(LEFT_PADDING, 11, self.bounds.size.width - LEFT_PADDING - RIGHT_PADDING , TIPS_HEIGHT)];
        _tipLabel.backgroundColor = [UIColor whiteColor];
        _tipLabel.font = [UIFont themeFontRegular:11];
        _tipLabel.textAlignment = NSTextAlignmentRight;
        _tipLabel.textColor = [UIColor themeGray4];
    }
    return _tipLabel;
}

- (FHPostUGCMainView *)socialGroupSelectEntry {
    if(!_socialGroupSelectEntry) {
        _socialGroupSelectEntry = [[FHPostUGCMainView alloc] initWithFrame:CGRectMake(0, self.tipLabel.bottom, self.frame.size.width, SELECT_ENTRY_HEIGHT) type:self.type];
        _socialGroupSelectEntry.backgroundColor = [UIColor themeWhite];
        _socialGroupSelectEntry.clipsToBounds = YES;
        
        UIView *topLine = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _socialGroupSelectEntry.width, 0.5)];
        topLine.backgroundColor = [UIColor themeGray6];
        
        [_socialGroupSelectEntry addSubview:topLine];
        _socialGroupSelectEntry.delegate = self;
    }
    return _socialGroupSelectEntry;
}

- (UICollectionView *)tagSelectCollectionView {
    if(!_tagSelectCollectionView){
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 10;
        
        _tagSelectCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, self.socialGroupSelectEntry.bottom, self.frame.size.width, TAGS_VIEW_HEIGHT) collectionViewLayout:flowLayout];
        
        _tagSelectCollectionView.backgroundColor = [UIColor themeWhite];
        
        _tagSelectCollectionView.showsVerticalScrollIndicator = NO;
        _tagSelectCollectionView.showsHorizontalScrollIndicator = NO;
        
        [_tagSelectCollectionView registerClass:[FHUGCToolbarTagCollectionViewCell class] forCellWithReuseIdentifier:[FHUGCToolbarTagCollectionViewCell reuseIdentifier]];
        
        _tagSelectCollectionView.delegate = self;
        _tagSelectCollectionView.dataSource = self;
    }
    
    return _tagSelectCollectionView;
}

- (void)layoutTagSelectCollectionViewWithTags:(NSMutableArray<FHUGCToolBarTag *> *)tags hasSelected:(BOOL)isSelected{
    self.tags = tags;
    self.isSelected = isSelected;
    
    [self relayoutSelctCollectionView];
}

- (void)relayoutSelctCollectionView {
    
    if(self.isSelected) {
        self.socialGroupSelectEntry.height = 0;
    }
    
    CGRect frame = self.tagSelectCollectionView.frame;
    frame.origin.y = self.socialGroupSelectEntry.bottom;
    
    BOOL hasTagsView = (!self.isSelected && self.tags.count > 0);
    frame.size.height = hasTagsView ? TAGS_VIEW_HEIGHT : 0;

    self.tagSelectCollectionView.frame = frame;
    
    [self.tagSelectCollectionView reloadData];
    
    if(!self.executeOnceFlag) {
        self.toolbarViewOriginWhenInit = self.origin;
        self.toolbarViewOrigin = self.origin;
        self.executeOnceFlag = YES;
    }
    else {
        if(!self.isSelected) {
            self.toolbarViewOrigin = CGPointMake(self.toolbarViewOriginWhenInit.x, self.toolbarViewOriginWhenInit.y + (hasTagsView ? 0 : TAGS_VIEW_HEIGHT));
        }
    }
    
    [self layoutSuperView];
    
    // 热门标签展现埋点
    [self traceTagsCollectionViewShow];
}

#pragma mark - 父类键盘事件重载

- (void)keyboardWillShow:(NSNotification *)notification {
    CGFloat targetY;
    CGRect keyboardScreenFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = self.frame;
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = animationCurve << 16;
            break;
    }
    
    targetY = CGRectGetMinY(keyboardScreenFrame) - [FHUGCToolbar toolbarHeightWithTags:self.tags hasSelected:self.isSelected] + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    
    // Emoji 选择器输入情况下，点击 TextView 自动弹出键盘
    if (self.emojiInputViewVisible) {
        self.emojiInputViewVisible = NO;
    }
    
    self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_normal";
    self.keyboardButton.accessibilityLabel = @"收起键盘";
    self.emojiButton.imageName = @"fh_ugc_toolbar_emoj_normal";
    self.emojiButton.accessibilityLabel = @"表情";
    
    frame.origin.y = targetY;
    
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        if (self.emojiInputViewVisible) {
            self.emojiInputView.hidden = NO;
        } else {
            self.emojiInputView.hidden = YES;
        }
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    CGFloat targetY;
    CGRect keyboardScreenFrame = [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat duration = [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
    CGRect frame = self.frame;
    
    UIViewAnimationCurve animationCurve = [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] unsignedIntegerValue];
    UIViewAnimationOptions options = UIViewAnimationCurveEaseIn | UIViewAnimationCurveEaseOut | UIViewAnimationCurveLinear;
    switch (animationCurve) {
        case UIViewAnimationCurveEaseInOut:
            options = UIViewAnimationOptionCurveEaseInOut;
            break;
        case UIViewAnimationCurveEaseIn:
            options = UIViewAnimationOptionCurveEaseIn;
            break;
        case UIViewAnimationCurveEaseOut:
            options = UIViewAnimationOptionCurveEaseOut;
            break;
        case UIViewAnimationCurveLinear:
            options = UIViewAnimationOptionCurveLinear;
            break;
        default:
            options = animationCurve << 16;
            break;
    }
    
    if (self.emojiInputViewVisible) { // 切换到表情输入，收起键盘
        // 提前显示表情选择器
        targetY = CGRectGetMinY(keyboardScreenFrame) - CGRectGetHeight(frame);
        self.emojiInputView.hidden = !self.emojiInputViewVisible;
        self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_normal";
        self.keyboardButton.accessibilityLabel = @"收起键盘";
        self.emojiButton.imageName = @"fh_ugc_toolbar_keyboard_selected";
        self.emojiButton.accessibilityLabel = @"收起表情选择框";
    } else {
        self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_selected";
        self.keyboardButton.accessibilityLabel = @"弹出键盘";
        self.emojiButton.imageName = @"fh_ugc_toolbar_emoj_normal";
        self.emojiButton.accessibilityLabel = @"表情";
        
        targetY = CGRectGetMinY(keyboardScreenFrame) - [FHUGCToolbar toolbarHeightWithTags:self.tags hasSelected:self.isSelected];
    }
    
    frame.origin.y = targetY;
    
    [UIView animateWithDuration:duration delay:0.0 options:options animations:^{
        self.frame = frame;
    } completion:^(BOOL finished) {
        if (self.emojiInputViewVisible) {
            self.emojiInputView.hidden = NO;
        } else {
            self.emojiInputView.hidden = YES;
        }
    }];
}

- (void)keyboardAction:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickKeyboardButton:)]) {
        BOOL switchToInput = [self.keyboardButton.imageName isEqualToString:@"fh_ugc_toolbar_keyboard_selected"]; // 这里折衷一下
        [self.delegate toolbarDidClickKeyboardButton:switchToInput];
        self.keyboardButton.imageName = switchToInput ? @"fh_ugc_toolbar_keyboard_normal" : @"fh_ugc_toolbar_keyboard_selected";
        self.keyboardButton.accessibilityLabel = switchToInput ? @"收起键盘" : @"弹出键盘";
        self.emojiButton.imageName = @"fh_ugc_toolbar_emoj_normal";
        self.emojiButton.accessibilityLabel = @"表情";
        
        if(!switchToInput) {
            [self.tagDelegate needRelayoutToolbar];
        }
    }
}

- (BOOL)endEditing:(BOOL)animated {
    
    void (^animations)(void) = ^{
        self.top = self.toolbarViewOrigin.y;
    };
    
    void (^completion)(BOOL) = ^(BOOL finished) {
        self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_selected";
        self.keyboardButton.accessibilityLabel = @"弹出键盘";
        self.emojiButton.imageName = @"fh_ugc_toolbar_emoj_normal";
        self.emojiButton.accessibilityLabel = @"表情";
        
        if (self.emojiInputViewVisible) {
            self.emojiInputViewVisible = NO;
        }
        
        self.emojiInputView.hidden = !self.emojiInputViewVisible;
    };
    
    if (animated) {
        
        [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:animations completion:completion];
        
    } else {
        animations();
        completion(YES);
    }
    
    return YES;
}

- (void)emojiAction:(id)sender {
    if (self.emojiInputViewVisible) {
        self.emojiInputViewVisible = NO;
        self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_selected";
        self.keyboardButton.accessibilityLabel = @"弹出键盘";
        self.emojiButton.imageName = @"fh_ugc_toolbar_emoj_normal";
        self.emojiButton.accessibilityLabel = @"表情";
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickEmojiButton:)]) {
            [self.delegate toolbarDidClickEmojiButton:NO];
        }
    } else {
        self.emojiInputViewVisible = YES;
        self.emojiInputView.hidden = NO;
        self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_normal";
        self.keyboardButton.accessibilityLabel = @"收起键盘";
        self.emojiButton.imageName = @"fh_ugc_toolbar_keyboard_selected";
        self.emojiButton.accessibilityLabel = @"收起表情选择框";
        if (self.delegate && [self.delegate respondsToSelector:@selector(toolbarDidClickEmojiButton:)]) {
            [self.delegate toolbarDidClickEmojiButton:YES];
            
            [UIView animateWithDuration:0.25 delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
                self.top = self.toolbarViewOrigin.y - EMOJI_INPUT_VIEW_HEIGHT - 60;
            } completion:^(BOOL finished) {
                self.height = [FHUGCToolbar toolbarHeightWithTags:self.tags hasSelected:self.isSelected] + EMOJI_INPUT_VIEW_HEIGHT;
            }];
        }
    }
}

#pragma mark - 辅助函数

-(BOOL)switchToInput {
    BOOL switchToInput = [self.keyboardButton.imageName isEqualToString:@"fh_ugc_toolbar_keyboard_selected"];
    return switchToInput;
}

#pragma mark - UICollectionViewDelegate

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.row;
    
    if(index >= 0 && index < self.tags.count) {
        FHUGCToolBarTag *tag = self.tags[index];
        
        if(self.tagDelegate && [self.tagDelegate respondsToSelector:@selector(selectedTag:)]) {
            
            if([self.socialGroupSelectEntry hasValidData]) {
                [self tagCloseButtonClicked];
            }
            
            NSInteger index = [self.tags indexOfObject:tag];
            [self.tags removeObjectAtIndex: index];
            [collectionView reloadData];
            
            if(self.tags.count <= 0) {
                [self relayoutSelctCollectionView];
            }
            [self.tagDelegate selectedTag:tag];
        }
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath {
    
    NSInteger index = indexPath.row;
    
    if(index >= 0 && index < self.tags.count) {
        FHUGCToolBarTag *tag = self.tags[index];
        
        // 热门标签上报展示一次埋点
        [self traceTagShowOnce:tag];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tags.count;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FHUGCToolbarTagCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[FHUGCToolbarTagCollectionViewCell reuseIdentifier] forIndexPath:indexPath];
    
    if(indexPath.row >= 0 && indexPath.row < self.tags.count) {
        
        FHUGCToolBarTag *tagInfo = self.tags[indexPath.row];
        
        cell.tagLabel.text = tagInfo.groupName;
    }
    
    return cell;
}


#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    if(indexPath.row >= 0 && indexPath.row < self.tags.count) {
        NSString *content = self.tags[indexPath.row].groupName;
        CGSize size = [content sizeWithAttributes:@{
                                      NSFontAttributeName: [UIFont themeFontRegular:16]
                                      }];
        
        size.width += 10;
        size.height = TAG_BUTTON_HEIGHT;
        
        return size;
    }
    
    return CGSizeZero;
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, LEFT_PADDING, 10, RIGHT_PADDING);
}

#pragma mark - FHPostUGCMainViewDelegate

- (void)tagCloseButtonClicked {
    
    [self stagePopAll];
    
    if([self.socialGroupSelectEntry hasValidData]) {
        
        FHUGCToolBarTag *tagInfo = [[FHUGCToolBarTag alloc] init];
        tagInfo.groupId = self.socialGroupSelectEntry.groupId;
        tagInfo.groupName = self.socialGroupSelectEntry.communityName;
        tagInfo.tagType = self.socialGroupSelectEntry.tagType;
        tagInfo.index = self.socialGroupSelectEntry.tagIndex;
        
        
        self.socialGroupSelectEntry.groupId = nil;
        self.socialGroupSelectEntry.communityName = nil;
        self.socialGroupSelectEntry.followed = NO;
        self.socialGroupSelectEntry.tagType = FHPostUGCTagType_Normal;
        self.socialGroupSelectEntry.tagIndex = INVALID_TAG_INDEX;
        
        // 去重
        if(tagInfo.tagType == FHPostUGCTagType_Normal || [self.tags containsObject:tagInfo]) {
            return;
        }
        
        BOOL shouldRelayout = self.tags.count <= 0;
        if(tagInfo.index >= 0 && tagInfo.index <= self.tags.count) {
            [self.tags insertObject:tagInfo atIndex:tagInfo.index];
            if(shouldRelayout) {
                if(self.tagDelegate && [self.tagDelegate respondsToSelector:@selector(needRelayoutToolbar)]) {
                    [self.tagDelegate needRelayoutToolbar];
                }
            } else {
                [self.tagSelectCollectionView reloadData];
            }
            [self.tagSelectCollectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:tagInfo.index inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
        }
    }
}

- (void)stagePushDuplicateTagIfNeedWithGroupId:(NSString *)groupId {
    
    [self stagePopAll];
    
    FHUGCToolBarTag *tagInfo = [[FHUGCToolBarTag alloc] init];
    tagInfo.groupId = groupId;
    
    NSUInteger index =  [self.tags indexOfObject:tagInfo];
    if(index != NSNotFound) {
        [self.stageStack addObject:self.tags[index]];
        [self.tags removeObjectAtIndex:index];
        [self.tagSelectCollectionView reloadData];
    }
}

- (void)stagePopAll {
    WeakSelf;
    [self.stageStack enumerateObjectsUsingBlock:^(FHUGCToolBarTag * _Nonnull tagInfo, NSUInteger idx, BOOL * _Nonnull stop) {
        StrongSelf;
        [self.tags insertObject:tagInfo atIndex:tagInfo.index];
    }];
    
    if(self.stageStack.count > 0) {
        [self.tagSelectCollectionView reloadData];
    }
    [self.stageStack removeAllObjects];
}

#pragma mark - 埋点

- (void)traceTagsCollectionViewShow {
    
    if(!self.isReportedTagsCollectionViewShow && self.tags.count > 0) {
        
        NSMutableDictionary *param = @{}.mutableCopy;
        param[UT_ENTER_FROM] = self.reportModel.enterFrom;
        param[UT_ORIGIN_FROM] = self.reportModel.originFrom?:UT_BE_NULL;
        param[UT_PAGE_TYPE] = self.reportModel.pageType;
        param[UT_ELEMENT_TYPE] = @"hot_label";
        TRACK_EVENT(@"element_show", param);
        self.isReportedTagsCollectionViewShow = YES;
        
    }
}

- (void)traceTagShowOnce:(FHUGCToolBarTag *)tagInfo {

    BOOL isValid = tagInfo && tagInfo.groupId.length > 0;
    
    if(!isValid) {
        return;
    }
    
    if(![self.tagShowReportOnceSet containsObject:tagInfo.groupId]) {
        
        NSMutableDictionary *param = @{}.mutableCopy;
        param[UT_ENTER_FROM] = self.reportModel.enterFrom;
        param[UT_ORIGIN_FROM] = self.reportModel.originFrom?:UT_BE_NULL;
        param[UT_PAGE_TYPE] = self.reportModel.pageType;
        param[UT_ELEMENT_TYPE] = @"hot_label";
        
        NSString *labelType = @"";
        
        if(tagInfo.tagType == FHPostUGCTagType_HotTag) {
            labelType = @"hot";
        } else if(tagInfo.tagType == FHPostUGCTagType_History) {
            labelType = @"history";
        }
        param[@"label_type"] = labelType;
        param[@"group_id"] = tagInfo.groupId;
        TRACK_EVENT(@"topic_show", param);
        [self.tagShowReportOnceSet addObject:tagInfo.groupId];
    }
}
@end
