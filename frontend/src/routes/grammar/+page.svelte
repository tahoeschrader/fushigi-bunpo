<script lang="ts">
  import SearchForm from "$lib/components/search-form.svelte";
  import DataTable from "./data-table.svelte";
  import { columns } from "./columns.js";

  let { data } = $props();

</script>

<div>
  <!-- Search bar placeholder (not implemented) -->
  <div class="mb-4">
    <SearchForm />
   </div>
  <DataTable data={data.grammarPoints} {columns} />
</div>
