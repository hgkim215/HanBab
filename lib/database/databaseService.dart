import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:han_bab/widget/alert.dart';
import 'package:han_bab/widget/notification.dart';
import '../view/page2/home/home.dart';
import '../widget/encryption.dart';

int saveNumberOfDocuments = 0;

class DatabaseService {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;

  Reference get firebaseStorage => FirebaseStorage.instance.ref();

  final CollectionReference userCollection =
      FirebaseFirestore.instance.collection("user");
  final CollectionReference groupCollection =
      FirebaseFirestore.instance.collection("groups");

  final uid = FirebaseAuth.instance.currentUser?.uid;

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
      "togetherOrder": "",
      "recentMessage": "",
      "recentMessageSender": "",
      "recentMessageSenderId": "",
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

  Future<void> enterChattingRoom(
      String groupId, String userName, String groupName) async {
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);
    await groupDocumentReference.update({
      "members": FieldValue.arrayUnion(["${uid}_$userName"]),
    });

    DocumentReference userDocumentReference = userCollection.doc(uid);
    await userDocumentReference.update({
      "groups":
          FieldValue.arrayUnion(["${groupDocumentReference.id}_$groupName"])
    });
  }

  // send message
  sendMessage(String groupId,String groupName, Map<String, dynamic> chatMessageData) async {
    groupCollection.doc(groupId).collection("messages").add(chatMessageData);
    groupCollection.doc(groupId).update({
      "recentMessage": chatMessageData['message'],
      "recentMessageSender": chatMessageData['sender'],
      "recentMessageTime": chatMessageData['time'].toString(),
      "recentMessageSenderId": uid
    });

    String? result = await FlutterLocalNotification()
        .postMessage(groupId, groupName, chatMessageData['sender'], chatMessageData['message']);
    print(result);
  }

  // toggling the group join/exit
  Future exitGroup(
      String groupId, String userName, String groupName, String admin) async {
    // doc reference
    DocumentReference userDocumentReference = userCollection.doc(uid);
    DocumentReference groupDocumentReference = groupCollection.doc(groupId);

    DocumentSnapshot documentSnapshot = await groupDocumentReference.get();
    List<dynamic> members = await documentSnapshot['members'];

    await userDocumentReference.update({
      "groups": FieldValue.arrayRemove(["${groupId}_$groupName"]),
      "currentGroup": ""
    });
    await groupDocumentReference.update({
      "members": FieldValue.arrayRemove(["${uid}_$userName"])
    }).then((value) {
      if (members.length > 1 && admin.contains(userName)) {
        groupDocumentReference.update({"admin": members[1]});
      }
    });
  }

  Future<void> deleteRestaurantDocument(String groupId) async {
    if (groupId.isNotEmpty) {
      QuerySnapshot collectionsSnapshot =
          await groupCollection.doc(groupId).collection('messages').get();
      for (DocumentSnapshot collectionDoc in collectionsSnapshot.docs) {
        await collectionDoc.reference.delete();
      }
      return groupCollection.doc(groupId).delete();
    }
  }

  void modifyGroupInfo(String groupId, String name, String date, String time,
      String place, String people) {
    DocumentReference dr = groupCollection.doc(groupId);
    dr.update({
      'groupName': name,
      'date': date,
      'orderTime': time,
      'pickup': place,
      'maxPeople': people
    });
  }

  Future<DocumentSnapshot<Object?>> getUserInfo(String uid) async {
    DocumentSnapshot dr = await userCollection.doc(uid).get();
    return dr;
  }

  Future<void> modifyUserInfo(
      String name, String email, String phone, String account) async {
    DocumentReference dr = userCollection.doc(uid);
    final encrypted = encrypt(aesKey, account);
    String encryptAccount = encrypted.base16;
    dr.update({
      'name': name,
      'email': email,
      'phone': phone,
      'bankAccount': encryptAccount
    });
  }

  void saveSocialAccount(String text, bool kakao) {
    DocumentReference dr = userCollection.doc(uid);
    if (kakao) {
      dr.update({'kakaoLink': true, 'kakaopay': text});
    } else {
      dr.update({'tossLink': true, 'tossId': text});
    }
  }

  Future<List<String>> getSocialAccount() async {
    DocumentReference d = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await d.get();
    return [documentSnapshot['kakaopay'], documentSnapshot['tossId']];
  }

  void saveTogetherOrder(String groupId, String value) {
    DocumentReference dr = groupCollection.doc(groupId);
    dr.update({
      "togetherOrder": value,
    });
  }

  Future<bool> enterOnlyOneRest(
      context, String groupName, String groupId) async {
    DocumentReference dr = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await dr.get();
    String currentGroup = documentSnapshot['currentGroup'];
    String gid = "";
    if (currentGroup != "") {
      gid = currentGroup.substring(currentGroup.indexOf("_") + 1,
          currentGroup.indexOf("_", currentGroup.indexOf("_", 1) + 1));
    }
    if (currentGroup.toString() != "" && gid != groupId) {
      showDialog(
        context: context,
        barrierDismissible: true, //바깥 영역 터치시 닫을지 여부 결정
        builder: ((context) {
          return AlertModal(
            text: '이미 다른 방에 들어가 있습니다!\n퇴장 후 들어가주세요.',
            yesOrNo: false,
            function: () {},
          );
        }),
      );
      return false;
    }
    return true;
  }

  getCurrentRest() async {
    DocumentReference d = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await d.get();
    String currentGroup = documentSnapshot['currentGroup'];
    String groupId = currentGroup.substring(currentGroup.indexOf("_") + 1,
        currentGroup.indexOf("_", currentGroup.indexOf("_", 1) + 1));
    DocumentSnapshot dr = await groupCollection.doc(groupId).get();
    return dr;
  }

  setReset(date, groupId, groupName) {
    DocumentReference dr = userCollection.doc(uid);
    String currentGroup = date + "_" + groupId + "_" + groupName;
    print(currentGroup);
    dr.update({
      "currentGroup": currentGroup,
    });
  }

  getRest() async {
    DocumentReference d = userCollection.doc(uid);
    DocumentSnapshot documentSnapshot = await d.get();
    return documentSnapshot['currentGroup'];
  }

  void resetRest() {
    DocumentReference dr = userCollection.doc(uid);
    dr.update({
      "currentGroup": "",
    });
  }

  void setDeliveryTip(String groupId, int value) {
    DocumentReference dr = groupCollection.doc(groupId);
    dr.update({
      "deliveryTip": value,
    });
  }

  // alarm() async {
  //   DocumentReference d = userCollection.doc(uid);
  //   DocumentSnapshot documentSnapshot = await d.get();
  //   String currentGroup = documentSnapshot['currentGroup'];
  //   if (currentGroup != "") {
  //     String groupId = currentGroup.substring(currentGroup.indexOf("_") + 1,
  //         currentGroup.indexOf("_", currentGroup.indexOf("_", 1) + 1));
  //     String groupName = currentGroup.substring(
  //         currentGroup.indexOf("_", currentGroup.indexOf("_", 1) + 1) + 1);
  //     DocumentSnapshot dr = await groupCollection.doc(groupId).get();
  //     QuerySnapshot d =
  //         await groupCollection.doc(groupId).collection("messages").get();
  //     int numberOfDocuments = d.docs.length;
  //     String recentMessageSenderId = dr['recentMessageSenderId'];
  //     if (saveNumberOfDocuments != numberOfDocuments &&
  //         uid != recentMessageSenderId) {
  //       // String? result = await FlutterLocalNotification()
  //       //     .postMessage(['fqe5t-RETEn9j96i-wDnhW:APA91bEp0X-Fpss5JrGmEe_0j0ykNbiNd4nKNLTOMkKVafAu4zJtzOZ4MAF-1SzqtRUeYdw5yJ4EA3ezH_1ZpZDJXtGLJz5o0nWDjWp2KsKhlN7Q_oWYWBCn_PBg9xZ9P-2LH7SVwx1I'] ,groupName, dr['recentMessage']);
  //
  //       saveNumberOfDocuments = numberOfDocuments;
  //     }
  //   }
  // }

  Future sendFeedback(
      String sender, String target, String title, String content) async {
    await FirebaseFirestore.instance.collection("feedback").add({
      "sender": sender,
      "target": target,
      "title": title,
      "content": content
    });
  }

  Future<void> closeRoom(groupId, double num) async {
    DocumentReference dr = groupCollection.doc(groupId);
    dr.update({
      "close": num,
    });
  }
}
