import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

const AGENT = "pi";

export default function (pi: ExtensionAPI): void {
  let working = false;

  function fire(event: "start" | "end"): void {
    pi.exec("coding-agent-status", [event, "--agent", AGENT]).catch(() => {});
  }

  pi.on("agent_start", async () => { working = true; fire("start"); });
  pi.on("agent_end", async () => { working = false; fire("end"); });
  pi.on("session_shutdown", async () => {
    if (!working) return;
    working = false;
    fire("end");
  });
}
