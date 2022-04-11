//
//  CocoaSecurity.h
//  CocoaSecurity
//
//  Created by nenhall on 2020/6/12.
//  Copyright © 2020 nenhall. All rights reserved.
//

#import <Foundation/Foundation.h>

//! Project version number for CocoaSecurity.
FOUNDATION_EXPORT double CocoaSecurityVersionNumber;

//! Project version string for CocoaSecurity.
FOUNDATION_EXPORT const unsigned char CocoaSecurityVersionString[];

// In this header, you should import all the public headers of your framework using statements like #import <CocoaSecurity/PublicHeader.h>


@interface CocoaSecurityResult : NSObject
@property (strong, nonatomic, readonly) NSData *data;
@property (strong, nonatomic, readonly) NSString *utf8String;
@property (strong, nonatomic, readonly) NSString *hex;
@property (strong, nonatomic, readonly) NSString *hexLower;
@property (strong, nonatomic, readonly) NSString *base64;
@end


@interface CocoaSecurity : NSObject

+ (CocoaSecurityResult *)md5:(NSString *)hashString;

+ (CocoaSecurityResult *)md5WithData:(NSData *)hashData;
@end




