import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vybe/data/models/club_info_model.dart';
import 'package:vybe/data/models/club_model.dart';
import 'package:vybe/data/models/menu_model.dart';

class ClubDataSource {
  final FirebaseFirestore _firestore;

  ClubDataSource() : _firestore = FirebaseFirestore.instance;

  Future<List<ClubModel>> getActiveClubs() async {
    final snapshot = await _firestore
        .collection('clubs')
        .where('isActive', isEqualTo: true)
        .get();
    return snapshot.docs.map(ClubModel.fromFirestore).toList();
  }

  Stream<List<ClubModel>> watchActiveClubs() {
    return _firestore
        .collection('clubs')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .map((s) => s.docs.map(ClubModel.fromFirestore).toList());
  }

  Future<ClubModel?> getClub(String clubId) async {
    final doc = await _firestore.collection('clubs').doc(clubId).get();
    if (!doc.exists) return null;
    return ClubModel.fromFirestore(doc);
  }

  Future<ClubInfoModel?> getClubInfo(String clubId) async {
    final doc = await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('info')
        .doc(clubId)
        .get();
    if (!doc.exists) return null;
    return ClubInfoModel.fromFirestore(doc);
  }

  Future<List<MenuModel>> getMenus(String clubId) async {
    final snapshot = await _firestore
        .collection('clubs')
        .doc(clubId)
        .collection('menus')
        .where('isAvailable', isEqualTo: true)
        .get();
    return snapshot.docs.map(MenuModel.fromFirestore).toList();
  }

  Future<List<ClubModel>> searchClubs(String keyword) async {
    final snapshot = await _firestore
        .collection('clubs')
        .where('isActive', isEqualTo: true)
        .get();
    final lower = keyword.toLowerCase();
    return snapshot.docs
        .map(ClubModel.fromFirestore)
        .where((c) =>
            c.name.toLowerCase().contains(lower) ||
            c.tags.any((t) => t.toLowerCase().contains(lower)))
        .toList();
  }
}
