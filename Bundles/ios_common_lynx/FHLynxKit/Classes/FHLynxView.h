//
//  FHLynxView.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2020/4/21.
//

#import <UIKit/UIKit.h>
@class LynxView;

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, FHLynxViewSizeMode) {
  FHLynxViewSizeModeUndefined = 0,
  FHLynxViewSizeModeExact,
  FHLynxViewSizeModeMax
};


typedef void (^FHLynxViewBridgeHandler)(id container, NSString *name, NSDictionary * _Nullable params, void(^callback)(NSInteger code, NSDictionary * _Nullable data));


@protocol FHLynxClientViewDelegate <NSObject>

- (void)viewDidChangeIntrinsicContentSize:(CGSize)size;

@end


@interface FHLynxViewBaseParams : NSObject

@property (nonatomic, copy) NSString * sourceUrl;
@property (nonatomic, copy) NSString * channel;
@property (nonatomic, copy) NSString * bundle;
@property (nonatomic, copy) NSString * fallbackSchema;
@property (nonatomic, copy) id initialProperties;

@end


@interface FHLynxView : UIView

@property (nonatomic, strong) NSData * data;

@property (nonatomic, weak) id <FHLynxClientViewDelegate> lynxDelegate;

@property (nonatomic, copy) NSString * containerID;
@property (nonatomic, strong) LynxView *lynxView;

@property (nonatomic, strong) FHLynxViewBaseParams *params;

@property (nonatomic, assign) FHLynxViewSizeMode widthMode;
@property (nonatomic, assign) FHLynxViewSizeMode heightMode;

- (instancetype)initWithFrame:(CGRect)frame;
- (void)loadLynxWithParams:(FHLynxViewBaseParams *)params;
- (void)updateData:(NSDictionary *)dict;

- (void)registerHandler:(FHLynxViewBridgeHandler)handler forMethod:(NSString *)method;

- (void)reload;
- (void)reloadWithBaseParams:(FHLynxViewBaseParams *)params data:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
