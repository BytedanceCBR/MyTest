//
//  TTDislikeViewController.h
//  Article
//
//  Created by zhaoqin on 27/02/2017.
//
//

#import "SSViewControllerBase.h"
#import "TTDislikeConst.h"

@class TTDetailModel;

@interface TTDislikeViewController : SSViewControllerBase

@property (nonatomic, strong) void (^ _Nonnull commitComplete)();
@property (nonatomic, strong) void (^ _Nonnull dismissComplete)();
@property (nonatomic, strong) void (^ _Nonnull hasComplainMessage)(BOOL isMessage);
@property (nonatomic, assign) TTDislikeType type;
@property (nonatomic, strong) TTDetailModel * _Nonnull detailModel;

- (void)insertDislikeOptions:(NSArray * _Nonnull)dislikeOptions reportOptions:(NSArray * _Nonnull)reportOptions;

- (void)insertExtraDict:(NSMutableDictionary * _Nullable)extraDict;

- (void)updateComplainMessage:(BOOL)isMessage;

@end
