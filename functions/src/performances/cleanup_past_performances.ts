import { pubsub, logger } from "firebase-functions/v1";
import * as admin from "firebase-admin";

// 공연 시작 후 이 시간이 지나면 "종료된 공연"으로 간주.
// 클럽 새벽 마감(~06:00) + 여유 → 8시간.
// 예: 22:00 시작 공연은 다음날 06:00까지 진행 중으로 보존.
const PERFORMANCE_DURATION_HOURS = 8;

// 지난 공연 데이터 정리 (매일 KST 04:00 실행)
// - 예정 공연 (startAt > now)            → 보존
// - 진행 중 (now - 8h < startAt < now)   → 보존 (새벽 공연 보호)
// - 8시간 전 시작 (확실히 종료)          → 삭제
export const cleanupPastPerformances = pubsub
  .schedule("every day 04:00")
  .timeZone("Asia/Seoul")
  .onRun(async () => {
    const db = admin.firestore();
    const now = Date.now();
    const cutoffMs = now - PERFORMANCE_DURATION_HOURS * 60 * 60 * 1000;
    const cutoff = admin.firestore.Timestamp.fromMillis(cutoffMs);

    // startAt이 cutoff 이전 = 8시간 넘게 지난 = 종료된 공연
    const snap = await db
      .collection("performances")
      .where("startAt", "<", cutoff)
      .get();

    if (snap.empty) {
      logger.info("cleanupPastPerformances: no past performances");
      return;
    }

    const docs = snap.docs;
    // Firestore 배치 한도 500개씩 분할 삭제
    for (let i = 0; i < docs.length; i += 500) {
      const batch = db.batch();
      docs.slice(i, i + 500).forEach((doc) => batch.delete(doc.ref));
      await batch.commit();
    }

    logger.info(
      `cleanupPastPerformances: deleted ${docs.length} performances ` +
        `(startAt < ${cutoff.toDate().toISOString()})`
    );
  });
