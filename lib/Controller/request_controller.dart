import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:foodbari_deliver_app/Controller/auth_controller.dart';
import 'package:get/get.dart';

import '../Models/all_request_model.dart';

class RequestController extends GetxController {
  Rxn<List<AllRequestModel>> offerList = Rxn<List<AllRequestModel>>();
  List<AllRequestModel>? get offers => offerList.value;
  final AuthController auth = Get.find<AuthController>();
  final _firestore = FirebaseFirestore.instance;
  @override
  void onInit() {
    offerList.bindStream(receiveOfferStream());
    super.onInit();
  }

  Stream<List<AllRequestModel>> receiveOfferStream() {
    print("receive offer stream funtion");
    return _firestore
        .collection('all_requests')
        .where("delivery_boy_id", isEqualTo: "")
        .where("status", isEqualTo: "")
        .snapshots()
        .map((QuerySnapshot query) {
      List<AllRequestModel> retVal = [];

      for (var element in query.docs) {
        retVal.add(AllRequestModel.fromSnapshot(element));
      }

      debugPrint('offer receive  lenght is ${retVal.length}');
      return retVal;
    });
  }

  Future<void> sentOffer({String? offerId, int? noOfRequest, context}) async {
    try {
      await _firestore.collection('all_requests').doc(offerId).update({
        "status": "Pending",
        "no_of_request": noOfRequest! + 1,
      }).then((value) {
        _firestore
            .collection('all_requests')
            .doc(offerId)
            .collection("received_offer")
            .add({
          "offer_id": offerId,
          "delivery_boy_id": auth.deliveryBoyModel.value!.id,
          "name": auth.deliveryBoyModel.value!.name,
          "address": auth.deliveryBoyModel.value!.address,
          "location": auth.deliveryBoyModel.value!.location,
          "phone": auth.deliveryBoyModel.value!.phone,
          "image": auth.deliveryBoyModel.value!.profileImage == ""
              ? "https://cdn.techjuice.pk/wp-content/uploads/2015/02/wallpaper-for-facebook-profile-photo-1024x645.jpg"
              : auth.deliveryBoyModel.value!.profileImage,
          "email": auth.deliveryBoyModel.value!.email,
        });
        Get.snackbar("Success", "Offer sent...");
      });
    } catch (e) {
      Get.snackbar("Alert", e.toString());
    }
  }
}
