export async function load() {
  const API_BASE = import.meta.env.VITE_API_BASE;
  const res = await fetch(`${API_BASE}/api/grammar`);
  if (!res.ok) {
    throw new Error(`Failed to fetch grammar points: ${res.status}`);
  }
  const grammarPoints = await res.json();
  return {
    grammarPoints,
  };
}
