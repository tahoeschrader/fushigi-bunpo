document.addEventListener('alpine:init', () => {
  Alpine.data('journalApp', () => ({
    title: '',
    content: '',
    result: '',

    async submitJournal() {
      if (!this.title.trim() || !this.content.trim()) {
        this.result = 'Please fill out all fields.';
        return;
      }

      try {
        const res = await fetch('/api/journal', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            title: this.title,
            content: this.content,
            sentences: []
          }),
        });

        if (!res.ok) throw new Error('Failed to save journal entry');
        const id = await res.json();
        this.result = `Journal saved (ID: ${id})`;
        this.title = '';
        this.content = '';
      } catch (e) {
        this.result = `Error: ${e.message}`;
      }
    }
  }));
});
