<script lang="ts" generics="TData, TValue">
  import {
    type ColumnDef,
    type PaginationState,
    getCoreRowModel,
    getPaginationRowModel,
  } from "@tanstack/table-core";

  import {
    createSvelteTable,
    FlexRender,
  } from "$lib/components/ui/data-table/index.js";
  import * as Table from "$lib/components/ui/table/index.js";
  import { Button } from "$lib/components/ui/button/index.js";

  type DataTableProps<TData, TValue> = {
    columns: ColumnDef<TData, TValue>[];
    data: TData[];
  };

  let { data, columns }: DataTableProps<TData, TValue> = $props();
  let pagination = $state<PaginationState>({ pageIndex: 0, pageSize: 10 });
  const table = createSvelteTable({
      get data() {
        return data;
      },
      columns,
      state: {
        get pagination() {
          return pagination;
        },
      },
      onPaginationChange: (updater) => {
        if (typeof updater === "function") {
          pagination = updater(pagination);
        } else {
          pagination = updater;
        }
      },
      getCoreRowModel: getCoreRowModel(),
      getPaginationRowModel: getPaginationRowModel(),
    });
</script>

<div >
  <div class="flex items-center justify-end space-x-2 py-4">
    <div class= "mr-4"> Page {table.getState().pagination.pageIndex + 1} of {table.getPageCount()}
  </div>
    <Button
      variant="outline"
      size="sm"
      onclick={() => table.previousPage()}
      disabled={!table.getCanPreviousPage()}
    >
      Previous
    </Button>
    <Button
      variant="outline"
      size="sm"
      onclick={() => table.nextPage()}
      disabled={!table.getCanNextPage()}
    >
      Next
    </Button>
  </div>
  <div class="rounded-md border">
    <Table.Root class="table-auto w-full">
      <Table.Header>
       {#each table.getHeaderGroups() as headerGroup (headerGroup.id)}
        <Table.Row>
         {#each headerGroup.headers as header (header.id)}
            <Table.Head
              colspan={header.colSpan}
              class="whitespace-normal break-words"
              style="width: {header.column.columnDef.size ?? 'auto'}px"
            >
           {#if !header.isPlaceholder}
            <FlexRender
             content={header.column.columnDef.header}
             context={header.getContext()}
            />
           {/if}
          </Table.Head>
         {/each}
        </Table.Row>
       {/each}
      </Table.Header>
      <Table.Body>
       {#each table.getRowModel().rows as row (row.id)}
        <Table.Row data-state={row.getIsSelected() && "selected"}>
         {#each row.getVisibleCells() as cell (cell.id)}
           <Table.Cell
             class="whitespace-normal break-words"
             style="width: {cell.column.columnDef.size ?? 'auto'}px"
           >
           <FlexRender
            content={cell.column.columnDef.cell}
            context={cell.getContext()}
           />
          </Table.Cell>
         {/each}
        </Table.Row>
       {:else}
        <Table.Row>
         <Table.Cell colspan={columns.length} class="h-24 text-center">
          No results.
         </Table.Cell>
        </Table.Row>
       {/each}
      </Table.Body>
    </Table.Root>
  </div>
</div>
