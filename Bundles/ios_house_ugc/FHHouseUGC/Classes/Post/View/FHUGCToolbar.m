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
@end

@implementation FHUGCToolbar


+ (CGFloat)toolbarHeightWithTags:(NSArray *)tags {
    return FHUGCToolbarHeight + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom + SELECT_ENTRY_HEIGHT + (tags.count > 0 ? TAGS_VIEW_HEIGHT : 0);
}

- (instancetype)initWithFrame:(CGRect)frame type:(FHPostUGCMainViewType)type {
    if(self = [super initWithFrame:frame]) {
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

- (void)layoutTagSelectCollectionViewWithTags:(NSMutableArray<FHUGCToolBarTag *> *)tags {
    self.tags = tags;
    [self relayoutSelctCollectionView];
}

- (void)relayoutSelctCollectionView {
    CGRect frame = self.tagSelectCollectionView.frame;
    frame.size.height = self.tags.count > 0 ? TAGS_VIEW_HEIGHT : 0;
    self.tagSelectCollectionView.frame = frame;
    
    [self.tagSelectCollectionView reloadData];
    [self layoutSuperView];
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
    
    targetY = CGRectGetMinY(keyboardScreenFrame) - [FHUGCToolbar toolbarHeightWithTags:self.tags] + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    
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
    
    targetY = CGRectGetMinY(keyboardScreenFrame) - CGRectGetHeight(frame);
    if (self.emojiInputViewVisible) { // 切换到表情输入，收起键盘
        // 提前显示表情选择器
        self.emojiInputView.hidden = !self.emojiInputViewVisible;
        self.keyboardButton.imageName = @"fh_ugc_toolbar_keyboard_normal";
        self.keyboardButton.accessibilityLabel = @"收起键盘";
        self.emojiButton.imageName = @"fh_ugc_toolbar_keyboard_selected";
        self.emojiButton.accessibilityLabel = @"收起表情选择框";
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
            [self.tagSelectCollectionView deleteItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:index inSection:0]]];
            if(self.tags.count <= 0) {
                [self relayoutSelctCollectionView];
            }
            [self.tagDelegate selectedTag:tag];
        }
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
@end
