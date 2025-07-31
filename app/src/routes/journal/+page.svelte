<script lang="ts">
  import { onMount } from 'svelte';
  //import { Button } from "$lib/components/ui/button/index.js";

  let title = '';
  let content = '';
  let result = '';
  let isPrivate = false;

  async function submitJournal() {
    if (!title.trim() || !content.trim()) {
      result = 'Please fill out all fields.';
      return;
    }

    try {
      const API_BASE = import.meta.env.VITE_API_BASE;
      const res = await fetch(`${API_BASE}/api/journal`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title, content, private: isPrivate }),
      });

      if (!res.ok) throw new Error('Failed to save journal entry');
      const id = await res.json();
      result = `Journal saved (ID: ${id})`;

      // Reset form
      title = '';
      content = '';
      isPrivate = false;
    } catch (e) {
      result = `Error: ${e.message}`;
    }
  }
</script>

<form on:submit|preventDefault={submitJournal} class="space-y-4">
  <div>
    <label class="block text-sm font-medium">Title</label>
    <input type="text" bind:value={title} class="w-full border rounded p-2" required />
  </div>

  <div>
    <label class="block text-sm font-medium">Content</label>
    <textarea bind:value={content} class="w-full border rounded p-2 h-32" required></textarea>
  </div>

  <div>
    <input type="checkbox" id="private" bind:checked={isPrivate} />
    <label for="private">Private</label>
  </div>

  <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded hover:bg-blue-700">
    Save
  </button>

</form>

{#if result}
  <p class="mt-4 text-green-600">{result}</p>
{/if}
