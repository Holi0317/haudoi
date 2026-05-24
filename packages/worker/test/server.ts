import { HttpResponse, http } from "msw";
import { setupServer } from "msw/node";

export const server = setupServer(
  http.all("*", () => {
    return HttpResponse.error();
  }),
);
