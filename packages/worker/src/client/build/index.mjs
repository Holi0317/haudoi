import { hc } from "hono/client";
//#region src/client/index.ts
/**
* Create a Hono client for the worker app.
*
* Basically a wrapper around {@link hc} from `hono/client`.
*/
function createClient(baseUrl, options) {
	return hc(baseUrl, options);
}
//#endregion
export { createClient };
