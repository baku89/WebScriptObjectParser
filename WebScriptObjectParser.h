//
//  WebScriptObjectParser.m
//
//  Created by Baku Hashimoto on 2013/08/10.
//	Free to use under terms of MIT license.

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

@interface WebScriptObjectParser : NSObject

+ (NSDictionary*) parse: (WebScriptObject*) webObject;

@end
