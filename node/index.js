const express = require("express");

const app = express();

app.get("/", (_req, res) => {
  res.json({ message: "hello world" });
});

const port = process.env.PORT || 8080;
app.listen(port, "0.0.0.0", () => {
  console.log(`Server running on http://0.0.0.0:${port}`);
});
