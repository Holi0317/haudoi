import * as z from "zod";
import { useKv } from "./kv";
import { uidToString, type UserIdentifier } from "./user/ident";
import type { LinkInsertItem } from "../schemas";
import { InsertLinkItemSchema, InsertSchema } from "../schemas";
import { MAX_EDIT_OPS } from "../constants";
import { genSessionID } from "./session/id";
import dayjs from "dayjs";
import { chunk } from "es-toolkit/array";
import { getParser, type CsvFormat } from "./import_format";

const RawMetaSchema = z.object({
  uid: z.string(),
  format: z.enum(["pocket", "raindrop"]),
});

function useRawStore(env: CloudflareBindings) {
  return useKv(env.KV, "import:raw", z.string(), RawMetaSchema);
}

export const PartSchema = z.object({
  items: z.array(InsertSchema),
});

/**
 * Schema for prepared insert objects ready for insertion
 */
export const PreparedPartSchema = z.object({
  items: z.array(InsertLinkItemSchema),
});

function usePartStore(env: CloudflareBindings) {
  return useKv(env.KV, "import:part", PartSchema, z.undefined());
}

function usePreparedPartStore(env: CloudflareBindings) {
  return useKv(env.KV, "import:prepared", PreparedPartSchema, z.undefined());
}

export function useImportStore(env: CloudflareBindings) {
  const raw = useRawStore(env);
  const part = usePartStore(env);
  const prepared = usePreparedPartStore(env);

  /**
   * Write raw import content (string/file) to KV store
   *
   * @returns ID for the raw content
   */
  const writeRaw = async (
    uid: UserIdentifier,
    content: string,
    format: CsvFormat,
  ) => {
    const id = genSessionID();

    await raw.write({
      key: id,
      content,
      expire: dayjs().add(1, "day"),
      metadata: {
        uid: uidToString(uid),
        format,
      },
    });

    return id;
  };

  const parseFile = (body: string, format: CsvFormat) => {
    const parser = getParser(format);
    return parser(body);
  };

  /**
   * Parse and partition the import file into parts.
   * Each part should contain up to 30 items, aligning with edit API limit.
   *
   * @return object containing part IDs and parsing statistics
   */
  const partition = async (
    uid: UserIdentifier,
    rawId: string,
    format: CsvFormat,
  ) => {
    const uidStr = uidToString(uid);

    const body = await raw.read(rawId);
    if (body == null) {
      throw new Error(`Raw import data ${rawId} not found`);
    }

    // Parse file content
    const { items, errors } = parseFile(body, format);

    // Partition items into chunks of MAX_EDIT_OPS
    const parts: number[] = [];
    let partId = 0;

    for (const c of chunk(items, MAX_EDIT_OPS)) {
      await part.write({
        key: `${uidStr}:${partId}`,
        content: {
          items: c,
        },
      });

      parts.push(partId);
      partId++;
    }

    return {
      parts,
      stats: {
        validRows: items.length,
        parseErrors: errors,
      },
    };
  };

  /**
   * Read a specific part of import data for given user
   */
  const readPart = async (uid: UserIdentifier, partId: number) => {
    const uidStr = uidToString(uid);
    const data = await part.read(`${uidStr}:${partId}`);
    if (data == null) {
      throw new Error(`Import part ${partId} not found`);
    }

    return data;
  };

  /**
   * Delete raw import data from KV store
   *
   * @param id ID of the raw import data
   */
  const clearRaw = async (id: string) => {
    await raw.remove(id);
  };

  /**
   * Delete import data in part store for given user
   */
  const clearPart = async (uid: UserIdentifier) => {
    const uidStr = uidToString(uid);

    // Delete all parts
    const allKeys = await part.listAll(`${uidStr}:`);

    await Promise.all(allKeys.map((key) => part.remove(key.name)));
  };

  /**
   * Write prepared insert items (with resolved titles) to KV store
   */
  const writePrepared = async (
    uid: UserIdentifier,
    partId: number,
    items: LinkInsertItem[],
  ) => {
    const uidStr = uidToString(uid);
    await prepared.write({
      key: `${uidStr}:${partId}`,
      content: { items },
    });
  };

  /**
   * Read prepared insert items for a specific part
   */
  const readPrepared = async (uid: UserIdentifier, partId: number) => {
    const uidStr = uidToString(uid);
    const data = await prepared.read(`${uidStr}:${partId}`);
    if (data == null) {
      throw new Error(`Prepared import part ${partId} not found`);
    }
    return data;
  };

  /**
   * Delete all prepared import data for given user
   */
  const clearPrepared = async (uid: UserIdentifier) => {
    const uidStr = uidToString(uid);
    const allKeys = await prepared.listAll(`${uidStr}:`);
    await Promise.all(allKeys.map((key) => prepared.remove(key.name)));
  };

  return {
    writeRaw,
    partition,
    readPart,
    clearRaw,
    clearPart,
    writePrepared,
    readPrepared,
    clearPrepared,
  };
}
