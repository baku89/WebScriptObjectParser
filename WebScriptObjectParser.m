//
//  WebScriptObjectParser.m
//
//  Created by Baku Hashimoto on 2013/08/10.
//	Free to use under terms of MIT license.

#import "WebScriptObjectParser.h"

@implementation WebScriptObjectParser

static WebScriptObject *parser;

+ (id) parse: (WebScriptObject*) webObject
{
	if (!parser) {
		[[self class] initParser];
	}
	
	if ( [[self class] isArray:webObject] ) {
		return [[self class] arrayWithWebScriptObject:webObject];
	} else {
		return [[self class] dictionaryWithWebScriptObject:webObject];
	}
}

+ (NSDictionary*) dictionaryWithWebScriptObject:(WebScriptObject *)webObject {
	NSMutableDictionary *dict = [NSMutableDictionary dictionary];
	id keys = [parser callWebScriptMethod:@"arrayWithWebScriptObjectKey"
						   withArguments:[NSArray arrayWithObjects:webObject, nil]];
    NSArray *keyAry = [[self class] arrayWithWebScriptObject:keys];

	for (unsigned i = 0; i < [keyAry count]; i++) {
		NSString *key = [keyAry objectAtIndex:i];
		id value = [webObject valueForKey:key];
		if ( [value isMemberOfClass:[WebScriptObject class]] ) {
			value = [[self class] parse:value];
		}
		[dict setObject:value forKey:key];
	}
	return dict;
	
}

+ (NSArray*) arrayWithWebScriptObject:(WebScriptObject *)webObject {
    NSMutableArray *ary = [NSMutableArray array];
    NSUInteger count = [[webObject valueForKey:@"length"] integerValue];
	
    for (unsigned i = 0; i < count; i++) {
		id value = [webObject webScriptValueAtIndex:i];
		if ( [value isMemberOfClass:[WebScriptObject class]] ) {
			value = [[self class] parse:value];
		}
        [ary addObject:value];
    }
    return ary;
}

+ (bool) isArray:(WebScriptObject *)webObject {
	id val = [parser callWebScriptMethod:@"isArray"
						   withArguments:[NSArray arrayWithObjects:webObject, nil]];
	if (!val) {
		return false;
	}
	return CFBooleanGetValue((CFBooleanRef)val);
}

+ (void)initParser
{
	WebView *parserView = [[WebView alloc] init];
	[[parserView mainFrame] loadHTMLString:@"" baseURL:NULL];
	parser = [parserView windowScriptObject];
	NSString *toArrayFunc = @"function arrayWithWebScriptObjectKey(hash) {"
							@"	try {"
							@"		var r=[];"
							@"		for(var key in hash) {"
							@"			if (hash[key] == undefined) continue;"
							@"			r.push(key);"
							@"		}"
							@"	} catch (e) {"
							@"		return null;"
							@"	}"
							@"	return r;"
							@"}";
	NSString *isArrayFunc = @"function isArray(val) {"
							@"	try {"
							@"		if ( val instanceof Array ) {"
							@"			return true;"
							@"		} else {"
							@"			return false;"
							@"		}"
							@"	} catch(e) {"
							@"		return null;"
							@"	}"
							@"}";
	NSString *script = [NSString stringWithFormat:@"%@ %@", toArrayFunc, isArrayFunc];
	[parser evaluateWebScript:script];
}

@end
