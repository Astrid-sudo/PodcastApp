//
//  RssHelper.m
//  PodcastApp
//
//  Created by Astrid on 2022/2/11.
//

#import "RssHelper.h"

@implementation RssHelper

- (void)parsefeedWithUrlString:(NSString*) urlString {
    NSURL *feedURL = [NSURL URLWithString:urlString];
    xmlParser = [[NSXMLParser alloc]initWithContentsOfURL:feedURL];
    xmlParser.delegate = self;
    [xmlParser parse];
}

- (instancetype)init {
    if ((self = [super init])) {
        _infoTitleFound = false;
        _infoImageFound = false; 
        _rssItems = [[NSMutableArray alloc] init];
        _rssInfoImage = [[NSString alloc] init];
        _rssInfoTitle = [[NSMutableString alloc] init];
        _audioUrl = [[NSString alloc] init];
        _currentElement = [[NSString alloc] init];
        _currentTitle = [[NSMutableString alloc] init];
        _currentDescription = [[NSMutableString alloc] init];
        _currentPubDate = [[NSMutableString alloc] init];
        _currentInfoImageUrl = [[NSString alloc] init];
        _currentAudioUrl = [[NSString alloc] init];
    }
    return self;
}

// MARK: - NSXMLParserDelegate

- (void)parserDidStartDocument:(NSXMLParser *)parser {
    NSLog(@"NSXMLParserStarted Parsing: %@", parser.description);
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary<NSString *,NSString *> *)attributeDict {
    _currentElement = elementName;
    
    if ([_currentElement  isEqualToString: @"item"]) {
        [_currentTitle setString:@""];
        [_currentDescription setString:@""];
        [_currentPubDate setString:@""];
    }
    
    if ([_currentElement  isEqualToString: @"title"]) {
        [_currentTitle setString:@""];
    }
    
    if ([_currentElement  isEqualToString: @"enclosure"]) {
        if (attributeDict[@"url"] != nil) {
            _currentAudioUrl = attributeDict[@"url"];
        } else{
            NSLog(@"malformed element: enclosure without url attribute@");
        }
    }
    
    if ([_currentElement  isEqualToString: @"itunes:image"]) {
        if (attributeDict[@"href"] != nil) {
            _currentInfoImageUrl = attributeDict[@"href"];
        } else{
            NSLog(@"malformed element: enclosure without href attribute@");
        }
    }
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    
    if ([_currentElement  isEqualToString: @"title"]) {
        [ _currentTitle appendString:string];
    }
    
    if ([_currentElement  isEqualToString: @"description"]) {
        [ _currentDescription appendString:string];
    }
    
    if ([_currentElement  isEqualToString: @"pubDate"]) {
        [ _currentPubDate appendString:string];
    }
    
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([elementName  isEqualToString: @"enclosure"]) {
        _audioUrl = _currentAudioUrl;
    }
    
    if ([elementName  isEqualToString: @"item"]) {
        RssItem *rssItem = [[RssItem alloc] initWithRssTitle: _currentTitle initWithRssDescription:_currentDescription initWithRssPubDate:_currentPubDate initWithAudioUrl:_currentAudioUrl initWithEpImageUrl:_currentInfoImageUrl];
        
            if (rssItem) [_rssItems addObject:rssItem];
    }

    if ([elementName  isEqualToString: @"itunes:image"]) {
        if (!_infoImageFound) {
            _infoImageFound = true;
            _rssInfoImage = _currentInfoImageUrl;
        }
    }

    if ([elementName  isEqualToString: @"title"]) {
        if (_infoTitleFound != true) {
            _infoTitleFound = true;
            _rssInfoTitle = _currentTitle;
        }
    }

}

- (void)parserDidEndDocument:(NSXMLParser *)parser {
    NSLog(@"NSXMLParserFinished Parsing@");
    [_delegate suceededFetchRss:_rssItems infoTitle:_rssInfoTitle infoImage:_rssInfoImage];
}

@end
