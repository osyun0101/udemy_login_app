import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:udemy_login_app/model/post.dart';

class PostFirestore {
  static final _firestoreInstance = FirebaseFirestore.instance;
  static final CollectionReference posts = _firestoreInstance.collection('posts');

  static Future<dynamic> addPost(Post newPost) async{
    try{
      final CollectionReference _userPosts = _firestoreInstance.collection('users')
      .doc(newPost.postAccountId).collection('my_post');
      var result = await posts.add({
        'content': newPost.content,
        'post_account_id': newPost.postAccountId,
        'created_time': Timestamp.now()
      });
      _userPosts.doc(result.id).set({
        'post_id': result.id,
        'created_time': Timestamp.now()
      });
      print('投稿完了');
      return true;
    } on FirebaseException catch(e){
      print('投稿エラー: $e');
    }
  }

  static Future<List<Post>?> getPostsFromIds(List<String> ids) async{
    List<Post> postList = [];
    try{
      await Future.forEach(ids, (String id) async{
        Map<String, dynamic> data = new Map<String, dynamic>();
        var doc = await posts.doc(id).get();
        if(doc.data() != null){
          data = doc.data() as Map<String, dynamic>;
        }
        else{
          print('postData is null');
          return null;
        }
        Post post = Post(
          id: doc.id,
          content: data['content'],
          postAccountId: data['post_account_id'],
          createdTime: data['created_time']
        );
        postList.add(post);
      });
      print('自分の投稿を取得完了');
      return postList;
    } on FirebaseException catch(e){
      print('自分の投稿取得エラー: $e');
      return null;
    }
  }

  static Future<dynamic> deletePosts(String accountId) async{
    final CollectionReference _userPosts = _firestoreInstance.collection('users')
    .doc(accountId).collection('my_post');
    var snapshot = await _userPosts.get();
    snapshot.docs.forEach((doc) async{ 
      await posts.doc(doc.id).delete();
      _userPosts.doc(doc.id).delete();
    });
    print('postデータ削除完了');
  }
}