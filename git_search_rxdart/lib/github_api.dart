
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

//搜索结果项，包含 名字、地址、头像地址
class SearchResultItem {
  final String fullName;
  final String url;
  final String avatarUrl;

//简单构造器
  SearchResultItem(this.fullName, this.url, this.avatarUrl);

//工厂构造器
  factory SearchResultItem.fromJson(Map<String, Object> json) {
    return SearchResultItem(
      json['full_name'] as String,
      json['html_url'] as String,
      (json['owner'] as Map<String, Object>)['avatar_url'] as String,
    );
  }
}

//搜索结果集
class SearchResult {
  final List<SearchResultItem> items;

  SearchResult(this.items);

  factory SearchResult.fromJson(dynamic json) {
    final itemsT = (json as List);
    print('items: $itemsT');
    final itemsTC = itemsT.cast<Map<String, Object>>();
    print('items > cast : $itemsTC');
    
    final items = (json as List)
    .cast<Map<String, Object>>()
    .map((Map<String, Object> item) {
          return SearchResultItem.fromJson(item);
        }).toList();

      return SearchResult(items);
    }

    bool get isPopulated => items.isNotEmpty;

    bool get isEmpty => items.isEmpty;
    
}


class GithubAPI {
  final String baseUrl;

  //搜索缓存字典
  final Map<String, SearchResult> cache;

  final http.Client client;

  GithubAPI({
    HttpClient client, 
    Map<String, SearchResult> cache, 
    this.baseUrl = 'https://api.github.com/search/repositories?q='
    }): this.client = client ?? http.Client(),
        this.cache = cache ?? <String, SearchResult>{};

//搜索函数，搜索开始，首先从缓存字典中查找，没有则进行数据请求并存储在缓存中
  Future<SearchResult> search(String term) async {
    if(cache.containsKey(term)) {
      return cache[term];
    } else {
      final result = await _fetchResult(term);
      cache[term] = result;
      return result;
    }
  }

//数据请求
Future<SearchResult> _fetchResult(String term) async {
  final response = await client.get(Uri.parse('$baseUrl$term'));
  final result = json.decode(response.body);
  return SearchResult.fromJson(result['items']);
}

}