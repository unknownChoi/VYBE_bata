"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onFavoriteCreated = void 0;
const functions = require("firebase-functions");
const admin = require("firebase-admin");
exports.onFavoriteCreated = functions.firestore
    .document("favorites/{favoriteId}")
    .onCreate(async (snapshot) => {
    const data = snapshot.data();
    const clubId = data === null || data === void 0 ? void 0 : data.clubId;
    if (!clubId) {
        functions.logger.error("onFavoriteCreated: clubId missing", data);
        return;
    }
    await admin.firestore().collection("clubs").doc(clubId).update({
        favoriteCount: admin.firestore.FieldValue.increment(1),
    });
    functions.logger.info(`favoriteCount +1 for club: ${clubId}`);
});
//# sourceMappingURL=on_favorite_created.js.map