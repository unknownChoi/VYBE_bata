import * as admin from "firebase-admin";

admin.initializeApp();

export {onUserCreated} from "./auth/on_user_created";
export {checkPhoneDuplicate} from "./auth/check_phone_duplicate";
export {naverLogin} from "./auth/naver_login";
export {kakaoLogin} from "./auth/kakao_login";
export {verifyIdentity} from "./auth/verify_identity";
export {deleteUser} from "./auth/delete_user";
export {onFavoriteCreated} from "./favorites/on_favorite_created";
export {onFavoriteDeleted} from "./favorites/on_favorite_deleted";
