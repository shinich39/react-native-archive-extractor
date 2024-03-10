//
//  ReactNativeArchiveExtractor.m
//  ReactNativeArchiveExtractor
//
//  Created by Icheol Shin on 3/8/24.
//

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(ReactNativeArchiveExtractor, NSObject)

RCT_EXTERN__BLOCKING_SYNCHRONOUS_METHOD(getName)

RCT_EXTERN_METHOD(
    isProtectedZip:(NSString *)srcPath
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractZip:(NSString *)srcPath
    dstPath:(NSString *)dstPath
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractZipWithPassword:(NSString *)srcPath
    dstPath:(NSString *)dstPath
    password:(NSString *)password
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    isProtectedRar:(NSString *)srcPath
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractRar:(NSString *)srcPath
    dstPath:(NSString *)dstPath
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractRarWithPassword:(NSString *)srcPath
    dstPath:(NSString *)dstPath
    password:(NSString *)password
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

// RCT_EXTERN_METHOD(
//     isProtectedSevenZip:(NSString *)srcPath
//     resolve:(RCTPromiseResolveBlock)resolve
//     reject:(RCTPromiseRejectBlock)reject
// )

RCT_EXTERN_METHOD(
    extractSevenZip:(NSString *)srcPath
    dstPath:(NSString *)dstPath
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractSevenZipWithPassword:(NSString *)srcPath
    dstPath:(NSString *)dstPath
    password:(NSString *)password
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    isProtectedPdf:(NSString *)srcPath
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractPdf:(NSString *)srcPath
    dstPath:(NSString *)dstPath
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

RCT_EXTERN_METHOD(
    extractPdfWithPassword:(NSString *)srcPath
    dstPath:(NSString *)dstPath
    password:(NSString *)password
    resolve:(RCTPromiseResolveBlock)resolve
    reject:(RCTPromiseRejectBlock)reject
)

@end
