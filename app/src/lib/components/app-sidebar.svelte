<script lang="ts">
  import CalendarIcon from "@lucide/svelte/icons/calendar";
  import HouseIcon from "@lucide/svelte/icons/house";
  import HistoryIcon from "@lucide/svelte/icons/history";
  import SearchIcon from "@lucide/svelte/icons/search";
  import NotebookPenIcon from "@lucide/svelte/icons/notebook-pen"
  import * as Sidebar from "$lib/components/ui/sidebar/index.js";

	const items = [
		{ url: "/", title: 'Home', icon: HouseIcon},
		{ url: "/grammar", title: 'Grammar', icon: SearchIcon},
		{ url: "/history", title: 'History', icon: HistoryIcon },
		{ url: "/journal", title: 'Journal Entry', icon: NotebookPenIcon }
	];
</script>
 
<Sidebar.Root>
  <Sidebar.Content>
    <Sidebar.Group>
      <Sidebar.GroupLabel>Fushigi Japanese</Sidebar.GroupLabel>
      <Sidebar.GroupContent>
        <Sidebar.Menu>
          {#each items as item (item.title)}
            <Sidebar.MenuItem>
              <Sidebar.MenuButton>
                {#snippet child({ props })}
                  <a href={item.url} {...props}>
                    <item.icon />
                    <span>{item.title}</span>
                  </a>
                {/snippet}
              </Sidebar.MenuButton>
            </Sidebar.MenuItem>
          {/each}
        </Sidebar.Menu>
      </Sidebar.GroupContent>
    </Sidebar.Group>
  </Sidebar.Content>
</Sidebar.Root>
