/**
 * Unstaged Git Changes Guard Extension
 *
 * Checks for unstaged git changes before processing user input.
 * Prompts the user to confirm whether to continue when there are unstaged changes.
 *
 * Usage:
 *   This extension is auto-discovered from ~/.pi/agent/extensions/
 */

import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

async function hasUnstagedChanges(pi: ExtensionAPI): Promise<boolean> {
  const { code } = await pi.exec("git", ["diff", "--quiet"]);

  return code === 1;
}

export default function (pi: ExtensionAPI) {
  pi.on("input", async (event, ctx) => {
    if (event.source === "extension" || !ctx.hasUI) {
      return { action: "continue" };
    }

    // Check for unstaged changes
    const hasChanges = await hasUnstagedChanges(pi);

    if (!hasChanges) {
      return;
    }

    // Interactive mode: prompt user for confirmation
    const choice = await ctx.ui.select(
      `You have unstaged file(s). Continue anyway?`,
      ["Yes, proceed", "No, cancel input"],
    );

    if (choice === "Yes, proceed") {
      // User chose to continue
      return;
    } else {
      ctx.ui.notify(
        "Input cancelled. Stage or commit your changes first.",
        "warning",
      );
      return { action: "handled" };
    }
  });
}
