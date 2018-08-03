//
//  TTDataAdapter.h
//  CSDoubleBindModel
//
//  Created by SongChai on 2017/5/4.
//  Copyright © 2017年 SongChai. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <NSObject+FBKVOController.h>
#import "TTValueTransformer.h"

#define TTUGC_CONCAT2(A, B) A ## B
#define TTUGC_CONCAT(A, B) TTUGC_CONCAT2(A, B)

#define TTValueTrans(property) \
+ (NSValueTransformer*) TTUGC_CONCAT(property, DATransformer)

#define MetaKeypath(PATH) \
@_MK(PATH)

#define MetaKeypath1(PATH) \
@_MK(PATH)

#define MetaKeypath2(PATH1, PATH2) \
@[MetaKeypath(PATH1), MetaKeypath(PATH2)]

#define MetaKeypath3(PATH1, PATH2, PATH3) \
@[MetaKeypath(PATH1), MetaKeypath(PATH2), MetaKeypath(PATH3)]

#define MetaKeypath4(PATH1, PATH2, PATH3, PATH4) \
@[MetaKeypath(PATH1), MetaKeypath(PATH2), MetaKeypath(PATH3), MetaKeypath(PATH4)]

#define MetaKeypath5(PATH1, PATH2, PATH3, PATH4, PATH5) \
@[MetaKeypath(PATH1), MetaKeypath(PATH2), MetaKeypath(PATH3), MetaKeypath(PATH4), MetaKeypath(PATH5)]

#define MetaKeypath6(PATH1, PATH2, PATH3, PATH4, PATH5, PATH6) \
@[MetaKeypath(PATH1), MetaKeypath(PATH2), MetaKeypath(PATH3), MetaKeypath(PATH4), MetaKeypath(PATH5), MetaKeypath(PATH6)]

#define MetaKeypath7(PATH1, PATH2, PATH3, PATH4, PATH5, PATH6, PATH7) \
@[MetaKeypath(PATH1), MetaKeypath(PATH2), MetaKeypath(PATH3), MetaKeypath(PATH4), MetaKeypath(PATH5), MetaKeypath(PATH6), MetaKeypath(PATH7)]

#define MetaKeypath8(PATH1, PATH2, PATH3, PATH4, PATH5, PATH6, PATH7, PATH8) \
@[MetaKeypath(PATH1), MetaKeypath(PATH2), MetaKeypath(PATH3), MetaKeypath(PATH4), MetaKeypath(PATH5), MetaKeypath(PATH6), MetaKeypath(PATH7), MetaKeypath(PATH8)]

#define ViewKeypath(PATH) \
@_VK(PATH)

//先传ui使用的业务model，再传原数据model

#ifdef DEBUG

#define _MK(PATH) \
(((void)(NO && ((void)[self _tmpMetaObj].PATH, NO)), # PATH))

#define _VK(PATH) \
(((void)(NO && ((void)[self _tmpViewObj].PATH, NO)), # PATH))

#define TTDARegister(Class1, Class2) \
+ (Class1 *)_tmpViewObj { return nil; } \
+ (Class2 *)_tmpMetaObj { return nil; } \
- (Class1 *)_tmpViewObj { return nil; } \
- (Class2 *)_tmpMetaObj { return nil; } \
- (Class)metaDataClass { \
return [Class2 class]; \
} \
- (Class)viewDataClass { \
return [Class1 class]; \
}

#else

#define _MK(PATH) (# PATH)

#define _VK(PATH) (# PATH)

#define TTDARegister(Class1, Class2) \
- (Class)metaDataClass { \
return [Class2 class]; \
} \
- (Class)viewDataClass { \
return [Class1 class]; \
}

#endif

//改宏只为兼容旧代码，新写的请不要这么做
#define TTDAConst(PATH) \
ttDataAdaptertmpStr = @_VK(PATH);\
viewData.PATH = [self PATH:metaData];

static NSString *ttDataAdaptertmpStr = nil;

@protocol TTDataAdapter <NSObject>

- (Class) metaDataClass;
- (Class) viewDataClass;
+ (NSDictionary*) DAKeyMap; //kvo属性，会双向绑定
@optional
+ (void) prepareCustomTransformer:(NSMutableDictionary*) inputDict; //会KVO的绑定关系
@end

@interface TTDataAdapter<__covariant MetaDataType,__covariant ViewDataType> : NSObject<TTDataAdapter>

@property(weak, nonatomic) FBKVOController* dataKVOController;

- (instancetype)initWithMetaData:(MetaDataType)metaData;

- (void)prepareWithViewData:(ViewDataType)viewData;

- (void)prepareConstMetaData:(MetaDataType)metaData viewData:(ViewDataType)viewData; //仅仅单项初始化
@end

@interface NSMutableDictionary (TTDataAdapter)
- (void) addKey:(NSString *)key forwardBlock:(TTValueTransformerBlock)transformation;
- (void) addKey:(NSString *)key reversibleBlock:(TTValueTransformerBlock)transformation;
- (void) addKey:(NSString *)key forwardBlock:(TTValueTransformerBlock)forwardTransformation reverseBlock:(TTValueTransformerBlock)reverseTransformation;
@end
