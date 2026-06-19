import { DurableObject } from "cloudflare:workers";
import dayjs from "dayjs";
import type { Session } from "../composable/session/schema";
import { useSessionStorage } from "../composable/session/schema";
import { exchangeToken } from "../google/oauth_token";
import { makeSessionContent } from "../composable/session/content";
import { useBasicKy } from "../composable/http";
import { useUserRegistry } from "../composable/user/registry";

export class TokenRefreshDO extends DurableObject<CloudflareBindings> {
  /**
   * Session hash being handled by this DO instance. Used to ensure single session per instance.
   */
  private _sessHash: string | null = null;

  /**
   * Time when session data was last read from storage.
   */
  private _readTime: dayjs.Dayjs | null = null;

  /**
   * Cache of session data.
   * null can mean either "not loaded yet" or "session not found". Check `_readTime` to distinguish.
   */
  private _cache: Session | null = null;

  public async refresh(sessHash: string) {
    await this.ctx.blockConcurrencyWhile(() => this._refresh(sessHash));
  }

  private async _refresh(sessHash: string) {
    console.info(`Refreshing token for session ${sessHash}`);

    const sess = await this._read(sessHash);
    if (sess == null) {
      console.warn(`Session ${sessHash} not found for token refresh.`);
      return;
    }

    const now = dayjs();

    // If token is not expiring within 5 minutes, skip refresh
    if (dayjs(sess.accessTokenExpire).isAfter(now.add(5, "minutes"))) {
      console.info(
        `Access token for session ${sessHash} is not expiring soon, skipping refresh.`,
      );
      return;
    }

    console.info(
      `Access token for session ${sessHash} is expiring soon, refreshing.`,
    );

    try {
      await this._exchange(sessHash, sess);
      console.info(`Token refresh for session ${sessHash} completed.`);
    } catch (err) {
      console.error(`Failed to refresh token for session ${sessHash}:`, err);
      await this._delete(sessHash);
    }
  }

  private async _exchange(sessHash: string, sess: Session) {
    const now = dayjs();

    const ky = useBasicKy(this.env);
    const { write: writeUser } = useUserRegistry(this.env);

    const tokens = await exchangeToken(
      this.env,
      ky,
      sess.refreshToken,
      "refresh",
    );

    const expire = now.add(7, "day");
    const newSess = await makeSessionContent(ky, tokens);

    console.info(`Storing refreshed session for ${sessHash}`);

    await this._put(sessHash, newSess.session, expire);
    await writeUser(newSess.user);
  }

  /**
   * Read session from storage or from cache.
   *
   * If cached data is older than 10 minutes, read from storage again.
   *
   * This makes sure even though we are blocking concurrency for token refresh,
   * subsequent refresh calls will finish in O(1) time within a 10-minute window.
   */
  private async _read(sessHash: string) {
    if (this._sessHash == null) {
      this._sessHash = sessHash;
    }

    if (this._sessHash !== sessHash) {
      throw new Error(
        "TokenRefreshDO: Tried to read different session than initialized with. This DO instance can only handle one session.",
      );
    }

    const now = dayjs();

    if (
      this._readTime == null ||
      now.isAfter(this._readTime.add(10, "minutes"))
    ) {
      console.log(
        "Cache miss or expired for session data, reading from storage.",
      );

      const { read } = useSessionStorage(this.env);
      this._cache = await read(sessHash);
      this._readTime = now;
    }

    return this._cache;
  }

  private async _put(sessHash: string, sess: Session, expire: dayjs.Dayjs) {
    const { write } = useSessionStorage(this.env);

    await write({
      key: sessHash,
      content: sess,
      expire,
    });

    this._cache = sess;
    this._readTime = dayjs();
  }

  private async _delete(sessHash: string) {
    const { remove } = useSessionStorage(this.env);

    await remove(sessHash);

    this._cache = null;
    this._readTime = null;
  }
}
