import type { Config } from "tailwindcss";

export default {
  content: ["./app/**/*.{js,jsx,ts,tsx}"],
  theme: {
    extend: {
      colors: {
        "tess-light-grey": "#9b9b9b",
        "tess-hover": "#99a1bd14"
      }
    },
  },
  plugins: [],
} satisfies Config;
