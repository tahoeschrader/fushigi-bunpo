<script>
  import { onMount } from 'svelte';

  let entries = [];
  let loading = true;
  let error = '';

  async function loadEntries() {
    try {
      const API_BASE = import.meta.env.VITE_API_BASE;
      const res = await fetch(`${API_BASE}/api/journal`);
      if (!res.ok) throw new Error('Failed to fetch journal entries');
      entries = await res.json();
    } catch (e) {
      error = e.message;
    } finally {
      loading = false;
    }
  }

  onMount(loadEntries);
</script>

<main class="flex-1 overflow-auto p-6">

  {#if loading}
    <p>Loading entries...</p>
  {:else if error}
    <p class="text-red-600">{error}</p>
  {:else if entries.length > 0}
    <ul class="space-y-4">
      {#each entries as entry (entry.id)}
        <li class="p-4 border rounded hover:bg-gray-100 cursor-pointer">
          <h2 class="text-lg font-semibold">
            {#if entry.private}
              <span class="mr-1" title="Private">🔒</span>
            {/if}
            {entry.title}
          </h2>
          <p class="text-sm text-gray-600">
            {new Date(entry.created_at).toLocaleDateString()} – {new Date(entry.created_at).toLocaleTimeString()}
          </p>
        </li>
      {/each}
    </ul>
  {:else}
    <p>No entries yet.</p>
  {/if}
</main>
