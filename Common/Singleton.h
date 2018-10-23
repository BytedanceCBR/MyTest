//
//  Singleton.h
//  Article
//
//  Created by gaohaidong on 6/22/16.
//
//

#ifndef Singleton_h
#define Singleton_h

// https://gist.github.com/lukeredpath/1057420
/*!
 * @function Singleton GCD Macro
 */
#ifndef SINGLETON_GCD
#define SINGLETON_GCD(classname)                        \
                                                        \
+ (classname *)shared##classname {                      \
                                                        \
    static dispatch_once_t pred;                        \
    __strong static classname * shared##classname = nil;\
    dispatch_once( &pred, ^{                            \
        shared##classname = [[self alloc] init]; });    \
    return shared##classname;                           \
}
#endif

#endif /* Singleton_h */
