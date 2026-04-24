"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onFavoriteCreated = void 0;
const v1_1 = require("firebase-functions/v1");
const admin = require("firebase-admin");
exports.onFavoriteCreated = v1_1.firestore
    .document("favorites/{favoriteId}")
    .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const clubId = data === null || data === void 0 ? void 0 : data.clubId;
    if (!clubId) {
        v1_1.logger.error("onFavoriteCreated: clubId missing", data);
        return;
    }
    await admin.firestore().collection("clubs").doc(clubId).update({
        favoriteCount: admin.firestore.FieldValue.increment(1),
    });
    v1_1.logger.info(`favoriteCount +1 for club: ${clubId}`);
});
//# sourceMappingURL=on_favorite_created.js.map