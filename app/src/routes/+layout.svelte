<script lang="ts">
	import '../app.css';
	import { writable } from 'svelte/store';
	import { page } from '$app/stores';

	const mobileMenuOpen = writable(false);

	const links = [
		{ href: '/', label: 'Home' },
		{ href: '/grammar', label: 'Grammar' },
		{ href: '/history', label: 'History' },
		{ href: '/journal', label: 'Journal Entry' }
	];
</script>

<svelte:head>
	<title>Fushigi</title>
</svelte:head>

<div class="flex min-h-screen">
	<!-- Sidebar -->
	<div>
		<!-- Mobile top bar -->
		<div class="flex items-center justify-between bg-gray-900 p-4 text-white md:hidden">
			<button on:click={() => mobileMenuOpen.update((v) => !v)} aria-label="Toggle menu">
				<svg class="h-6 w-6" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24">
					<path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16"></path>
				</svg>
			</button>
		</div>

		<!-- Mobile menu -->
		{#if $mobileMenuOpen}
			<nav class="flex h-screen flex-col space-y-2 bg-gray-900 p-4 text-white md:hidden">
				{#each links as link}
					<a
						href={link.href}
						class="rounded px-3 py-2 hover:bg-gray-700"
						class:bg-gray-700={$page.url.pathname === link.href}
					>
						{link.label}
					</a>
				{/each}
			</nav>
		{/if}

		<!-- Desktop sidebar -->
		<nav class="hidden h-screen w-48 flex-col space-y-2 bg-gray-900 p-4 text-white md:flex">
			{#each links as link}
				<a
					href={link.href}
					class="rounded px-3 py-2 text-left hover:bg-gray-700"
					class:bg-gray-700={$page.url.pathname === link.href}
				>
					{link.label}
				</a>
			{/each}
		</nav>
	</div>

	<!-- Main content -->
	<main class="flex-1 overflow-auto p-6">
		<slot />
	</main>
</div>
