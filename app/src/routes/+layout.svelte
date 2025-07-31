<svelte:head>
  <title>Fushigi</title>
</svelte:head>

<script lang="ts">
  import '../app.css';
  import { writable } from 'svelte/store';
  import { page } from '$app/stores';

  const mobileMenuOpen = writable(false);

  const links = [
    { href: '/', label: 'Home' },
    { href: '/grammar', label: 'Grammar' },
    { href: '/history', label: 'History' },
    { href: '/journal', label: 'Journal Entry' },
  ];
</script>

<div class="min-h-screen flex">
  <!-- Sidebar -->
  <div>
    <!-- Mobile top bar -->
    <div class="md:hidden flex items-center justify-between p-4 bg-gray-900 text-white">
      <button on:click={() => mobileMenuOpen.update(v => !v)} aria-label="Toggle menu">
        <svg class="w-6 h-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
          <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"></path>
        </svg>
      </button>
    </div>

    <!-- Mobile menu -->
    {#if $mobileMenuOpen}
      <nav class="md:hidden h-screen bg-gray-900 text-white flex flex-col p-4 space-y-2">
        {#each links as link}
          <a
            href={link.href}
            class="px-3 py-2 rounded hover:bg-gray-700"
            class:bg-gray-700={$page.url.pathname === link.href}
          >
            {link.label}
          </a>
        {/each}
      </nav>
    {/if}

    <!-- Desktop sidebar -->
    <nav class="hidden md:flex w-48 h-screen bg-gray-900 text-white flex-col p-4 space-y-2">
      {#each links as link}
        <a
          href={link.href}
          class="text-left px-3 py-2 rounded hover:bg-gray-700"
          class:bg-gray-700={$page.url.pathname === link.href}
        >
          {link.label}
        </a>
      {/each}
    </nav>
  </div>

  <!-- Main content -->
  <main class="flex-1 p-6 overflow-auto">
    <slot />
  </main>
</div>
