document.addEventListener('alpine:init', () => {
  Alpine.data('grammarApp', () => ({
    entries: [],
    loading: true,
    error: '',

    async init() {
      try {
        const res = await fetch('/api/grammar');
        if (!res.ok) throw new Error('Failed to fetch grammar points');
        this.grammarPoints = await res.json();
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    }
  }));
});
