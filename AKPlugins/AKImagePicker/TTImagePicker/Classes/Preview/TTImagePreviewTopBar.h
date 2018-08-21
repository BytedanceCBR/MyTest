//
//  TTImagePreviewTopBar.h
//  Article
//
//  Created by SongChai on 2017/4/9.
//
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TTImagePreviewType) {
    TTImagePreviewTypeDefalut = 0,
    TTImagePreviewTypeDelete,
    TTImagePreviewTypeVideo
};

typedef NS_ENUM(NSInteger, TTImagePreviewTopBarButtonTag) {
    TTImagePreviewTopBarButtonTagClose = 0,
    TTImagePreviewTopBarButtonTagDelete,
    TTImagePreviewTopBarButtonTagComplete,
};

@protocol TTImagePreviewTopBarDelegate <NSObject>

- (void) ttImagePreviewTopBarOnButtonClick:(TTImagePreviewTopBarButtonTag) tag;

@end

@interface TTImagePreviewTopBar : UIView
@property(nonatomic, strong) NSString* title;
@property(nonatomic, assign) int selectedCount;
@property (nonatomic,strong)UIImageView *backImg;

@property(nonatomic, weak) id<TTImagePreviewTopBarDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame withType:(TTImagePreviewType)type;

@end
