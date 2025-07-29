document.addEventListener('alpine:init', () => {
  Alpine.data('historyApp', () => ({
    entries: [],
    loading: true,
    error: '',

    async init() {
      try {
        const res = await fetch('/api/journal');
        if (!res.ok) throw new Error('Failed to fetch journal entries');
        this.entries = await res.json();
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }));
});
