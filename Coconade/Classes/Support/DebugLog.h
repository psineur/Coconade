/*
 *  DebugLog.h
 *  DebugLog
 *
 *  Created by Karl Kraft on 3/22/09.
 *  Copyright 2009 Karl Kraft. All rights reserved.
 *  http://www.karlkraft.com/index.php/2009/03/23/114/
 *
 */
#import "Foundation/Foundation.h"

// Like NSLog, but without annoying TimeStamps
void TinyLog(NSString *format,...);

// Better NSLog by Karl Kraft
#ifdef DEBUG
	#define DebugLog(args...) _DebugLog(__FILE__,__LINE__,__PRETTY_FUNCTION__,args);
#else
	#define DebugLog(x...)
#endif

void _DebugLog(const char *file, int lineNumber, const char *funcName, NSString *format,...);


