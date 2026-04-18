const API = "http://<ALB_DNS_PLACEHOLDER>";

const taskList = document.getElementById("task-list");
const taskInput = document.getElementById("task-input");
const addTaskBtn = document.getElementById("add-task-btn");

document.addEventListener("DOMContentLoaded", () => {
  addTaskBtn.addEventListener("click", onAddTask);
  loadTasks();
});

async function loadTasks() {
  try {
    const response = await fetch(`${API}/tasks`, {
      headers: {
        "Content-Type": "application/json",
      },
    });
    const tasks = await response.json();

    while (taskList.firstChild) {
      taskList.removeChild(taskList.firstChild);
    }

    tasks.forEach((task) => {
      taskList.appendChild(renderTaskItem(task));
    });
  } catch (error) {
    console.error(error);
  }
}

function renderTaskItem(task) {
  const li = document.createElement("li");

  const main = document.createElement("div");
  main.className = "task-main";

  const checkbox = document.createElement("input");
  checkbox.type = "checkbox";
  checkbox.checked = Boolean(task.done);
  checkbox.addEventListener("change", async (event) => {
    await updateTask(task.id, { done: event.target.checked });
    await loadTasks();
  });

  const title = document.createElement("span");
  title.className = `task-title ${task.done ? "done" : ""}`.trim();
  title.textContent = task.title;

  const delBtn = document.createElement("button");
  delBtn.type = "button";
  delBtn.textContent = "Delete";
  delBtn.addEventListener("click", async () => {
    await deleteTask(task.id);
    await loadTasks();
  });

  main.appendChild(checkbox);
  main.appendChild(title);
  li.appendChild(main);
  li.appendChild(delBtn);

  return li;
}

async function onAddTask() {
  const title = taskInput.value.trim();
  if (!title) {
    return;
  }

  await createTask(title);
  taskInput.value = "";
  await loadTasks();
}

async function createTask(title) {
  try {
    await fetch(`${API}/tasks`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ title }),
    });
  } catch (error) {
    console.error(error);
  }
}

async function updateTask(id, payload) {
  try {
    await fetch(`${API}/tasks/${id}`, {
      method: "PUT",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify(payload),
    });
  } catch (error) {
    console.error(error);
  }
}

async function deleteTask(id) {
  try {
    await fetch(`${API}/tasks/${id}`, {
      method: "DELETE",
      headers: {
        "Content-Type": "application/json",
      },
    });
  } catch (error) {
    console.error(error);
  }
}
