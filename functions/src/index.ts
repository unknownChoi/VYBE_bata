import * as admin from "firebase-admin";

admin.initializeApp();

export {onUserCreated} from "./auth/on_user_created";
export {checkPhoneDuplicate} from "./auth/check_phone_duplicate";
export {phoneLogin} from "./auth/phone_login";
export {naverLogin} from "./auth/naver_login";
export {kakaoLogin} from "./auth/kakao_login";
export {verifyIdentity} from "./auth/verify_identity";
export {deleteUser} from "./auth/delete_user";
export {onFavoriteCreated} from "./favorites/on_favorite_created";
export {onFavoriteDeleted} from "./favorites/on_favorite_deleted";
export {onReviewCreated} from "./reviews/on_review_created";
export {onReviewDeleted} from "./reviews/on_review_deleted";
export {onReviewUpdated} from "./reviews/on_review_updated";
export {onClubWritten} from "./search/on_club_written";
export {cleanupPastPerformances} from "./performances/cleanup_past_performances";
