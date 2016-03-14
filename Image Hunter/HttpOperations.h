//
//  HttpOperations.h
//  Media Library
//
//  Created by Jonatan Yde on 30/01/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpOperations : NSObject




//+ (NSMutableURLRequest *)sendPostRequest:(NSString *)url withParameters:(NSDictionary *)parameters;
+ (NSMutableURLRequest *)sendGetRequest:(NSString *)url;
@end
