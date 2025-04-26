import http from "k6/http";
import { sleep, check } from "k6";

export const options = {
  vus: 11,
  duration: "30s",
};

export default function () {
  const res = http.get("https://test-api.k6.io/");
  check(res, {
    "status is 200": (r) => r.status === 200,
  });
  sleep(1);
}
