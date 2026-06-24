import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI): void {
  let working = false;

  function fire(event: "start" | "end"): void {
    pi.exec("coding-agent-status", [event], { stdio: "inherit" });
  }

  pi.on("agent_start", () => {
    working = true;
    fire("start");
  });
  pi.on("agent_end", () => {
    working = false;
    fire("end");
  });
  pi.on("session_shutdown", () => {
    if (!working) return;
    working = false;
    fire("end");
  });
}
