//
//  TTBaseCellAction.h
//  Article
//
//  Created by panxiang on 16/7/11.
//
//

//typedef NS_ENUM(NSUInteger, TTBaseCellActions) {
//    TTBaseCellActions_Default,
//};

typedef void(^TTCellActionCallback)(BOOL success,id object);
@protocol TTBaseCellAction <NSObject>
@required
- (void)tt_cellAction:(NSUInteger)action object:(id)object callbackBlock:(TTCellActionCallback)callbackBlock;//action 最好用枚举定义 callbackBlock不要传nil ,接受者使用nil block会崩溃
@end