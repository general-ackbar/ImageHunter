//
//  HttpOperations.m
//  Media Library
//
//  Created by Jonatan Yde on 30/01/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import "HttpOperations.h"

@implementation HttpOperations




#define kServerConnectionTimeout 60

+ (NSMutableURLRequest *)sendPostRequest:(NSString *)url withParameters:(NSDictionary *)parameters
{
    NSMutableData *reqData = [NSMutableData data];
    NSURL *encUrl;
    encUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:encUrl];
    [request setHTTPShouldHandleCookies:YES];
    request.HTTPMethod = @"POST";
    request.timeoutInterval = kServerConnectionTimeout;
    NSString *stringBoundary = @"Multipart-Boundary"; // TODO - randomize this
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=\"%@\"",stringBoundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    [reqData appendData:[[NSString stringWithFormat:@"\r\n\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
    for (id key in [parameters allKeys])
    {
        if (![key isEqualToString:@"data"])
        {
            NSString *val = [parameters objectForKey:key];
            if (val != nil)
            {
                [reqData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
                [reqData appendData:[[NSString stringWithFormat:@"Content-Type: text/plain\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [reqData appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: 8bit\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
                [reqData appendData:[[NSString stringWithFormat:@"%@",val] dataUsingEncoding:NSUTF8StringEncoding]];
                [reqData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
            }
        }
    }
    
    // send binary part last
    if ([parameters objectForKey:@"data"])
    {
        NSString *key  = @"data";
        NSData *fileData = [parameters objectForKey:key];
        if (fileData != nil)
        {
            [reqData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"FILE1\";filename=\"upload.file\"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [reqData appendData:[[NSString stringWithFormat:@"Content-Type: application/octet-stream\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            
            [reqData appendData:[[NSString stringWithFormat:@"Content-Transfer-Encoding: binary\r\n\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
            [reqData appendData:fileData];
            [reqData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",stringBoundary] dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    NSString * dataLength = [NSString stringWithFormat:@"%lu", (unsigned long)[reqData length]];
    [request addValue:dataLength forHTTPHeaderField:@"Content-Length"];
    
    request.HTTPBody = reqData;
    //NSLog(@"postBody=%@", [[NSString alloc] initWithData:reqData encoding:NSASCIIStringEncoding]);
    
    return request;
}

+ (NSMutableURLRequest *)sendGetRequest:(NSString *)url
{
    NSURL *encUrl;
    encUrl = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:encUrl];
    [request setHTTPShouldHandleCookies:YES];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = kServerConnectionTimeout;
    
    return request;
}

@end
