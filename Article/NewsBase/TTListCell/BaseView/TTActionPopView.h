//
//  TTActionPopView.h
//  Article
//
//  Created by 杨心雨 on 16/8/21.
//
//

#import "TTFeedPopupView.h"
#import "SSThemed.h"
#import "TTFeedDislikeWord.h"
#import "TTFeedDislikeKeywordsView.h"

@class TTActionPopView;
@class TTActionListView;
@class TTDislikePopView;
@class TTActionListItem;

extern CGFloat kCornerRadius();
extern CGFloat kPopButtonWidth();
extern CGFloat kPopButtonHeight();
extern CGFloat kButtonFontSize();
extern CGFloat kTitleLabelFontSize();
extern CGFloat kSubtitleLabelFontSize();
extern CGFloat kDislikeButtonGapX();
extern CGFloat kArrowOffsetY();

// MARK: - TTDislikePopViewDelegate
@protocol TTDislikePopViewDelegate <NSObject>

- (void)dislikeButtonClicked:(NSArray<NSString *> * _Nonnull)selectedWords onlyOne:(BOOL)onlyOne;

@optional
- (void)dislikeCancelClicked:(NSArray<NSString *> * _Nonnull)selectedWords onlyOne:(BOOL)onlyOne;

@end

@interface TTActionPopView : TTFeedPopupView

+ (nullable TTActionPopView *)shareView;
+ (nullable NSMutableArray<TTFeedDislikeWord *> *)shareLastDislikeWords;
+ (nullable NSNumber *)shareGroupId;
+ (BOOL)shareEnable;

@property (nonatomic, strong) UIView * _Nonnull arrowBackgroundView;
@property (nonatomic, strong) SSThemedImageView * _Nonnull arrowView;
@property (nonatomic, strong) SSThemedView * _Nonnull contentBackgroundView;
@property (nonatomic, strong) TTActionListView * _Nonnull actionListView;
@property (nonatomic, strong) TTDislikePopView * _Nonnull dislikeView;
@property (nonatomic, weak) id<TTDislikePopViewDelegate> _Nullable delegate;

- (nonnull instancetype)initWithActionItems:(NSArray<TTActionListItem *> * _Nonnull)actionItems width:(CGFloat)width;
+ (void)dismissIfVisible;
- (void)rootViewWillTransitionToSize;
- (void)showAtPoint:(CGPoint)point fromView:(UIView * _Nonnull)fromView animation:(BOOL)animation completeBock:(void (^ _Nullable)(void))completeBock;
- (void)showAtPoint:(CGPoint)point fromView:(UIView * _Nonnull)fromView;
- (void)showDislikeView:(id _Nullable)aOrderedData dislikeWords:(NSArray<TTFeedDislikeWord *> * _Nonnull)dislikeWords groupID:(NSNumber * _Nonnull)groupID transformAnimation:(BOOL)transformAnimation;
- (void)showDislikeView:(id _Nullable)aOrderedData dislikeWords:(NSArray<TTFeedDislikeWord *> * _Nonnull)dislikeWords groupID:(NSNumber * _Nonnull)groupID;
- (void)clickMask;

@end

@interface TTActionListView : SSThemedTableView <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, copy) NSArray<TTActionListItem *> * _Null_unspecified actionItem;
- (nonnull instancetype)initWithWidth:(CGFloat)width;

@end

@interface TTDislikePopView : SSThemedView <TTFeedDislikeKeywordsViewDelegate>

@property (nonatomic, strong) UILabel * _Nonnull titleLabel;
@property (nonatomic, strong) SSThemedButton * _Nonnull okBtn;
@property (nonatomic, strong) TTFeedDislikeKeywordsView * _Nonnull keywordsView;
@property (nonatomic, strong) NSMutableArray<TTFeedDislikeWord *> * _Nonnull dislikewords;
@property (nonatomic) NSInteger selectedKeywordsCount;

- (nonnull instancetype)initWithWidth:(CGFloat)width;

- (nonnull NSArray<NSString *> *)selectedWords;
- (void)refreshContentUI;
- (void)refreshOKBtn;
- (void)refreshTitleLabel;
- (CGFloat)leftPadding;
- (void)okBtnClicked:(id _Nullable)sender;

@end

@interface TTActionListItem : NSObject

@property (nonatomic, copy, readonly) void(^ _Nonnull action)(void);
@property (nonatomic, strong, readonly) NSString * _Nonnull descrip;
@property (nonatomic, strong, readonly) NSString * _Nonnull iconName;
@property (nonatomic, readonly) BOOL hasSub;

- (nonnull instancetype)initWithDescription:(NSString * _Nonnull)descrip iconName:(NSString * _Nonnull)iconName hasSub:(BOOL)hasSub action:(void (^ _Nonnull)(void))action;
- (nonnull instancetype)initWithDescription:(NSString * _Nonnull)descrip iconName:(NSString * _Nonnull)iconName action:(void (^ _Nonnull)(void))action;

@end
