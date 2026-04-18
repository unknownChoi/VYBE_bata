"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.onFavoriteDeleted = exports.onFavoriteCreated = exports.onUserCreated = void 0;
const admin = require("firebase-admin");
admin.initializeApp();
var on_user_created_1 = require("./auth/on_user_created");
Object.defineProperty(exports, "onUserCreated", { enumerable: true, get: function () { return on_user_created_1.onUserCreated; } });
var on_favorite_created_1 = require("./favorites/on_favorite_created");
Object.defineProperty(exports, "onFavoriteCreated", { enumerable: true, get: function () { return on_favorite_created_1.onFavoriteCreated; } });
var on_favorite_deleted_1 = require("./favorites/on_favorite_deleted");
Object.defineProperty(exports, "onFavoriteDeleted", { enumerable: true, get: function () { return on_favorite_deleted_1.onFavoriteDeleted; } });
//# sourceMappingURL=index.js.map