require("dotenv").config();

const express = require("express");
const cors = require("cors");
const pool = require("./db");

const app = express();
const PORT = Number(process.env.PORT || 3000);

let dbReady = false;

app.use(cors());
app.use(express.json());

async function initDb() {
  const createTableQuery = `
    CREATE TABLE IF NOT EXISTS tasks (
      id SERIAL PRIMARY KEY,
      title VARCHAR(255) NOT NULL,
      done BOOLEAN DEFAULT false,
      created_at TIMESTAMP DEFAULT NOW()
    );
  `;

  await pool.query(createTableQuery);
  dbReady = true;
}

async function initDbWithRetry(delayMs = 5000) {
  try {
    await initDb();
    console.log("Database initialized");
  } catch (error) {
    dbReady = false;
    console.error(`Database init failed, retrying in ${delayMs}ms:`, error.message);
    setTimeout(() => {
      initDbWithRetry(delayMs);
    }, delayMs);
  }
}

app.get("/health", async (_req, res) => {
  res.status(200).json({ status: "ok", dbReady });
});

app.get("/tasks", async (_req, res) => {
  try {
    const result = await pool.query(
      "SELECT * FROM tasks ORDER BY created_at DESC"
    );
    res.status(200).json(result.rows);
  } catch (error) {
    res.status(500).json({ error: error.message });
  }
});

app.post("/tasks", async (req, res) => {
  try {
    const { title } = req.body || {};
    const normalizedTitle = typeof title === "string" ? title.trim() : "";

    if (!normalizedTitle) {
      return res.status(400).json({ error: "title is required" });
    }

    const result = await pool.query(
      "INSERT INTO tasks (title) VALUES ($1) RETURNING *",
      [normalizedTitle]
    );
    return res.status(201).json(result.rows[0]);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.put("/tasks/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);
    const hasTitle = Object.prototype.hasOwnProperty.call(req.body || {}, "title");
    const hasDone = Object.prototype.hasOwnProperty.call(req.body || {}, "done");

    const titleValue = hasTitle && typeof req.body.title === "string"
      ? req.body.title.trim()
      : null;
    const doneValue = hasDone ? req.body.done : undefined;

    if (hasTitle && !titleValue) {
      return res.status(400).json({ error: "title cannot be empty" });
    }

    if (hasDone && typeof doneValue !== "boolean") {
      return res.status(400).json({ error: "done must be a boolean" });
    }

    const result = await pool.query(
      `UPDATE tasks
       SET
         title = CASE WHEN $2::boolean THEN $3 ELSE title END,
         done = CASE WHEN $4::boolean THEN $5 ELSE done END
       WHERE id = $1
       RETURNING *`,
      [id, hasTitle, titleValue, hasDone, doneValue]
    );

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "task not found" });
    }

    return res.status(200).json(result.rows[0]);
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.delete("/tasks/:id", async (req, res) => {
  try {
    const id = Number(req.params.id);
    const result = await pool.query("DELETE FROM tasks WHERE id = $1", [id]);

    if (result.rowCount === 0) {
      return res.status(404).json({ error: "task not found" });
    }

    return res.status(200).json({ deleted: true });
  } catch (error) {
    return res.status(500).json({ error: error.message });
  }
});

app.listen(PORT, () => {
  console.log(`Server listening on port ${PORT}`);
  initDbWithRetry();
});
