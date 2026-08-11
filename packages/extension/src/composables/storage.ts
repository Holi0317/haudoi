import { browser } from "wxt/browser";

export function useExtLocalStorage<T>(key: string, defaultValue: () => T) {
  const get = async () => {
    const result = await browser.storage.local.get(key);
    return (result[key] ?? defaultValue()) as T;
  };

  const set = async (value: T) => {
    await browser.storage.local.set({
      [key]: value,
    });
  };

  return {
    get,
    set,
  };
}
