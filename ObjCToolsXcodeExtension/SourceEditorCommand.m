//  Created by dasdom on 28.07.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

#import "SourceEditorCommand.h"
#import <ToolsHelper/ToolsHelper.h>

@implementation SourceEditorCommand

- (void)performCommandWithInvocation:(XCSourceEditorCommandInvocation *)invocation completionHandler:(void (^)(NSError * _Nullable nilOrError))completionHandler {
    
//    NSLog(@"id: %@", invocation.commandIdentifier);
    XCSourceTextBuffer *buffer = invocation.buffer;
    
    NSMutableArray<XCSourceTextRange *> *selections = buffer.selections;
    XCSourceTextRange *firstSelection = selections.firstObject;
    
    NSInteger lineNumber = firstSelection.start.line;
    NSString *line = buffer.lines[lineNumber];
    
    NSError *error = nil;
//    NSLog(@"contentUTI: %@", invocation.buffer.contentUTI);
    NSString *identifier = invocation.commandIdentifier;
    BOOL isObjC = [invocation.buffer.contentUTI containsString:@".objective-c-source"];
    BOOL isSwift = [invocation.buffer.contentUTI containsString:@".swift-source"];
    if ([identifier containsString:@".ImportHeader"]) {
        if (isObjC) {
            NSRange range = NSMakeRange(firstSelection.start.column, firstSelection.end.column-firstSelection.start.column);
            NSString *selectedString = [line substringWithRange:range];
            [SourceEditorMethods addImportStatementFromSelectedString:selectedString toLines:buffer.lines];
        } else {
            error = [NSError errorWithDomain:@"WrongLanguage" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"This functionality only supports Objctive-C."}];
        }
    } else if ([identifier containsString:@".DublicateLineAndReplaceStrings"] ||
               [identifier containsString:@".DublicateLine"]) {
        
        BOOL replaceStrings = [identifier containsString:@".DublicateLineAndReplaceStrings"];
        
        [SourceEditorMethods dublicateLine:line lineNumber:lineNumber inLines:buffer.lines replaceStrings:replaceStrings];
        
    } else if ([identifier containsString:@".SortImportsAndRemoveDuplicates"]) {
      
        [SourceEditorMethods sortImportsAndRemoveDublicatesInLines:buffer.lines];
      
    } else if ([identifier containsString:@".HexToUIColor"]) {
        
        NSString *string = [line substringWithRange:NSMakeRange(firstSelection.start.column, firstSelection.end.column-firstSelection.start.column)];

        NSMutableString *indentation = [[NSMutableString alloc] initWithString:@""];
        for (int i = 0; i<buffer.indentationWidth; i++) {
            [indentation appendString:@" "];
        }
        if (buffer.usesTabsForIndentation) {
            NSMutableString *spacesToReplace = [[NSMutableString alloc] initWithString:@""];
            for (int i = 0; i<buffer.tabWidth; i++) {
                [spacesToReplace appendString:@" "];
            }
            [indentation replaceOccurrencesOfString:spacesToReplace withString:@"\t" options:0 range:NSMakeRange(0, indentation.length)];
        }
        
        if (isObjC || isSwift) {
            [SourceEditorMethods hexToUIColorFromSelectedString:string lineNumber:lineNumber inLines:buffer.lines indentation:indentation contentUTI:invocation.buffer.contentUTI];
        }
    } else if ([identifier containsString:@".CopyDeclarationToClipboard"]) {
        
        if (isObjC) {
            NSArray<NSString *> *lines = [buffer.lines subarrayWithRange:NSMakeRange(selections.firstObject.start.line, selections.firstObject.end.line-selections.firstObject.start.line+1)];
            
            NSString *declarations = [SourceEditorMethods declarationForStrings:lines];
            
            [[NSPasteboard generalPasteboard] clearContents];
            [[NSPasteboard generalPasteboard] setString:declarations forType:NSStringPboardType];
        } else {
            error = [NSError errorWithDomain:@"WrongLanguage" code:1001 userInfo:@{NSLocalizedDescriptionKey: @"This functionality only supports Objctive-C."}];
        }
    } else if ([identifier containsString:@".AlignEquals"]) {
        
        NSRange subRange = NSMakeRange(selections.firstObject.start.line, selections.firstObject.end.line-selections.firstObject.start.line+1);
        NSArray<NSString *> *lines = [buffer.lines subarrayWithRange:subRange];
        
        NSArray<NSString *> *changedLines = [SourceEditorMethods alignEquals:lines];
        
        [buffer.lines replaceObjectsInRange:subRange withObjectsFromArray:changedLines];
    }
    
    completionHandler(error);
}

@end
