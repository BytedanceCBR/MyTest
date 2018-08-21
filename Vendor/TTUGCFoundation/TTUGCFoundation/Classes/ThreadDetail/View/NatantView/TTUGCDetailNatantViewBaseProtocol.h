//
//  TTUGCDetailNatantViewBaseProtocol.h
//  TTUGCFoundation
//
//  Created by jinqiushi on 2018/1/29.
//

#import <Foundation/Foundation.h>

typedef void(^UGCLayoutSubViewsBlock)(BOOL animated);
typedef void(^UGCScrollInOrOutBlock)(BOOL isVisible);

@protocol TTUGCDetailNatantViewBaseProtocol <NSObject>

@optional
@property (nonatomic, assign) BOOL hasShow;
@property (nonatomic, copy, nullable) NSString * eventLabel;
@property (nonatomic, copy, nullable) UGCLayoutSubViewsBlock relayOutBlock;
@property (nonatomic, copy, nullable) UGCScrollInOrOutBlock scrollInOrOutBlock;
-(void)reloadData:(nullable id)object;

-(void)trackEventIfNeeded;

- (void)trackEventIfNeededWithStyle:(NSString * _Nonnull)style;

- (void)checkVisableRelatedArticlesAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight;

- (void)scrollViewDidEndDraggingAtContentOffset:(CGFloat)offsetY referViewHeight:(CGFloat)referHeight;

- (void)fontChanged;

@end
