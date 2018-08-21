//
//  TTDislikeView.h
//  Article
//
//  Created by zhaoqin on 27/02/2017.
//
//

#import "SSViewBase.h"
#import "TTDislikeConst.h"

typedef enum : NSUInteger {
    TTDislikeOptionHeaderViewTypeNormal,
    TTDislikeOptionHeaderViewTypeNOCommitButton
} TTDislikeOptionHeaderViewType;

@class TTAlphaThemedButton;
@class SSThemedLabel;
@class TTActionSheetCellModel;
@class TTDetailModel;

@interface TTDislikeOptionCell : UICollectionViewCell
@property (nonatomic, strong) void(^ _Nullable didSelectedComplete)();
@property (nonatomic, assign) BOOL showArrow;

- (void)configModel:(TTActionSheetCellModel * _Nonnull)model;

@end

@interface TTDislikeOptionHeaderView : UICollectionReusableView
@property (nonatomic, assign) TTDislikeOptionHeaderViewType type;
@property (nonatomic, strong, nonnull) NSString *title;
@property (nonatomic, strong) void (^ _Nullable commitComplete)();
@end

@interface TTDislikeView : SSViewBase
@property (nonatomic, assign) TTDislikeType type;
@property (nonatomic, strong) TTDetailModel * _Nonnull detailModel;
@property (nonatomic, strong) void (^ _Nullable cancelComplete)();
@property (nonatomic, strong) void (^ _Nullable commitComplete)();
@property (nonatomic, strong) void (^ _Nullable extraComeplete)();

- (void)insertDislikeOptions:(NSArray * _Nonnull)dislikeOptions reportOptions:(NSArray * _Nonnull)reportOptions;

- (void)setComplainMessage:(BOOL)hasComplainMessage;

@end
