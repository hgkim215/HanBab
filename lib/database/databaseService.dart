import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:intl/intl.dart';


DateTime now = DateTime.now();
DateFormat formatter = DateFormat('yyyy-MM-dd');
String strToday = formatter.format(now);

class DatabaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  Reference get firebaseStorage => FirebaseStorage.instance.ref();

  final CollectionReference userCollection =
  FirebaseFirestore.instance.collection("user");
  final CollectionReference groupCollection =
  FirebaseFirestore.instance.collection("groups");

  final uid = FirebaseAuth.instance.currentUser?.uid;

  Future<String> getImage(String name) async {
    if(name == "") return "start";
    try {
      DocumentSnapshot documentSnapshot = await firestore
          .collection('restaurants')
          .doc(name)
          .get();

      Map<String, dynamic> data =
      documentSnapshot.data() as Map<String, dynamic>;
      int index = data['index'];

      // Firebase Storage에서 이미지 가져오기
      Reference reference = storage.ref('$index.jpg');
      String imageUrl = await reference.getDownloadURL();

      return imageUrl;
    } catch (e) {
      return "null";
    }
  }

  Future<String> getUserName() async {
    DocumentReference d = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['name'];
  }

  // getting the chats
  getChats(String groupId) async {
    return groupCollection
        .doc(groupId)
        .collection("messages")
        .orderBy("time")
        .snapshots();
  }

  Future getGroupAdmin(String groupId) async {
    DocumentReference d = groupCollection.doc(groupId);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['admin'];
  }

  // get group members
  getGroupMembers(groupId) async {
    return groupCollection.doc(groupId).snapshots();
  }

  // creating a group
  Future createGroup(String userName, String id, String groupName,
      String orderTime, String pickup, String maxPeople, String imgUrl) async {

    DocumentReference groupDocumentReference = await groupCollection.add({
      "groupName": groupName,
      "admin": "${id}_$userName",
      "members": [],
      "groupId": "",
      "orderTime": orderTime,
      "pickup": pickup,
      "currPeople": "1",
      "maxPeople": maxPeople,
      "imgUrl": imgUrl,
      "date": strToday,
      "recentMessage": "",
      "recentMessageSender": "",
    });
    //update the members
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
      "groupId": groupDocumentReference.id,
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    await userDocumentReference.update({
      "groups":
      FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
    return groupDocumentReference.id;
  }

  // send message
  sendMessage(String groupId, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
    });
  }

  // toggling the group join/exit
  Future toggleGroupJoin(
      String groupId, String userName, String groupName) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await userDocumentReference.get();
    List<dynamic> groups = await documentSnapshot['groups'];

    // if user has our groups -> then remove then or also in other part re join
    if (groups.contains("${groupId}_$groupName")) {
      await userDocumentReference.update({
        "groups": FieldValue.arrayRemove(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayRemove(["${uid}_$userName"])
      });
    } else {
      await userDocumentReference.update({
        "groups": FieldValue.arrayUnion(["${groupId}_$groupName"])
      });
      await groupDocumentReference.update({
        "members": FieldValue.arrayUnion(["${uid}_$userName"])
      });
    }
  }
}