import type { PageServerLoad } from "./$types";

export const load: PageServerLoad = async ({ fetch }) => {
	try {
		const res = await fetch("/api/journal"); // relative URL, Vite proxy handles backend
		if (!res.ok) {
			throw new Error(`Failed to fetch journal entries: ${res.status}`);
		}
		const entries = await res.json();
		return { entries };
	} catch (error) {
		return {
			entries: [],
			error: error instanceof Error ? error.message : String(error),
		};
	}
};
