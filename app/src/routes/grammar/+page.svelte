<script lang="ts">
  import { onMount } from 'svelte';
  import { writable, derived } from 'svelte/store';

  type GrammarPoint = {
    id: number;
    level: string;
    usage: string;
    meaning: string;
    tags: string[];
  };

  const grammarPoints = writable<GrammarPoint[]>([]);
  const loading = writable(true);
  const error = writable('');
  const currentPage = writable(1);
  const perPage = 10;

  // Fetch data on mount
  onMount(async () => {
    loading.set(true);
    error.set('');
    try {
      const API_BASE = import.meta.env.VITE_API_BASE;
      const res = await fetch(`${API_BASE}/api/grammar`);
      if (!res.ok) throw new Error('Failed to fetch grammar points');
      const data = await res.json();
      grammarPoints.set(data);
    } catch (e) {
      error.set(e instanceof Error ? e.message : String(e));
    } finally {
      loading.set(false);
    }
  });

  // Total pages derived store
  const totalPages = derived(grammarPoints, ($grammarPoints) =>
    Math.ceil($grammarPoints.length / perPage)
  );

  // Points for current page
  const paginatedPoints = derived(
    [grammarPoints, currentPage],
    ([$grammarPoints, $currentPage]) => {
      const start = ($currentPage - 1) * perPage;
      return $grammarPoints.slice(start, start + perPage);
    }
  );

  // Helper to disable prev/next buttons
  $: canPrev = $currentPage > 1;
  $: canNext = $currentPage < $totalPages;
</script>

{#if $loading}
  <p>Loading grammar points...</p>
{:else if $error}
  <p class="text-red-600">{$error}</p>
{:else if $grammarPoints.length === 0}
  <p>No grammar points found.</p>
{:else}
  <div>
    <!-- Search bar placeholder (not implemented) -->
    <div class="mb-4">
      <input
        type="text"
        placeholder="Search not implemented"
        class="p-2 border rounded w-full"
      />
    </div>

    <!-- Pagination controls -->
    <div class="mt-4 flex justify-between items-center">
      <button
        class="px-3 py-1 bg-gray-200 rounded hover:bg-gray-300 disabled:opacity-50"
        on:click={() => currentPage.update(n => Math.max(n - 1, 1))}
        disabled={!canPrev}
      >
        Prev
      </button>

      <span class="text-sm">
        Page {$currentPage} of {$totalPages}
      </span>

      <button
        class="px-3 py-1 bg-gray-200 rounded hover:bg-gray-300 disabled:opacity-50"
        on:click={() => currentPage.update(n => Math.min(n + 1, $totalPages))}
        disabled={!canNext}
      >
        Next
      </button>
    </div>

    <!-- Grammar table -->
    <table class="mt-2 min-w-full bg-white border rounded shadow">
      <thead>
        <tr class="bg-gray-200 text-left">
          <th class="p-2 border">場合</th>
          <th class="p-2 border">使い方</th>
          <th class="p-2 border">意味</th>
          <th class="p-2 border">Tags</th>
        </tr>
      </thead>
      <tbody>
        {#each $paginatedPoints as point (point.id)}
          <tr
            class="border-b hover:bg-gray-100 cursor-pointer"
            on:click={() => alert(`Selected grammar point:\n${point.usage}`)}
          >
            <td class="p-2 border">{point.level}</td>
            <td class="p-2 border">{point.usage}</td>
            <td class="p-2 border">{point.meaning}</td>
            <td class="p-2 border">
              {#each point.tags as tag}
                <span
                  class="inline-block bg-blue-200 text-blue-800 text-xs px-2 py-0.5 rounded mr-1"
                >
                  {tag}
                </span>
              {/each}
            </td>
          </tr>
        {/each}
      </tbody>
    </table>
  </div>
{/if}
