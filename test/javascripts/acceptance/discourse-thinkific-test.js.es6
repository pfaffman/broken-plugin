import { acceptance } from "helpers/qunit-helpers";

acceptance("DiscourseThinkific", { loggedIn: true });

test("DiscourseThinkific works", async assert => {
  await visit("/admin/plugins/discourse-thinkific");

  assert.ok(false, "it shows the DiscourseThinkific button");
});
