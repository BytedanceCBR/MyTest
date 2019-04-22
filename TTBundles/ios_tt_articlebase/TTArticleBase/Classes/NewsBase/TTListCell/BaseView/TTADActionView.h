//
//  TTADActionView.h
//  Article
//
//  Created by 杨心雨 on 16/8/24.
//
//

#import "SSThemed.h"
#import "ExploreOrderedData+TTBusiness.h"

@interface TTADActionView : SSThemedView

@property (nonatomic, strong) SSThemedView * _Nonnull separatorView;
@property (nonatomic, strong) SSThemedLabel * _Nonnull sourceLabel;
@property (nonatomic, strong) SSThemedButton * _Nullable actionButton;

- (void)layoutADActionView;
- (void)updateADActionView:(ExploreOrderedData * _Nonnull)orderedData;

@end
