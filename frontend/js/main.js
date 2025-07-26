const main = document.getElementById('main');
const btnGrammar = document.getElementById('btn-grammar');
const btnHistory = document.getElementById('btn-history');
const btnJournal = document.getElementById('btn-journal');
const buttons = [btnGrammar, btnHistory, btnJournal];

function setActive(button) {
  buttons.forEach(b => b.classList.remove('active'));
  button.classList.add('active');
}

async function loadGrammar() {
  setActive(btnGrammar);
  main.innerHTML = '<h2>Grammar List</h2><p>Loading...</p>';
  try {
    const res = await fetch('/grammar?limit=20');
    if (!res.ok) throw new Error('Failed to fetch grammar');
    const data = await res.json();
    if (data.length === 0) {
      main.innerHTML = '<p>No grammar found.</p>';
      return;
    }
    const ul = document.createElement('ul');
    data.forEach(g => {
      const li = document.createElement('li');
      li.textContent = `${g.level} - ${g.meaning} (Usage: ${g.usage})`;
      ul.appendChild(li);
    });
    main.innerHTML = '<h2>Grammar List</h2>';
    main.appendChild(ul);
  } catch (e) {
    main.innerHTML = `<p class="error">${e.message}</p>`;
  }
}

async function loadHistory() {
  setActive(btnHistory);
  main.innerHTML = '<h2>Journal History</h2><p>Loading...</p>';
  try {
    const res = await fetch('/journal?limit=20');
    if (!res.ok) throw new Error('Failed to fetch journal entries');
    const data = await res.json();
    if (data.length === 0) {
      main.innerHTML = '<p>No journal entries found.</p>';
      return;
    }
    const ul = document.createElement('ul');
    data.forEach(entry => {
      const li = document.createElement('li');
      li.textContent = `${entry.title} (${new Date(entry.created_at).toLocaleDateString()})`;
      ul.appendChild(li);
    });
    main.innerHTML = '<h2>Journal History</h2>';
    main.appendChild(ul);
  } catch (e) {
    main.innerHTML = `<p class="error">${e.message}</p>`;
  }
}

function loadJournalForm() {
  setActive(btnJournal);
  main.innerHTML = `
    <h2>New Journal Entry</h2>
    <form id="journal-form">
      <label for="title">Title</label>
      <input id="title" name="title" required />

      <label for="content">Content</label>
      <textarea id="content" name="content" required></textarea>

      <button type="submit" class="submit-btn">Save</button>
    </form>
    <div id="result"></div>
  `;
  document.getElementById('journal-form').onsubmit = async (e) => {
    e.preventDefault();
    const title = e.target.title.value.trim();
    const content = e.target.content.value.trim();
    if (!title || !content) {
      alert('Please fill all fields');
      return;
    }
    try {
      const res = await fetch('/journal/', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          title,
          content,
          sentences: []
        }),
      });
      if (!res.ok) throw new Error('Failed to save journal');
      const id = await res.json();
      document.getElementById('result').textContent = `Saved journal with id ${id}`;
      e.target.reset();
    } catch (err) {
      document.getElementById('result').textContent = `Error: ${err.message}`;
    }
  };
}

// Initial load
loadGrammar();

btnGrammar.onclick = loadGrammar;
btnHistory.onclick = loadHistory;
btnJournal.onclick = loadJournalForm;
