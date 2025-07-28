document.addEventListener('alpine:init', () => {
  Alpine.data('grammarApp', () => ({
    grammarPoints: [],
    loading: true,
    error: '',
    currentPage: 1,
    perPage: 10, 
    selected: null,

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
    },

    get totalPages() {
      return Math.ceil(this.grammarPoints.length / this.perPage);
    },

    paginatedPoints() {
      const start = (this.currentPage - 1) * this.perPage;
      return this.grammarPoints.slice(start, start + this.perPage);
    }
  }));
});
