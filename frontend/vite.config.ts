import { sveltekit } from "@sveltejs/kit/vite";
import tailwindcss from "@tailwindcss/vite";
import { defineConfig } from "vite";

export default defineConfig({
	plugins: [sveltekit(), tailwindcss()],
	server: {
		host: true,
		port: 5173,
		proxy: {
			"/api": {
				target: "http://backend:8000",
				changeOrigin: true,
				secure: false,
			},
		},
	},
});
