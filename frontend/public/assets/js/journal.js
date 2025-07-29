document.addEventListener('alpine:init', () => {
  Alpine.data('journalApp', () => ({
    title: '',
    content: '',
    result: '',
    private: false,

    async submitJournal() {
      if (!this.title.trim() || !this.content.trim()) {
        this.result = 'Please fill out all fields.';
        return;
      }

      try {
        console.log("Submitting journal", {
          title: this.title,
          content: this.content,
          private: this.private,
        });
        const res = await fetch('/api/journal', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            title: this.title,
            content: this.content,
            private: this.private
          }),
        });

        if (!res.ok) throw new Error('Failed to save journal entry');
        const id = await res.json();
        this.result = `Journal saved (ID: ${id})`;
        this.title = '';
        this.content = '';
        this.private = false;
      } catch (e) {
        this.result = `Error: ${e.message}`;
      }
    }
  }));
});
