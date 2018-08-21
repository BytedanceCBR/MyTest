//
//  TTWatchMacroDefine.h
//  Article
//
//  Created by 邱鑫玥 on 16/8/19.
//
//

#ifndef TTWatchMacroDefine_h
#define TTWatchMacroDefine_h

#define SSIsEmptyDictionary(dict) (!dict || ![dict isKindOfClass:[NSDictionary class]] || ((NSDictionary *)dict).count == 0)

#define isEmptyString(str) (!str || ![str isKindOfClass:[NSString class]] || str.length == 0)

#define WeakSelf   __weak typeof(self) wself = self
#define StrongSelf __strong typeof(wself) self = wself


#endif /* TTWatchMacroDefine_h */
