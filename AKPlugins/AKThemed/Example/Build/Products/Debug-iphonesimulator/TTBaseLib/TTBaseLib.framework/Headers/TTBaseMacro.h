//
//  TTBaseMacro.h
//  Article
//
//  Created by panxiang on 15/11/5.
//
//

#ifndef TTBaseMacro_h
#define TTBaseMacro_h

#define WeakSelf __weak typeof(self) wself = self
#define StrongSelf __strong typeof(wself) self = wself

#ifndef DEBUG

#ifndef SSLog
#define SSLog(format,...) \
{ \
}
#endif

#else
#ifndef SSLog

#define SSLog(...) \
NSLog(__VA_ARGS__)

#endif
#endif


#ifndef isEmptyString
#define isEmptyString(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)
#endif

#ifndef SSIsEmptyArray
#define SSIsEmptyArray(array) (!array || ![array isKindOfClass:[NSArray class]] || array.count == 0)
#endif

#ifndef SSIsEmptyDictionary
#define SSIsEmptyDictionary(dict) (!dict || ![dict isKindOfClass:[NSDictionary class]] || ((NSDictionary *)dict).count == 0)
#endif

#endif /* TTBaseMacro_h */
