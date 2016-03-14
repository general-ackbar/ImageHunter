//
//  GoogleSearcher.h
//  Image Hunter
//
//  Created by Jonatan Yde on 18/03/13.
//  Copyright (c) 2013 Codeninja. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GoogleSearcher : NSObject

+ (NSArray *)PerformSearchFrom: (NSString *)keyword fromIndex: (int)start onType: (NSString *)type withSafe: (BOOL) safe
;
+ (NSArray *)PerformSearchUsingQuery:(NSString *)query fromIndex:(int)start;
@end
