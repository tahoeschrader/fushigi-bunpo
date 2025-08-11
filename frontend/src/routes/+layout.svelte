<svelte:head>
	<title>Fushigi</title>
</svelte:head>

<script lang="ts">
	import '../app.css'; // why does shadcn docs not have this line...
  import AppSidebar from "$lib/components/app-sidebar.svelte";
  //import * as Breadcrumb from "$lib/components/ui/breadcrumb/index.js";
  import { Separator } from "$lib/components/ui/separator/index.js";
  import * as Sidebar from "$lib/components/ui/sidebar/index.js";

  let { children } = $props();
</script>
<Sidebar.Provider>
  <AppSidebar />
  <Sidebar.Inset>
    <header class="flex h-16 shrink-0 items-center gap-2 border-b px-4">
      <Sidebar.Trigger class="-ml-1" />
      <Separator orientation="vertical" class="mr-2 h-4" />
    </header>
    <div class="flex flex-1 flex-col gap-4 p-4">
    	{@render children?.()}
    </div>
  </Sidebar.Inset>
</Sidebar.Provider>
