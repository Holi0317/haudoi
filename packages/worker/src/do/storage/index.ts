import { DurableObject } from "cloudflare:workers";
import type * as z from "zod";
import { useDBMigration } from "../../composable/db_migration";
import { sql, useSql } from "../../composable/sql";
import type {
  EditOpSchema,
  LinkInsertItem,
  SearchQueryType,
  TagCreateSchema,
} from "../../schemas";
import type { Matcher } from "@haudoi/dsl";
import { migrations } from "./migrations";
import { useMeta } from "./meta";
import { useLink } from "./link";
import { useBatch } from "./batch";
import { useTag } from "./tags";

export class StorageDO extends DurableObject<CloudflareBindings> {
  private readonly conn: ReturnType<typeof useSql>;

  public constructor(ctx: DurableObjectState, env: CloudflareBindings) {
    super(ctx, env);
    this.conn = useSql(ctx);

    this.conn.void_(sql`PRAGMA foreign_keys = ON;`);

    const { run } = useDBMigration(ctx);
    run(migrations);
  }

  /**
   * Get statistics about this durable object
   */
  public async stat() {
    const { stat } = useMeta(this.ctx);
    return await stat();
  }

  /**
   * Vacuum underlying SQLite database
   */
  public vacuum() {
    this.conn.void_(sql`PRAGMA optimize`);
  }

  /**
   * Deallocate this durable object and delete all stored data
   *
   * Technically we only truncate the link table here. The DO instance
   * will still exist and cost us small amount of fee.
   *
   * Doing `storage.deleteAll()` will cause subsequent call to `stats` fail.
   * That resets the state and will recreate the DO with migration on next wake.
   * It's just better to keep the DO instance around.
   */
  public deallocate() {
    this.conn.void_(sql`DELETE FROM link_tag;`);
    this.conn.void_(sql`DELETE FROM tag;`);
    this.conn.void_(sql`DELETE FROM link;`);
  }

  /**
   * Insert given links to database
   */
  public insert(links: LinkInsertItem[]) {
    const { insert } = useLink(this.ctx);
    return insert(links);
  }

  /**
   * Apply given edit operations to database
   *
   * @see EditOpSchema for supported edit operations
   */
  public edit(ops: Array<z.output<typeof EditOpSchema>>) {
    const { edit } = useLink(this.ctx);
    return edit(ops);
  }

  /**
   * Get link item by ID. Returns null if not found.
   */
  public get(id: number) {
    const { get } = useLink(this.ctx);
    return get(id);
  }

  /**
   * Search stored links with given query and matchers. Returns matched items.
   */
  public search(param: Omit<SearchQueryType, "query">, matchers: Matcher[]) {
    const { search } = useLink(this.ctx);
    return search(param, matchers);
  }

  /**
   * Export all stored links as csv
   */
  public async export_() {
    const { export_ } = useBatch(this.ctx);
    return export_();
  }

  public listTags() {
    const { list } = useTag(this.ctx);
    return list();
  }

  public createTag(input: z.output<typeof TagCreateSchema>) {
    const { create } = useTag(this.ctx);
    return create(input);
  }

  public updateTag(id: number, input: z.output<typeof TagCreateSchema>) {
    const { update } = useTag(this.ctx);
    return update(id, input);
  }

  public deleteTag(id: number) {
    const { deleteTag } = useTag(this.ctx);
    return deleteTag(id);
  }
}
