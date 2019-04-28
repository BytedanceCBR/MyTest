//
//  TTDislikeComplainView.h
//  Article
//
//  Created by zhaoqin on 05/03/2017.
//
//

#import "SSViewBase.h"

@interface TTDislikeComplainView : SSViewBase
@property (nonatomic, strong) void (^ _Nullable dismissComplete)();
@property (nonatomic, strong) void (^ _Nullable showKeyboardComeplete)(CGFloat keyboardHeight);
@property (nonatomic, strong) void (^ _Nullable dismissKeyboardComeplete)();
@property (nonatomic, strong) void (^ _Nullable sendComplainComplete)();
@property (nonatomic, strong) void (^ _Nullable hasComplainMessage)(BOOL isMessage);

- (void)insertExtraDict:(NSMutableDictionary * _Nullable)extraDict;

@end
