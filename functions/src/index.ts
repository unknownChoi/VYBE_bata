import * as admin from "firebase-admin";

admin.initializeApp();

export {onUserCreated} from "./auth/on_user_created";
export {onFavoriteCreated} from "./favorites/on_favorite_created";
export {onFavoriteDeleted} from "./favorites/on_favorite_deleted";
