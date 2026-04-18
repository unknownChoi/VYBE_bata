"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onFavoriteDeleted = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
exports.onFavoriteDeleted = functions.firestore
    .document("favorites/{favoriteId}")
    .onDelete(async (snapshot) => {
    const data = snapshot.data();
    const clubId = data === null || data === void 0 ? void 0 : data.clubId;
    if (!clubId) {
        functions.logger.error("onFavoriteDeleted: clubId missing", data);
        return;
    }
    const clubRef = admin.firestore().collection("clubs").doc(clubId);
    // 0 미만으로 내려가지 않도록 트랜잭션으로 처리
    await admin.firestore().runTransaction(async (tx) => {
        var _a, _b;
        const clubSnap = await tx.get(clubRef);
        if (!clubSnap.exists)
            return;
        const current = (_b = (_a = clubSnap.data()) === null || _a === void 0 ? void 0 : _a.favoriteCount) !== null && _b !== void 0 ? _b : 0;
        tx.update(clubRef, {
            favoriteCount: Math.max(0, current - 1),
        });
    });
    functions.logger.info(`favoriteCount -1 for club: ${clubId}`);
});
//# sourceMappingURL=on_favorite_deleted.js.map