//
//  TTProfileHeaderVisitorView.h
//  Article
//
//  Created by liuzuopeng on 8/8/16.
//
//

#import "SSThemed.h"

@class TTProfileHeaderVisitorView;
@interface TTProfileHeaderVisitorModel : NSObject
/**
 * 0: 我的访客
 * 1: 关注我的人
 * 2：我关注的人
 * 3：动态
 */
@property (nonatomic, assign) NSUInteger visitorType;
@property (nonatomic, assign) long long number;
@property (nonatomic, strong) NSString  *text;

+ (instancetype)visitorModelWithText:(NSString *)text number:(long long)number type:(NSUInteger)type;
+ (NSArray<TTProfileHeaderVisitorModel *> *)modelsWithMoments:(long long)moments followings:(long long)followings followers:(long long)followers visitors:(long long)visitors;
@end


typedef void(^TTVisitorCompletionBlock)(TTProfileHeaderVisitorView *visitorView, NSUInteger selectedIndex);
/**
 * 访客模块(我关注的人，关注我的人，我的访客)
 */
@interface TTProfileHeaderVisitorView : SSThemedView
@property (nonatomic, assign) BOOL separatorEnabled; // separator is YES
@property (nonatomic, copy)   NSString *separatorColorKey; // default is kColorLine12
@property (nonatomic, copy)   TTVisitorCompletionBlock didTapButtonCallback;
@property (nonatomic, strong, readonly) NSArray<TTProfileHeaderVisitorModel *> *models;
@property (nonatomic, assign) BOOL showUpDownArrow; 

- (instancetype)initWithModels:(NSArray<TTProfileHeaderVisitorModel *> *)models;
- (SSThemedButton *)buttonAtIndex:(NSUInteger)index;
- (void)reloadModels:(NSArray<TTProfileHeaderVisitorModel *> *)models;
- (void)reloadModel:(TTProfileHeaderVisitorModel *)model forIndex:(NSUInteger)index;
@end


@interface TTProfileHeaderAppFansView : SSThemedView

@property (nonatomic, strong) NSMutableArray *appInfos;

@end
