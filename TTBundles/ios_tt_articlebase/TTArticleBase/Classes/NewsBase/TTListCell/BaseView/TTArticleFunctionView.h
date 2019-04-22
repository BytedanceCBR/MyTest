//
//  TTArticleFunctionView.h
//  Article
//
//  Created by 杨心雨 on 16/8/23.
//
//

#import "SSThemed.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTImageView.h"

// MARK: - TTFunctionViewProtocol 功能区协议
@protocol TTFunctionViewProtocol <NSObject>

- (void)functionViewLikeViewClick;

@optional
- (void)functionViewPGCClick;
- (void)functionViewEntityClick;

@end


@interface TTArticleFunctionView : SSThemedView

@property (nonatomic, weak) id<TTFunctionViewProtocol> _Nullable delegate;
@property (nonatomic, strong) SSThemedLabel * _Nonnull likeView;
@property (nonatomic, strong) TTImageView * _Nonnull sourceImageView;
@property (nonatomic, strong) SSThemedLabel * _Nonnull sourceView;
@property (nonatomic, strong) SSThemedLabel * _Nonnull subscriptView;
@property (nonatomic, strong) SSThemedImageView * _Nonnull moreImageView;
@property (nonatomic, strong) SSThemedLabel * _Nonnull entityView;

- (void)updateFunction:(ExploreOrderedData * _Nonnull)orderedData refer:(NSUInteger)refer;
- (void)updateADFunction:(ExploreOrderedData * _Nonnull)orderedData;
- (void)layoutFunction;
- (void)likeViewClick;
- (void)sourceImageClick;
- (void)entityViewClick;
- (void)updateReadState:(BOOL)hasRead;

@end
