//
//  TTPersonalHomeBottomSegmentView.h
//  Article
//
//  Created by wangdi on 2017/3/27.
//
//

#import "SSThemed.h"
#import "TTPersonalHomeUserInfoResponseModel.h"

@class TTPersonalHomeBottomSegmentView;

@protocol TTPersonalHomeBottomSegmentViewDelegate <NSObject>
@optional
- (void)bottomSegmentView:(TTPersonalHomeBottomSegmentView *)segmentView didSelectedItem:(TTPersonalHomeUserInfoDataBottomItemResponseModel *)item didSelectedPoint:(CGPoint)point didSelectedIndex:(NSInteger)index;


@end

@interface TTPersonalHomeBottomSegmentView : SSThemedView

@property (nonatomic, strong) NSArray<TTPersonalHomeUserInfoDataBottomItemResponseModel *> *items;
@property (nonatomic, weak) id <TTPersonalHomeBottomSegmentViewDelegate> delegate;

@end
