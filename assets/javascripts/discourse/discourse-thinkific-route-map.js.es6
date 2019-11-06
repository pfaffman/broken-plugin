export default function() {
  this.route("discourse-thinkific", function() {
    this.route("actions", function() {
      this.route("show", { path: "/:id" });
    });
  });
};
