//
//  TTPhotoMultiSearchWordsView.m
//  Article
//
//  Created by 邱鑫玥 on 2017/4/1.
//
//

#import "TTPhotoMultiSearchWordsView.h"
#import "TTDeviceUIUtils.h"
#import "TTPhotoSearchWordModel.h"
#import "UIColor+TTThemeExtension.h"
#import "TTStringHelper.h"
#import "TTRoute.h"

#pragma mark - 搜索词view参数
NS_INLINE CGFloat SearchWordsTopPadding(){
    return [TTDeviceUIUtils tt_newPadding:12.f];
}

NS_INLINE CGFloat SearchWordsBottomPadding(){
    return [TTDeviceUIUtils tt_newPadding:20.f];
}

NS_INLINE CGFloat SearchWordsHeight(){
    return [TTDeviceUIUtils tt_newPadding:28.f];
}

NS_INLINE CGFloat SearchWordsSpacing(){
    return [TTDeviceUIUtils tt_newPadding:12.f];
}

NS_INLINE CGFloat SearchWordsFont(){
    return [TTDeviceUIUtils tt_newFontSize:12.f];
}

NS_INLINE CGFloat SearchWordsBorderWidth(){
    return 1.f;
}

NS_INLINE CGFloat SearchWordsInsidePadding(){
    return [TTDeviceUIUtils tt_newPadding:16.f];
}

NS_INLINE NSInteger SearchWordsMaxLength(){
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return 12;
        case TTDeviceMode736: return 12;
        case TTDeviceMode667: return 11;
        case TTDeviceMode568: return 10;
        case TTDeviceMode480: return 10;
        default:
            return 10;
    }
}

#pragma mark -
#pragma mark - TTPhotoSearchWordItemView
@interface TTPhotoSearchWordItemView : UIView

@property(nonatomic, strong) TTPhotoSearchWordModel *searchWorditem;
@property(nonatomic, strong) UILabel *textLabel;

@end

@implementation TTPhotoSearchWordItemView

- (instancetype)initWithItem:(TTPhotoSearchWordModel *)item{
    if(self = [super init]){
        self.searchWorditem = item;
        self.backgroundColor = [UIColor clearColor];
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        self.textLabel.textAlignment = NSTextAlignmentLeft;
        self.textLabel.numberOfLines = 1;
        self.textLabel.font = [UIFont systemFontOfSize:SearchWordsFont()];
        self.textLabel.textColor = [UIColor tt_defaultColorForKey:kColorText9Highlighted];
        
        NSString *searchWord = item.label;
        /*超过SearchWordsMaxLength个截断*/
        NSInteger searchWordsMaxLen = SearchWordsMaxLength();
        if(!isEmptyString(searchWord) && searchWord.length > searchWordsMaxLen){
            searchWord = [searchWord substringWithRange:NSMakeRange(0, searchWordsMaxLen - 1)];
            searchWord = [searchWord stringByAppendingString:@"…"];
        }
        
        self.textLabel.text = searchWord;
        
        [self.textLabel sizeToFit];
        [self addSubview:self.textLabel];
        
        self.width = self.textLabel.width + 2 * SearchWordsInsidePadding();
        self.height = SearchWordsHeight();
        self.textLabel.center = self.center;
        
        UIBezierPath * maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(SearchWordsHeight() / 2.f, SearchWordsHeight() / 2.f)];
        CAShapeLayer * maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = self.bounds;
        maskLayer.path = maskPath.CGPath;
        maskLayer.lineWidth = SearchWordsBorderWidth();
        maskLayer.strokeColor = [UIColor colorWithHexString:@"ffffff4d"].CGColor;
        maskLayer.fillColor = [UIColor clearColor].CGColor;
        [self.layer insertSublayer:maskLayer atIndex:0];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOn:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)tapOn:(UITapGestureRecognizer *)tap{
    NSString * url = _searchWorditem.link;
    NSURL *openURL = [TTStringHelper URLWithURLString:url];
    if([[TTRoute sharedRoute] canOpenURL:openURL]){
        [[TTRoute sharedRoute] openURLByPushViewController:openURL];
    }
    wrapperTrackEvent(@"gallery2", @"click");
}

@end

#pragma mark - 
#pragma mark - TTPhotoMultiSearchWordsView
@interface TTPhotoMultiSearchWordsView()

@property (nonatomic, strong) NSArray *itemViews;

@end

@implementation TTPhotoMultiSearchWordsView

- (instancetype)initWithFrame:(CGRect)frame{
    if(self = [super initWithFrame:frame]){
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    return self;
}

- (CGFloat)maxHeight{
    return SearchWordsHeight() + SearchWordsTopPadding() + SearchWordsBottomPadding();
}

- (void)setSearchWordsItems:(NSArray *)searchWordsItems{
    _searchWordsItems = [searchWordsItems copy];
    
    NSMutableArray *mutItemViews = [[NSMutableArray alloc] initWithCapacity:_searchWordsItems.count];
    for(TTPhotoSearchWordModel *item in searchWordsItems){
        TTPhotoSearchWordItemView *itemView = [[TTPhotoSearchWordItemView alloc] initWithItem:item];
        [mutItemViews addObject:itemView];
        [self addSubview:itemView];
    }
    _itemViews = [mutItemViews copy];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    CGFloat maxWidth = self.width;
    CGFloat x_pos = 0.f;
    CGFloat y_pos = SearchWordsTopPadding();
    x_pos += SearchWordsSpacing();
    NSInteger visibleCount = 0;
    for(UIView *subview in _itemViews){
        subview.left = x_pos;
        subview.top = y_pos;
        
        if(subview.right > maxWidth - SearchWordsSpacing() || visibleCount >= 4){
            subview.hidden = YES;
        }
        else{
            subview.hidden = NO;
            visibleCount += 1;
        }
        
        x_pos += subview.width;
        x_pos += SearchWordsSpacing();
    }
}

@end
